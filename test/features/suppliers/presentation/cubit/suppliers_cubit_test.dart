import 'package:bloc_test/bloc_test.dart';
import 'package:contruttore/features/suppliers/domain/entities/quote_entity.dart';
import 'package:contruttore/features/suppliers/domain/entities/supplier_entity.dart';
import 'package:contruttore/features/suppliers/domain/usecases/accept_quote_usecase.dart';
import 'package:contruttore/features/suppliers/domain/usecases/add_quote_usecase.dart';
import 'package:contruttore/features/suppliers/domain/usecases/add_supplier_usecase.dart';
import 'package:contruttore/features/suppliers/domain/usecases/compare_quotes_usecase.dart';
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

class MockGetQuotesUseCase extends Mock implements GetQuotesUseCase {}

class MockAddQuoteUseCase extends Mock implements AddQuoteUseCase {}

class MockAcceptQuoteUseCase extends Mock implements AcceptQuoteUseCase {}

class MockCompareQuotesUseCase extends Mock implements CompareQuotesUseCase {}

void main() {
  late SuppliersCubit suppliersCubit;
  late MockGetSuppliersUseCase mockGetSuppliersUseCase;
  late MockAddSupplierUseCase mockAddSupplierUseCase;
  late MockUpdateSupplierUseCase mockUpdateSupplierUseCase;
  late MockGetQuotesUseCase mockGetQuotesUseCase;
  late MockAddQuoteUseCase mockAddQuoteUseCase;
  late MockAcceptQuoteUseCase mockAcceptQuoteUseCase;
  late MockCompareQuotesUseCase mockCompareQuotesUseCase;

  setUp(() {
    mockGetSuppliersUseCase = MockGetSuppliersUseCase();
    mockAddSupplierUseCase = MockAddSupplierUseCase();
    mockUpdateSupplierUseCase = MockUpdateSupplierUseCase();
    mockGetQuotesUseCase = MockGetQuotesUseCase();
    mockAddQuoteUseCase = MockAddQuoteUseCase();
    mockAcceptQuoteUseCase = MockAcceptQuoteUseCase();
    mockCompareQuotesUseCase = MockCompareQuotesUseCase();

    suppliersCubit = SuppliersCubit(
      mockGetSuppliersUseCase,
      mockAddSupplierUseCase,
      mockUpdateSupplierUseCase,
      mockGetQuotesUseCase,
      mockAddQuoteUseCase,
      mockAcceptQuoteUseCase,
      mockCompareQuotesUseCase,
    );
  });

  final tSupplier = SupplierEntity(
    id: '1',
    name: 'João Marceneiro',
    type: SupplierType.marceneiro,
    phone: '11999999999',
    status: SupplierStatus.active,
    createdAt: DateTime.now(),
  );

  final tQuotes = [
    QuoteEntity(
      id: 'q1',
      supplierId: '1',
      projectId: 'p1',
      description: 'Armários Cozinha',
      totalValue: 15000,
      status: QuoteStatus.pending,
      validUntil: DateTime.now().add(const Duration(days: 30)),
      createdAt: DateTime.now(),
    ),
    QuoteEntity(
      id: 'q2',
      supplierId: '1',
      projectId: 'p1',
      description: 'Armários Quarto',
      totalValue: 12000,
      status: QuoteStatus.pending,
      validUntil: DateTime.now().add(const Duration(days: 30)),
      createdAt: DateTime.now(),
    ),
  ];

  group('SuppliersCubit - Gestão de Fornecedores e Orçamentos', () {
    // Teste 1: Cálculo do Orçamento Mais Barato
    // O que ele faz: Testa a lógica interna do Cubit para encontrar o menor valor entre orçamentos.
    // Isso é essencial para o recurso de "Comparador de Orçamentos" do app.
    test('Deve identificar corretamente o orçamento mais barato da lista', () {
      final cheapest = suppliersCubit.getCheapestQuote(tQuotes);
      expect(cheapest?.totalValue, 12000);
      expect(cheapest?.id, 'q2');
    });

    // Teste 2: Aceite de Orçamento
    // O que ele faz: Verifica se ao aceitar um orçamento, o Cubit emite sucesso e recarrega os detalhes.
    // Regra de Negócio: Aceitar um orçamento deve futuramente criar um lançamento 'committed' no financeiro.
    blocTest<SuppliersCubit, SuppliersState>(
      'Deve aceitar um orçamento e emitir sucesso',
      build: () {
        when(
          () => mockAcceptQuoteUseCase(
            projectId: any(named: 'projectId'),
            quoteId: any(named: 'quoteId'),
          ),
        ).thenAnswer((_) async => const Right(null));

        when(
          () => mockGetSuppliersUseCase(any()),
        ).thenAnswer((_) async => Right([tSupplier]));
        when(
          () => mockGetQuotesUseCase(
            projectId: any(named: 'projectId'),
            supplierId: any(named: 'supplierId'),
          ),
        ).thenAnswer((_) async => Right(tQuotes));

        return suppliersCubit;
      },
      act: (cubit) => cubit.acceptQuote('p1', 'q1', '1'),
      expect: () => [
        SuppliersLoading(),
        const SupplierOperationSuccess('Orçamento aceito com sucesso'),
        SupplierDetailLoaded(supplier: tSupplier, quotes: tQuotes),
      ],
    );

    // Teste 3 (Futuro): Validação de CNPJ via BrasilAPI
    // O que ele faz: Este teste simula a falha de validação de um fornecedor com documento inválido.
    // O app deve usar a BrasilAPI para garantir que o usuário não cadastre empresas inexistentes.
    blocTest<SuppliersCubit, SuppliersState>(
      'Deve emitir SuppliersError se o CNPJ do fornecedor for inválido (Integração BrasilAPI)',
      build: () {
        when(() => mockAddSupplierUseCase(any())).thenAnswer(
          (_) async => const Left(
            ServerFailure(
              'CNPJ não encontrado ou inválido na base da Receita.',
            ),
          ),
        );
        return suppliersCubit;
      },
      act: (cubit) => cubit.addSupplier(tSupplier),
      expect: () => [
        SuppliersLoading(),
        const SuppliersError(
          'CNPJ não encontrado ou inválido na base da Receita.',
        ),
      ],
    );
  });
}
