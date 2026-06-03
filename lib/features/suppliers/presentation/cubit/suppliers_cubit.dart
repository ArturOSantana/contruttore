import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/utils/payment_generator.dart';
import '../../../payments/domain/repositories/payment_repository.dart';
import '../../domain/entities/supplier_entity.dart';
import '../../domain/entities/quote_entity.dart';
import '../../domain/usecases/get_suppliers_usecase.dart';
import '../../domain/usecases/add_supplier_usecase.dart';
import '../../domain/usecases/update_supplier_usecase.dart';
import '../../domain/usecases/delete_supplier_usecase.dart';
import '../../domain/usecases/get_quotes_usecase.dart';
import '../../domain/usecases/add_quote_usecase.dart';
import '../../domain/usecases/accept_quote_usecase.dart';
import '../../domain/usecases/compare_quotes_usecase.dart';
import 'suppliers_state.dart';

@injectable
class SuppliersCubit extends Cubit<SuppliersState> {
  final GetSuppliersUseCase _getSuppliersUseCase;
  final AddSupplierUseCase _addSupplierUseCase;
  final UpdateSupplierUseCase _updateSupplierUseCase;
  final DeleteSupplierUseCase _deleteSupplierUseCase;
  final GetQuotesUseCase _getQuotesUseCase;
  final AddQuoteUseCase _addQuoteUseCase;
  final AcceptQuoteUseCase _acceptQuoteUseCase;
  final CompareQuotesUseCase _compareQuotesUseCase;
  final PaymentRepository _paymentRepository;

  SuppliersCubit(
    this._getSuppliersUseCase,
    this._addSupplierUseCase,
    this._updateSupplierUseCase,
    this._deleteSupplierUseCase,
    this._getQuotesUseCase,
    this._addQuoteUseCase,
    this._acceptQuoteUseCase,
    this._compareQuotesUseCase,
    this._paymentRepository,
  ) : super(SuppliersInitial());

  String? _currentProjectId;

  Future<void> loadSuppliers(String projectId) async {
    _currentProjectId = projectId;
    emit(SuppliersLoading());

    final result = await _getSuppliersUseCase(projectId);

    result.fold(
      (failure) => emit(SuppliersError(failure.message)),
      (suppliers) => emit(SuppliersLoaded(suppliers: suppliers)),
    );
  }

  Future<void> loadSupplierDetail(String projectId, String supplierId) async {
    emit(SuppliersLoading());

    // Buscar fornecedor
    final suppliersResult = await _getSuppliersUseCase(projectId);

    await suppliersResult.fold(
      (failure) async => emit(SuppliersError(failure.message)),
      (suppliers) async {
        final supplier = suppliers.firstWhere((s) => s.id == supplierId);

        // Buscar orçamentos do fornecedor
        final quotesResult = await _getQuotesUseCase(
          projectId: projectId,
          supplierId: supplierId,
        );

        quotesResult.fold(
          (failure) => emit(SuppliersError(failure.message)),
          (quotes) =>
              emit(SupplierDetailLoaded(supplier: supplier, quotes: quotes)),
        );
      },
    );
  }

  Future<void> addSupplier(SupplierEntity supplier) async {
    emit(SuppliersLoading());

    final result = await _addSupplierUseCase(supplier);

    await result.fold(
      (failure) async => emit(SuppliersError(failure.message)),
      (_) async {
        // Se o supplier tem valor e parcelas, gera payments automaticamente
        if (supplier.totalValue != null &&
            supplier.totalValue! > 0 &&
            supplier.firstPaymentDate != null) {
          try {
            final payments = PaymentGenerator.generatePayments(
              projectId: supplier.projectId,
              name: supplier.name,
              sourceType: 'supplier',
              sourceId: supplier.id,
              totalAmount: supplier.totalValue!,
              installments: supplier.installments,
              firstPaymentDate: supplier.firstPaymentDate!,
            );

            await _paymentRepository.createPayments(payments);
          } catch (e) {
            // Se falhar ao criar payments, emite erro mas não falha a operação
            emit(
              SuppliersError(
                'Fornecedor criado, mas erro ao gerar parcelas: $e',
              ),
            );
            return;
          }
        }

        emit(SupplierOperationSuccess('Fornecedor adicionado com sucesso'));
        if (_currentProjectId != null) {
          await loadSuppliers(_currentProjectId!);
        }
      },
    );
  }

  Future<void> updateSupplier(SupplierEntity supplier) async {
    emit(SuppliersLoading());

    final result = await _updateSupplierUseCase(supplier);

    await result.fold(
      (failure) async => emit(SuppliersError(failure.message)),
      (_) async {
        emit(SupplierOperationSuccess('Fornecedor atualizado com sucesso'));
        if (_currentProjectId != null) {
          await loadSuppliers(_currentProjectId!);
        }
      },
    );
  }

  Future<void> updateSupplierRating(
    SupplierEntity supplier,
    double rating,
  ) async {
    final updatedSupplier = supplier.copyWith(rating: rating);
    await updateSupplier(updatedSupplier);
  }

  Future<void> updateSupplierStatus(
    SupplierEntity supplier,
    SupplierStatus status,
  ) async {
    final updatedSupplier = supplier.copyWith(status: status);
    await updateSupplier(updatedSupplier);
  }

  Future<void> deleteSupplier(String projectId, String supplierId) async {
    emit(SuppliersLoading());

    // Primeiro cancela os payments pendentes deste fornecedor
    try {
      await _paymentRepository.cancelPendingPaymentsBySource(
        projectId: projectId,
        sourceId: supplierId,
      );
    } catch (e) {
      // Se falhar ao cancelar payments, emite erro e não continua
      emit(
        SuppliersError(
          'Erro ao cancelar parcelas pendentes: $e. Tente novamente.',
        ),
      );
      return;
    }

    // Depois deleta o fornecedor
    final result = await _deleteSupplierUseCase(
      DeleteSupplierParams(projectId: projectId, supplierId: supplierId),
    );

    await result.fold(
      (failure) async => emit(SuppliersError(failure.message)),
      (_) async {
        emit(SupplierOperationSuccess('Fornecedor removido com sucesso'));
        await loadSuppliers(projectId);
      },
    );
  }

  Future<void> addQuote(QuoteEntity quote) async {
    print('🟢 CUBIT: addQuote chamado');
    print('  ProjectId: ${quote.projectId}');
    print('  SupplierId: ${quote.supplierId}');

    emit(SuppliersLoading());

    final result = await _addQuoteUseCase(quote);

    await result.fold(
      (failure) async {
        print('🔴 CUBIT: Erro ao adicionar orçamento: ${failure.message}');
        emit(SuppliersError(failure.message));
      },
      (_) async {
        print('✅ CUBIT: Orçamento adicionado com sucesso!');
        emit(SupplierOperationSuccess('Orçamento adicionado com sucesso'));
        // Recarrega a lista de orçamentos
        print('🔄 CUBIT: Recarregando lista de orçamentos...');
        await loadQuotes(quote.projectId, quote.supplierId);
      },
    );
  }

  Future<void> loadQuotes(String projectId, String supplierId) async {
    print('🔵 CUBIT: loadQuotes chamado');
    print('  ProjectId: $projectId');
    print('  SupplierId: $supplierId');

    emit(SuppliersLoading());

    final result = await _getQuotesUseCase(
      projectId: projectId,
      supplierId: supplierId,
    );

    result.fold(
      (failure) {
        print('🔴 CUBIT: Erro ao carregar orçamentos: ${failure.message}');
        emit(SuppliersError(failure.message));
      },
      (quotes) {
        print('✅ CUBIT: ${quotes.length} orçamentos carregados');
        for (var quote in quotes) {
          print(
            '  - ${quote.description}: R\$ ${quote.totalValue.toStringAsFixed(2)}',
          );
        }
        emit(QuotesLoaded(quotes));
      },
    );
  }

  /// Aceita um orçamento
  ///
  /// INTEGRAÇÃO COMPLETA:
  /// - Atualiza status do quote
  /// - Cria transaction de commitment (vai para "Comprometido")
  /// - Gera payments (parcelas) automaticamente
  Future<void> acceptQuote({
    required String projectId,
    required String quoteId,
    required String supplierId,
    required int installments,
    required DateTime firstPaymentDate,
  }) async {
    emit(SuppliersLoading());

    final result = await _acceptQuoteUseCase(
      projectId: projectId,
      quoteId: quoteId,
      installments: installments,
      firstPaymentDate: firstPaymentDate,
    );

    await result.fold(
      (failure) async => emit(SuppliersError(failure.message)),
      (_) async {
        emit(
          SupplierOperationSuccess(
            'Orçamento aceito! Parcelas criadas automaticamente.',
          ),
        );
        await loadSupplierDetail(projectId, supplierId);
      },
    );
  }

  Future<void> loadAllQuotes(String projectId) async {
    emit(SuppliersLoading());

    final quotesResult = await _getQuotesUseCase(projectId: projectId);

    quotesResult.fold(
      (failure) => emit(SuppliersError(failure.message)),
      (quotes) => emit(SuppliersLoaded(suppliers: const [], quotes: quotes)),
    );
  }

  List<SupplierEntity> filterSuppliersByType(
    List<SupplierEntity> suppliers,
    SupplierType? type,
  ) {
    if (type == null) return suppliers;
    return suppliers.where((s) => s.type == type).toList();
  }

  List<SupplierEntity> filterSuppliersByStatus(
    List<SupplierEntity> suppliers,
    SupplierStatus? status,
  ) {
    if (status == null) return suppliers;
    return suppliers.where((s) => s.status == status).toList();
  }

  List<QuoteEntity> getActiveQuotes(List<QuoteEntity> quotes) {
    return quotes
        .where((q) => q.status == QuoteStatus.pending && !q.isExpired)
        .toList();
  }

  List<QuoteEntity> getExpiredQuotes(List<QuoteEntity> quotes) {
    return quotes
        .where((q) => q.status == QuoteStatus.pending && q.isExpired)
        .toList();
  }

  double calculateAverageQuoteValue(List<QuoteEntity> quotes) {
    if (quotes.isEmpty) return 0;
    final total = quotes.fold<double>(
      0,
      (sum, quote) => sum + quote.totalValue,
    );
    return total / quotes.length;
  }

  QuoteEntity? getCheapestQuote(List<QuoteEntity> quotes) {
    if (quotes.isEmpty) return null;
    return quotes.reduce((a, b) => a.totalValue < b.totalValue ? a : b);
  }

  QuoteEntity? getMostExpensiveQuote(List<QuoteEntity> quotes) {
    if (quotes.isEmpty) return null;
    return quotes.reduce((a, b) => a.totalValue > b.totalValue ? a : b);
  }

  Future<void> compareQuotes(String projectId, List<String> quoteIds) async {
    emit(SuppliersLoading());

    final result = await _compareQuotesUseCase(projectId, quoteIds);

    result.fold(
      (failure) => emit(SuppliersError(failure.message)),
      (comparison) => emit(QuotesCompared(comparison)),
    );
  }
}

// Made with Bob
