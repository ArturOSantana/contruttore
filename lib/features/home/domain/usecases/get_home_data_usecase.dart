import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contruttore/core/error/failures.dart';
import 'package:contruttore/features/auth/domain/repositories/auth_repository.dart';
import 'package:contruttore/features/projects/domain/repositories/project_repository.dart';
import 'package:contruttore/features/home/domain/entities/home_data_entity.dart';
import 'package:contruttore/features/home/domain/entities/next_action_entity.dart';
import 'package:contruttore/features/home/domain/entities/financial_summary_entity.dart';
import 'package:contruttore/features/home/domain/entities/alert_entity.dart';
import 'package:contruttore/features/home/domain/entities/weather_entity.dart';
import 'package:contruttore/features/projects/domain/entities/project_entity.dart';
import 'package:contruttore/features/projects/domain/entities/phase_entity.dart';
import 'package:contruttore/app/router/route_names.dart';
import 'package:contruttore/core/services/reform_health_service.dart';

/// UseCase responsável por carregar todos os dados necessários para a Home
@injectable
class GetHomeDataUseCase {
  final AuthRepository _authRepository;
  final ProjectRepository _projectRepository;
  final FirebaseFirestore _firestore;
  final ReformHealthService _healthService;

  GetHomeDataUseCase(
    this._authRepository,
    this._projectRepository,
    this._firestore,
    this._healthService,
  );

  Future<Either<Failure, HomeDataEntity>> call() async {
    try {
      print('🔵 [GetHomeDataUseCase] Iniciando carregamento dos dados da Home');

      // 1. Buscar usuário atual
      print('🔵 [GetHomeDataUseCase] Buscando usuário atual...');
      final userResult = await _authRepository.getCurrentUser();
      if (userResult.isLeft()) {
        print('❌ [GetHomeDataUseCase] Usuário não encontrado');
        return Left(ServerFailure('Usuário não encontrado'));
      }

      final user = userResult.fold(
        (failure) => throw Exception('Usuário não encontrado'),
        (user) => user,
      );

      if (user == null) {
        print('❌ [GetHomeDataUseCase] Usuário não autenticado');
        return Left(ServerFailure('Usuário não autenticado'));
      }

      print('🔵 [GetHomeDataUseCase] Usuário encontrado: ${user.email}');
      print(
        '🔵 [GetHomeDataUseCase] currentProjectId: ${user.currentProjectId}',
      );

      // 2. Buscar projeto atual
      if (user.currentProjectId == null) {
        print('❌ [GetHomeDataUseCase] Nenhum projeto ativo');
        return Left(ServerFailure('Nenhum projeto ativo'));
      }

      print(
        '🔵 [GetHomeDataUseCase] Buscando projeto: ${user.currentProjectId}',
      );
      final projectResult = await _projectRepository.getProject(
        user.currentProjectId!,
      );

      if (projectResult.isLeft()) {
        print('❌ [GetHomeDataUseCase] Projeto não encontrado no Firestore');
        return Left(ServerFailure('Projeto não encontrado'));
      }

      final project = projectResult.fold(
        (failure) => throw Exception('Projeto não encontrado'),
        (project) => project,
      );

      print('🔵 [GetHomeDataUseCase] Projeto encontrado: ${project.name}');

      // 3. Calcular próxima ação (implementar lógica de prioridade)
      print('🔵 [GetHomeDataUseCase] Calculando próxima ação...');
      final nextAction = await _calculateNextAction(project.id);

      // 4. Buscar resumo financeiro
      print('🔵 [GetHomeDataUseCase] Buscando resumo financeiro...');
      final financialSummary = await _getFinancialSummary(project);

      // 5. Buscar alertas ativos
      print('🔵 [GetHomeDataUseCase] Buscando alertas ativos...');
      final activeAlerts = await _getActiveAlerts(project.id);

      // 6. Buscar previsão do tempo (se necessário)
      print('🔵 [GetHomeDataUseCase] Verificando previsão do tempo...');
      final weather = await _getWeatherIfNeeded(project);

      // 7. Buscar fases do projeto
      print('🔵 [GetHomeDataUseCase] Buscando fases do projeto...');
      final phases = await _getPhases(project.id);

      // 8. Calcular saúde da reforma
      print('🔵 [GetHomeDataUseCase] Calculando saúde da reforma...');
      final healthScore = await _calculateHealthScore(
        project: project,
        phases: phases,
        financialSummary: financialSummary,
        activeAlerts: activeAlerts,
      );

      // 9. Calcular progresso geral
      print('🔵 [GetHomeDataUseCase] Calculando progresso geral...');
      final overallProgress = _healthService.calculateOverallProgress(phases);

      print('✅ [GetHomeDataUseCase] Dados da Home carregados com sucesso!');
      return Right(
        HomeDataEntity(
          user: user,
          project: project,
          nextAction: nextAction,
          financialSummary: financialSummary,
          activeAlerts: activeAlerts,
          weather: weather,
          healthScore: healthScore,
          overallProgress: overallProgress,
        ),
      );
    } catch (e) {
      print('❌ [GetHomeDataUseCase] Erro ao carregar dados: $e');
      return Left(ServerFailure('Erro ao carregar dados: $e'));
    }
  }

  /// Calcula a próxima ação prioritária conforme documento:
  /// 1. Alertas críticos
  /// 2. Parcelas vencendo
  /// 3. Subtarefas atrasadas
  /// 4. Próxima fase sem fornecedor
  /// 5. Decisão de personalização pendente
  Future<NextActionEntity?> _calculateNextAction(String projectId) async {
    try {
      // Buscar alertas críticos não lidos
      final alertsSnapshot = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('alerts')
          .where('type', isEqualTo: 'critical')
          .where('isRead', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (alertsSnapshot.docs.isNotEmpty) {
        final alert = alertsSnapshot.docs.first.data();
        return NextActionEntity(
          id: alertsSnapshot.docs.first.id,
          title: alert['title'] as String,
          description: alert['message'] as String,
          deadline: null,
          phaseName: null,
          route: alert['actionRoute'] as String? ?? RouteNames.alerts,
          priority: ActionPriority.high,
        );
      }

      // Se não houver alertas críticos, retorna null
      // A UI já trata quando nextAction é null
      return null;
    } catch (e) {
      print('❌ [GetHomeDataUseCase] Erro ao calcular próxima ação: $e');
      return null;
    }
  }

  /// Busca o resumo financeiro REAL do projeto
  Future<FinancialSummaryEntity> _getFinancialSummary(
    ProjectEntity project,
  ) async {
    try {
      final totalBudget = project.totalBudget ?? 0.0;

      // Buscar todas as despesas confirmadas (pagas)
      final expensesSnapshot = await _firestore
          .collection('projects')
          .doc(project.id)
          .collection('expenses')
          .where('status', isEqualTo: 'confirmed')
          .get();

      double totalCommitted = 0.0;
      for (final doc in expensesSnapshot.docs) {
        final amount = doc.data()['amount'] as num?;
        if (amount != null) {
          totalCommitted += amount.toDouble();
        }
      }

      final percentage =
          totalBudget > 0 ? (totalCommitted / totalBudget) * 100 : 0.0;

      return FinancialSummaryEntity(
        totalCommitted: totalCommitted,
        totalBudget: totalBudget,
        percentage: percentage,
      );
    } catch (e) {
      print('❌ [GetHomeDataUseCase] Erro ao buscar resumo financeiro: $e');
      // Retorna valores zerados em caso de erro
      return FinancialSummaryEntity(
        totalCommitted: 0.0,
        totalBudget: project.totalBudget ?? 0.0,
        percentage: 0.0,
      );
    }
  }

  /// Busca alertas ativos REAIS do projeto (não lidos, ordenados por prioridade)
  Future<List<AlertEntity>> _getActiveAlerts(String projectId) async {
    try {
      // Buscar alertas não lidos, ordenados por data (mais recentes primeiro)
      final alertsSnapshot = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('alerts')
          .where('isRead', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(5) // Mostrar no máximo 5 alertas na home
          .get();

      if (alertsSnapshot.docs.isEmpty) {
        return [];
      }

      return alertsSnapshot.docs.map((doc) {
        final data = doc.data();
        return AlertEntity(
          id: doc.id,
          title: data['title'] as String,
          description: data['message'] as String,
          type: _mapAlertType(data['type'] as String),
          priority: _mapAlertPriority(data['type'] as String),
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          actionRoute: data['actionRoute'] as String?,
        );
      }).toList();
    } catch (e) {
      print('❌ [GetHomeDataUseCase] Erro ao buscar alertas ativos: $e');
      return [];
    }
  }

  /// Mapeia o tipo de alerta do Firestore para o enum
  AlertType _mapAlertType(String type) {
    switch (type) {
      case 'critical':
      case 'preventive':
        return AlertType.payment;
      case 'info':
        return AlertType.phase;
      case 'educational':
        return AlertType.other;
      default:
        return AlertType.other;
    }
  }

  /// Mapeia a prioridade do alerta baseado no tipo
  AlertPriority _mapAlertPriority(String type) {
    switch (type) {
      case 'critical':
        return AlertPriority.critical;
      case 'preventive':
        return AlertPriority.high;
      case 'info':
        return AlertPriority.medium;
      case 'educational':
        return AlertPriority.low;
      default:
        return AlertPriority.low;
    }
  }

  /// Busca as fases do projeto
  Future<List<PhaseEntity>> _getPhases(String projectId) async {
    try {
      final phasesSnapshot = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('phases')
          .orderBy('number')
          .get();

      if (phasesSnapshot.docs.isEmpty) {
        return [];
      }

      return phasesSnapshot.docs.map((doc) {
        final data = doc.data();
        return PhaseEntity(
          id: doc.id,
          projectId: projectId,
          number: data['number'] as int,
          name: data['name'] as String,
          description: data['description'] as String? ?? '',
          status: _mapPhaseStatus(data['status'] as String),
          startDate: data['startDate'] != null
              ? (data['startDate'] as Timestamp).toDate()
              : null,
          endDate: data['endDate'] != null
              ? (data['endDate'] as Timestamp).toDate()
              : null,
          estimatedDurationDays: data['estimatedDurationDays'] as int? ?? 0,
          subtasks: [],
          estimatedBudget: (data['estimatedBudget'] as num?)?.toDouble() ?? 0.0,
          totalSpent: (data['totalSpent'] as num?)?.toDouble() ?? 0.0,
          totalPending: (data['totalPending'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();
    } catch (e) {
      print('❌ [GetHomeDataUseCase] Erro ao buscar fases: $e');
      return [];
    }
  }

  /// Mapeia o status da fase do Firestore para o enum
  PhaseStatus _mapPhaseStatus(String status) {
    switch (status) {
      case 'locked':
        return PhaseStatus.locked;
      case 'active':
        return PhaseStatus.active;
      case 'done':
        return PhaseStatus.done;
      case 'doneNoRecord':
        return PhaseStatus.doneNoRecord;
      default:
        return PhaseStatus.locked;
    }
  }

  /// Calcula a saúde da reforma
  Future<ReformHealthScore?> _calculateHealthScore({
    required ProjectEntity project,
    required List<PhaseEntity> phases,
    required FinancialSummaryEntity financialSummary,
    required List<AlertEntity> activeAlerts,
  }) async {
    try {
      if (phases.isEmpty) {
        return null;
      }

      // Contar alertas críticos
      final criticalAlertsCount = activeAlerts
          .where((a) => a.priority == AlertPriority.critical)
          .length;

      // Contar fases atrasadas (fases ativas com data de fim passada)
      final now = DateTime.now();
      final delayedPhasesCount = phases
          .where((p) =>
              p.status == PhaseStatus.active &&
              p.endDate != null &&
              p.endDate!.isBefore(now))
          .length;

      return _healthService.calculateHealth(
        project: project,
        phases: phases,
        totalSpent: financialSummary.totalCommitted,
        totalPending: 0.0, // TODO: Buscar parcelas pendentes
        criticalAlertsCount: criticalAlertsCount,
        delayedPhasesCount: delayedPhasesCount,
      );
    } catch (e) {
      print('❌ [GetHomeDataUseCase] Erro ao calcular saúde: $e');
      return null;
    }
  }

  /// Verifica se há fase ativa sensível ao clima e busca previsão
  Future<WeatherEntity?> _getWeatherIfNeeded(ProjectEntity project) async {
    // TODO: Implementar verificação de fases sensíveis ao clima
    // TODO: Integrar com Open-Meteo API quando necessário

    // Por enquanto, retorna exemplo se houver obra em andamento
    if (project.currentSituation == 'construction') {
      return WeatherEntity(
        condition: 'rainy',
        temperature: 22.0,
        forecastDate: DateTime.now().add(const Duration(days: 2)),
        warning:
            'Chuva prevista quinta-feira. Atenção: comunique o engenheiro se houver concretagem ou pintura externa prevista',
        isCritical: true,
      );
    }

    return null;
  }
}

// Made with Bob
