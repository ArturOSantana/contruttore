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
import 'onboarding_state.dart';

@injectable
class OnboardingCubit extends Cubit<OnboardingState> {
  final CreateProjectUseCase _createProjectUseCase;
  final GeneratePhasesUseCase _generatePhasesUseCase;
  final PhaseRepository _phaseRepository;
  final FirebaseFirestore _firestore;

  OnboardingCubit(
    this._createProjectUseCase,
    this._generatePhasesUseCase,
    this._phaseRepository,
    this._firestore,
  ) : super(OnboardingInitial());

  void startOnboarding() {
    emit(OnboardingInProgress(currentStep: 1, data: {}));
  }

  void nextStep(Map<String, dynamic> stepData) {
    if (state is! OnboardingInProgress) return;

    final current = state as OnboardingInProgress;
    final newData = {...current.data, ...stepData};

    if (current.currentStep < 5) {
      emit(
        OnboardingInProgress(
          currentStep: current.currentStep + 1,
          data: newData,
        ),
      );
    }
  }

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

  void updateStepData(Map<String, dynamic> stepData) {
    if (state is! OnboardingInProgress) return;

    final current = state as OnboardingInProgress;
    final newData = {...current.data, ...stepData};

    emit(OnboardingInProgress(currentStep: current.currentStep, data: newData));
  }

  Future<void> completeOnboarding() async {
    if (state is! OnboardingInProgress) return;

    // Salvar os dados ANTES de emitir Loading
    final current = state as OnboardingInProgress;
    final data = current.data;

    emit(OnboardingLoading());

    try {
      // Criar projeto
      final projectId = const Uuid().v4();
      final userId = FirebaseAuth.instance.currentUser!.uid;

      final project = ProjectEntity(
        id: projectId,
        userId: userId,
        name: data['projectName'] as String,
        address: data['address'] as String,
        constructorName: data['constructorName'] as String,
        area: data['area'] as double,
        deliveryDate: data['deliveryDate'] as DateTime,
        contractDate: data['contractDate'] as DateTime,
        totalBudget: data['totalBudget'] as double?,
        contingencyPercent: data['contingencyPercent'] as double? ?? 10.0,
        propertyValue: data['propertyValue'] as double?,
        currentSituation: data['currentSituation'] as String,
        createdAt: DateTime.now(),
      );

      final result = await _createProjectUseCase(project);

      await result.fold(
        (failure) async {
          emit(OnboardingError(failure.message));
        },
        (createdProject) async {
          // Gerar fases
          final phasesResult = await _generatePhasesUseCase(
            projectId: projectId,
            currentSituation: data['currentSituation'] as String,
          );

          phasesResult.fold(
            (failure) => emit(OnboardingError(failure.message)),
            (_) => emit(OnboardingCompleted(createdProject)),
          );
        },
      );
    } catch (e) {
      emit(OnboardingError('Erro ao completar onboarding: $e'));
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
