import 'package:injectable/injectable.dart';
import '../../../financial/domain/entities/transaction_entity.dart';
import '../../../financial/domain/repositories/transaction_repository.dart';
import '../../../shopping/domain/entities/shopping_item_entity.dart';
import '../../../shopping/domain/repositories/shopping_repository.dart';
import '../../../suppliers/domain/entities/supplier_entity.dart';
import '../../../suppliers/domain/repositories/supplier_repository.dart';
import '../../../installments/domain/repositories/installment_repository.dart';
import '../../../installments/domain/entities/installment_entity.dart';
import '../entities/reform_risk_entity.dart';
import '../entities/problem_entity.dart';
import '../entities/next_steps_data.dart';
import '../../../projects/domain/entities/phase_entity.dart';
import '../repositories/reform_map_repository.dart';
import '../../../../core/data/reform_risks_seed_data.dart';

/// Serviço de integração do Mapa da Reforma
///
/// Este serviço conecta automaticamente o Mapa da Reforma com:
/// - Financeiro (transações)
/// - Compras (shopping items)
/// - Fornecedores (suppliers)
/// - Parcelas (installments)
/// - Documentos (documents)
/// - Diário (diary)
/// - Wishlist
/// - Alertas (alerts)
///
/// Sempre que algo acontece em um módulo, este serviço:
/// 1. Atualiza o progresso da etapa
/// 2. Recalcula a saúde da reforma
/// 3. Sugere a próxima ação
/// 4. Gera alertas se necessário
@injectable
class ReformMapIntegrationService {
  final TransactionRepository _transactionRepository;
  final ShoppingRepository _shoppingRepository;
  final SupplierRepository _supplierRepository;
  final InstallmentRepository _installmentRepository;
  final ReformMapRepository _reformMapRepository;

  ReformMapIntegrationService(
    this._transactionRepository,
    this._shoppingRepository,
    this._supplierRepository,
    this._installmentRepository,
    this._reformMapRepository,
  );

  /// Processa uma nova transação financeira
  ///
  /// Quando o usuário adiciona uma despesa:
  /// - Atualiza custo realizado da etapa
  /// - Recalcula saúde (orçamento)
  /// - Verifica se há estouro
  /// - Gera alerta se necessário
  Future<void> onTransactionAdded({
    required String projectId,
    required TransactionEntity transaction,
  }) async {
    // TODO: Implementar lógica de integração
    // 1. Buscar etapa relacionada (transaction.phaseId)
    // 2. Atualizar custo realizado
    // 3. Recalcular saúde
    // 4. Verificar se estourou orçamento
    // 5. Gerar alerta se necessário
  }

  /// Processa uma compra realizada
  ///
  /// Quando o usuário marca item como comprado:
  /// - Marca checklist da etapa
  /// - Atualiza progresso
  /// - Sugere próxima compra
  /// - Verifica riscos relacionados
  Future<void> onShoppingItemPurchased({
    required String projectId,
    required ShoppingItemEntity item,
  }) async {
    // TODO: Implementar lógica de integração
    // 1. Buscar etapa relacionada (item.phaseId)
    // 2. Marcar item do checklist
    // 3. Atualizar progresso
    // 4. Sugerir próxima compra
    // 5. Verificar riscos (ex: comprou 10% a mais?)
  }

  /// Processa contratação de fornecedor
  ///
  /// Quando o usuário contrata um profissional:
  /// - Marca checklist da etapa
  /// - Atualiza progresso
  /// - Cria compromisso financeiro
  /// - Sugere próxima ação
  Future<void> onSupplierHired({
    required String projectId,
    required SupplierEntity supplier,
  }) async {
    // TODO: Implementar lógica de integração
    // 1. Buscar etapa relacionada (supplier.phaseId)
    // 2. Marcar "contratar profissional" no checklist
    // 3. Criar commitment no financeiro
    // 4. Atualizar progresso
    // 5. Sugerir próxima ação
  }

  /// Processa conclusão de etapa
  ///
  /// Quando o usuário conclui uma etapa:
  /// - Marca etapa como concluída
  /// - Ativa próxima etapa
  /// - Gera riscos da próxima etapa
  /// - Sugere preparação
  /// - Registra no diário
  Future<void> onPhaseCompleted({
    required String projectId,
    required String phaseId,
  }) async {
    // TODO: Implementar lógica de integração
    // 1. Marcar etapa como concluída
    // 2. Ativar próxima etapa
    // 3. Gerar riscos da próxima etapa
    // 4. Sugerir preparação
    // 5. Registrar no diário
  }

  /// Gera riscos automaticamente para uma etapa
  ///
  /// Quando uma etapa é iniciada:
  /// - Busca riscos do seed data
  /// - Filtra por contexto do projeto
  /// - Cria alertas preventivos
  /// - Sugere ações de prevenção
  Future<List<ReformRiskEntity>> generateRisksForPhase({
    required String projectId,
    required String phaseId,
    required String phaseName,
  }) async {
    // Busca riscos do seed data
    final risks = ReformRisksSeedData.getRisksForPhase(phaseId, phaseName);

    // TODO: Filtrar por contexto do projeto
    // Ex: Se não tem ar-condicionado, não mostrar risco de dreno

    // TODO: Criar alertas no módulo de alertas

    return risks;
  }

  /// Busca próximos passos COM DADOS REAIS
  ///
  /// Retorna lista completa de:
  /// - Próxima ação prioritária
  /// - Tarefas pendentes da etapa atual
  /// - Prazos próximos
  /// - Compras necessárias
  /// - Pagamentos próximos
  Future<NextStepsData> getNextStepsWithRealData({
    required String projectId,
  }) async {
    final nextSteps = <String>[];
    final pendingTasks = <PendingTask>[];
    final upcomingDeadlines = <Deadline>[];
    String? nextAction;

    // 1. Buscar mapa da reforma
    final reformMapResult = await _reformMapRepository.getReformMap(projectId);

    await reformMapResult.fold(
      (failure) async {},
      (reformMap) async {
        // Encontrar fase ativa
        final activePhase = reformMap.phases.firstWhere(
          (p) => p.status == PhaseStatus.active,
          orElse: () => reformMap.phases.first,
        );

        // 2. Buscar tarefas pendentes da fase ativa
        for (final subtask in activePhase.subtasks) {
          if (!subtask.isDone) {
            pendingTasks.add(PendingTask(
              id: subtask.id,
              name: subtask.name,
              phaseName: activePhase.name,
              isRequired: subtask.isRequired,
              priority: subtask.isRequired ? 'Alta' : 'Média',
            ));
          }
        }

        // 3. Verificar problemas críticos
        final criticalProblems = reformMap.problems
            .where((p) =>
                p.severity == ProblemSeverity.critical &&
                p.status != ProblemStatus.resolved)
            .toList();

        if (criticalProblems.isNotEmpty) {
          nextAction =
              'Resolver problema crítico: ${criticalProblems.first.title}';
          nextSteps.add(' ${criticalProblems.first.title}');
        }

        // 4. Calcular prazo da fase ativa
        if (activePhase.endDate != null) {
          final daysRemaining =
              activePhase.endDate!.difference(DateTime.now()).inDays;
          upcomingDeadlines.add(Deadline(
            title: 'Conclusão: ${activePhase.name}',
            date: activePhase.endDate!,
            daysRemaining: daysRemaining,
            isOverdue: daysRemaining < 0,
          ));
        }
      },
    );

    // 5. Buscar parcelas próximas
    final installmentsResult =
        await _installmentRepository.getInstallments(projectId);
    await installmentsResult.fold(
      (failure) async {},
      (installments) async {
        final now = DateTime.now();
        final next30Days = now.add(Duration(days: 30));

        for (final installment in installments) {
          for (final payment in installment.payments) {
            if (!payment.isPaid &&
                payment.dueDate.isAfter(now) &&
                payment.dueDate.isBefore(next30Days)) {
              final daysUntil = payment.dueDate.difference(now).inDays;
              upcomingDeadlines.add(Deadline(
                title: 'Pagamento: ${installment.serviceDescription}',
                date: payment.dueDate,
                daysRemaining: daysUntil,
                isOverdue: false,
                amount: payment.amount,
              ));

              if (daysUntil <= 7) {
                nextSteps.add(
                    ' Pagar ${installment.serviceDescription} em $daysUntil dias');
              }
            }
          }
        }
      },
    );

    // 6. Buscar compras pendentes
    final shoppingResult =
        await _shoppingRepository.getShoppingItems(projectId);
    await shoppingResult.fold(
      (failure) async {},
      (items) async {
        final pendingItems =
            items.where((i) => !i.isPurchased).take(5).toList();
        for (final item in pendingItems) {
          nextSteps.add(' Comprar: ${item.name}');
        }
      },
    );

    // 7. Definir próxima ação se ainda não foi definida
    if (nextAction == null) {
      if (pendingTasks.isNotEmpty) {
        final firstRequired = pendingTasks.firstWhere(
          (t) => t.isRequired,
          orElse: () => pendingTasks.first,
        );
        nextAction = firstRequired.name;
      } else {
        nextAction = 'Revisar progresso da reforma';
      }
    }

    // Ordenar prazos por data
    upcomingDeadlines.sort((a, b) => a.date.compareTo(b.date));

    return NextStepsData(
      nextAction: nextAction ?? 'Nenhuma ação pendente no momento',
      pendingTasks: pendingTasks,
      upcomingDeadlines: upcomingDeadlines,
      nextSteps: nextSteps.take(10).toList(),
    );
  }

  /// Calcula próxima ação inteligente (versão simplificada)
  Future<String> calculateNextAction({
    required String projectId,
    String? currentPhaseId,
    List<String>? pendingChecklistItems,
    List<String>? criticalProblems,
    bool? hasOverduePayments,
    bool? needsBudgetReview,
  }) async {
    // Prioridade 1: Problemas críticos
    if (criticalProblems != null && criticalProblems.isNotEmpty) {
      return 'Resolver problema crítico: ${criticalProblems.first}';
    }

    // Prioridade 2: Pagamentos vencidos
    if (hasOverduePayments == true) {
      return 'Regularizar pagamentos em atraso';
    }

    // Prioridade 3: Revisão de orçamento
    if (needsBudgetReview == true) {
      return 'Revisar orçamento da reforma';
    }

    // Prioridade 4: Checklist pendente da etapa atual
    if (pendingChecklistItems != null && pendingChecklistItems.isNotEmpty) {
      return pendingChecklistItems.first;
    }

    // Prioridade 5: Ações baseadas na etapa atual
    if (currentPhaseId != null) {
      switch (currentPhaseId) {
        case 'planejamento':
          return 'Definir orçamento total da reforma';
        case 'aprovacoes':
          return 'Comunicar condomínio sobre início da obra';
        case 'infraestrutura':
          return 'Definir pontos de tomada e interruptores';
        case 'revestimentos':
          return 'Escolher pisos e revestimentos';
        case 'forros':
          return 'Definir tipo de forro (gesso ou drywall)';
        case 'pintura':
          return 'Escolher cores e tipo de tinta';
        case 'acabamentos':
          return 'Comprar louças e metais';
        case 'marcenaria':
          return 'Fazer medição final para marcenaria';
        case 'mudanca':
          return 'Agendar limpeza pós-obra';
        default:
          return 'Revisar progresso da reforma';
      }
    }

    // Ação padrão
    return 'Revisar o mapa da reforma';
  }

  /// Calcula saúde da reforma COM DADOS REAIS
  ///
  /// Busca dados dos repositórios e calcula score baseado em:
  /// - Atraso no prazo (0-30 pontos)
  /// - Estouro de orçamento (0-30 pontos)
  /// - Problemas abertos (0-20 pontos)
  /// - Tarefas pendentes (0-10 pontos)
  /// - Parcelas vencidas (0-10 pontos)
  ///
  /// Score: 0-100
  Future<int> calculateHealthWithRealData({
    required String projectId,
    DateTime? estimatedEndDate,
    double? totalBudget,
  }) async {
    int score = 100;

    // 1. Buscar dados reais do financeiro
    final transactionsResult =
        await _transactionRepository.getTransactions(projectId);
    double spentAmount = 0;
    transactionsResult.fold(
      (failure) => spentAmount = 0,
      (transactions) {
        spentAmount = transactions
            .where((t) => t.type == TransactionType.expense)
            .fold(0.0, (sum, t) => sum + t.signedAmount.abs());
      },
    );

    // 2. Buscar dados do mapa da reforma (problemas e tarefas)
    final reformMapResult = await _reformMapRepository.getReformMap(projectId);
    int openProblemsCount = 0;
    int pendingTasksCount = 0;

    reformMapResult.fold(
      (failure) {
        openProblemsCount = 0;
        pendingTasksCount = 0;
      },
      (reformMap) {
        // Contar problemas não resolvidos
        openProblemsCount = reformMap.problems
            .where((p) => p.status != ProblemStatus.resolved)
            .length;

        // Contar tarefas pendentes de todas as fases ativas
        for (final phase in reformMap.phases) {
          if (phase.status == PhaseStatus.active) {
            pendingTasksCount +=
                phase.subtasks.where((task) => !task.isDone).length;
          }
        }
      },
    );

    // 3. Buscar parcelas vencidas
    final installmentsResult =
        await _installmentRepository.getInstallments(projectId);
    int overdueInstallmentsCount = 0;
    installmentsResult.fold(
      (failure) => overdueInstallmentsCount = 0,
      (installments) {
        final now = DateTime.now();
        for (final installment in installments) {
          for (final payment in installment.payments) {
            if (!payment.isPaid && payment.dueDate.isBefore(now)) {
              overdueInstallmentsCount++;
            }
          }
        }
      },
    );

    // Calcular score
    return _calculateScore(
      estimatedEndDate: estimatedEndDate,
      totalBudget: totalBudget,
      spentAmount: spentAmount,
      openProblemsCount: openProblemsCount,
      pendingTasksCount: pendingTasksCount,
      overdueInstallmentsCount: overdueInstallmentsCount,
    );
  }

  /// Calcula saúde da reforma (versão com parâmetros)
  ///
  /// Use esta versão quando já tiver os dados calculados
  Future<int> calculateHealth({
    required String projectId,
    DateTime? estimatedEndDate,
    double? totalBudget,
    double? spentAmount,
    int? openProblemsCount,
    int? pendingTasksCount,
    int? overdueInstallmentsCount,
  }) async {
    return _calculateScore(
      estimatedEndDate: estimatedEndDate,
      totalBudget: totalBudget,
      spentAmount: spentAmount,
      openProblemsCount: openProblemsCount,
      pendingTasksCount: pendingTasksCount,
      overdueInstallmentsCount: overdueInstallmentsCount,
    );
  }

  /// Método privado que faz o cálculo do score
  int _calculateScore({
    DateTime? estimatedEndDate,
    double? totalBudget,
    double? spentAmount,
    int? openProblemsCount,
    int? pendingTasksCount,
    int? overdueInstallmentsCount,
  }) {
    int score = 100;

    // 1. Verificar atraso no prazo (0-30 pontos)
    if (estimatedEndDate != null) {
      final now = DateTime.now();
      if (now.isAfter(estimatedEndDate)) {
        final daysLate = now.difference(estimatedEndDate).inDays;
        if (daysLate > 60) {
          score -= 30;
        } else if (daysLate > 30) {
          score -= 20;
        } else if (daysLate > 15) {
          score -= 10;
        } else {
          score -= 5;
        }
      }
    }

    // 2. Verificar estouro de orçamento (0-30 pontos)
    if (totalBudget != null && spentAmount != null && totalBudget > 0) {
      final percentage = (spentAmount / totalBudget);
      if (percentage > 1.2) {
        score -= 30;
      } else if (percentage > 1.1) {
        score -= 20;
      } else if (percentage > 1.0) {
        score -= 10;
      } else if (percentage > 0.9) {
        score -= 5;
      }
    }

    // 3. Contar problemas abertos (0-20 pontos)
    if (openProblemsCount != null) {
      if (openProblemsCount > 10) {
        score -= 20;
      } else if (openProblemsCount > 5) {
        score -= 15;
      } else if (openProblemsCount > 2) {
        score -= 10;
      } else if (openProblemsCount > 0) {
        score -= 5;
      }
    }

    // 4. Contar tarefas pendentes (0-10 pontos)
    if (pendingTasksCount != null) {
      if (pendingTasksCount > 20) {
        score -= 10;
      } else if (pendingTasksCount > 10) {
        score -= 7;
      } else if (pendingTasksCount > 5) {
        score -= 5;
      } else if (pendingTasksCount > 0) {
        score -= 2;
      }
    }

    // 5. Verificar parcelas vencidas (0-10 pontos)
    if (overdueInstallmentsCount != null) {
      if (overdueInstallmentsCount > 5) {
        score -= 10;
      } else if (overdueInstallmentsCount > 2) {
        score -= 7;
      } else if (overdueInstallmentsCount > 0) {
        score -= 5;
      }
    }

    return score.clamp(0, 100);
  }

  /// Verifica se deve gerar alerta
  ///
  /// Exemplos:
  /// - Ar-condicionado sem infraestrutura
  /// - Lava-louças sem pontos
  /// - Medição antes dos acabamentos
  /// - Poucas tomadas
  Future<List<String>> checkAlerts({
    required String projectId,
    required String phaseId,
  }) async {
    final alerts = <String>[];

    // TODO: Implementar verificações
    // 1. Verificar riscos da etapa
    // 2. Verificar contexto do projeto
    // 3. Gerar alertas personalizados

    return alerts;
  }

  /// Sugere compras para a etapa
  ///
  /// Baseado no seed data de cada etapa
  Future<List<String>> suggestPurchases({
    required String projectId,
    required String phaseId,
  }) async {
    // TODO: Buscar do seed data
    // Retornar lista de compras sugeridas

    return [];
  }

  /// Sugere profissionais para a etapa
  ///
  /// Baseado no seed data de cada etapa
  Future<List<String>> suggestProfessionals({
    required String projectId,
    required String phaseId,
  }) async {
    // TODO: Buscar do seed data
    // Retornar lista de profissionais sugeridos

    return [];
  }

  /// Sugere documentos para a etapa
  ///
  /// Baseado no seed data de cada etapa
  Future<List<String>> suggestDocuments({
    required String projectId,
    required String phaseId,
  }) async {
    // TODO: Buscar do seed data
    // Retornar lista de documentos esperados

    return [];
  }

  /// Registra evento no diário automaticamente
  ///
  /// Sempre que algo importante acontece:
  /// - Etapa iniciada
  /// - Etapa concluída
  /// - Profissional contratado
  /// - Compra realizada
  /// - Problema reportado
  Future<void> logToDiary({
    required String projectId,
    required String phaseId,
    required String event,
    String? notes,
  }) async {
    // TODO: Integrar com módulo de diário
    // Criar entrada automática
  }

  /// Atualiza progresso da etapa
  ///
  /// Calcula baseado em:
  /// - Checklist concluído
  /// - Compras realizadas
  /// - Profissionais contratados
  /// - Documentos salvos
  Future<double> calculatePhaseProgress({
    required String projectId,
    required String phaseId,
  }) async {
    // TODO: Implementar cálculo
    // 1. Contar itens do checklist
    // 2. Contar itens concluídos
    // 3. Calcular porcentagem

    return 0.0;
  }

  /// Verifica se etapa pode ser iniciada
  ///
  /// Algumas etapas dependem de outras
  /// Ex: Não pode pintar antes do gesso
  Future<bool> canStartPhase({
    required String projectId,
    required String phaseId,
  }) async {
    // TODO: Implementar verificação de dependências
    // 1. Verificar etapas anteriores
    // 2. Verificar pré-requisitos

    return true;
  }

  /// Verifica se etapa pode ser concluída
  ///
  /// Valida se todos os itens obrigatórios foram feitos
  Future<bool> canCompletePhase({
    required String projectId,
    required String phaseId,
  }) async {
    // TODO: Implementar validação
    // 1. Verificar checklist obrigatório
    // 2. Verificar documentos obrigatórios
    // 3. Verificar profissionais obrigatórios

    return true;
  }
}

// Made with Bob
