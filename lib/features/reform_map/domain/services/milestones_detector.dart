import 'package:injectable/injectable.dart';
import '../entities/milestone_entity.dart';
import '../entities/reform_map_entity.dart';
import '../../../projects/domain/entities/phase_entity.dart';

/// Serviço que detecta marcos alcançados na reforma
///
/// Analisa o estado da reforma e identifica quais marcos
/// foram alcançados, estão próximos ou ainda não foram atingidos.
///
/// Exemplo de uso:
/// ```dart
/// final detector = MilestonesDetector();
/// final milestones = detector.detect(reformMap);
/// // Retorna lista de marcos com status atualizado
/// ```
@injectable
class MilestonesDetector {
  /// Detecta todos os marcos e seus status
  List<MilestoneEntity> detect(ReformMapEntity reformMap) {
    final milestones = <MilestoneEntity>[];

    // Detecta marcos de progresso
    milestones.addAll(_detectProgressMilestones(reformMap));

    // Detecta marcos de fases
    milestones.addAll(_detectPhaseMilestones(reformMap));

    // Detecta marcos financeiros
    milestones.addAll(_detectFinancialMilestones(reformMap));

    // Detecta marcos de tempo
    milestones.addAll(_detectTimelineMilestones(reformMap));

    // Detecta marcos especiais
    milestones.addAll(_detectSpecialMilestones(reformMap));

    return milestones;
  }

  /// Detecta apenas marcos alcançados
  List<MilestoneEntity> detectAchieved(ReformMapEntity reformMap) {
    return detect(reformMap).where((m) => m.isAchieved).toList();
  }

  /// Detecta apenas marcos próximos (faltam menos de 10%)
  List<MilestoneEntity> detectNear(ReformMapEntity reformMap) {
    return detect(reformMap).where((m) => m.isNear).toList();
  }

  /// Detecta apenas marcos recentes (últimos 7 dias)
  List<MilestoneEntity> detectRecent(ReformMapEntity reformMap) {
    return detect(reformMap).where((m) => m.isRecent).toList();
  }

  /// Detecta marcos de progresso geral
  List<MilestoneEntity> _detectProgressMilestones(ReformMapEntity reformMap) {
    final progress = reformMap.progress.completedPercentage;
    final milestones = <MilestoneEntity>[];

    // 10% concluído
    milestones.add(MilestoneEntity(
      id: 'progress_10',
      title: 'Primeiros Passos',
      description: '10% da reforma concluída',
      type: MilestoneType.progress,
      isAchieved: progress >= 10,
      achievedAt: progress >= 10 ? DateTime.now() : null,
      celebrationMessage:
          ' Você começou! Os primeiros 10% são sempre os mais difíceis.',
      progressPercentage: progress.round(),
      icon: '',
    ));

    // 25% concluído
    milestones.add(MilestoneEntity(
      id: 'progress_25',
      title: 'Um Quarto do Caminho',
      description: '25% da reforma concluída',
      type: MilestoneType.progress,
      isAchieved: progress >= 25,
      achievedAt: progress >= 25 ? DateTime.now() : null,
      celebrationMessage: ' Você já está em 1/4 da jornada! Continue assim!',
      progressPercentage: progress.round(),
      icon: '',
    ));

    // 50% concluído
    milestones.add(MilestoneEntity(
      id: 'progress_50',
      title: 'Metade da Jornada',
      description: '50% da reforma concluída',
      type: MilestoneType.progress,
      isAchieved: progress >= 50,
      achievedAt: progress >= 50 ? DateTime.now() : null,
      celebrationMessage:
          ' Metade do caminho percorrido! Você está indo muito bem!',
      progressPercentage: progress.round(),
      icon: '',
    ));

    // 75% concluído
    milestones.add(MilestoneEntity(
      id: 'progress_75',
      title: 'Reta Final',
      description: '75% da reforma concluída',
      type: MilestoneType.progress,
      isAchieved: progress >= 75,
      achievedAt: progress >= 75 ? DateTime.now() : null,
      celebrationMessage: ' Falta pouco! Você está na reta final!',
      progressPercentage: progress.round(),
      icon: '',
    ));

    // 90% concluído
    milestones.add(MilestoneEntity(
      id: 'progress_90',
      title: 'Quase Lá',
      description: '90% da reforma concluída',
      type: MilestoneType.progress,
      isAchieved: progress >= 90,
      achievedAt: progress >= 90 ? DateTime.now() : null,
      celebrationMessage: ' Só mais um empurrãozinho! Você está quase lá!',
      progressPercentage: progress.round(),
      icon: '',
    ));

    // 100% concluído
    milestones.add(MilestoneEntity(
      id: 'progress_100',
      title: 'Reforma Concluída',
      description: '100% da reforma finalizada',
      type: MilestoneType.progress,
      isAchieved: progress >= 100,
      achievedAt: progress >= 100 ? DateTime.now() : null,
      celebrationMessage:
          ' PARABÉNS! Você concluiu sua reforma! Hora de aproveitar!',
      progressPercentage: progress.round(),
      icon: '',
    ));

    return milestones;
  }

  /// Detecta marcos de fases específicas
  List<MilestoneEntity> _detectPhaseMilestones(ReformMapEntity reformMap) {
    final milestones = <MilestoneEntity>[];

    // Infraestrutura
    final infrastructurePhase = _findPhaseByName(
      reformMap.phases,
      ['infraestrutura', 'instalações', 'elétrica', 'hidráulica'],
    );
    if (infrastructurePhase != null) {
      milestones.add(MilestoneEntity(
        id: 'phase_infrastructure',
        title: 'Infraestrutura Completa',
        description: 'Elétrica e hidráulica finalizadas',
        type: MilestoneType.phase,
        isAchieved: infrastructurePhase.status == PhaseStatus.done ||
            infrastructurePhase.status == PhaseStatus.doneNoRecord,
        achievedAt: infrastructurePhase.status == PhaseStatus.done ||
                infrastructurePhase.status == PhaseStatus.doneNoRecord
            ? DateTime.now()
            : null,
        celebrationMessage:
            ' A parte mais crítica está pronta! Agora é só embelezar!',
        progressPercentage: infrastructurePhase.progressPercentage.round(),
        icon: '',
      ));
    }

    // Pisos
    final flooringPhase = _findPhaseByName(
      reformMap.phases,
      ['pisos', 'revestimentos', 'porcelanato'],
    );
    if (flooringPhase != null) {
      milestones.add(MilestoneEntity(
        id: 'phase_flooring',
        title: 'Pisos Instalados',
        description: 'Todos os pisos foram colocados',
        type: MilestoneType.phase,
        isAchieved: flooringPhase.status == PhaseStatus.done ||
            flooringPhase.status == PhaseStatus.doneNoRecord,
        achievedAt: flooringPhase.status == PhaseStatus.done ||
                flooringPhase.status == PhaseStatus.doneNoRecord
            ? DateTime.now()
            : null,
        celebrationMessage:
            ' Seus pisos estão lindos! A casa já tem cara de nova!',
        progressPercentage: flooringPhase.progressPercentage.round(),
        icon: '',
      ));
    }

    // Pintura
    final paintingPhase = _findPhaseByName(
      reformMap.phases,
      ['pintura', 'massa corrida'],
    );
    if (paintingPhase != null) {
      milestones.add(MilestoneEntity(
        id: 'phase_painting',
        title: 'Pintura Finalizada',
        description: 'Todas as paredes foram pintadas',
        type: MilestoneType.phase,
        isAchieved: paintingPhase.status == PhaseStatus.done ||
            paintingPhase.status == PhaseStatus.doneNoRecord,
        achievedAt: paintingPhase.status == PhaseStatus.done ||
                paintingPhase.status == PhaseStatus.doneNoRecord
            ? DateTime.now()
            : null,
        celebrationMessage:
            ' As cores deram vida ao ambiente! Ficou incrível!',
        progressPercentage: paintingPhase.progressPercentage.round(),
        icon: '',
      ));
    }

    // Acabamentos
    final finishingPhase = _findPhaseByName(
      reformMap.phases,
      ['acabamentos', 'metais', 'louças'],
    );
    if (finishingPhase != null) {
      milestones.add(MilestoneEntity(
        id: 'phase_finishing',
        title: 'Acabamentos Prontos',
        description: 'Metais, louças e interruptores instalados',
        type: MilestoneType.phase,
        isAchieved: finishingPhase.status == PhaseStatus.done ||
            finishingPhase.status == PhaseStatus.doneNoRecord,
        achievedAt: finishingPhase.status == PhaseStatus.done ||
                finishingPhase.status == PhaseStatus.doneNoRecord
            ? DateTime.now()
            : null,
        celebrationMessage:
            ' Os detalhes fazem toda a diferença! Está ficando perfeito!',
        progressPercentage: finishingPhase.progressPercentage.round(),
        icon: '',
      ));
    }

    // Marcenaria
    final carpentryPhase = _findPhaseByName(
      reformMap.phases,
      ['marcenaria', 'móveis planejados'],
    );
    if (carpentryPhase != null) {
      milestones.add(MilestoneEntity(
        id: 'phase_carpentry',
        title: 'Marcenaria Instalada',
        description: 'Todos os móveis planejados foram colocados',
        type: MilestoneType.phase,
        isAchieved: carpentryPhase.status == PhaseStatus.done ||
            carpentryPhase.status == PhaseStatus.doneNoRecord,
        achievedAt: carpentryPhase.status == PhaseStatus.done ||
                carpentryPhase.status == PhaseStatus.doneNoRecord
            ? DateTime.now()
            : null,
        celebrationMessage:
            ' Seus móveis estão prontos! A casa ganhou funcionalidade!',
        progressPercentage: carpentryPhase.progressPercentage.round(),
        icon: '',
      ));
    }

    return milestones;
  }

  /// Detecta marcos financeiros
  List<MilestoneEntity> _detectFinancialMilestones(ReformMapEntity reformMap) {
    final milestones = <MilestoneEntity>[];
    final percentageSpent = reformMap.financial.percentageSpent;
    final progress = reformMap.progress.completedPercentage;

    // 50% do orçamento utilizado
    milestones.add(MilestoneEntity(
      id: 'financial_50',
      title: 'Metade do Orçamento',
      description: '50% do orçamento utilizado',
      type: MilestoneType.financial,
      isAchieved: percentageSpent >= 50,
      achievedAt: percentageSpent >= 50 ? DateTime.now() : null,
      celebrationMessage:
          ' Você está controlando bem os gastos! Continue assim!',
      progressPercentage: percentageSpent.round(),
      icon: '',
    ));

    // Dentro do orçamento ao finalizar
    final isOnBudget = percentageSpent <= 100 && progress >= 100;
    milestones.add(MilestoneEntity(
      id: 'financial_on_budget',
      title: 'Dentro do Orçamento',
      description: 'Reforma concluída sem estourar o orçamento',
      type: MilestoneType.financial,
      isAchieved: isOnBudget,
      achievedAt: isOnBudget ? DateTime.now() : null,
      celebrationMessage:
          ' Você conseguiu! Reforma completa dentro do orçamento!',
      progressPercentage: percentageSpent.round(),
      icon: '',
    ));

    return milestones;
  }

  /// Detecta marcos de tempo
  List<MilestoneEntity> _detectTimelineMilestones(ReformMapEntity reformMap) {
    final milestones = <MilestoneEntity>[];
    final daysSinceStart =
        DateTime.now().difference(reformMap.lastUpdated).inDays;
    final progress = reformMap.progress.completedPercentage;
    final isDelayed = reformMap.progress.daysDelayed == 0;

    // Primeiro mês
    milestones.add(MilestoneEntity(
      id: 'timeline_first_month',
      title: 'Primeiro Mês',
      description: 'Um mês de reforma',
      type: MilestoneType.timeline,
      isAchieved: daysSinceStart >= 30,
      achievedAt: daysSinceStart >= 30 ? DateTime.now() : null,
      celebrationMessage: ' Um mês se passou! Você está firme na jornada!',
      progressPercentage: progress.round(),
      icon: '',
    ));

    // No prazo
    final isOnSchedule = isDelayed && progress >= 100;
    milestones.add(MilestoneEntity(
      id: 'timeline_on_schedule',
      title: 'No Prazo',
      description: 'Reforma concluída dentro do prazo',
      type: MilestoneType.timeline,
      isAchieved: isOnSchedule,
      achievedAt: isOnSchedule ? DateTime.now() : null,
      celebrationMessage: '⏰ Pontualidade é tudo! Você cumpriu o prazo!',
      progressPercentage: progress.round(),
      icon: '⏰',
    ));

    return milestones;
  }

  /// Detecta marcos especiais
  List<MilestoneEntity> _detectSpecialMilestones(ReformMapEntity reformMap) {
    final milestones = <MilestoneEntity>[];
    final progress = reformMap.progress.completedPercentage;

    // Primeira noite (quando reforma está 100% concluída)
    milestones.add(MilestoneEntity(
      id: 'special_first_night',
      title: 'Primeira Noite',
      description: 'Primeira noite na casa reformada',
      type: MilestoneType.special,
      isAchieved: progress >= 100,
      achievedAt: progress >= 100 ? DateTime.now() : null,
      celebrationMessage:
          ' Que momento especial! Aproveite sua primeira noite no lar renovado!',
      progressPercentage: progress.round(),
      icon: '',
    ));

    // Festa de inauguração
    milestones.add(MilestoneEntity(
      id: 'special_housewarming',
      title: 'Festa de Inauguração',
      description: 'Primeira festa na casa reformada',
      type: MilestoneType.special,
      isAchieved: false, // Usuário deve marcar manualmente
      celebrationMessage: 'Parabéns! Você alcançou este marco!',
      progressPercentage: progress.round(),
      icon: '',
    ));

    return milestones;
  }

  /// Encontra uma fase pelo nome (busca parcial)
  PhaseEntity? _findPhaseByName(
    List<PhaseEntity> phases,
    List<String> keywords,
  ) {
    for (final phase in phases) {
      final phaseName = phase.name.toLowerCase();
      for (final keyword in keywords) {
        if (phaseName.contains(keyword.toLowerCase())) {
          return phase;
        }
      }
    }
    return null;
  }
}

// Made with Bob
