import 'package:bloc_test/bloc_test.dart';
import 'package:contruttore/core/error/failures.dart';
import 'package:contruttore/features/alerts/domain/entities/alert_entity.dart';
import 'package:contruttore/features/alerts/domain/usecases/add_alert_usecase.dart';
import 'package:contruttore/features/alerts/domain/usecases/generate_alerts_usecase.dart';
import 'package:contruttore/features/alerts/domain/usecases/get_alerts_usecase.dart';
import 'package:contruttore/features/alerts/domain/usecases/get_unread_count_usecase.dart';
import 'package:contruttore/features/alerts/domain/usecases/mark_as_read_usecase.dart';
import 'package:contruttore/features/alerts/presentation/cubit/alerts_cubit.dart';
import 'package:contruttore/features/alerts/presentation/cubit/alerts_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetAlertsUseCase extends Mock implements GetAlertsUseCase {}

class MockAddAlertUseCase extends Mock implements AddAlertUseCase {}

class MockMarkAsReadUseCase extends Mock implements MarkAsReadUseCase {}

class MockGetUnreadCountUseCase extends Mock implements GetUnreadCountUseCase {}

class MockGenerateAlertsUseCase extends Mock implements GenerateAlertsUseCase {}

void main() {
  late AlertsCubit alertsCubit;
  late MockGetAlertsUseCase mockGetAlertsUseCase;
  late MockAddAlertUseCase mockAddAlertUseCase;
  late MockMarkAsReadUseCase mockMarkAsReadUseCase;
  late MockGetUnreadCountUseCase mockGetUnreadCountUseCase;
  late MockGenerateAlertsUseCase mockGenerateAlertsUseCase;

  final tAlerts = <AlertEntity>[
    AlertEntity(
      id: '1',
      projectId: 'p1',
      type: AlertType.critical,
      title: 'Pagamento Vencendo',
      message: 'Parcela de R\$ 1.000 vence amanhã',
      isRead: false,
      createdAt: DateTime.now(),
    ),
    AlertEntity(
      id: '2',
      projectId: 'p1',
      type: AlertType.preventive,
      title: 'Orçamento Excedido',
      message: 'Categoria "Materiais" ultrapassou 90%',
      isRead: true,
      createdAt: DateTime.now(),
    ),
  ];

  setUp(() {
    mockGetAlertsUseCase = MockGetAlertsUseCase();
    mockAddAlertUseCase = MockAddAlertUseCase();
    mockMarkAsReadUseCase = MockMarkAsReadUseCase();
    mockGetUnreadCountUseCase = MockGetUnreadCountUseCase();
    mockGenerateAlertsUseCase = MockGenerateAlertsUseCase();

    alertsCubit = AlertsCubit(
      mockGetAlertsUseCase,
      mockAddAlertUseCase,
      mockMarkAsReadUseCase,
      mockGetUnreadCountUseCase,
      mockGenerateAlertsUseCase,
    );
  });

  setUpAll(() {
    registerFallbackValue(
      AlertEntity(
        id: '1',
        projectId: 'p1',
        type: AlertType.critical,
        title: 'Test',
        message: 'Test',
        isRead: false,
        createdAt: DateTime.now(),
      ),
    );
  });

  group('AlertsCubit - Sistema de Notificações', () {
    // Teste 1: Estado inicial
    test('O estado inicial deve ser AlertsInitial', () {
      expect(alertsCubit.state, equals(const AlertsInitial()));
    });

    // Teste 2: Carregamento de alertas com sucesso
    // O que ele faz: Verifica se os alertas são carregados corretamente junto com a contagem de não lidos
    blocTest<AlertsCubit, AlertsState>(
      'Deve emitir [AlertsLoading, AlertsLoaded] quando carregar alertas com sucesso',
      build: () {
        when(() => mockGetAlertsUseCase(any())).thenAnswer(
          (_) async => Right(tAlerts),
        );
        when(() => mockGetUnreadCountUseCase(any())).thenAnswer(
          (_) async => const Right(1),
        );
        return alertsCubit;
      },
      act: (cubit) => cubit.loadAlerts('p1'),
      expect: () => [
        const AlertsLoading(),
        AlertsLoaded(
          alerts: tAlerts,
          unreadCount: 1,
          filterType: null,
        ),
      ],
    );

    // Teste 3: Erro ao carregar alertas
    blocTest<AlertsCubit, AlertsState>(
      'Deve emitir [AlertsLoading, AlertsError] quando falhar ao carregar alertas',
      build: () {
        when(() => mockGetAlertsUseCase(any())).thenAnswer(
          (_) async => const Left(ServerFailure('Erro ao buscar alertas')),
        );
        return alertsCubit;
      },
      act: (cubit) => cubit.loadAlerts('p1'),
      expect: () => [
        const AlertsLoading(),
        const AlertsError('Erro ao buscar alertas'),
      ],
    );

    // Teste 4: Adicionar alerta
    // O que ele faz: Verifica se um novo alerta é adicionado e a lista é recarregada
    blocTest<AlertsCubit, AlertsState>(
      'Deve adicionar alerta e recarregar a lista',
      build: () {
        when(() => mockAddAlertUseCase(any())).thenAnswer(
          (_) async => const Right(null),
        );
        when(() => mockGetAlertsUseCase(any())).thenAnswer(
          (_) async => Right(tAlerts),
        );
        when(() => mockGetUnreadCountUseCase(any())).thenAnswer(
          (_) async => const Right(2),
        );
        return alertsCubit;
      },
      seed: () => const AlertsInitial(),
      act: (cubit) async {
        await cubit.loadAlerts('p1');
        await cubit.addAlert(tAlerts.first);
      },
      verify: (_) {
        verify(() => mockAddAlertUseCase(any())).called(1);
        verify(() => mockGetAlertsUseCase('p1')).called(2); // Carrega 2x
      },
    );

    // Teste 5: Marcar alerta como lido
    // O que ele faz: Verifica se um alerta é marcado como lido e a lista é atualizada
    blocTest<AlertsCubit, AlertsState>(
      'Deve marcar alerta como lido e recarregar',
      build: () {
        when(() => mockMarkAsReadUseCase(any(), any())).thenAnswer(
          (_) async => const Right(null),
        );
        when(() => mockGetAlertsUseCase(any())).thenAnswer(
          (_) async => Right(tAlerts),
        );
        when(() => mockGetUnreadCountUseCase(any())).thenAnswer(
          (_) async => const Right(0),
        );
        return alertsCubit;
      },
      seed: () => const AlertsInitial(),
      act: (cubit) async {
        await cubit.loadAlerts('p1');
        await cubit.markAsRead('1');
      },
      expect: () => [
        const AlertsLoading(),
        AlertsLoaded(alerts: tAlerts, unreadCount: 0, filterType: null),
        const AlertMarkedAsRead('1'),
        const AlertsLoading(),
        AlertsLoaded(alerts: tAlerts, unreadCount: 0, filterType: null),
      ],
    );

    // Teste 6: Gerar alertas automaticamente
    // O que ele faz: Verifica se o sistema consegue gerar alertas baseados em regras
    blocTest<AlertsCubit, AlertsState>(
      'Deve gerar alertas automaticamente e recarregar',
      build: () {
        when(() => mockGenerateAlertsUseCase(any())).thenAnswer(
          (_) async => const Right(null),
        );
        when(() => mockGetAlertsUseCase(any())).thenAnswer(
          (_) async => Right(tAlerts),
        );
        when(() => mockGetUnreadCountUseCase(any())).thenAnswer(
          (_) async => const Right(2),
        );
        return alertsCubit;
      },
      act: (cubit) => cubit.generateAlerts('p1'),
      expect: () => [
        const AlertsGenerated(),
        const AlertsLoading(),
        AlertsLoaded(alerts: tAlerts, unreadCount: 2, filterType: null),
      ],
    );

    // Teste 7: Filtrar alertas por tipo
    // O que ele faz: Verifica se o filtro de tipo funciona corretamente
    blocTest<AlertsCubit, AlertsState>(
      'Deve filtrar alertas por tipo',
      build: () => alertsCubit,
      seed: () => AlertsLoaded(
        alerts: tAlerts,
        unreadCount: 1,
        filterType: null,
      ),
      act: (cubit) => cubit.filterByType(AlertType.critical),
      expect: () => [
        AlertsLoaded(
          alerts: tAlerts,
          unreadCount: 1,
          filterType: AlertType.critical,
        ),
      ],
    );

    // Teste 8: Limpar filtro
    blocTest<AlertsCubit, AlertsState>(
      'Deve limpar o filtro de alertas',
      build: () => alertsCubit,
      seed: () => AlertsLoaded(
        alerts: tAlerts,
        unreadCount: 1,
        filterType: AlertType.critical,
      ),
      act: (cubit) => cubit.clearFilter(),
      expect: () => [
        AlertsLoaded(
          alerts: tAlerts,
          unreadCount: 1,
          filterType: null,
        ),
      ],
    );

    // Teste 9: Obter contagem de não lidos
    test('Deve retornar contagem de alertas não lidos', () async {
      when(() => mockGetUnreadCountUseCase(any())).thenAnswer(
        (_) async => const Right(5),
      );

      final count = await alertsCubit.getUnreadCount('p1');

      expect(count, equals(5));
      verify(() => mockGetUnreadCountUseCase('p1')).called(1);
    });

    // Teste 10: Retornar 0 em caso de erro na contagem
    test('Deve retornar 0 quando houver erro ao buscar contagem', () async {
      when(() => mockGetUnreadCountUseCase(any())).thenAnswer(
        (_) async => const Left(ServerFailure('Erro')),
      );

      final count = await alertsCubit.getUnreadCount('p1');

      expect(count, equals(0));
    });
  });
}

// Made with Bob
