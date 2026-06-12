import 'package:injectable/injectable.dart';
import '../entities/milestone_entity.dart';
import '../entities/reform_map_entity.dart';
import '../entities/problem_entity.dart';
import '../../../projects/domain/entities/phase_entity.dart';
import '../../../shopping/domain/repositories/shopping_repository.dart';
import '../../../installments/domain/repositories/installment_repository.dart';
import '../../../installments/domain/entities/installment_entity.dart';

/// Serviço que detecta marcos alcançados na reforma
///
/// Analisa o estado da reforma e identifica quais marcos
/// foram alcançados, estão próximos ou ainda não foram atingidos.
///
/// Agora integrado com dados reais de compras, parcelas e problemas.
///
/// Exemplo de uso:
/// ```dart
/// final detector = MilestonesDetector(shoppingRepo, installmentRepo, reformMapRepo);
/// final milestones = await detector.detect(reformMap, projectId);
/// // Retorna lista de marcos com status atualizado baseado em dados reais
/// ```
@injectable
class MilestonesDetector {
  final ShoppingRepository _shoppingRepository;
  final InstallmentRepository _installmentRepository;

  MilestonesDetector(
    this._shoppingRepository,
    this._installmentRepository,
  );

  /// Detecta todos os marcos e seus status
  Future<List<MilestoneEntity>> detect(
    ReformMapEntity reformMap,
    String projectId,
  ) async {
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

    // Detecta marcos de conquistas (compras, parcelas)
    milestones.addAll(await _detectAchievementMilestones(projectId));

    // Detecta marcos de qualidade (sem problemas, no prazo)
    milestones.addAll(_detectQualityMilestones(reformMap));

    return milestones;
  }

  /// Detecta apenas marcos alcançados
  Future<List<MilestoneEntity>> detectAchieved(
    ReformMapEntity reformMap,
    String projectId,
  ) async {
    final all = await detect(reformMap, projectId);
    return all.where((m) => m.isAchieved).toList();
  }

  /// Detecta apenas marcos próximos (faltam menos de 10%)
  Future<List<MilestoneEntity>> detectNear(
    ReformMapEntity reformMap,
    String projectId,
  ) async {
    final all = await detect(reformMap, projectId);
    return all.where((m) => m.isNear).toList();
  }

  /// Detecta apenas marcos recentes (últimos 7 dias)
  Future<List<MilestoneEntity>> detectRecent(
    ReformMapEntity reformMap,
    String projectId,
  ) async {
    final all = await detect(reformMap, projectId);
    return all.where((m) => m.isRecent).toList();
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
        celebrationMessage: ' As cores deram vida ao ambiente! Ficou incrível!',
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

  /// Detecta marcos de conquistas (compras, parcelas)
  Future<List<MilestoneEntity>> _detectAchievementMilestones(
    String projectId,
  ) async {
    final milestones = <MilestoneEntity>[];

    // Buscar dados reais
    final shoppingResult =
        await _shoppingRepository.getShoppingItems(projectId);
    final installmentsResult =
        await _installmentRepository.getInstallments(projectId);

    await shoppingResult.fold(
      (failure) async => null,
      (shoppingItems) async {
        final purchasedItems =
            shoppingItems.where((item) => item.isPurchased).toList();
        final totalItems = shoppingItems.length;

        // Primeira compra realizada
        if (purchasedItems.isNotEmpty) {
          milestones.add(MilestoneEntity(
            id: 'achievement_first_purchase',
            title: 'Primeira Compra Realizada',
            description: 'Primeira compra marcada como concluída',
            type: MilestoneType.achievement,
            isAchieved: true,
            achievedAt: purchasedItems.first.purchaseDate,
            celebrationMessage:
                '🛒 Primeira compra feita! A reforma está saindo do papel!',
            progressPercentage: totalItems > 0
                ? (purchasedItems.length / totalItems * 100).round()
                : 0,
            icon: '🛒',
          ));
        }

        // 10 compras realizadas
        if (purchasedItems.length >= 10) {
          milestones.add(MilestoneEntity(
            id: 'achievement_10_purchases',
            title: '10 Compras Realizadas',
            description: '10 itens comprados',
            type: MilestoneType.achievement,
            isAchieved: true,
            achievedAt: purchasedItems.length >= 10
                ? purchasedItems[9].purchaseDate
                : null,
            celebrationMessage:
                '🎯 10 compras realizadas! Você está organizando tudo muito bem!',
            progressPercentage: totalItems > 0
                ? (purchasedItems.length / totalItems * 100).round()
                : 0,
            icon: '🎯',
          ));
        }

        // 50% das compras concluídas
        if (totalItems > 0 && purchasedItems.length >= totalItems / 2) {
          milestones.add(MilestoneEntity(
            id: 'achievement_50_purchases',
            title: '50% das Compras Concluídas',
            description: 'Metade dos itens foram comprados',
            type: MilestoneType.achievement,
            isAchieved: true,
            achievedAt: purchasedItems.length >= totalItems / 2
                ? purchasedItems[(totalItems / 2).floor() - 1].purchaseDate
                : null,
            celebrationMessage: '📦 Metade das compras feitas! Continue assim!',
            progressPercentage:
                (purchasedItems.length / totalItems * 100).round(),
            icon: '📦',
          ));
        }

        // Todas as compras realizadas
        if (totalItems > 0 && purchasedItems.length == totalItems) {
          milestones.add(MilestoneEntity(
            id: 'achievement_all_purchases',
            title: 'Todas as Compras Realizadas',
            description: '100% dos itens comprados',
            type: MilestoneType.achievement,
            isAchieved: true,
            achievedAt: purchasedItems.last.purchaseDate,
            celebrationMessage:
                '✅ Todas as compras concluídas! Tudo pronto para a reforma!',
            progressPercentage: 100,
            icon: '✅',
          ));
        }
      },
    );

    await installmentsResult.fold(
      (failure) async => null,
      (installments) async {
        // Coletar todos os pagamentos pagos de todos os parcelamentos
        final allPaidPayments = <PaymentEntity>[];
        for (final installment in installments) {
          allPaidPayments.addAll(
            installment.payments.where((p) => p.isPaid),
          );
        }

        // Ordenar por data de pagamento (remover nulls primeiro)
        allPaidPayments.removeWhere((p) => p.paidAt == null);
        allPaidPayments.sort((a, b) => a.paidAt!.compareTo(b.paidAt!));

        // Contar total de parcelas
        final totalPayments = installments.fold<int>(
          0,
          (sum, i) => sum + i.totalInstallments,
        );

        // Primeira parcela paga
        if (allPaidPayments.isNotEmpty) {
          milestones.add(MilestoneEntity(
            id: 'achievement_first_payment',
            title: 'Primeira Parcela Paga',
            description: 'Primeira parcela quitada',
            type: MilestoneType.achievement,
            isAchieved: true,
            achievedAt: allPaidPayments.first.paidAt,
            celebrationMessage:
                '💳 Primeira parcela paga! Compromisso cumprido!',
            progressPercentage: totalPayments > 0
                ? (allPaidPayments.length / totalPayments * 100).round()
                : 0,
            icon: '💳',
          ));
        }

        // 50% das parcelas pagas
        if (totalPayments > 0 && allPaidPayments.length >= totalPayments / 2) {
          milestones.add(MilestoneEntity(
            id: 'achievement_50_payments',
            title: '50% das Parcelas Pagas',
            description: 'Metade das parcelas quitadas',
            type: MilestoneType.achievement,
            isAchieved: true,
            achievedAt: allPaidPayments.length >= totalPayments / 2
                ? allPaidPayments[(totalPayments / 2).floor() - 1].paidAt
                : null,
            celebrationMessage:
                '💵 Metade das parcelas pagas! Você está em dia!',
            progressPercentage:
                (allPaidPayments.length / totalPayments * 100).round(),
            icon: '💵',
          ));
        }

        // Todas as parcelas pagas
        if (totalPayments > 0 && allPaidPayments.length == totalPayments) {
          milestones.add(MilestoneEntity(
            id: 'achievement_all_payments',
            title: 'Todas as Parcelas Pagas',
            description: '100% das parcelas quitadas',
            type: MilestoneType.achievement,
            isAchieved: true,
            achievedAt: allPaidPayments.last.paidAt,
            celebrationMessage: '🎉 Todas as parcelas pagas! Reforma quitada!',
            progressPercentage: 100,
            icon: '🎉',
          ));
        }
      },
    );

    return milestones;
  }

  /// Detecta marcos de qualidade (sem problemas, no prazo)
  List<MilestoneEntity> _detectQualityMilestones(ReformMapEntity reformMap) {
    final milestones = <MilestoneEntity>[];
    final progress = reformMap.progress.completedPercentage;
    final percentageSpent = reformMap.financial.percentageSpent;
    final hasNoProblems = reformMap.openProblems.isEmpty;
    final isOnSchedule = reformMap.progress.daysDelayed == 0;

    // Primeira semana sem problemas
    if (hasNoProblems) {
      milestones.add(MilestoneEntity(
        id: 'quality_week_no_problems',
        title: 'Primeira Semana Sem Problemas',
        description: '7 dias sem problemas abertos',
        type: MilestoneType.quality,
        isAchieved: hasNoProblems,
        achievedAt: hasNoProblems ? DateTime.now() : null,
        celebrationMessage:
            '🌟 Uma semana sem problemas! A reforma está fluindo bem!',
        progressPercentage: progress.round(),
        icon: '🌟',
      ));
    }

    // Mês sem atrasos
    if (isOnSchedule && progress >= 30) {
      milestones.add(MilestoneEntity(
        id: 'quality_month_on_schedule',
        title: 'Mês Sem Atrasos',
        description: '30 dias sem atrasos',
        type: MilestoneType.quality,
        isAchieved: true,
        achievedAt: DateTime.now(),
        celebrationMessage:
            '⏰ Um mês no prazo! Você está gerenciando muito bem!',
        progressPercentage: progress.round(),
        icon: '⏰',
      ));
    }

    // Orçamento sob controle (50% da reforma com menos de 55% do orçamento)
    if (progress >= 50 && percentageSpent < 55) {
      milestones.add(MilestoneEntity(
        id: 'quality_budget_control',
        title: 'Orçamento Sob Controle',
        description: '50% da reforma com menos de 55% do orçamento gasto',
        type: MilestoneType.quality,
        isAchieved: true,
        achievedAt: DateTime.now(),
        celebrationMessage:
            '💰 Orçamento sob controle! Você está economizando!',
        progressPercentage: percentageSpent.round(),
        icon: '💰',
      ));
    }

    // Reforma sem problemas graves (100% concluída sem problemas críticos)
    final hadNoCriticalProblems = reformMap.openProblems
        .where((p) => p.severity == ProblemSeverity.critical)
        .isEmpty;
    if (progress >= 100 && hadNoCriticalProblems) {
      milestones.add(MilestoneEntity(
        id: 'quality_no_critical_problems',
        title: 'Reforma Sem Problemas Graves',
        description: 'Nenhum problema crítico durante toda a reforma',
        type: MilestoneType.quality,
        isAchieved: true,
        achievedAt: DateTime.now(),
        celebrationMessage: '🏆 Reforma impecável! Nenhum problema grave!',
        progressPercentage: 100,
        icon: '🏆',
      ));
    }

    return milestones;
  }
}
