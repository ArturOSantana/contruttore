import 'package:bloc_test/bloc_test.dart';
import 'package:contruttore/core/error/failures.dart';
import 'package:contruttore/features/payments/domain/repositories/payment_repository.dart';
import 'package:contruttore/features/shopping/domain/entities/shopping_item_entity.dart';
import 'package:contruttore/features/shopping/domain/usecases/add_shopping_item_usecase.dart';
import 'package:contruttore/features/shopping/domain/usecases/cancel_shopping_purchase_usecase.dart';
import 'package:contruttore/features/shopping/domain/usecases/delete_shopping_item_usecase.dart';
import 'package:contruttore/features/shopping/domain/usecases/generate_suggestions_usecase.dart';
import 'package:contruttore/features/shopping/domain/usecases/get_shopping_items_usecase.dart';
import 'package:contruttore/features/shopping/domain/usecases/mark_as_purchased_usecase.dart';
import 'package:contruttore/features/shopping/presentation/cubit/shopping_cubit.dart';
import 'package:contruttore/features/shopping/presentation/cubit/shopping_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetShoppingItemsUseCase extends Mock
    implements GetShoppingItemsUseCase {}

class MockAddShoppingItemUseCase extends Mock
    implements AddShoppingItemUseCase {}

class MockMarkAsPurchasedUseCase extends Mock
    implements MarkAsPurchasedUseCase {}

class MockCancelShoppingPurchaseUseCase extends Mock
    implements CancelShoppingPurchaseUseCase {}

class MockGenerateSuggestionsUseCase extends Mock
    implements GenerateSuggestionsUseCase {}

class MockDeleteShoppingItemUseCase extends Mock
    implements DeleteShoppingItemUseCase {}

class MockPaymentRepository extends Mock implements PaymentRepository {}

void main() {
  late ShoppingCubit shoppingCubit;
  late MockGetShoppingItemsUseCase mockGetShoppingItemsUseCase;
  late MockAddShoppingItemUseCase mockAddShoppingItemUseCase;
  late MockMarkAsPurchasedUseCase mockMarkAsPurchasedUseCase;
  late MockCancelShoppingPurchaseUseCase mockCancelPurchaseUseCase;
  late MockGenerateSuggestionsUseCase mockGenerateSuggestionsUseCase;
  late MockDeleteShoppingItemUseCase mockDeleteShoppingItemUseCase;
  late MockPaymentRepository mockPaymentRepository;

  final tItems = <ShoppingItemEntity>[
    ShoppingItemEntity(
      id: '1',
      projectId: 'p1',
      name: 'Cimento',
      category: ShoppingCategory.other,
      quantity: 10,
      unit: 'sacos',
      estimatedPrice: 50.0,
      isPurchased: false,
      createdAt: DateTime.now(),
    ),
    ShoppingItemEntity(
      id: '2',
      projectId: 'p1',
      name: 'Areia',
      category: ShoppingCategory.other,
      quantity: 5,
      unit: 'm³',
      estimatedPrice: 80.0,
      isPurchased: true,
      actualPrice: 75.0,
      store: 'Loja ABC',
      purchaseDate: DateTime.now(),
      createdAt: DateTime.now(),
    ),
  ];

  setUp(() {
    mockGetShoppingItemsUseCase = MockGetShoppingItemsUseCase();
    mockAddShoppingItemUseCase = MockAddShoppingItemUseCase();
    mockMarkAsPurchasedUseCase = MockMarkAsPurchasedUseCase();
    mockCancelPurchaseUseCase = MockCancelShoppingPurchaseUseCase();
    mockGenerateSuggestionsUseCase = MockGenerateSuggestionsUseCase();
    mockDeleteShoppingItemUseCase = MockDeleteShoppingItemUseCase();
    mockPaymentRepository = MockPaymentRepository();

    shoppingCubit = ShoppingCubit(
      mockGetShoppingItemsUseCase,
      mockAddShoppingItemUseCase,
      mockMarkAsPurchasedUseCase,
      mockCancelPurchaseUseCase,
      mockGenerateSuggestionsUseCase,
      mockDeleteShoppingItemUseCase,
      mockPaymentRepository,
    );
  });

  setUpAll(() {
    registerFallbackValue(
      ShoppingItemEntity(
        id: '1',
        projectId: 'p1',
        name: 'Test',
        category: ShoppingCategory.other,
        quantity: 1,
        unit: 'un',
        estimatedPrice: 10.0,
        isPurchased: false,
        createdAt: DateTime.now(),
      ),
    );
    registerFallbackValue(
      DeleteShoppingItemParams(projectId: 'p1', itemId: '1'),
    );
  });

  group('ShoppingCubit - Lista de Compras', () {
    // Teste 1: Estado inicial
    test('O estado inicial deve ser ShoppingInitial', () {
      expect(shoppingCubit.state, equals(ShoppingInitial()));
    });

    // Teste 2: Carregamento de itens com sucesso
    // O que ele faz: Verifica se os itens são carregados e os totais calculados corretamente
    blocTest<ShoppingCubit, ShoppingState>(
      'Deve emitir [ShoppingLoading, ShoppingLoaded] com totais calculados',
      build: () {
        when(() => mockGetShoppingItemsUseCase(any())).thenAnswer(
          (_) async => Right(tItems),
        );
        return shoppingCubit;
      },
      act: (cubit) => cubit.loadShoppingItems('p1'),
      expect: () => [
        ShoppingLoading(),
        ShoppingLoaded(
          items: tItems,
          totalEstimated: 900.0, // 500 + 400
          totalPaid: 375.0, // Apenas o item comprado
          pendingCount: 1, // 1 item não comprado
          purchasedCount: 1, // 1 item comprado
        ),
      ],
    );

    // Teste 3: Erro ao carregar itens
    blocTest<ShoppingCubit, ShoppingState>(
      'Deve emitir [ShoppingLoading, ShoppingError] quando falhar',
      build: () {
        when(() => mockGetShoppingItemsUseCase(any())).thenAnswer(
          (_) async => const Left(ServerFailure('Erro ao buscar itens')),
        );
        return shoppingCubit;
      },
      act: (cubit) => cubit.loadShoppingItems('p1'),
      expect: () => [
        ShoppingLoading(),
        ShoppingError('Erro ao buscar itens'),
      ],
    );

    // Teste 4: Adicionar item à lista
    // O que ele faz: Verifica se um novo item é adicionado e a lista é recarregada
    blocTest<ShoppingCubit, ShoppingState>(
      'Deve adicionar item e recarregar a lista',
      build: () {
        when(() => mockAddShoppingItemUseCase(any())).thenAnswer(
          (_) async => const Right(null),
        );
        when(() => mockGetShoppingItemsUseCase(any())).thenAnswer(
          (_) async => Right(tItems),
        );
        return shoppingCubit;
      },
      act: (cubit) => cubit.addShoppingItem(tItems.first),
      verify: (_) {
        verify(() => mockAddShoppingItemUseCase(any())).called(1);
        verify(() => mockGetShoppingItemsUseCase('p1')).called(1);
      },
    );

    // Teste 5: Marcar item como comprado (sem parcelamento)
    // O que ele faz: Verifica se um item é marcado como comprado corretamente
    blocTest<ShoppingCubit, ShoppingState>(
      'Deve marcar item como comprado sem parcelamento',
      build: () {
        when(
          () => mockMarkAsPurchasedUseCase(
            projectId: any(named: 'projectId'),
            itemId: any(named: 'itemId'),
            actualPrice: any(named: 'actualPrice'),
            store: any(named: 'store'),
            purchaseDate: any(named: 'purchaseDate'),
          ),
        ).thenAnswer((_) async => const Right(null));
        when(() => mockGetShoppingItemsUseCase(any())).thenAnswer(
          (_) async => Right(tItems),
        );
        return shoppingCubit;
      },
      act: (cubit) => cubit.markAsPurchased(
        projectId: 'p1',
        itemId: '1',
        actualPrice: 480.0,
        store: 'Loja XYZ',
        purchaseDate: DateTime.now(),
        installments: 1,
      ),
      expect: () => [
        ShoppingOperationSuccess('Item marcado como comprado'),
        ShoppingLoading(),
        ShoppingLoaded(
          items: tItems,
          totalEstimated: 900.0,
          totalPaid: 375.0,
          pendingCount: 1,
          purchasedCount: 1,
        ),
      ],
    );

    // Teste 6: Marcar item como comprado com parcelamento
    // O que ele faz: Verifica se ao marcar como comprado com parcelas, os payments são gerados
    blocTest<ShoppingCubit, ShoppingState>(
      'Deve marcar item como comprado e gerar parcelas automaticamente',
      build: () {
        when(
          () => mockMarkAsPurchasedUseCase(
            projectId: any(named: 'projectId'),
            itemId: any(named: 'itemId'),
            actualPrice: any(named: 'actualPrice'),
            store: any(named: 'store'),
            purchaseDate: any(named: 'purchaseDate'),
          ),
        ).thenAnswer((_) async => const Right(null));
        when(() => mockGetShoppingItemsUseCase(any())).thenAnswer(
          (_) async => Right(tItems),
        );
        when(() => mockPaymentRepository.createPayments(any())).thenAnswer(
          (_) async => const Right(null),
        );
        return shoppingCubit;
      },
      act: (cubit) => cubit.markAsPurchased(
        projectId: 'p1',
        itemId: '1',
        actualPrice: 600.0,
        store: 'Loja XYZ',
        purchaseDate: DateTime.now(),
        installments: 3,
        firstPaymentDate: DateTime.now(),
      ),
      verify: (_) {
        verify(() => mockPaymentRepository.createPayments(any())).called(1);
      },
    );

    // Teste 7: Devolver item (cancelar compra)
    // O que ele faz: Verifica se um item comprado pode ser devolvido
    blocTest<ShoppingCubit, ShoppingState>(
      'Deve devolver item e recarregar lista',
      build: () {
        when(
          () => mockCancelPurchaseUseCase(
            projectId: any(named: 'projectId'),
            itemId: any(named: 'itemId'),
            expenseTransactionId: any(named: 'expenseTransactionId'),
          ),
        ).thenAnswer((_) async => const Right(null));
        when(() => mockGetShoppingItemsUseCase(any())).thenAnswer(
          (_) async => Right(tItems),
        );
        return shoppingCubit;
      },
      act: (cubit) => cubit.returnItem(
        projectId: 'p1',
        itemId: '2',
        expenseTransactionId: 'tx1',
      ),
      expect: () => [
        ShoppingOperationSuccess('Item devolvido com sucesso'),
        ShoppingLoading(),
        ShoppingLoaded(
          items: tItems,
          totalEstimated: 900.0,
          totalPaid: 375.0,
          pendingCount: 1,
          purchasedCount: 1,
        ),
      ],
    );

    // Teste 8: Gerar sugestões de compras
    // O que ele faz: Verifica se o sistema consegue sugerir itens baseado na fase da obra
    blocTest<ShoppingCubit, ShoppingState>(
      'Deve gerar sugestões de compras baseadas na fase',
      build: () {
        final suggestions = <ShoppingItemEntity>[
          ShoppingItemEntity(
            id: '3',
            projectId: 'p1',
            name: 'Tijolo',
            category: ShoppingCategory.other,
            quantity: 1000,
            unit: 'un',
            estimatedPrice: 0.5,
            isPurchased: false,
            createdAt: DateTime.now(),
          ),
        ];

        when(
          () => mockGenerateSuggestionsUseCase(
            projectId: any(named: 'projectId'),
            phaseNumber: any(named: 'phaseNumber'),
          ),
        ).thenReturn(suggestions);

        when(() => mockAddShoppingItemUseCase(any())).thenAnswer(
          (_) async => const Right(null),
        );

        when(() => mockGetShoppingItemsUseCase(any())).thenAnswer(
          (_) async => Right([...tItems, ...suggestions]),
        );

        return shoppingCubit;
      },
      act: (cubit) => cubit.generateSuggestions(
        projectId: 'p1',
        phaseNumber: 2,
      ),
      verify: (_) {
        verify(() => mockAddShoppingItemUseCase(any())).called(1);
      },
    );

    // Teste 9: Deletar item da lista
    // O que ele faz: Verifica se um item pode ser removido da lista
    blocTest<ShoppingCubit, ShoppingState>(
      'Deve deletar item e recarregar lista',
      build: () {
        when(
          () => mockPaymentRepository.cancelPendingPaymentsBySource(
            projectId: any(named: 'projectId'),
            sourceId: any(named: 'sourceId'),
          ),
        ).thenAnswer((_) async => const Right(null));

        when(() => mockDeleteShoppingItemUseCase(any())).thenAnswer(
          (_) async => const Right(null),
        );

        when(() => mockGetShoppingItemsUseCase(any())).thenAnswer(
          (_) async => Right([tItems.last]),
        );

        return shoppingCubit;
      },
      act: (cubit) => cubit.deleteShoppingItem('p1', '1'),
      expect: () => [
        ShoppingLoading(),
        ShoppingOperationSuccess('Item removido com sucesso'),
        ShoppingLoading(),
        ShoppingLoaded(
          items: [tItems.last],
          totalEstimated: 400.0,
          totalPaid: 375.0,
          pendingCount: 0,
          purchasedCount: 1,
        ),
      ],
    );

    // Teste 10: Erro ao deletar item (falha ao cancelar payments)
    blocTest<ShoppingCubit, ShoppingState>(
      'Deve emitir erro se falhar ao cancelar parcelas pendentes',
      build: () {
        when(
          () => mockPaymentRepository.cancelPendingPaymentsBySource(
            projectId: any(named: 'projectId'),
            sourceId: any(named: 'sourceId'),
          ),
        ).thenThrow(Exception('Erro ao cancelar parcelas'));

        return shoppingCubit;
      },
      act: (cubit) => cubit.deleteShoppingItem('p1', '1'),
      expect: () => [
        ShoppingLoading(),
        isA<ShoppingError>().having(
          (e) => e.message,
          'message',
          contains('Erro ao cancelar parcelas pendentes'),
        ),
      ],
    );

    // Teste 11: Atualizar item (usa o mesmo método de adicionar)
    blocTest<ShoppingCubit, ShoppingState>(
      'Deve atualizar item usando o método addItem',
      build: () {
        when(() => mockAddShoppingItemUseCase(any())).thenAnswer(
          (_) async => const Right(null),
        );
        when(() => mockGetShoppingItemsUseCase(any())).thenAnswer(
          (_) async => Right(tItems),
        );
        return shoppingCubit;
      },
      act: (cubit) => cubit.updateItem(tItems.first),
      verify: (_) {
        verify(() => mockAddShoppingItemUseCase(any())).called(1);
      },
    );

    // Teste 12: Cálculo correto de totais com múltiplos itens
    test('Deve calcular totais corretamente com múltiplos itens', () async {
      final multipleItems = <ShoppingItemEntity>[
        ShoppingItemEntity(
          id: '1',
          projectId: 'p1',
          name: 'Item 1',
          category: ShoppingCategory.other,
          quantity: 2,
          unit: 'un',
          estimatedPrice: 100.0,
          isPurchased: false,
          createdAt: DateTime.now(),
        ),
        ShoppingItemEntity(
          id: '2',
          projectId: 'p1',
          name: 'Item 2',
          category: ShoppingCategory.other,
          quantity: 3,
          unit: 'un',
          estimatedPrice: 50.0,
          isPurchased: true,
          actualPrice: 45.0,
          createdAt: DateTime.now(),
        ),
        ShoppingItemEntity(
          id: '3',
          projectId: 'p1',
          name: 'Item 3',
          category: ShoppingCategory.other,
          quantity: 1,
          unit: 'un',
          estimatedPrice: 300.0,
          isPurchased: true,
          actualPrice: 280.0,
          createdAt: DateTime.now(),
        ),
      ];

      when(() => mockGetShoppingItemsUseCase(any())).thenAnswer(
        (_) async => Right(multipleItems),
      );

      await shoppingCubit.loadShoppingItems('p1');

      final state = shoppingCubit.state as ShoppingLoaded;
      expect(state.totalEstimated, equals(650.0)); // 200 + 150 + 300
      expect(state.totalPaid, equals(415.0)); // 135 + 280
      expect(state.pendingCount, equals(1));
      expect(state.purchasedCount, equals(2));
    });
  });
}

// Made with Bob
