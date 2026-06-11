import 'package:injectable/injectable.dart';
import '../../../projects/domain/entities/phase_entity.dart';

/// Serviço de Ordenação Inteligente de Fases
///
/// Responsável por:
/// - Detectar a fase atual automaticamente
/// - Calcular a próxima ação do usuário
/// - Organizar fases em grupos (concluídas, atual, futuras)
/// - Determinar qual tarefa mostrar no hero card
@lazySingleton
class PhaseOrderingService {
  /// Detecta qual é a fase atual do projeto
  ///
  /// Lógica:
  /// 1. Se houver fase com status `inProgress` → é a atual
  /// 2. Se não, primeira fase `notStarted` → é a atual
  /// 3. Se todas `completed` → última fase é a atual
  PhaseEntity? detectCurrentPhase(List<PhaseEntity> phases) {
    if (phases.isEmpty) return null;

    // Ordenar por número
    final sortedPhases = List<PhaseEntity>.from(phases)
      ..sort((a, b) => a.number.compareTo(b.number));

    // 1. Procurar fase em progresso
    final inProgress = sortedPhases
        .where(
          (p) => p.status == PhaseStatus.active,
        )
        .toList();

    if (inProgress.isNotEmpty) {
      return inProgress.first;
    }

    // 2. Procurar primeira fase não iniciada
    final notStarted = sortedPhases
        .where(
          (p) =>
              p.status == PhaseStatus.locked || p.status == PhaseStatus.locked,
        )
        .toList();

    if (notStarted.isNotEmpty) {
      return notStarted.first;
    }

    // 3. Se todas concluídas, retornar a última
    final completed = sortedPhases
        .where(
          (p) => p.status == PhaseStatus.done,
        )
        .toList();

    if (completed.isNotEmpty) {
      return completed.last;
    }

    // Fallback: primeira fase
    return sortedPhases.first;
  }

  /// Calcula a próxima ação que o usuário deve fazer
  ///
  /// Retorna um mapa com:
  /// - title: Título da ação
  /// - description: Descrição opcional
  /// - phaseId: ID da fase relacionada
  /// - phaseName: Nome da fase
  /// - phaseNumber: Número da fase
  /// - subtaskId: ID da subtarefa (se aplicável)
  Map<String, dynamic>? calculateNextAction(List<PhaseEntity> phases) {
    final currentPhase = detectCurrentPhase(phases);
    if (currentPhase == null) return null;

    // Procurar primeira subtarefa não concluída
    final pendingSubtask =
        currentPhase.subtasks.cast<SubtaskEntity>().firstWhere(
              (s) => !s.isDone,
              orElse: () => currentPhase.subtasks.first,
            );

    return {
      'title': pendingSubtask.name,
      'description': _getSubtaskDescription(pendingSubtask),
      'phaseId': currentPhase.id,
      'phaseName': currentPhase.name,
      'phaseNumber': currentPhase.number,
      'subtaskId': pendingSubtask.id,
      'isRequired': pendingSubtask.isRequired,
    };
  }

  /// Organiza as fases em grupos
  ///
  /// Retorna um mapa com:
  /// - completed: Fases concluídas
  /// - current: Fase atual
  /// - upcoming: Fases futuras
  Map<String, dynamic> organizePhasesIntoGroups(List<PhaseEntity> phases) {
    if (phases.isEmpty) {
      return {
        'completed': <PhaseEntity>[],
        'current': null,
        'upcoming': <PhaseEntity>[],
      };
    }

    final currentPhase = detectCurrentPhase(phases);

    // Ordenar por número
    final sortedPhases = List<PhaseEntity>.from(phases)
      ..sort((a, b) => a.number.compareTo(b.number));

    // Separar em grupos
    final completed = sortedPhases
        .where(
          (p) => p.status == PhaseStatus.done && p.id != currentPhase?.id,
        )
        .toList();

    final upcoming = sortedPhases
        .where(
          (p) =>
              (p.status == PhaseStatus.locked ||
                  p.status == PhaseStatus.locked) &&
              p.id != currentPhase?.id,
        )
        .toList();

    return {
      'completed': completed,
      'current': currentPhase,
      'upcoming': upcoming,
    };
  }

  /// Calcula o progresso de uma fase (0.0 a 1.0)
  double calculatePhaseProgress(PhaseEntity phase) {
    if (phase.subtasks.isEmpty) return 0.0;

    final completedCount = phase.subtasks.where((s) => s.isDone).length;
    return completedCount / phase.subtasks.length;
  }

  /// Conta quantas tarefas estão completas em uma fase
  int countCompletedTasks(PhaseEntity phase) {
    return phase.subtasks.where((s) => s.isDone).length;
  }

  /// Conta o total de tarefas em uma fase
  int countTotalTasks(PhaseEntity phase) {
    return phase.subtasks.length;
  }

  /// Verifica se uma fase pode ser iniciada
  ///
  /// Lógica:
  /// - Fase 1 sempre pode ser iniciada
  /// - Demais fases só podem ser iniciadas se a anterior estiver completa
  bool canStartPhase(PhaseEntity phase, List<PhaseEntity> allPhases) {
    // Fase 1 sempre pode iniciar
    if (phase.number == 1) return true;

    // Verificar se fase anterior está completa
    final previousPhase = allPhases.firstWhere(
      (p) => p.number == phase.number - 1,
      orElse: () => phase,
    );

    return previousPhase.status == PhaseStatus.done;
  }

  /// Gera uma descrição contextual para uma subtarefa
  String? _getSubtaskDescription(SubtaskEntity subtask) {
    // Aqui podemos adicionar lógica para gerar descrições contextuais
    // baseadas no tipo de tarefa, fase, etc.

    if (subtask.notes != null && subtask.notes!.isNotEmpty) {
      return subtask.notes;
    }

    // Descrições padrão baseadas em palavras-chave
    final name = subtask.name.toLowerCase();

    if (name.contains('orçamento')) {
      return 'Defina quanto você pode investir na reforma';
    }

    if (name.contains('planta')) {
      return 'Tenha a planta baixa do imóvel em mãos';
    }

    if (name.contains('arquiteto')) {
      return 'Considere contratar um profissional para o projeto';
    }

    if (name.contains('condomínio')) {
      return 'Comunique a administração sobre a reforma';
    }

    if (name.contains('elevador')) {
      return 'Reserve o elevador para transporte de materiais';
    }

    return null;
  }

  /// Determina o ícone apropriado para uma ação
  String getActionIcon(String actionTitle) {
    final title = actionTitle.toLowerCase();

    if (title.contains('orçamento') || title.contains('dinheiro')) {
      return 'attach_money';
    }

    if (title.contains('planta') || title.contains('projeto')) {
      return 'architecture';
    }

    if (title.contains('arquiteto') || title.contains('profissional')) {
      return 'person';
    }

    if (title.contains('condomínio') || title.contains('comunicar')) {
      return 'apartment';
    }

    if (title.contains('elevador')) {
      return 'elevator';
    }

    if (title.contains('comprar') || title.contains('material')) {
      return 'shopping_cart';
    }

    if (title.contains('demolição') || title.contains('remover')) {
      return 'delete_sweep';
    }

    if (title.contains('elétrica') || title.contains('tomada')) {
      return 'electrical_services';
    }

    if (title.contains('hidráulica') || title.contains('água')) {
      return 'plumbing';
    }

    if (title.contains('piso') || title.contains('revestimento')) {
      return 'layers';
    }

    if (title.contains('pintura') || title.contains('pintar')) {
      return 'format_paint';
    }

    if (title.contains('marcenaria') || title.contains('móvel')) {
      return 'chair';
    }

    if (title.contains('limpeza') || title.contains('limpar')) {
      return 'cleaning_services';
    }

    // Ícone padrão
    return 'task_alt';
  }

  /// Calcula quantos dias faltam para completar a fase atual
  /// baseado na data de início e duração estimada
  int? calculateDaysUntilPhaseCompletion(PhaseEntity phase) {
    if (phase.startDate == null) return null;

    final estimatedEndDate = phase.startDate!.add(
      Duration(days: phase.estimatedDurationDays),
    );

    final now = DateTime.now();
    final difference = estimatedEndDate.difference(now).inDays;

    return difference;
  }

  /// Verifica se uma fase está atrasada
  bool isPhaseDelayed(PhaseEntity phase) {
    if (phase.startDate == null) return false;
    if (phase.status == PhaseStatus.done) return false;

    final estimatedEndDate = phase.startDate!.add(
      Duration(days: phase.estimatedDurationDays),
    );

    return DateTime.now().isAfter(estimatedEndDate);
  }

  /// Calcula quantos dias de atraso uma fase tem
  int calculateDelayDays(PhaseEntity phase) {
    if (!isPhaseDelayed(phase)) return 0;

    final estimatedEndDate = phase.startDate!.add(
      Duration(days: phase.estimatedDurationDays),
    );

    return DateTime.now().difference(estimatedEndDate).inDays;
  }
}

// Made with Bob
