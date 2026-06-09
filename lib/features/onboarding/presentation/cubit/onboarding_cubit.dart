import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../projects/domain/entities/project_entity.dart';
import '../../../projects/domain/entities/phase_entity.dart';
import '../../../projects/domain/usecases/create_project_usecase.dart';
import '../../../projects/domain/usecases/generate_phases_usecase.dart';
import '../../../phases/domain/repositories/phase_repository.dart';
import '../../domain/usecases/generate_onboarding_results_usecase.dart';
import '../../domain/usecases/generate_reform_risks_usecase.dart';
import '../../domain/entities/onboarding_results_entity.dart';
import '../../domain/entities/reform_risk_entity.dart';
import 'onboarding_state.dart';

@injectable
class OnboardingCubit extends Cubit<OnboardingState> {
  final CreateProjectUseCase _createProjectUseCase;
  final GeneratePhasesUseCase _generatePhasesUseCase;
  final PhaseRepository _phaseRepository;
  final FirebaseFirestore _firestore;
  final GenerateOnboardingResultsUseCase _generateResultsUseCase;
  final GenerateReformRisksUseCase _generateRisksUseCase;

  // Armazenar dados do onboarding para usar depois
  OnboardingInProgress? _savedOnboardingState;

  OnboardingCubit(
    this._createProjectUseCase,
    this._generatePhasesUseCase,
    this._phaseRepository,
    this._firestore,
    this._generateResultsUseCase,
    this._generateRisksUseCase,
  ) : super(OnboardingInitial());

  void startOnboarding() {
    emit(OnboardingInProgress(currentStep: 1, data: {}));
  }

  /// Avança para o próximo step (1-14)
  void nextStep(Map<String, dynamic> stepData) {
    if (state is! OnboardingInProgress) return;

    final current = state as OnboardingInProgress;
    final newData = {...current.data, ...stepData};

    // Atualizar campos específicos baseado no step
    final updatedState = _updateStateFromStepData(current, stepData);

    if (current.currentStep < 14) {
      emit(
        updatedState.copyWith(
          currentStep: current.currentStep + 1,
          data: newData,
        ),
      );
    }
  }

  /// Volta para o step anterior
  void previousStep() {
    if (state is! OnboardingInProgress) return;

    final current = state as OnboardingInProgress;
    if (current.currentStep > 1) {
      emit(
        OnboardingInProgress(
          currentStep: current.currentStep - 1,
          data: current.data,
        ),
      );
    }
  }

  /// Atualiza o state baseado nos dados do step
  OnboardingInProgress _updateStateFromStepData(
    OnboardingInProgress current,
    Map<String, dynamic> stepData,
  ) {
    // Step 1: Tipo de Imóvel
    if (stepData.containsKey('propertyType')) {
      return current.copyWith(
          propertyType: stepData['propertyType'] as String?);
    }

    // Step 2: Situação Atual
    if (stepData.containsKey('currentSituation')) {
      return current.copyWith(
          currentSituation: stepData['currentSituation'] as String?);
    }

    // Step 3: Nível da Reforma
    if (stepData.containsKey('reformLevel')) {
      return current.copyWith(reformLevel: stepData['reformLevel'] as String?);
    }

    // Step 4: O Que Já Foi Feito
    if (stepData.containsKey('completedItems')) {
      return current.copyWith(
          completedItems: stepData['completedItems'] as List<String>);
    }

    // Step 5: Tamanho do Imóvel
    if (stepData.containsKey('propertySize')) {
      return current.copyWith(
          propertySize: stepData['propertySize'] as String?);
    }

    // Step 6: Ambientes
    if (stepData.containsKey('selectedRooms')) {
      return current.copyWith(
          selectedRooms: stepData['selectedRooms'] as List<String>);
    }

    // Step 7: Quem Vai Morar
    if (stepData.containsKey('residents')) {
      return current.copyWith(residents: stepData['residents'] as String?);
    }

    // Step 8: Home Office
    if (stepData.containsKey('hasHomeOffice')) {
      return current.copyWith(
          hasHomeOffice: stepData['hasHomeOffice'] as bool?);
    }

    // Step 9: Pets
    if (stepData.containsKey('hasPets')) {
      return current.copyWith(hasPets: stepData['hasPets'] as bool?);
    }

    // Step 10: Ar-Condicionado
    if (stepData.containsKey('hasAirConditioning')) {
      return current.copyWith(
          hasAirConditioning: stepData['hasAirConditioning'] as String?);
    }

    // Step 11: Planejados
    if (stepData.containsKey('hasCustomFurniture')) {
      return current.copyWith(
          hasCustomFurniture: stepData['hasCustomFurniture'] as String?);
    }

    // Step 12: Orçamento
    if (stepData.containsKey('budgetRange')) {
      return current.copyWith(budgetRange: stepData['budgetRange'] as String?);
    }

    // Step 13: Prioridades
    if (stepData.containsKey('priorities')) {
      return current.copyWith(
          priorities: stepData['priorities'] as List<String>);
    }

    // Step 14: Infraestrutura Crítica
    if (stepData.containsKey('criticalInfrastructure')) {
      return current.copyWith(
          criticalInfrastructure:
              stepData['criticalInfrastructure'] as List<String>);
    }

    // Step 6.5: Ambientes Prioritários
    if (stepData.containsKey('priorityRooms')) {
      return current.copyWith(
          priorityRooms: stepData['priorityRooms'] as List<String>);
    }

    // Step 12.5: Coordenação da Obra (CRÍTICO)
    if (stepData.containsKey('projectManagementType')) {
      return current.copyWith(
          projectManagementType: stepData['projectManagementType'] as String?);
    }

    // Step 13.5: Prazo de Mudança
    if (stepData.containsKey('moveInGoal')) {
      return current.copyWith(moveInGoal: stepData['moveInGoal'] as String?);
    }

    // Step 14.5: Itens Já Comprados
    if (stepData.containsKey('alreadyPurchasedItems')) {
      return current.copyWith(
          alreadyPurchasedItems:
              stepData['alreadyPurchasedItems'] as List<String>);
    }

    return current;
  }

  void updateStepData(Map<String, dynamic> stepData) {
    if (state is! OnboardingInProgress) return;

    final current = state as OnboardingInProgress;
    final newData = {...current.data, ...stepData};

    // Extrair campos específicos do stepData para popular o state
    emit(OnboardingInProgress(
      currentStep: current.currentStep,
      data: newData,
      currentSituation:
          stepData['currentSituation'] as String? ?? current.currentSituation,
      budgetRange: _extractBudgetRange(stepData) ?? current.budgetRange,
      criticalInfrastructure:
          stepData['criticalInfrastructure'] as List<String>? ??
              current.criticalInfrastructure,
      projectName: stepData['projectName'] as String? ?? current.projectName,
      address: stepData['address'] as String? ?? current.address,
      constructorName:
          stepData['constructorName'] as String? ?? current.constructorName,
      area: stepData['area'] as double? ?? current.area,
      deliveryDate:
          stepData['deliveryDate'] as DateTime? ?? current.deliveryDate,
      contractDate:
          stepData['contractDate'] as DateTime? ?? current.contractDate,
    ));
  }

  String? _extractBudgetRange(Map<String, dynamic> stepData) {
    final totalBudget = stepData['totalBudget'] as double?;
    if (totalBudget == null || totalBudget == 0) return null;

    if (totalBudget < 30000) return 'under_30k';
    if (totalBudget < 50000) return '30k_50k';
    if (totalBudget < 100000) return '50k_100k';
    if (totalBudget < 200000) return '100k_200k';
    return 'over_200k';
  }

  /// Completa o onboarding com os 14 steps
  Future<void> completeOnboarding() async {
    print('🔵 [CUBIT] completeOnboarding iniciado');

    if (state is! OnboardingInProgress) {
      print(
          '❌ [CUBIT] Estado não é OnboardingInProgress: ${state.runtimeType}');
      return;
    }

    final current = state as OnboardingInProgress;
    final data = current.data;

    print('🔵 [CUBIT] Dados do state: ${data.keys.toList()}');

    // Salvar estado para usar depois
    _savedOnboardingState = current;

    emit(OnboardingLoading());

    try {
      print('🔵 [CUBIT] Chamando _generateResultsUseCase...');

      // 1. Gerar resultados do onboarding
      final results = _generateResultsUseCase(current);

      print('✅ [CUBIT] Resultados gerados com sucesso');
      print('  - Alertas: ${results.criticalAlerts.length}');
      print('  - Checklists: ${results.checklistsByRoom.length}');
      print('  - Health Score: ${results.initialHealthScore}');

      // 2. Gerar riscos da reforma
      print('🔵 [CUBIT] Gerando riscos da reforma...');
      final risks = _generateRisksUseCase(current);
      print('✅ [CUBIT] ${risks.length} riscos identificados');

      // 3. Mostrar resultados ao usuário ANTES de salvar
      emit(OnboardingResultsReady(
        nextAction: results.nextAction,
        criticalAlerts: results.criticalAlerts,
        checklistsByRoom: results.checklistsByRoom,
        healthScore: results.initialHealthScore.round(),
        estimatedDuration: results.estimatedDurationDays,
        reformRisks: risks,
      ));

      print('✅ [CUBIT] Estado OnboardingResultsReady emitido');

      // Aguardar confirmação do usuário para continuar
      // A UI deve chamar confirmResults() quando o usuário clicar em "Começar"
    } catch (e, stackTrace) {
      print('❌ [CUBIT] Erro ao completar onboarding: $e');
      print('❌ [CUBIT] StackTrace: $stackTrace');
      emit(OnboardingError('Erro ao completar onboarding: $e'));
    }
  }

  /// Confirma os resultados e salva tudo no Firestore
  Future<void> confirmResults() async {
    print('🔵 [CUBIT] confirmResults iniciado');

    if (state is! OnboardingResultsReady) {
      print(
          '❌ [CUBIT] Estado não é OnboardingResultsReady: ${state.runtimeType}');
      return;
    }

    // ✅ USAR O ESTADO SALVO
    if (_savedOnboardingState == null) {
      print('❌ [CUBIT] Estado salvo não encontrado');
      if (!isClosed) {
        emit(OnboardingError(
            'Estado inválido - dados do onboarding não encontrados'));
      }
      return;
    }

    final current = _savedOnboardingState!;
    final data = current.data;

    print('🔵 [CUBIT] Dados recuperados: ${data.keys.toList()}');

    if (!isClosed) {
      emit(OnboardingLoading());
    }

    try {
      // Gerar resultados novamente (já que perdemos o objeto)
      final results = _generateResultsUseCase(current);

      // 2. Criar projeto
      final projectId = const Uuid().v4();
      final userId = FirebaseAuth.instance.currentUser!.uid;

      final project = ProjectEntity(
        id: projectId,
        userId: userId,
        name: data['projectName'] as String? ?? 'Meu Projeto',
        address: data['address'] as String? ?? 'Não informado',
        constructorName: data['constructorName'] as String? ?? 'Não informado',
        area: data['area'] as double? ?? 50.0,
        deliveryDate: data['deliveryDate'] as DateTime? ??
            DateTime.now().add(const Duration(days: 365)),
        contractDate: data['contractDate'] as DateTime? ?? DateTime.now(),
        totalBudget: _parseBudgetFromRange(current.budgetRange),
        contingencyPercent: 10.0,
        propertyValue: data['propertyValue'] as double?,
        currentSituation: current.currentSituation ?? 'planning',
        createdAt: DateTime.now(),
      );

      final result = await _createProjectUseCase(project);

      await result.fold(
        (failure) async {
          if (!isClosed) {
            emit(OnboardingError(failure.message));
          }
        },
        (createdProject) async {
          // 3. Gerar fases
          final phasesResult = await _generatePhasesUseCase(
            projectId: projectId,
            currentSituation: current.currentSituation ?? 'planning',
          );

          await phasesResult.fold(
            (failure) async {
              if (!isClosed) {
                emit(OnboardingError(failure.message));
              }
            },
            (_) async {
              print('🔵 [CUBIT] Fases geradas com sucesso');

              // 4. Gerar riscos novamente
              print('🔵 [CUBIT] Gerando riscos...');
              final risks = _generateRisksUseCase(current);
              print('🔵 [CUBIT] ${risks.length} riscos gerados');

              // 5. Salvar alertas críticos no Firestore
              print('🔵 [CUBIT] Salvando alertas...');
              await _saveCriticalAlerts(projectId, results.criticalAlerts);

              // 6. Salvar checklists no Firestore
              print('🔵 [CUBIT] Salvando checklists...');
              await _saveChecklists(projectId, results.checklistsByRoom);

              // 7. Salvar riscos da reforma
              print('🔵 [CUBIT] Salvando riscos...');
              await _saveReformRisks(projectId, risks);

              // 8. Salvar próxima ação
              print('🔵 [CUBIT] Salvando próxima ação...');
              await _saveNextAction(projectId, results);

              print('🔵 [CUBIT] Tudo salvo! Emitindo OnboardingCompleted...');
              // Emitir o estado
              try {
                emit(OnboardingCompleted(createdProject));
                print('✅ [CUBIT] OnboardingCompleted emitido!');
              } catch (e) {
                print('❌ [CUBIT] Erro ao emitir estado (cubit fechado): $e');
              }

              // WORKAROUND: Como o cubit pode estar fechado, vamos usar um callback
              // A página de resultados deve passar um callback para navegar
              print(
                  '🔵 [CUBIT] Projeto criado com sucesso: ${createdProject.id}');
            },
          );
        },
      );
    } catch (e) {
      if (!isClosed) {
        emit(OnboardingError('Erro ao salvar projeto: $e'));
      }
    }
  }

  /// Converte faixa de orçamento em valor numérico (usa o máximo da faixa)
  double? _parseBudgetFromRange(String? budgetRange) {
    if (budgetRange == null) return null;

    switch (budgetRange) {
      case 'up_to_20k':
        return 20000;
      case '20k_to_50k':
        return 50000;
      case '50k_to_100k':
        return 100000;
      case '100k_to_200k':
        return 200000;
      case 'above_200k':
        return 200000;
      default:
        return null;
    }
  }

  /// Salva alertas críticos no Firestore
  Future<void> _saveCriticalAlerts(
    String projectId,
    List<dynamic> alerts,
  ) async {
    try {
      final batch = _firestore.batch();

      for (final alert in alerts) {
        final docRef = _firestore
            .collection('projects')
            .doc(projectId)
            .collection('alerts')
            .doc();

        batch.set(docRef, {
          'projectId': projectId, // ✅ ADICIONADO
          'title': alert.title,
          'message': alert.message,
          'phase': alert.phase,
          'priority': alert.priority.toString().split('.').last,
          'tasks': alert.tasks,
          'estimatedCost': alert.estimatedCost,
          'reworkCost': alert.reworkCost,
          'isCompleted': false,
          'createdAt': Timestamp.now(),
        });
      }

      await batch.commit();
      print('✅ [CUBIT] ${alerts.length} alertas salvos com sucesso');
    } catch (e) {
      print('❌ [CUBIT] Erro ao salvar alertas: $e');
      // Não propagar erro - continuar mesmo se falhar
    }
  }

  /// Salva checklists no Firestore
  Future<void> _saveChecklists(
    String projectId,
    Map<String, List<dynamic>> checklistsByRoom,
  ) async {
    try {
      final batch = _firestore.batch();

      checklistsByRoom.forEach((room, items) {
        for (final item in items) {
          final docRef = _firestore
              .collection('projects')
              .doc(projectId)
              .collection('checklists')
              .doc();

          batch.set(docRef, {
            'projectId': projectId, // ✅ ADICIONADO
            'name': item.name,
            'category': item.category,
            'room': room,
            'isCritical': item.isCritical,
            'isCompleted': false,
            'estimatedCost': item.estimatedCost,
            'notes': item.notes,
            'createdAt': Timestamp.now(),
          });
        }
      });

      await batch.commit();
      print('✅ [CUBIT] Checklists salvos com sucesso');
    } catch (e) {
      print('❌ [CUBIT] Erro ao salvar checklists: $e');
    }
  }

  /// Salva próxima ação no projeto
  Future<void> _saveNextAction(
    String projectId,
    OnboardingResultsEntity results,
  ) async {
    try {
      await _firestore.collection('projects').doc(projectId).update({
        'nextAction': results.nextAction,
        'nextActionDescription': results.nextActionDescription,
        'initialHealthScore': results.initialHealthScore,
        'estimatedDurationDays': results.estimatedDurationDays,
      });
    } catch (e) {
      print('Erro ao salvar próxima ação: $e');
    }
  }

  /// Salva riscos da reforma no Firestore
  Future<void> _saveReformRisks(
    String projectId,
    List<ReformRiskEntity> risks,
  ) async {
    try {
      final batch = _firestore.batch();

      for (final risk in risks) {
        final docRef = _firestore
            .collection('projects')
            .doc(projectId)
            .collection('reform_risks')
            .doc();

        batch.set(docRef, {
          'projectId': projectId, // ✅ ADICIONADO
          'title': risk.title,
          'description': risk.description,
          'severity': risk.severity.name,
          'relatedPhaseId': risk.relatedPhaseId,
          'preventionActions': risk.preventionActions,
          'resolved': risk.resolved,
          'createdAt': Timestamp.now(),
        });
      }

      await batch.commit();
      print('✅ [CUBIT] ${risks.length} riscos salvos no Firestore');
    } catch (e) {
      print('❌ [CUBIT] Erro ao salvar riscos: $e');
    }
  }

  /// Completa onboarding retroativo para usuários com obra em andamento
  Future<void> completeRetroactiveOnboarding({
    required String projectName,
    required String address,
    required String constructorName,
    required double area,
    required DateTime deliveryDate,
    required DateTime contractDate,
    required int currentPhaseNumber,
    double? totalSpent,
    List<Map<String, dynamic>>? activeSuppliers,
  }) async {
    emit(OnboardingLoading());

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(OnboardingError('Usuário não autenticado'));
        return;
      }

      // 1. Criar projeto
      final projectId = const Uuid().v4();
      final project = ProjectEntity(
        id: projectId,
        userId: user.uid,
        name: projectName,
        address: address,
        deliveryDate: deliveryDate,
        contractDate: contractDate,
        constructorName: constructorName,
        area: area,
        totalBudget: totalSpent ?? 0.0,
        contingencyPercent: 10.0,
        propertyValue: 0.0,
        currentSituation: 'retroactive_phase_$currentPhaseNumber',
        createdAt: DateTime.now(),
      );

      final createResult = await _createProjectUseCase(project);

      await createResult.fold(
        (failure) async {
          emit(OnboardingError(failure.message));
        },
        (createdProject) async {
          // Aguardar propagação do Firestore para evitar erro de permissão
          await Future.delayed(const Duration(milliseconds: 500));

          // 2. Gerar todas as 12 fases
          final phasesResult = await _generatePhasesUseCase(
            projectId: projectId,
            currentSituation: 'retroactive',
          );

          await phasesResult.fold(
            (failure) async {
              emit(OnboardingError(failure.message));
            },
            (_) async {
              // 3. Marcar fases anteriores como done_no_record
              await _markPreviousPhasesAsDone(projectId, currentPhaseNumber);

              // 4. Criar despesa estimada se informada
              if (totalSpent != null && totalSpent > 0) {
                await _createEstimatedExpense(projectId, totalSpent);
              }

              // 5. Cadastrar fornecedores ativos
              if (activeSuppliers != null && activeSuppliers.isNotEmpty) {
                await _createActiveSuppliers(projectId, activeSuppliers);
              }

              emit(OnboardingCompleted(createdProject));
            },
          );
        },
      );
    } catch (e) {
      emit(OnboardingError('Erro ao criar projeto retroativo: $e'));
    }
  }

  /// Marca fases anteriores à atual como done_no_record
  Future<void> _markPreviousPhasesAsDone(
    String projectId,
    int currentPhaseNumber,
  ) async {
    try {
      // Buscar todas as fases do projeto
      final phasesResult = await _phaseRepository.getPhases(projectId);

      await phasesResult.fold(
        (failure) {
          // Log error but don't fail the whole process
          print('Erro ao buscar fases: ${failure.message}');
        },
        (phases) async {
          // Marcar fases anteriores como done_no_record
          for (final phase in phases) {
            if (phase.number < currentPhaseNumber) {
              final updatedPhase = PhaseEntity(
                id: phase.id,
                projectId: phase.projectId,
                number: phase.number,
                name: phase.name,
                description: phase.description,
                status: PhaseStatus.doneNoRecord,
                startDate: phase.startDate,
                endDate: DateTime.now(),
                estimatedDurationDays: phase.estimatedDurationDays,
                subtasks: phase.subtasks,
                notes: 'Fase concluída antes do cadastro no app',
              );

              await _phaseRepository.updatePhase(updatedPhase);
            }
          }
        },
      );
    } catch (e) {
      print('Erro ao marcar fases anteriores: $e');
    }
  }

  /// Cria despesa estimada com o total gasto até o momento
  Future<void> _createEstimatedExpense(
    String projectId,
    double totalSpent,
  ) async {
    try {
      await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('expenses')
          .add({
        'categoryId': 'geral',
        'amount': totalSpent,
        'date': Timestamp.now(),
        'description': 'Total gasto até o momento (estimativa)',
        'status': 'estimated',
        'supplierId': null,
        'invoicePhotoUrl': null,
        'phaseId': null,
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      print('Erro ao criar despesa estimada: $e');
    }
  }

  /// Cadastra fornecedores ativos informados pelo usuário
  Future<void> _createActiveSuppliers(
    String projectId,
    List<Map<String, dynamic>> suppliers,
  ) async {
    try {
      final batch = _firestore.batch();

      for (final supplier in suppliers) {
        final docRef = _firestore
            .collection('projects')
            .doc(projectId)
            .collection('suppliers')
            .doc();

        batch.set(docRef, {
          'name': supplier['name'] ?? '',
          'type': supplier['type'] ?? 'outro',
          'phone': supplier['phone'] ?? '',
          'email': null,
          'cnpj': null,
          'cpf': null,
          'rating': null,
          'notes': 'Cadastrado via onboarding retroativo',
          'phaseId': null,
          'status': 'active',
          'createdAt': Timestamp.now(),
        });
      }

      await batch.commit();
    } catch (e) {
      print('Erro ao criar fornecedores: $e');
    }
  }
}

// Made with Bob
