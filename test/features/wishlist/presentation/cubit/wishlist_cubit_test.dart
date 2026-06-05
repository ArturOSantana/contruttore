import 'package:bloc_test/bloc_test.dart';
import 'package:contruttore/core/error/failures.dart';
import 'package:contruttore/features/wishlist/domain/entities/wishlist_item_entity.dart';
import 'package:contruttore/features/wishlist/domain/usecases/add_wishlist_item_usecase.dart';
import 'package:contruttore/features/wishlist/domain/usecases/delete_wishlist_item_usecase.dart';
import 'package:contruttore/features/wishlist/domain/usecases/get_wishlist_items_usecase.dart';
import 'package:contruttore/features/wishlist/domain/usecases/move_to_shopping_usecase.dart';
import 'package:contruttore/features/wishlist/domain/usecases/toggle_selected_usecase.dart';
import 'package:contruttore/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:contruttore/features/wishlist/presentation/cubit/wishlist_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetWishlistItemsUseCase extends Mock
    implements GetWishlistItemsUseCase {}

class MockAddWishlistItemUseCase extends Mock
    implements AddWishlistItemUseCase {}

class MockToggleSelectedUseCase extends Mock implements ToggleSelectedUseCase {}

class MockMoveToShoppingUseCase extends Mock implements MoveToShoppingUseCase {}

class MockDeleteWishlistItemUseCase extends Mock
    implements DeleteWishlistItemUseCase {}

void main() {
  late WishlistCubit wishlistCubit;
  late MockGetWishlistItemsUseCase mockGetWishlistItemsUseCase;
  late MockAddWishlistItemUseCase mockAddWishlistItemUseCase;
  late MockToggleSelectedUseCase mockToggleSelectedUseCase;
  late MockMoveToShoppingUseCase mockMoveToShoppingUseCase;
  late MockDeleteWishlistItemUseCase mockDeleteWishlistItemUseCase;

  final tItems = <WishlistItemEntity>[
    WishlistItemEntity(
      id: '1',
      projectId: 'p1',
      name: 'Lustre Sala',
      url: 'https://example.com/lustre',
      notes: 'Lustre moderno LED',
      price: 500.0,
      category: WishlistCategory.lighting,
      isSelected: false,
      createdAt: DateTime.now(),
    ),
    WishlistItemEntity(
      id: '2',
      projectId: 'p1',
      name: 'Papel de Parede',
      url: 'https://example.com/papel',
      notes: 'Papel de parede para quarto',
      price: 300.0,
      category: WishlistCategory.decoration,
      isSelected: true,
      createdAt: DateTime.now(),
    ),
  ];

  setUp(() {
    mockGetWishlistItemsUseCase = MockGetWishlistItemsUseCase();
    mockAddWishlistItemUseCase = MockAddWishlistItemUseCase();
    mockToggleSelectedUseCase = MockToggleSelectedUseCase();
    mockMoveToShoppingUseCase = MockMoveToShoppingUseCase();
    mockDeleteWishlistItemUseCase = MockDeleteWishlistItemUseCase();

    wishlistCubit = WishlistCubit(
      mockGetWishlistItemsUseCase,
      mockAddWishlistItemUseCase,
      mockToggleSelectedUseCase,
      mockMoveToShoppingUseCase,
      mockDeleteWishlistItemUseCase,
    );
  });

  setUpAll(() {
    registerFallbackValue(
      WishlistItemEntity(
        id: '1',
        projectId: 'p1',
        name: 'Test',
        url: 'https://example.com/test',
        category: WishlistCategory.other,
        isSelected: false,
        createdAt: DateTime.now(),
      ),
    );
    registerFallbackValue(
      DeleteWishlistItemParams(projectId: 'p1', itemId: '1'),
    );
  });

  group('WishlistCubit - Lista de Desejos', () {
    // Teste 1: Estado inicial
    test('O estado inicial deve ser WishlistInitial', () {
      expect(wishlistCubit.state, equals(WishlistInitial()));
    });

    // Teste 2: Carregamento de itens com sucesso
    // O que ele faz: Verifica se os itens são carregados e as contagens calculadas
    blocTest<WishlistCubit, WishlistState>(
      'Deve emitir [WishlistLoading, WishlistLoaded] com contagens corretas',
      build: () {
        when(() => mockGetWishlistItemsUseCase(any())).thenAnswer(
          (_) async => Right(tItems),
        );
        return wishlistCubit;
      },
      act: (cubit) => cubit.loadWishlistItems('p1'),
      expect: () => [
        WishlistLoading(),
        WishlistLoaded(
          items: tItems,
          selectedCount: 1, // 1 item selecionado
          totalCount: 2, // 2 itens no total
        ),
      ],
    );

    // Teste 3: Erro ao carregar itens
    blocTest<WishlistCubit, WishlistState>(
      'Deve emitir [WishlistLoading, WishlistError] quando falhar',
      build: () {
        when(() => mockGetWishlistItemsUseCase(any())).thenAnswer(
          (_) async => const Left(ServerFailure('Erro ao buscar itens')),
        );
        return wishlistCubit;
      },
      act: (cubit) => cubit.loadWishlistItems('p1'),
      expect: () => [
        WishlistLoading(),
        WishlistError('Erro ao buscar itens'),
      ],
    );

    // Teste 4: Adicionar item à wishlist
    // O que ele faz: Verifica se um novo item é adicionado e a lista é recarregada
    blocTest<WishlistCubit, WishlistState>(
      'Deve adicionar item e recarregar a lista',
      build: () {
        when(() => mockAddWishlistItemUseCase(any())).thenAnswer(
          (_) async => const Right(null),
        );
        when(() => mockGetWishlistItemsUseCase(any())).thenAnswer(
          (_) async => Right(tItems),
        );
        return wishlistCubit;
      },
      act: (cubit) => cubit.addWishlistItem(tItems.first),
      verify: (_) {
        verify(() => mockAddWishlistItemUseCase(any())).called(1);
        verify(() => mockGetWishlistItemsUseCase('p1')).called(1);
      },
    );

    // Teste 5: Marcar item como selecionado e mover para shopping
    // O que ele faz: Verifica se ao selecionar um item, ele é movido para a lista de compras
    blocTest<WishlistCubit, WishlistState>(
      'Deve marcar como selecionado e mover para lista de compras',
      build: () {
        when(
          () => mockToggleSelectedUseCase(
            projectId: any(named: 'projectId'),
            itemId: any(named: 'itemId'),
            isSelected: any(named: 'isSelected'),
          ),
        ).thenAnswer((_) async => const Right(null));

        when(() => mockMoveToShoppingUseCase(any())).thenAnswer(
          (_) async => const Right(null),
        );

        when(() => mockGetWishlistItemsUseCase(any())).thenAnswer(
          (_) async => Right(tItems),
        );

        return wishlistCubit;
      },
      act: (cubit) => cubit.toggleSelected(
        projectId: 'p1',
        itemId: '1',
        isSelected: true,
        item: tItems.first,
      ),
      expect: () => [
        WishlistOperationSuccess(
          'Item selecionado e adicionado à lista de compras',
        ),
        WishlistLoading(),
        WishlistLoaded(
          items: tItems,
          selectedCount: 1,
          totalCount: 2,
        ),
      ],
    );

    // Teste 6: Desmarcar item selecionado
    // O que ele faz: Verifica se ao desmarcar, o item não é movido para shopping
    blocTest<WishlistCubit, WishlistState>(
      'Deve desmarcar item sem mover para shopping',
      build: () {
        when(
          () => mockToggleSelectedUseCase(
            projectId: any(named: 'projectId'),
            itemId: any(named: 'itemId'),
            isSelected: any(named: 'isSelected'),
          ),
        ).thenAnswer((_) async => const Right(null));

        when(() => mockGetWishlistItemsUseCase(any())).thenAnswer(
          (_) async => Right(tItems),
        );

        return wishlistCubit;
      },
      act: (cubit) => cubit.toggleSelected(
        projectId: 'p1',
        itemId: '2',
        isSelected: false,
        item: tItems.last,
      ),
      expect: () => [
        WishlistOperationSuccess('Item desmarcado'),
        WishlistLoading(),
        WishlistLoaded(
          items: tItems,
          selectedCount: 1,
          totalCount: 2,
        ),
      ],
      verify: (_) {
        // Verifica que NÃO tentou mover para shopping
        verifyNever(() => mockMoveToShoppingUseCase(any()));
      },
    );

    // Teste 7: Erro ao mover para shopping
    // O que ele faz: Verifica o comportamento quando falha ao mover para shopping
    blocTest<WishlistCubit, WishlistState>(
      'Deve emitir erro se falhar ao mover para shopping',
      build: () {
        when(
          () => mockToggleSelectedUseCase(
            projectId: any(named: 'projectId'),
            itemId: any(named: 'itemId'),
            isSelected: any(named: 'isSelected'),
          ),
        ).thenAnswer((_) async => const Right(null));

        when(() => mockMoveToShoppingUseCase(any())).thenAnswer(
          (_) async => const Left(
            ServerFailure('Erro ao adicionar à lista de compras'),
          ),
        );

        when(() => mockGetWishlistItemsUseCase(any())).thenAnswer(
          (_) async => Right(tItems),
        );

        return wishlistCubit;
      },
      act: (cubit) => cubit.toggleSelected(
        projectId: 'p1',
        itemId: '1',
        isSelected: true,
        item: tItems.first,
      ),
      expect: () => [
        WishlistError(
          'Item selecionado mas não foi possível adicionar à lista de compras: Erro ao adicionar à lista de compras',
        ),
        WishlistLoading(),
        WishlistLoaded(
          items: tItems,
          selectedCount: 1,
          totalCount: 2,
        ),
      ],
    );

    // Teste 8: Deletar item da wishlist
    // O que ele faz: Verifica se um item pode ser removido da wishlist
    blocTest<WishlistCubit, WishlistState>(
      'Deve deletar item e recarregar lista',
      build: () {
        when(() => mockDeleteWishlistItemUseCase(any())).thenAnswer(
          (_) async => const Right(null),
        );

        when(() => mockGetWishlistItemsUseCase(any())).thenAnswer(
          (_) async => Right([tItems.first]),
        );

        return wishlistCubit;
      },
      act: (cubit) => cubit.deleteWishlistItem('p1', '2'),
      expect: () => [
        WishlistLoading(),
        WishlistLoaded(
          items: [tItems.first],
          selectedCount: 0,
          totalCount: 1,
        ),
      ],
    );

    // Teste 9: Erro ao deletar item
    blocTest<WishlistCubit, WishlistState>(
      'Deve emitir erro quando falhar ao deletar',
      build: () {
        when(() => mockDeleteWishlistItemUseCase(any())).thenAnswer(
          (_) async => const Left(ServerFailure('Erro ao deletar')),
        );
        return wishlistCubit;
      },
      act: (cubit) => cubit.deleteWishlistItem('p1', '1'),
      expect: () => [
        WishlistError('Erro ao deletar'),
      ],
    );

    // Teste 10: Atualizar item (usa o mesmo método de adicionar)
    blocTest<WishlistCubit, WishlistState>(
      'Deve atualizar item usando o método addItem',
      build: () {
        when(() => mockAddWishlistItemUseCase(any())).thenAnswer(
          (_) async => const Right(null),
        );
        when(() => mockGetWishlistItemsUseCase(any())).thenAnswer(
          (_) async => Right(tItems),
        );
        return wishlistCubit;
      },
      act: (cubit) => cubit.updateItem(tItems.first),
      verify: (_) {
        verify(() => mockAddWishlistItemUseCase(any())).called(1);
      },
    );

    // Teste 11: Contagem correta com múltiplos itens selecionados
    test('Deve calcular contagem de selecionados corretamente', () async {
      final multipleItems = <WishlistItemEntity>[
        WishlistItemEntity(
          id: '1',
          projectId: 'p1',
          name: 'Item 1',
          url: 'https://example.com/1',
          price: 100.0,
          category: WishlistCategory.furniture,
          isSelected: true,
          createdAt: DateTime.now(),
        ),
        WishlistItemEntity(
          id: '2',
          projectId: 'p1',
          name: 'Item 2',
          url: 'https://example.com/2',
          price: 200.0,
          category: WishlistCategory.lighting,
          isSelected: true,
          createdAt: DateTime.now(),
        ),
        WishlistItemEntity(
          id: '3',
          projectId: 'p1',
          name: 'Item 3',
          url: 'https://example.com/3',
          price: 300.0,
          category: WishlistCategory.decoration,
          isSelected: false,
          createdAt: DateTime.now(),
        ),
      ];

      when(() => mockGetWishlistItemsUseCase(any())).thenAnswer(
        (_) async => Right(multipleItems),
      );

      await wishlistCubit.loadWishlistItems('p1');

      final state = wishlistCubit.state as WishlistLoaded;
      expect(state.selectedCount, equals(2)); // 2 itens selecionados
      expect(state.totalCount, equals(3)); // 3 itens no total
    });

    // Teste 12: Lista vazia
    blocTest<WishlistCubit, WishlistState>(
      'Deve lidar corretamente com lista vazia',
      build: () {
        when(() => mockGetWishlistItemsUseCase(any())).thenAnswer(
          (_) async => const Right([]),
        );
        return wishlistCubit;
      },
      act: (cubit) => cubit.loadWishlistItems('p1'),
      expect: () => [
        WishlistLoading(),
        WishlistLoaded(
          items: [],
          selectedCount: 0,
          totalCount: 0,
        ),
      ],
    );
  });
}

// Made with Bob
