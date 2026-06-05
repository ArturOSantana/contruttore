import 'package:bloc_test/bloc_test.dart';
import 'package:contruttore/core/error/failures.dart';
import 'package:contruttore/features/payments/domain/repositories/payment_repository.dart';
import 'package:contruttore/features/suppliers/domain/entities/quote_entity.dart';
import 'package:contruttore/features/suppliers/domain/entities/supplier_entity.dart';
import 'package:contruttore/features/suppliers/domain/usecases/accept_quote_usecase.dart';
import 'package:contruttore/features/suppliers/domain/usecases/add_quote_usecase.dart';
import 'package:contruttore/features/suppliers/domain/usecases/add_supplier_usecase.dart';
import 'package:contruttore/features/suppliers/domain/usecases/compare_quotes_usecase.dart';
import 'package:contruttore/features/suppliers/domain/usecases/delete_supplier_usecase.dart';
import 'package:contruttore/features/suppliers/domain/usecases/get_quotes_usecase.dart';
import 'package:contruttore/features/suppliers/domain/usecases/get_suppliers_usecase.dart';
import 'package:contruttore/features/suppliers/domain/usecases/update_supplier_usecase.dart';
import 'package:contruttore/features/suppliers/presentation/cubit/suppliers_cubit.dart';
import 'package:contruttore/features/suppliers/presentation/cubit/suppliers_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetSuppliersUseCase extends Mock implements GetSuppliersUseCase {}

class MockAddSupplierUseCase extends Mock implements AddSupplierUseCase {}

class MockUpdateSupplierUseCase extends Mock implements UpdateSupplierUseCase {}

class MockDeleteSupplierUseCase extends Mock implements DeleteSupplierUseCase {}

class MockGetQuotesUseCase extends Mock implements GetQuotesUseCase {}

class MockAddQuoteUseCase extends Mock implements AddQuoteUseCase {}

class MockAcceptQuoteUseCase extends Mock implements AcceptQuoteUseCase {}

class MockCompareQuotesUseCase extends Mock implements CompareQuotesUseCase {}

class MockPaymentRepository extends Mock implements PaymentRepository {}

void main() {
  late SuppliersCubit suppliersCubit;
  late MockGetSuppliersUseCase mockGetSuppliersUseCase;
  late MockAddSupplierUseCase mockAddSupplierUseCase;
  late MockUpdateSupplierUseCase mockUpdateSupplierUseCase;
  late MockDeleteSupplierUseCase mockDeleteSupplierUseCase;
  late MockGetQuotesUseCase mockGetQuotesUseCase;
  late MockAddQuoteUseCase mockAddQuoteUseCase;
  late MockAcceptQuoteUseCase mockAcceptQuoteUseCase;
  late MockCompareQuotesUseCase mockCompareQuotesUseCase;
  late MockPaymentRepository mockPaymentRepository;

  final tSuppliers = <SupplierEntity>[
    SupplierEntity(
      id: '1',
      projectId: 'p1',
      name: 'Construtora ABC',
      type: SupplierType.generalContractor,
      phone: '11999999999',
      email: 'contato@abc.com',
      status: SupplierStatus.active,
      rating: 4.5,
      createdAt: DateTime.now(),
    ),
    SupplierEntity(
      id: '2',
      projectId: 'p1',
      name: 'Materiais XYZ',
      type: SupplierType.materialsStore,
      phone: '11888888888',
      status: SupplierStatus.active,
      createdAt: DateTime.now(),
    ),
  ];

  final tQuotes = <QuoteEntity>[
    QuoteEntity(
      id: 'q1',
      projectId: 'p1',
      supplierId: '1',
      description: 'Reforma completa',
      totalValue: 50000.0,
      validUntil: DateTime.now().add(const Duration(days: 30)),
      status: QuoteStatus.pending,
      deliveryDays: 90,
      items: const [],
      createdAt: DateTime.now(),
    ),
    QuoteEntity(
      id: 'q2',
      projectId: 'p1',
      supplierId: '1',
      description: 'Pintura',
      totalValue: 5000.0,
      validUntil: DateTime.now().add(const Duration(days: 15)),
      status: QuoteStatus.accepted,
      deliveryDays: 30,
      items: const [],
      createdAt: DateTime.now(),
    ),
  ];

  setUp(() {
    mockGetSuppliersUseCase = MockGetSuppliersUseCase();
    mockAddSupplierUseCase = MockAddSupplierUseCase();
    mockUpdateSupplierUseCase = MockUpdateSupplierUseCase();
    mockDeleteSupplierUseCase = MockDeleteSupplierUseCase();
    mockGetQuotesUseCase = MockGetQuotesUseCase();
    mockAddQuoteUseCase = MockAddQuoteUseCase();
    mockAcceptQuoteUseCase = MockAcceptQuoteUseCase();
    mockCompareQuotesUseCase = MockCompareQuotesUseCase();
    mockPaymentRepository = MockPaymentRepository();

    suppliersCubit = SuppliersCubit(
      mockGetSuppliersUseCase,
      mockAddSupplierUseCase,
      mockUpdateSupplierUseCase,
      mockDeleteSupplierUseCase,
      mockGetQuotesUseCase,
      mockAddQuoteUseCase,
      mockAcceptQuoteUseCase,
      mockCompareQuotesUseCase,
      mockPaymentRepository,
    );
  });

  setUpAll(() {
    registerFallbackValue(
      SupplierEntity(
        id: '1',
        projectId: 'p1',
        name: 'Test',
        type: SupplierType.generalContractor,
        phone: '11999999999',
        status: SupplierStatus.active,
        createdAt: DateTime.now(),
      ),
    );
    registerFallbackValue(
      QuoteEntity(
        id: 'q1',
        projectId: 'p1',
        supplierId: '1',
        description: 'Test',
        totalValue: 1000.0,
        validUntil: DateTime.now(),
        status: QuoteStatus.pending,
        deliveryDays: 30,
        items: const [],
        createdAt: DateTime.now(),
      ),
    );
    registerFallbackValue(
      DeleteSupplierParams(projectId: 'p1', supplierId: '1'),
    );
  });

  group('SuppliersCubit - Gestão de Fornecedores', () {
    // Teste 1: Estado inicial
    test('O estado inicial deve ser SuppliersInitial', () {
      expect(suppliersCubit.state, equals(SuppliersInitial()));
    });

    // Teste 2: Carregamento de fornecedores com sucesso
    blocTest<SuppliersCubit, SuppliersState>(
      'Deve emitir [SuppliersLoading, SuppliersLoaded] ao carregar fornecedores',
      build: () {
        when(() => mockGetSuppliersUseCase(any())).thenAnswer(
          (_) async => Right(tSuppliers),
        );
        return suppliersCubit;
      },
      act: (cubit) => cubit.loadSuppliers('p1'),
      expect: () => [
        SuppliersLoading(),
        SuppliersLoaded(suppliers: tSuppliers),
      ],
    );

    // Teste 3: Erro ao carregar fornecedores
    blocTest<SuppliersCubit, SuppliersState>(
      'Deve emitir [SuppliersLoading, SuppliersError] quando falhar',
      build: () {
        when(() => mockGetSuppliersUseCase(any())).thenAnswer(
          (_) async => const Left(ServerFailure('Erro ao buscar fornecedores')),
        );
        return suppliersCubit;
      },
      act: (cubit) => cubit.loadSuppliers('p1'),
      expect: () => [
        SuppliersLoading(),
        SuppliersError('Erro ao buscar fornecedores'),
      ],
    );

    // Teste 4: Adicionar fornecedor sem parcelamento
    blocTest<SuppliersCubit, SuppliersState>(
      'Deve adicionar fornecedor sem gerar parcelas',
      build: () {
        when(() => mockAddSupplierUseCase(any())).thenAnswer(
          (_) async => const Right(null),
        );
        when(() => mockGetSuppliersUseCase(any())).thenAnswer(
          (_) async => Right(tSuppliers),
        );
        return suppliersCubit;
      },
      act: (cubit) => cubit.addSupplier(tSuppliers.first),
      expect: () => [
        SuppliersLoading(),
        SupplierOperationSuccess('Fornecedor adicionado com sucesso'),
        SuppliersLoading(),
        SuppliersLoaded(suppliers: tSuppliers),
      ],
    );

    // Teste 5: Adicionar fornecedor com parcelamento
    // O que ele faz: Verifica se ao adicionar fornecedor com valor, as parcelas são geradas
    blocTest<SuppliersCubit, SuppliersState>(
      'Deve adicionar fornecedor e gerar parcelas automaticamente',
      build: () {
        final supplierWithPayment = tSuppliers.first.copyWith(
          totalValue: 10000.0,
          installments: 5,
          firstPaymentDate: DateTime.now(),
        );

        when(() => mockAddSupplierUseCase(any())).thenAnswer(
          (_) async => const Right(null),
        );
        when(() => mockPaymentRepository.createPayments(any())).thenAnswer(
          (_) async => const Right(null),
        );
        when(() => mockGetSuppliersUseCase(any())).thenAnswer(
          (_) async => Right([supplierWithPayment]),
        );

        return suppliersCubit;
      },
      act: (cubit) {
        final supplierWithPayment = tSuppliers.first.copyWith(
          totalValue: 10000.0,
          installments: 5,
          firstPaymentDate: DateTime.now(),
        );
        return cubit.addSupplier(supplierWithPayment);
      },
      verify: (_) {
        verify(() => mockPaymentRepository.createPayments(any())).called(1);
      },
    );

    // Teste 6: Atualizar fornecedor
    blocTest<SuppliersCubit, SuppliersState>(
      'Deve atualizar fornecedor e recarregar lista',
      build: () {
        when(() => mockUpdateSupplierUseCase(any())).thenAnswer(
          (_) async => const Right(null),
        );
        when(() => mockGetSuppliersUseCase(any())).thenAnswer(
          (_) async => Right(tSuppliers),
        );
        return suppliersCubit;
      },
      seed: () => SuppliersLoaded(suppliers: tSuppliers),
      act: (cubit) => cubit.updateSupplier(tSuppliers.first),
      expect: () => [
        SuppliersLoading(),
        SupplierOperationSuccess('Fornecedor atualizado com sucesso'),
        SuppliersLoading(),
        SuppliersLoaded(suppliers: tSuppliers),
      ],
    );

    // Teste 7: Atualizar avaliação do fornecedor
    blocTest<SuppliersCubit, SuppliersState>(
      'Deve atualizar avaliação do fornecedor',
      build: () {
        when(() => mockUpdateSupplierUseCase(any())).thenAnswer(
          (_) async => const Right(null),
        );
        when(() => mockGetSuppliersUseCase(any())).thenAnswer(
          (_) async => Right(tSuppliers),
        );
        return suppliersCubit;
      },
      seed: () => SuppliersLoaded(suppliers: tSuppliers),
      act: (cubit) => cubit.updateSupplierRating(tSuppliers.first, 5.0),
      verify: (_) {
        verify(() => mockUpdateSupplierUseCase(any())).called(1);
      },
    );

    // Teste 8: Deletar fornecedor
    // O que ele faz: Verifica se o fornecedor é deletado e parcelas pendentes canceladas
    blocTest<SuppliersCubit, SuppliersState>(
      'Deve cancelar parcelas pendentes e deletar fornecedor',
      build: () {
        when(
          () => mockPaymentRepository.cancelPendingPaymentsBySource(
            projectId: any(named: 'projectId'),
            sourceId: any(named: 'sourceId'),
          ),
        ).thenAnswer((_) async => const Right(null));

        when(() => mockDeleteSupplierUseCase(any())).thenAnswer(
          (_) async => const Right(null),
        );

        when(() => mockGetSuppliersUseCase(any())).thenAnswer(
          (_) async => Right([tSuppliers.first]),
        );

        return suppliersCubit;
      },
      act: (cubit) => cubit.deleteSupplier('p1', '2'),
      expect: () => [
        SuppliersLoading(),
        SupplierOperationSuccess('Fornecedor removido com sucesso'),
        SuppliersLoading(),
        SuppliersLoaded(suppliers: [tSuppliers.first]),
      ],
    );

    // Teste 9: Carregar orçamentos de um fornecedor
    blocTest<SuppliersCubit, SuppliersState>(
      'Deve carregar orçamentos de um fornecedor específico',
      build: () {
        when(
          () => mockGetQuotesUseCase(
            projectId: any(named: 'projectId'),
            supplierId: any(named: 'supplierId'),
          ),
        ).thenAnswer((_) async => Right(tQuotes));

        return suppliersCubit;
      },
      act: (cubit) => cubit.loadQuotes('p1', '1'),
      expect: () => [
        SuppliersLoading(),
        QuotesLoaded(tQuotes),
      ],
    );

    // Teste 10: Adicionar orçamento
    blocTest<SuppliersCubit, SuppliersState>(
      'Deve adicionar orçamento e recarregar lista',
      build: () {
        when(() => mockAddQuoteUseCase(any())).thenAnswer(
          (_) async => const Right(null),
        );
        when(
          () => mockGetQuotesUseCase(
            projectId: any(named: 'projectId'),
            supplierId: any(named: 'supplierId'),
          ),
        ).thenAnswer((_) async => Right(tQuotes));

        return suppliersCubit;
      },
      act: (cubit) => cubit.addQuote(tQuotes.first),
      expect: () => [
        SuppliersLoading(),
        SupplierOperationSuccess('Orçamento adicionado com sucesso'),
        SuppliersLoading(),
        QuotesLoaded(tQuotes),
      ],
    );

    // Teste 11: Aceitar orçamento
    // O que ele faz: Verifica se ao aceitar um orçamento, as parcelas são geradas
    blocTest<SuppliersCubit, SuppliersState>(
      'Deve aceitar orçamento e gerar parcelas',
      build: () {
        when(
          () => mockAcceptQuoteUseCase(
            projectId: any(named: 'projectId'),
            quoteId: any(named: 'quoteId'),
            installments: any(named: 'installments'),
            firstPaymentDate: any(named: 'firstPaymentDate'),
          ),
        ).thenAnswer((_) async => const Right(null));

        when(() => mockGetSuppliersUseCase(any())).thenAnswer(
          (_) async => Right(tSuppliers),
        );

        when(
          () => mockGetQuotesUseCase(
            projectId: any(named: 'projectId'),
            supplierId: any(named: 'supplierId'),
          ),
        ).thenAnswer((_) async => Right(tQuotes));

        return suppliersCubit;
      },
      act: (cubit) => cubit.acceptQuote(
        projectId: 'p1',
        quoteId: 'q1',
        supplierId: '1',
        installments: 10,
        firstPaymentDate: DateTime.now(),
      ),
      expect: () => [
        SuppliersLoading(),
        SupplierOperationSuccess(
          'Orçamento aceito! Parcelas criadas automaticamente.',
        ),
        SuppliersLoading(),
        SupplierDetailLoaded(supplier: tSuppliers.first, quotes: tQuotes),
      ],
    );

    // Teste 12: Filtrar fornecedores por tipo
    test('Deve filtrar fornecedores por tipo', () {
      final filtered = suppliersCubit.filterSuppliersByType(
        tSuppliers,
        SupplierType.generalContractor,
      );

      expect(filtered.length, equals(1));
      expect(filtered.first.type, equals(SupplierType.generalContractor));
    });

    // Teste 13: Filtrar fornecedores por status
    test('Deve filtrar fornecedores por status', () {
      final filtered = suppliersCubit.filterSuppliersByStatus(
        tSuppliers,
        SupplierStatus.active,
      );

      expect(filtered.length, equals(1));
      expect(filtered.first.status, equals(SupplierStatus.active));
    });

    // Teste 14: Obter orçamentos ativos
    test('Deve retornar apenas orçamentos ativos (não expirados)', () {
      final activeQuotes = suppliersCubit.getActiveQuotes(tQuotes);

      expect(
        activeQuotes
            .every((q) => q.status == QuoteStatus.pending && !q.isExpired),
        isTrue,
      );
    });

    // Teste 15: Calcular média de valores de orçamentos
    test('Deve calcular média correta dos valores de orçamentos', () {
      final average = suppliersCubit.calculateAverageQuoteValue(tQuotes);

      expect(average, equals(27500.0)); // (50000 + 5000) / 2
    });

    // Teste 16: Obter orçamento mais barato
    test('Deve retornar o orçamento mais barato', () {
      final cheapest = suppliersCubit.getCheapestQuote(tQuotes);

      expect(cheapest, isNotNull);
      expect(cheapest!.totalValue, equals(5000.0));
    });

    // Teste 17: Obter orçamento mais caro
    test('Deve retornar o orçamento mais caro', () {
      final expensive = suppliersCubit.getMostExpensiveQuote(tQuotes);

      expect(expensive, isNotNull);
      expect(expensive!.totalValue, equals(50000.0));
    });

    // Teste 18: Carregar detalhes do fornecedor com orçamentos
    blocTest<SuppliersCubit, SuppliersState>(
      'Deve carregar detalhes do fornecedor incluindo orçamentos',
      build: () {
        when(() => mockGetSuppliersUseCase(any())).thenAnswer(
          (_) async => Right(tSuppliers),
        );
        when(
          () => mockGetQuotesUseCase(
            projectId: any(named: 'projectId'),
            supplierId: any(named: 'supplierId'),
          ),
        ).thenAnswer((_) async => Right(tQuotes));

        return suppliersCubit;
      },
      act: (cubit) => cubit.loadSupplierDetail('p1', '1'),
      expect: () => [
        SuppliersLoading(),
        SupplierDetailLoaded(supplier: tSuppliers.first, quotes: tQuotes),
      ],
    );

    // Teste 19: Atualizar status do fornecedor
    blocTest<SuppliersCubit, SuppliersState>(
      'Deve atualizar status do fornecedor',
      build: () {
        when(() => mockUpdateSupplierUseCase(any())).thenAnswer(
          (_) async => const Right(null),
        );
        when(() => mockGetSuppliersUseCase(any())).thenAnswer(
          (_) async => Right(tSuppliers),
        );
        return suppliersCubit;
      },
      seed: () => SuppliersLoaded(suppliers: tSuppliers),
      act: (cubit) => cubit.updateSupplierStatus(
        tSuppliers.last,
        SupplierStatus.active,
      ),
      verify: (_) {
        verify(() => mockUpdateSupplierUseCase(any())).called(1);
      },
    );

    // Teste 20: Lista vazia de fornecedores
    blocTest<SuppliersCubit, SuppliersState>(
      'Deve lidar corretamente com lista vazia de fornecedores',
      build: () {
        when(() => mockGetSuppliersUseCase(any())).thenAnswer(
          (_) async => const Right([]),
        );
        return suppliersCubit;
      },
      act: (cubit) => cubit.loadSuppliers('p1'),
      expect: () => [
        SuppliersLoading(),
        SuppliersLoaded(suppliers: const []),
      ],
    );
  });
}

// Made with Bob
