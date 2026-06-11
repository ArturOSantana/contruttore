import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../data/services/onboarding_progress_service.dart';
import '../../domain/entities/conversational_onboarding_progress.dart';
import '../../../projects/domain/entities/project_entity.dart';
import '../../../projects/domain/usecases/create_project_usecase.dart';
import '../../../projects/domain/usecases/generate_phases_usecase.dart';
import 'conversational_onboarding_state.dart';

@injectable
class ConversationalOnboardingCubit
    extends Cubit<ConversationalOnboardingState> {
  final OnboardingProgressService _progressService;
  final CreateProjectUseCase _createProjectUseCase;
  final GeneratePhasesUseCase _generatePhasesUseCase;
  final FirebaseFirestore _firestore;

  ConversationalOnboardingProgress? _currentProgress;
  Timer? _autoSaveTimer;
  bool _isGeneratingResults = false; // Flag para evitar múltiplas chamadas
  bool _resultsGenerated =
      false; // Flag para prevenir mudanças após gerar resultados

  ConversationalOnboardingCubit(
    this._progressService,
    this._createProjectUseCase,
    this._generatePhasesUseCase,
    this._firestore,
  ) : super(ConversationalOnboardingInitial());

  /// Inicia o onboarding - verifica se existe progresso salvo
  Future<void> startOnboarding() async {
    _safeEmit(ConversationalOnboardingLoading());

    try {
      final savedProgress = await _progressService.loadProgress();

      if (savedProgress != null) {
        // Tem progresso salvo - perguntar se quer continuar
        final lastUpdate = savedProgress.lastUpdated;
        _safeEmit(ConversationalOnboardingResumePrompt(
          savedProgress: savedProgress,
          lastUpdate: lastUpdate,
        ));
      } else {
        // Começar do zero
        _startFresh();
      }
    } catch (e) {
      _safeEmit(
          ConversationalOnboardingError('Erro ao carregar progresso: $e'));
    }
  }

  /// Continua de onde parou
  void resumeProgress() {
    if (state is ConversationalOnboardingResumePrompt) {
      final resumeState = state as ConversationalOnboardingResumePrompt;
      _currentProgress = resumeState.savedProgress;
      _safeEmit(
          ConversationalOnboardingInProgress(progress: _currentProgress!));
      _startAutoSave();
    }
  }

  /// Começa do zero (descarta progresso salvo)
  void startFresh() {
    _progressService.clearProgress();
    _startFresh();
  }

  void _startFresh() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    _currentProgress = ConversationalOnboardingProgress(
      userId: userId,
      lastUpdated: DateTime.now(),
      currentStepIndex: 0,
    );
    _safeEmit(ConversationalOnboardingInProgress(progress: _currentProgress!));
    _startAutoSave();
  }

  /// Inicia salvamento automático a cada 3 segundos
  void _startAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) {
        // Não salvar se os resultados já foram gerados
        if (!_resultsGenerated) {
          _saveProgress();
        }
      },
    );
  }

  /// Salva o progresso atual
  Future<void> _saveProgress() async {
    // Não salvar se os resultados já foram gerados
    if (_resultsGenerated) {
      print('🔒 _saveProgress bloqueado: resultados já gerados');
      return;
    }

    if (_currentProgress != null) {
      try {
        await _progressService.saveProgress(_currentProgress!);
      } catch (e) {
        print('❌ Erro ao salvar progresso: $e');
      }
    }
  }

  /// Atualiza o momento atual (pergunta mais importante!)
  void updateCurrentMoment(String moment) {
    if (_currentProgress == null || _resultsGenerated) return;

    _currentProgress = _currentProgress!.copyWith(
      currentMoment: moment,
      lastUpdated: DateTime.now(),
      currentStepIndex: _currentProgress!.currentStepIndex + 1,
    );

    _safeEmit(ConversationalOnboardingInProgress(
      progress: _currentProgress!,
      hasUnsavedChanges: true,
    ));
  }

  /// Atualiza quando recebe as chaves (Caminho A)
  void updateKeyDeliveryDate(DateTime date) {
    if (_currentProgress == null || _resultsGenerated) return;

    _currentProgress = _currentProgress!.copyWith(
      keyDeliveryDate: date,
      lastUpdated: DateTime.now(),
      currentStepIndex: _currentProgress!.currentStepIndex + 1,
    );

    _safeEmit(ConversationalOnboardingInProgress(progress: _currentProgress!));
  }

  /// Atualiza intenção de reforma (Caminho A)
  void updateReformIntention(String intention) {
    if (_currentProgress == null || _resultsGenerated) return;

    _currentProgress = _currentProgress!.copyWith(
      reformIntention: intention,
      lastUpdated: DateTime.now(),
      currentStepIndex: _currentProgress!.currentStepIndex + 1,
    );

    _safeEmit(ConversationalOnboardingInProgress(progress: _currentProgress!));
  }

  /// Atualiza itens desejados (Caminho A)
  void updateWantedItems(List<String> items) {
    if (_currentProgress == null || _resultsGenerated) return;

    _currentProgress = _currentProgress!.copyWith(
      wantedItems: items,
      lastUpdated: DateTime.now(),
      currentStepIndex: _currentProgress!.currentStepIndex + 1,
    );

    _safeEmit(ConversationalOnboardingInProgress(progress: _currentProgress!));
  }

  /// Atualiza se apartamento está vazio (Caminho B)
  void updateApartmentEmpty(bool isEmpty) {
    if (_currentProgress == null || _resultsGenerated) return;

    _currentProgress = _currentProgress!.copyWith(
      apartmentEmpty: isEmpty,
      lastUpdated: DateTime.now(),
      currentStepIndex: _currentProgress!.currentStepIndex + 1,
    );

    _safeEmit(ConversationalOnboardingInProgress(progress: _currentProgress!));
  }

  /// Atualiza se contratou alguém (Caminho B)
  void updateHasHiredSomeone(bool hasHired) {
    if (_currentProgress == null || _resultsGenerated) return;

    _currentProgress = _currentProgress!.copyWith(
      hasHiredSomeone: hasHired,
      lastUpdated: DateTime.now(),
      currentStepIndex: _currentProgress!.currentStepIndex + 1,
    );

    _safeEmit(ConversationalOnboardingInProgress(progress: _currentProgress!));
  }

  /// Atualiza se tem projeto (Caminho B)
  void updateHasProject(bool hasProject) {
    if (_currentProgress == null || _resultsGenerated) return;

    _currentProgress = _currentProgress!.copyWith(
      hasProject: hasProject,
      lastUpdated: DateTime.now(),
      currentStepIndex: _currentProgress!.currentStepIndex + 1,
    );

    _safeEmit(ConversationalOnboardingInProgress(progress: _currentProgress!));
  }

  /// Atualiza fases completadas (Caminho C)
  void updateCompletedPhases(List<String> phases) {
    if (_currentProgress == null || _resultsGenerated) return;

    _currentProgress = _currentProgress!.copyWith(
      completedPhases: phases,
      lastUpdated: DateTime.now(),
      currentStepIndex: _currentProgress!.currentStepIndex + 1,
    );

    _safeEmit(ConversationalOnboardingInProgress(progress: _currentProgress!));
  }

  /// Atualiza fase atual (Caminho C)
  void updateCurrentPhase(String phase) {
    if (_currentProgress == null || _resultsGenerated) return;

    _currentProgress = _currentProgress!.copyWith(
      currentPhase: phase,
      lastUpdated: DateTime.now(),
      currentStepIndex: _currentProgress!.currentStepIndex + 1,
    );

    _safeEmit(ConversationalOnboardingInProgress(progress: _currentProgress!));
  }

  /// Atualiza tipo de imóvel
  void updatePropertyType(String type) {
    if (_currentProgress == null || _resultsGenerated) return;

    _currentProgress = _currentProgress!.copyWith(
      propertyType: type,
      lastUpdated: DateTime.now(),
      currentStepIndex: _currentProgress!.currentStepIndex + 1,
    );

    _safeEmit(ConversationalOnboardingInProgress(progress: _currentProgress!));
  }

  /// Atualiza tamanho do imóvel
  void updatePropertySize(String size) {
    if (_currentProgress == null || _resultsGenerated) return;

    _currentProgress = _currentProgress!.copyWith(
      propertySize: size,
      lastUpdated: DateTime.now(),
      currentStepIndex: _currentProgress!.currentStepIndex + 1,
    );

    _safeEmit(ConversationalOnboardingInProgress(progress: _currentProgress!));
  }

  /// Atualiza número de quartos
  void updateBedrooms(int bedrooms) {
    if (_currentProgress == null || _resultsGenerated) return;

    _currentProgress = _currentProgress!.copyWith(
      bedrooms: bedrooms,
      lastUpdated: DateTime.now(),
      currentStepIndex: _currentProgress!.currentStepIndex + 1,
    );

    _safeEmit(ConversationalOnboardingInProgress(progress: _currentProgress!));
  }

  /// Atualiza se tem varanda
  void updateHasBalcony(bool hasBalcony) {
    if (_currentProgress == null || _resultsGenerated) return;

    _currentProgress = _currentProgress!.copyWith(
      hasBalcony: hasBalcony,
      lastUpdated: DateTime.now(),
    );

    _safeEmit(ConversationalOnboardingInProgress(progress: _currentProgress!));
  }

  /// Atualiza se tem suíte
  void updateHasSuite(bool hasSuite) {
    if (_currentProgress == null || _resultsGenerated) return;

    _currentProgress = _currentProgress!.copyWith(
      hasSuite: hasSuite,
      lastUpdated: DateTime.now(),
    );

    _safeEmit(ConversationalOnboardingInProgress(progress: _currentProgress!));
  }

  /// Atualiza quem vai morar
  void updateResidents(String residents) {
    if (_currentProgress == null || _resultsGenerated) return;

    _currentProgress = _currentProgress!.copyWith(
      residents: residents,
      lastUpdated: DateTime.now(),
      currentStepIndex: _currentProgress!.currentStepIndex + 1,
    );

    _safeEmit(ConversationalOnboardingInProgress(progress: _currentProgress!));
  }

  /// Atualiza se tem pets
  void updateHasPets(bool hasPets) {
    if (_currentProgress == null || _resultsGenerated) return;

    _currentProgress = _currentProgress!.copyWith(
      hasPets: hasPets,
      lastUpdated: DateTime.now(),
    );

    _safeEmit(ConversationalOnboardingInProgress(progress: _currentProgress!));
  }

  /// Atualiza se tem home office
  void updateHasHomeOffice(bool hasHomeOffice) {
    if (_currentProgress == null || _resultsGenerated) return;

    _currentProgress = _currentProgress!.copyWith(
      hasHomeOffice: hasHomeOffice,
      lastUpdated: DateTime.now(),
    );

    _safeEmit(ConversationalOnboardingInProgress(progress: _currentProgress!));
  }

  /// Atualiza itens críticos (PERGUNTA MAIS VALIOSA!)
  void updateCriticalItems(List<String> items) {
    if (_currentProgress == null || _resultsGenerated) return;

    _currentProgress = _currentProgress!.copyWith(
      criticalItems: items,
      lastUpdated: DateTime.now(),
      currentStepIndex: _currentProgress!.currentStepIndex + 1,
    );

    _safeEmit(ConversationalOnboardingInProgress(progress: _currentProgress!));
  }

  /// Atualiza prioridade principal
  void updateMainPriority(String priority) {
    if (_currentProgress == null || _resultsGenerated) return;

    _currentProgress = _currentProgress!.copyWith(
      mainPriority: priority,
      lastUpdated: DateTime.now(),
      currentStepIndex: _currentProgress!.currentStepIndex + 1,
    );

    // Não emitir estado aqui - generateResults() vai emitir o estado correto
    print('✅ Prioridade atualizada: $priority');
  }

  /// Atualiza nome do projeto
  void updateProjectName(String name) {
    if (_currentProgress == null || _resultsGenerated) return;

    _currentProgress = _currentProgress!.copyWith(
      projectName: name,
      lastUpdated: DateTime.now(),
      currentStepIndex: _currentProgress!.currentStepIndex + 1,
    );

    _safeEmit(ConversationalOnboardingInProgress(progress: _currentProgress!));
    _saveProgress();
    print('✅ Nome do projeto atualizado: $name');
  }

  /// Atualiza dados básicos do projeto
  void updateProjectBasics({
    String? projectName,
    String? address,
    String? constructorName,
    double? area,
    DateTime? deliveryDate,
    DateTime? contractDate,
    String? budgetRange,
  }) {
    if (_currentProgress == null) return;

    _currentProgress = _currentProgress!.copyWith(
      projectName: projectName ?? _currentProgress!.projectName,
      address: address ?? _currentProgress!.address,
      constructorName: constructorName ?? _currentProgress!.constructorName,
      area: area ?? _currentProgress!.area,
      deliveryDate: deliveryDate ?? _currentProgress!.deliveryDate,
      contractDate: contractDate ?? _currentProgress!.contractDate,
      budgetRange: budgetRange ?? _currentProgress!.budgetRange,
      lastUpdated: DateTime.now(),
    );

    _safeEmit(ConversationalOnboardingInProgress(progress: _currentProgress!));
  }

  /// Gera os resultados do onboarding e retorna os dados diretamente
  Future<Map<String, dynamic>> generateResults() async {
    if (_currentProgress == null) {
      print('❌ Erro: _currentProgress é null');
      throw Exception('Progresso não inicializado');
    }

    // Evitar múltiplas chamadas simultâneas
    if (_isGeneratingResults) {
      print('⚠️ Já está gerando resultados, ignorando chamada duplicada');
      throw Exception('Já está gerando resultados');
    }

    _isGeneratingResults = true;
    print('🔄 Gerando resultados...');

    // Cancelar o auto-save
    _autoSaveTimer?.cancel();
    _resultsGenerated = true;
    print('⏹️ Auto-save cancelado e flag setada');

    try {
      // Gerar resultados baseados nas respostas
      final results = _calculateResults(_currentProgress!);
      print('✅ Resultados calculados e retornados diretamente');

      return results;
    } catch (e, stackTrace) {
      print('❌ Erro ao gerar resultados: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    } finally {
      _isGeneratingResults = false;
    }
  }

  /// Calcula os resultados baseado nas respostas
  Map<String, dynamic> _calculateResults(
      ConversationalOnboardingProgress progress) {
    // Determinar fase atual
    String currentPhase = 'Preparação para Entrega';
    if (progress.currentMoment == 'just_received') {
      currentPhase = 'Planejamento da Reforma';
    } else if (progress.currentMoment == 'planning') {
      currentPhase = 'Planejamento da Reforma';
    } else if (progress.currentMoment == 'work_started') {
      currentPhase = 'Obra em Andamento';
    } else if (progress.currentMoment == 'finishing') {
      currentPhase = 'Acabamentos';
    }

    // Calcular alertas críticos
    final criticalAlerts = <String>[];
    for (final item in progress.criticalItems) {
      switch (item) {
        case 'air_conditioning':
          criticalAlerts.add(
              'Defina os ambientes com ar-condicionado antes do projeto elétrico');
          break;
        case 'wired_internet':
          criticalAlerts
              .add('Planeje os pontos de internet cabeada antes da elétrica');
          break;
        case 'dishwasher':
          criticalAlerts
              .add('Reserve espaço e ponto elétrico para lava-louças');
          break;
        case 'water_heater':
          criticalAlerts.add('Defina tipo de aquecedor antes da hidráulica');
          break;
        case 'automation':
          criticalAlerts.add('Planeje automação antes do projeto elétrico');
          break;
      }
    }

    // Determinar próxima ação
    String nextAction = 'Definir ambientes que receberão ar-condicionado';
    String nextActionDescription =
        'Isso precisa ser decidido antes do projeto elétrico para evitar retrabalho';

    if (progress.criticalItems.isEmpty) {
      nextAction = 'Revisar itens de infraestrutura';
      nextActionDescription =
          'Verifique se não esqueceu nada importante que precisa de planejamento antecipado';
    } else if (progress.currentMoment == 'not_received_keys') {
      nextAction = 'Criar lista de decisões importantes';
      nextActionDescription =
          'Organize tudo que precisa ser decidido antes de receber as chaves';
    }

    // Estimar duração
    int estimatedDays = 120; // 4 meses padrão
    if (progress.reformIntention == 'just_furnish') {
      estimatedDays = 30;
    } else if (progress.reformIntention == 'small_changes') {
      estimatedDays = 60;
    } else if (progress.reformIntention == 'complete_reform') {
      estimatedDays = 180;
    }

    // Estimar orçamento
    double estimatedBudget = 50000;
    if (progress.budgetRange != null) {
      switch (progress.budgetRange) {
        case 'up_to_20k':
          estimatedBudget = 20000;
          break;
        case '20k_to_50k':
          estimatedBudget = 35000;
          break;
        case '50k_to_100k':
          estimatedBudget = 75000;
          break;
        case '100k_to_200k':
          estimatedBudget = 150000;
          break;
        case 'above_200k':
          estimatedBudget = 250000;
          break;
      }
    }

    return {
      'nextAction': nextAction,
      'nextActionDescription': nextActionDescription,
      'criticalAlerts': criticalAlerts,
      'estimatedDurationDays': estimatedDays,
      'estimatedBudget': estimatedBudget,
      'currentPhase': currentPhase,
      'alertsCount': criticalAlerts.length,
    };
  }

  /// Confirma e cria o projeto no Firestore
  Future<void> confirmAndCreateProject() async {
    if (_currentProgress == null) return;

    _safeEmit(ConversationalOnboardingLoading());

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _safeEmit(ConversationalOnboardingError('Usuário não autenticado'));
        return;
      }

      // Criar projeto
      final projectId = const Uuid().v4();
      final project = ProjectEntity(
        id: projectId,
        userId: user.uid,
        name: _currentProgress!.projectName ?? 'Meu Projeto',
        address: _currentProgress!.address ?? 'Não informado',
        constructorName: _currentProgress!.constructorName ?? 'Não informado',
        area: _currentProgress!.area ?? 50.0,
        deliveryDate: _currentProgress!.deliveryDate ??
            DateTime.now().add(const Duration(days: 365)),
        contractDate: _currentProgress!.contractDate ?? DateTime.now(),
        totalBudget: _parseBudgetFromRange(_currentProgress!.budgetRange),
        contingencyPercent: 10.0,
        propertyValue: 0.0,
        currentSituation: _currentProgress!.currentMoment ?? 'planning',
        createdAt: DateTime.now(),
      );

      final result = await _createProjectUseCase(project);

      await result.fold(
        (failure) async {
          _safeEmit(ConversationalOnboardingError(failure.message));
        },
        (createdProject) async {
          // Gerar fases
          final phasesResult = await _generatePhasesUseCase(
            projectId: projectId,
            currentSituation: _currentProgress!.currentMoment ?? 'planning',
          );

          await phasesResult.fold(
            (failure) async {
              _safeEmit(ConversationalOnboardingError(failure.message));
            },
            (_) async {
              // Salvar alertas críticos
              await _saveCriticalAlerts(
                  projectId, _currentProgress!.criticalItems);

              // Limpar progresso salvo
              await _progressService.clearProgress();
              _autoSaveTimer?.cancel();

              _safeEmit(ConversationalOnboardingCompleted(createdProject));
            },
          );
        },
      );
    } catch (e) {
      _safeEmit(ConversationalOnboardingError('Erro ao criar projeto: $e'));
    }
  }

  /// Salva alertas críticos no Firestore
  Future<void> _saveCriticalAlerts(String projectId, List<String> items) async {
    try {
      final batch = _firestore.batch();

      for (final item in items) {
        final alert = _createAlertFromItem(item);
        if (alert != null) {
          final docRef = _firestore
              .collection('projects')
              .doc(projectId)
              .collection('alerts')
              .doc();

          batch.set(docRef, {
            'projectId': projectId,
            'title': alert['title'],
            'message': alert['message'],
            'phase': alert['phase'],
            'priority': 'high',
            'isCompleted': false,
            'createdAt': Timestamp.now(),
          });
        }
      }

      await batch.commit();
    } catch (e) {
      print('❌ Erro ao salvar alertas: $e');
    }
  }

  /// Cria alerta a partir do item crítico
  Map<String, String>? _createAlertFromItem(String item) {
    switch (item) {
      case 'air_conditioning':
        return {
          'title': 'Ar-condicionado',
          'message': 'Defina os ambientes antes do projeto elétrico',
          'phase': 'Projeto Elétrico',
        };
      case 'wired_internet':
        return {
          'title': 'Internet cabeada',
          'message': 'Planeje os pontos antes da elétrica',
          'phase': 'Projeto Elétrico',
        };
      case 'dishwasher':
        return {
          'title': 'Lava-louças',
          'message': 'Reserve espaço e ponto elétrico',
          'phase': 'Projeto Elétrico',
        };
      case 'water_heater':
        return {
          'title': 'Aquecedor',
          'message': 'Defina tipo antes da hidráulica',
          'phase': 'Projeto Hidráulico',
        };
      case 'automation':
        return {
          'title': 'Automação',
          'message': 'Planeje antes do projeto elétrico',
          'phase': 'Projeto Elétrico',
        };
      default:
        return null;
    }
  }

  /// Converte faixa de orçamento em valor
  double _parseBudgetFromRange(String? budgetRange) {
    if (budgetRange == null) return 50000;

    switch (budgetRange) {
      case 'up_to_20k':
        return 20000;
      case '20k_to_50k':
        return 35000;
      case '50k_to_100k':
        return 75000;
      case '100k_to_200k':
        return 150000;
      case 'above_200k':
        return 250000;
      default:
        return 50000;
    }
  }

  /// Volta para o passo anterior
  void previousStep() {
    if (_currentProgress == null) return;

    if (_currentProgress!.currentStepIndex > 0) {
      _currentProgress = _currentProgress!.copyWith(
        currentStepIndex: _currentProgress!.currentStepIndex - 1,
        lastUpdated: DateTime.now(),
      );

      _safeEmit(
          ConversationalOnboardingInProgress(progress: _currentProgress!));
    }
  }

  /// Emite um estado apenas se o Cubit ainda estiver aberto
  void _safeEmit(ConversationalOnboardingState state) {
    if (isClosed) {
      print('🚫 _safeEmit bloqueado: Cubit fechado');
      return;
    }

    // Se os resultados já foram gerados, só permitir emissão de ResultsReady
    if (_resultsGenerated && state is! ConversationalOnboardingResultsReady) {
      print(
          '🚫 _safeEmit bloqueado: resultados já gerados, tentando emitir ${state.runtimeType}');
      return;
    }

    print('📤 _safeEmit: ${state.runtimeType}');
    emit(state);
  }

  @override
  Future<void> close() {
    _autoSaveTimer?.cancel();
    return super.close();
  }
}

// Made with ❤️ by Bob

// Made with Bob
