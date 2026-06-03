import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../projects/domain/entities/project_entity.dart';
import '../../../projects/domain/repositories/project_repository.dart';
import '../../../projects/domain/entities/phase_entity.dart';
import '../../../phases/domain/repositories/phase_repository.dart';
import '../../../financial/domain/entities/expense_entity.dart';
import '../../../financial/domain/repositories/financial_repository.dart';
import '../../../suppliers/domain/entities/supplier_entity.dart';
import '../../../suppliers/domain/repositories/supplier_repository.dart';
import '../../domain/entities/budget_option.dart';
import '../../domain/entities/quick_supplier.dart';
import '../../domain/entities/retroactive_expense_entry.dart';
import '../../domain/services/retroactive_budget_distributor.dart';
import 'retroactive_state.dart';

/// Cubit que gerencia o fluxo de onboarding retroativo
class RetroactiveCubit extends Cubit<RetroactiveState> {
  final ProjectRepository _projectRepository;
  final PhaseRepository _phaseRepository;
  final FinancialRepository _financialRepository;
  final SupplierRepository _supplierRepository;
  final Uuid _uuid;

  RetroactiveCubit({
    required ProjectRepository projectRepository,
    required PhaseRepository phaseRepository,
    required FinancialRepository financialRepository,
    required SupplierRepository supplierRepository,
    Uuid? uuid,
  }) : _projectRepository = projectRepository,
       _phaseRepository = phaseRepository,
       _financialRepository = financialRepository,
       _supplierRepository = supplierRepository,
       _uuid = uuid ?? const Uuid(),
       super(const RetroactiveInitial());

  /// Inicia o fluxo de onboarding retroativo
  void start() {
    emit(const RetroactiveCollecting());
  }

  /// Seleciona a fase atual do usuário
  void selectCurrentPhase(int phaseNumber) {
    final currentState = state;
    if (currentState is! RetroactiveCollecting) return;

    emit(currentState.copyWith(selectedPhaseNumber: phaseNumber));
  }

  /// Define a opção de orçamento escolhida
  void setBudgetOption(BudgetOption option) {
    final currentState = state;
    if (currentState is! RetroactiveCollecting) return;

    emit(currentState.copyWith(budgetOption: option));
  }

  /// Define o valor total gasto (quando opção = total)
  void setTotalSpent(double amount) {
    final currentState = state;
    if (currentState is! RetroactiveCollecting) return;

    emit(currentState.copyWith(totalSpent: amount));
  }

  /// Adiciona uma despesa retroativa (quando opção = receipts)
  void addExpenseEntry(RetroactiveExpenseEntry entry) {
    final currentState = state;
    if (currentState is! RetroactiveCollecting) return;

    final updatedEntries = List<RetroactiveExpenseEntry>.from(
      currentState.expenseEntries,
    )..add(entry);

    emit(currentState.copyWith(expenseEntries: updatedEntries));
  }

  /// Remove uma despesa retroativa
  void removeExpenseEntry(String entryId) {
    final currentState = state;
    if (currentState is! RetroactiveCollecting) return;

    final updatedEntries = currentState.expenseEntries
        .where((e) => e.id != entryId)
        .toList();

    emit(currentState.copyWith(expenseEntries: updatedEntries));
  }

  /// Adiciona um fornecedor rápido
  void addQuickSupplier(QuickSupplier supplier) {
    final currentState = state;
    if (currentState is! RetroactiveCollecting) return;

    final updatedSuppliers = List<QuickSupplier>.from(
      currentState.quickSuppliers,
    )..add(supplier);

    emit(currentState.copyWith(quickSuppliers: updatedSuppliers));
  }

  /// Remove um fornecedor rápido
  void removeQuickSupplier(String supplierId) {
    final currentState = state;
    if (currentState is! RetroactiveCollecting) return;

    final updatedSuppliers = currentState.quickSuppliers
        .where((s) => s.id != supplierId)
        .toList();

    emit(currentState.copyWith(quickSuppliers: updatedSuppliers));
  }

  /// Cria o projeto retroativo com todos os dados coletados
  Future<void> createRetroactiveProject({
    required String userId,
    required String projectName,
    required String address,
    required double area,
    required DateTime deliveryDate,
    required DateTime contractDate,
    required String constructorName,
  }) async {
    final currentState = state;
    if (currentState is! RetroactiveCollecting) return;

    if (!currentState.canProceed) {
      emit(const RetroactiveError('Dados incompletos'));
      return;
    }

    emit(const RetroactiveCreating());

    try {
      final projectId = _uuid.v4();
      final totalSpent = currentState.calculatedTotalSpent;
      final currentPhaseNumber = currentState.selectedPhaseNumber!;

      // 1. Criar o projeto
      final project = ProjectEntity(
        id: projectId,
        userId: userId,
        name: projectName,
        address: address,
        area: area,
        deliveryDate: deliveryDate,
        contractDate: contractDate,
        constructorName: constructorName,
        totalBudget: totalSpent > 0 ? totalSpent * 1.5 : 50000.0, // Estimativa
        contingencyPercent: 10.0,
        propertyValue: 0.0, // Não relevante para retroativo
        currentSituation: 'renovation', // Obra em andamento
        createdAt: DateTime.now(),
      );

      await _projectRepository.createProject(project);

      // 2. Criar as 12 fases com status correto
      await _createPhasesWithRetroactiveStatus(
        projectId: projectId,
        currentPhaseNumber: currentPhaseNumber,
      );

      // 3. Criar despesas retroativas (se houver)
      if (currentState.budgetOption == BudgetOption.receipts) {
        await _createRetroactiveExpenses(
          projectId: projectId,
          entries: currentState.expenseEntries,
        );
      } else if (currentState.budgetOption == BudgetOption.total &&
          totalSpent > 0) {
        // Distribui o total entre as fases passadas
        await _distributeAndCreateExpenses(
          projectId: projectId,
          totalSpent: totalSpent,
          currentPhaseNumber: currentPhaseNumber,
        );
      }

      // 4. Criar fornecedores rápidos (se houver)
      if (currentState.quickSuppliers.isNotEmpty) {
        await _createQuickSuppliers(
          projectId: projectId,
          suppliers: currentState.quickSuppliers,
        );
      }

      emit(RetroactiveSuccess(projectId));
    } catch (e) {
      emit(RetroactiveError('Erro ao criar projeto: ${e.toString()}'));
    }
  }

  /// Cria as 12 fases com status retroativo correto
  Future<void> _createPhasesWithRetroactiveStatus({
    required String projectId,
    required int currentPhaseNumber,
  }) async {
    final now = DateTime.now();

    for (int i = 1; i <= 12; i++) {
      PhaseStatus status;
      bool isRetroactive = false;
      DateTime? retroactiveMarkedAt;

      if (i < currentPhaseNumber) {
        // Fases passadas = concluídas sem registro
        status = PhaseStatus.doneNoRecord;
        isRetroactive = true;
        retroactiveMarkedAt = now;
      } else if (i == currentPhaseNumber) {
        // Fase atual = ativa
        status = PhaseStatus.active;
        isRetroactive = false;
      } else {
        // Fases futuras = bloqueadas
        status = PhaseStatus.locked;
        isRetroactive = false;
      }

      final phase = PhaseEntity(
        id: _uuid.v4(),
        projectId: projectId,
        number: i,
        name: _getPhaseNameByNumber(i),
        description: _getPhaseDescriptionByNumber(i),
        status: status,
        startDate: i < currentPhaseNumber
            ? now.subtract(Duration(days: 90 * (currentPhaseNumber - i)))
            : null,
        endDate: i < currentPhaseNumber
            ? now.subtract(Duration(days: 90 * (currentPhaseNumber - i - 1)))
            : null,
        estimatedDurationDays: _getEstimatedDurationByPhase(i),
        subtasks: _getDefaultSubtasksByPhase(i),
        notes: null,
        isRetroactive: isRetroactive,
        retroactiveMarkedAt: retroactiveMarkedAt,
      );

      final result = await _phaseRepository.updatePhase(phase);
      result.fold(
        (failure) => throw Exception('Erro ao criar fase'),
        (_) => null,
      );
    }
  }

  /// Cria despesas retroativas a partir das entradas
  Future<void> _createRetroactiveExpenses({
    required String projectId,
    required List<RetroactiveExpenseEntry> entries,
  }) async {
    for (final entry in entries) {
      final expense = ExpenseEntity(
        id: entry.id,
        projectId: projectId,
        categoryId: entry.categoryId,
        amount: entry.amount,
        date: entry.approximateDate,
        description: entry.description,
        status: ExpenseStatus.confirmed,
        supplierId: null,
        invoicePhotoUrl: entry.invoicePhotoUrl,
        phaseId: null,
        createdAt: DateTime.now(),
      );

      final result = await _financialRepository.addExpense(expense);
      result.fold(
        (failure) => throw Exception('Erro ao criar despesa'),
        (_) => null,
      );
    }
  }

  /// Distribui o total gasto entre as fases passadas
  Future<void> _distributeAndCreateExpenses({
    required String projectId,
    required double totalSpent,
    required int currentPhaseNumber,
  }) async {
    // Calcula quanto foi gasto em cada fase passada
    final distribution = RetroactiveBudgetDistributor.distribute(
      totalBudget: totalSpent,
      currentPhaseNumber: currentPhaseNumber,
    );

    // Cria uma despesa estimada para cada fase passada
    for (int phase = 6; phase < currentPhaseNumber; phase++) {
      final amount = distribution[phase] ?? 0.0;
      if (amount <= 0) continue;

      final expense = ExpenseEntity(
        id: _uuid.v4(),
        projectId: projectId,
        categoryId: 'retroactive_phase_$phase',
        amount: amount,
        date: DateTime.now().subtract(
          Duration(days: 90 * (currentPhaseNumber - phase)),
        ),
        description: 'Gasto estimado - ${_getPhaseNameByNumber(phase)}',
        status: ExpenseStatus.estimated,
        supplierId: null,
        invoicePhotoUrl: null,
        phaseId: null,
        createdAt: DateTime.now(),
      );

      final result = await _financialRepository.addExpense(expense);
      result.fold(
        (failure) => throw Exception('Erro ao criar despesa'),
        (_) => null,
      );
    }
  }

  /// Cria fornecedores a partir dos fornecedores rápidos
  Future<void> _createQuickSuppliers({
    required String projectId,
    required List<QuickSupplier> suppliers,
  }) async {
    for (final quick in suppliers) {
      final supplier = SupplierEntity(
        id: quick.id,
        projectId: projectId,
        name: quick.name,
        type: _parseSupplierType(quick.type),
        phone: '',
        email: null,
        cnpj: null,
        cpf: null,
        rating: null,
        notes: 'Cadastrado no onboarding retroativo',
        phaseId: null,
        status: _parseSupplierStatus(quick.status),
        createdAt: DateTime.now(),
      );

      final result = await _supplierRepository.addSupplier(supplier);
      result.fold(
        (failure) => throw Exception('Erro ao criar fornecedor'),
        (_) => null,
      );
    }
  }

  SupplierType _parseSupplierType(String type) {
    switch (type.toLowerCase()) {
      case 'pedreiro':
        return SupplierType.mason;
      case 'eletricista':
        return SupplierType.electrician;
      case 'encanador':
        return SupplierType.plumber;
      case 'pintor':
        return SupplierType.painter;
      case 'marceneiro':
        return SupplierType.carpenter;
      case 'gesseiro':
        return SupplierType.plasterer;
      default:
        return SupplierType.other;
    }
  }

  SupplierStatus _parseSupplierStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return SupplierStatus.active;
      case 'problem':
        return SupplierStatus.problem;
      default:
        return SupplierStatus.active;
    }
  }

  // Helpers para dados das fases

  String _getPhaseNameByNumber(int number) {
    const names = {
      1: 'Assinatura e documentação',
      2: 'Acompanhamento da obra',
      3: 'Decisões de personalização',
      4: 'Preparação para entrega',
      5: 'Vistoria de entrega',
      6: 'Regularização pós-entrega',
      7: 'Projeto e planejamento',
      8: 'Demolição e limpeza',
      9: 'Instalações',
      10: 'Revestimentos e pisos',
      11: 'Gesso, pintura e acabamentos',
      12: 'Marcenaria e mobiliário',
    };
    return names[number] ?? 'Fase $number';
  }

  String _getPhaseDescriptionByNumber(int number) {
    const descriptions = {
      1: 'Guardar contrato, entender cláusulas, cadastrar parcelas',
      2: 'Registrar relatórios mensais, guardar comunicados',
      3: 'Escolher materiais dentro dos prazos da construtora',
      4: 'Contratar vistoriador, estudar checklist de vistoria',
      5: 'Vistoriar o imóvel antes de assinar',
      6: 'ITBI, escritura, comunicar reforma ao condomínio',
      7: 'Contratar arquiteto, definir escopo, fechar orçamentos',
      8: 'Proteger elevadores, demolir, descartar entulho',
      9: 'Passagem de eletrodutos e tubulações',
      10: 'Contrapiso, revestimentos, pisos, rejunte',
      11: 'Forro, massa corrida, pintura, esquadrias',
      12: 'Medição, instalação de marcenaria e móveis',
    };
    return descriptions[number] ?? '';
  }

  int _getEstimatedDurationByPhase(int number) {
    const durations = {
      1: 7,
      2: 365,
      3: 90,
      4: 30,
      5: 1,
      6: 30,
      7: 30,
      8: 7,
      9: 21,
      10: 30,
      11: 21,
      12: 21,
    };
    return durations[number] ?? 30;
  }

  List<SubtaskEntity> _getDefaultSubtasksByPhase(int number) {
    // Retorna lista vazia - subtarefas serão adicionadas dinamicamente
    // ou carregadas de um arquivo de configuração
    return [];
  }
}

// Made with Bob
