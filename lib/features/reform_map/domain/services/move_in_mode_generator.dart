import 'package:injectable/injectable.dart';
import '../../../projects/domain/entities/phase_entity.dart';
import '../../../shopping/domain/repositories/shopping_repository.dart';
import '../../../installments/domain/repositories/installment_repository.dart';
import '../../../problems/domain/repositories/problem_repository.dart';
import '../entities/move_in_mode_entity.dart';

/// Serviço que gera o Modo Mudança
///
/// Ativa quando a reforma está próxima da conclusão
/// e gera checklist de preparação para mudança
///
/// Agora integrado com dados reais de compras, parcelas e problemas
@injectable
class MoveInModeGenerator {
  final ShoppingRepository _shoppingRepository;
  final InstallmentRepository _installmentRepository;
  final ProblemRepository _problemRepository;

  MoveInModeGenerator(
    this._shoppingRepository,
    this._installmentRepository,
    this._problemRepository,
  );

  /// Gera o modo mudança baseado no estado da reforma
  Future<MoveInModeEntity> generate({
    required String projectId,
    required List<PhaseEntity> phases,
    required double overallProgress,
    DateTime? plannedMoveInDate,
    List<String> userCriticalItems = const [],
  }) async {
    // Detecta pendências reais
    final criticalPendingItems = await _detectRealPendingItems(projectId);
    // Calcula dias até a mudança
    final now = DateTime.now();
    final moveInDate = plannedMoveInDate ?? _estimateMoveInDate(phases, now);
    final daysUntilMoveIn = moveInDate.difference(now).inDays;

    // Determina se o modo está ativo
    // Ativa quando: progresso >= 80% OU faltam <= 90 dias (3 meses)
    final isActive = overallProgress >= 80 || daysUntilMoveIn <= 90;

    // Gera tarefas de preparação
    final tasks = _generateTasks(
      phases: phases,
      daysUntilMoveIn: daysUntilMoveIn,
      overallProgress: overallProgress,
      userCriticalItems: userCriticalItems,
    );

    // Gera recomendações
    final recommendations = _generateRecommendations(
      daysUntilMoveIn: daysUntilMoveIn,
      overallProgress: overallProgress,
      criticalPendingItems: criticalPendingItems,
    );

    // Determina status
    final status = _determineStatus(
      overallProgress: overallProgress,
      criticalPendingItems: criticalPendingItems,
      daysUntilMoveIn: daysUntilMoveIn,
      tasks: tasks,
    );

    return MoveInModeEntity(
      isActive: isActive,
      daysUntilMoveIn: daysUntilMoveIn,
      moveInDate: moveInDate,
      overallProgress: overallProgress,
      tasks: tasks,
      criticalPendingItems: criticalPendingItems,
      recommendations: recommendations,
      status: status,
    );
  }

  /// Estima data de mudança baseada nas fases
  DateTime _estimateMoveInDate(List<PhaseEntity> phases, DateTime now) {
    // Pega a última fase
    if (phases.isEmpty) {
      return now.add(const Duration(days: 90)); // 3 meses padrão
    }

    final lastPhase = phases.last;

    // Se tem data de fim, usa ela + 7 dias
    if (lastPhase.endDate != null) {
      return lastPhase.endDate!.add(const Duration(days: 7));
    }

    // Senão, estima baseado no progresso
    final remainingProgress = 100 - lastPhase.progressPercentage;
    final estimatedDays = (remainingProgress * 0.5).round(); // 0.5 dia por %

    return now.add(Duration(days: estimatedDays));
  }

  /// Gera lista de tarefas de preparação
  List<MoveInTaskEntity> _generateTasks({
    required List<PhaseEntity> phases,
    required int daysUntilMoveIn,
    required double overallProgress,
    List<String> userCriticalItems = const [],
  }) {
    final tasks = <MoveInTaskEntity>[];

    // Adiciona tarefas personalizadas baseadas nos itens críticos do usuário
    tasks
        .addAll(_generatePersonalizedTasks(userCriticalItems, daysUntilMoveIn));
    // ESSENCIAIS - Itens básicos para morar (PRIORIDADE MÁXIMA)
    if (daysUntilMoveIn <= 60) {
      // 2 meses antes
      tasks.add(
        MoveInTaskEntity(
          id: 'essentials_1',
          title: 'Comprar cama e colchão',
          description: 'Item essencial para o primeiro dia',
          category: MoveInTaskCategory.essentials,
          isCompleted: false,
          isCritical: true,
          dueDate: DateTime.now().add(Duration(days: daysUntilMoveIn - 30)),
        ),
      );

      tasks.add(
        MoveInTaskEntity(
          id: 'essentials_2',
          title: 'Comprar geladeira',
          description: 'Essencial para conservar alimentos',
          category: MoveInTaskCategory.essentials,
          isCompleted: false,
          isCritical: true,
          dueDate: DateTime.now().add(Duration(days: daysUntilMoveIn - 25)),
        ),
      );

      tasks.add(
        MoveInTaskEntity(
          id: 'essentials_3',
          title: 'Comprar fogão',
          description: 'Necessário para preparar refeições',
          category: MoveInTaskCategory.essentials,
          isCompleted: false,
          isCritical: true,
          dueDate: DateTime.now().add(Duration(days: daysUntilMoveIn - 25)),
        ),
      );

      tasks.add(
        MoveInTaskEntity(
          id: 'essentials_4',
          title: 'Comprar máquina de lavar',
          description: 'Importante para o dia a dia',
          category: MoveInTaskCategory.essentials,
          isCompleted: false,
          isCritical: false,
          dueDate: DateTime.now().add(Duration(days: daysUntilMoveIn - 20)),
        ),
      );

      tasks.add(
        MoveInTaskEntity(
          id: 'essentials_5',
          title: 'Comprar micro-ondas',
          description: 'Facilita o preparo de refeições',
          category: MoveInTaskCategory.essentials,
          isCompleted: false,
          isCritical: false,
          dueDate: DateTime.now().add(Duration(days: daysUntilMoveIn - 15)),
        ),
      );

      tasks.add(
        MoveInTaskEntity(
          id: 'essentials_6',
          title: 'Comprar chuveiro elétrico',
          description: 'Se não tiver aquecedor a gás',
          category: MoveInTaskCategory.essentials,
          isCompleted: false,
          isCritical: false,
          dueDate: DateTime.now().add(Duration(days: daysUntilMoveIn - 20)),
        ),
      );
    }

    // SERVIÇOS - Água, Luz, Gás, Internet (CRÍTICO)
    if (daysUntilMoveIn <= 45) {
      // 1.5 mês antes
      tasks.add(
        MoveInTaskEntity(
          id: 'utilities_water',
          title: 'Transferir conta de água',
          description: 'Transferir para seu nome ou solicitar nova ligação',
          category: MoveInTaskCategory.utilities,
          isCompleted: false,
          isCritical: true,
          dueDate: DateTime.now().add(Duration(days: daysUntilMoveIn - 30)),
        ),
      );

      tasks.add(
        MoveInTaskEntity(
          id: 'utilities_power',
          title: 'Transferir conta de luz',
          description: 'Transferir para seu nome ou solicitar nova ligação',
          category: MoveInTaskCategory.utilities,
          isCompleted: false,
          isCritical: true,
          dueDate: DateTime.now().add(Duration(days: daysUntilMoveIn - 30)),
        ),
      );

      tasks.add(
        MoveInTaskEntity(
          id: 'utilities_gas',
          title: 'Contratar gás (se aplicável)',
          description: 'Gás encanado ou botijão',
          category: MoveInTaskCategory.utilities,
          isCompleted: false,
          isCritical: false,
          dueDate: DateTime.now().add(Duration(days: daysUntilMoveIn - 25)),
        ),
      );

      tasks.add(
        MoveInTaskEntity(
          id: 'utilities_internet',
          title: 'Contratar internet',
          description: 'Agendar instalação com antecedência (pode demorar)',
          category: MoveInTaskCategory.utilities,
          isCompleted: false,
          isCritical: true,
          dueDate: DateTime.now().add(Duration(days: daysUntilMoveIn - 20)),
        ),
      );

      tasks.add(
        MoveInTaskEntity(
          id: 'utilities_activate',
          title: 'Ativar energia elétrica',
          description: 'Garantir que a energia esteja funcionando',
          category: MoveInTaskCategory.utilities,
          isCompleted: false,
          isCritical: true,
          dueDate: DateTime.now().add(Duration(days: daysUntilMoveIn - 15)),
        ),
      );
    }

    // Limpeza pós-obra
    if (overallProgress >= 90) {
      tasks.add(
        MoveInTaskEntity(
          id: 'cleaning_1',
          title: 'Limpeza pós-obra',
          description: 'Contratar empresa de limpeza profissional',
          category: MoveInTaskCategory.cleaning,
          isCompleted: false,
          isCritical: true,
          dueDate: DateTime.now().add(Duration(days: daysUntilMoveIn - 7)),
        ),
      );

      tasks.add(
        MoveInTaskEntity(
          id: 'cleaning_2',
          title: 'Limpeza de vidros',
          description: 'Limpar todas as janelas e espelhos',
          category: MoveInTaskCategory.cleaning,
          isCompleted: false,
          isCritical: false,
          dueDate: DateTime.now().add(Duration(days: daysUntilMoveIn - 5)),
        ),
      );
    }

    // Vistoria final
    if (overallProgress >= 85) {
      tasks.add(
        MoveInTaskEntity(
          id: 'inspection_1',
          title: 'Vistoria final',
          description: 'Verificar todos os acabamentos e instalações',
          category: MoveInTaskCategory.inspection,
          isCompleted: false,
          isCritical: true,
          dueDate: DateTime.now().add(Duration(days: daysUntilMoveIn - 10)),
        ),
      );

      tasks.add(
        MoveInTaskEntity(
          id: 'inspection_2',
          title: 'Testar instalações',
          description: 'Testar água, luz, gás e internet',
          category: MoveInTaskCategory.inspection,
          isCompleted: false,
          isCritical: true,
          dueDate: DateTime.now().add(Duration(days: daysUntilMoveIn - 8)),
        ),
      );
    }

    // Documentação
    tasks.add(
      MoveInTaskEntity(
        id: 'doc_1',
        title: 'Organizar documentos',
        description: 'Reunir ARTs, garantias e manuais',
        category: MoveInTaskCategory.documentation,
        isCompleted: false,
        isCritical: false,
        dueDate: DateTime.now().add(Duration(days: daysUntilMoveIn - 5)),
      ),
    );

    // Mudança
    if (daysUntilMoveIn <= 20) {
      tasks.add(
        MoveInTaskEntity(
          id: 'moving_1',
          title: 'Contratar mudança',
          description: 'Pesquisar e contratar empresa de mudança',
          category: MoveInTaskCategory.moving,
          isCompleted: false,
          isCritical: true,
          dueDate: DateTime.now().add(Duration(days: daysUntilMoveIn - 15)),
        ),
      );

      tasks.add(
        MoveInTaskEntity(
          id: 'moving_2',
          title: 'Embalar pertences',
          description: 'Começar a embalar itens não essenciais',
          category: MoveInTaskCategory.moving,
          isCompleted: false,
          isCritical: false,
          dueDate: DateTime.now().add(Duration(days: daysUntilMoveIn - 10)),
        ),
      );
    }

    // Decoração
    if (overallProgress >= 95) {
      tasks.add(
        MoveInTaskEntity(
          id: 'decoration_1',
          title: 'Comprar decoração',
          description: 'Adquirir itens de decoração pendentes',
          category: MoveInTaskCategory.decoration,
          isCompleted: false,
          isCritical: false,
          dueDate: DateTime.now().add(Duration(days: daysUntilMoveIn - 3)),
        ),
      );
    }

    return tasks;
  }

  /// Gera recomendações personalizadas
  List<String> _generateRecommendations({
    required int daysUntilMoveIn,
    required double overallProgress,
    required List<String> criticalPendingItems,
  }) {
    final recommendations = <String>[];

    // Recomendações baseadas no tempo
    if (daysUntilMoveIn <= 7) {
      recommendations.add('Foque apenas no essencial para a mudança');
      recommendations.add('Deixe decoração para depois da mudança');
    } else if (daysUntilMoveIn <= 15) {
      recommendations.add('Comece a embalar itens não essenciais');
      recommendations.add('Já contrate a empresa de mudança');
    } else if (daysUntilMoveIn <= 30) {
      recommendations.add('Pesquise empresas de mudança');
      recommendations.add('Organize documentos da obra');
    }

    // Recomendações baseadas no progresso
    if (overallProgress < 90) {
      recommendations.add('Priorize acabamentos essenciais');
      recommendations.add('Deixe detalhes para depois');
    } else if (overallProgress >= 95) {
      recommendations.add('Faça uma vistoria completa');
      recommendations.add('Teste todas as instalações');
    }

    // Recomendações baseadas em pendências
    if (criticalPendingItems.isNotEmpty) {
      recommendations.add('Resolva pendências críticas primeiro');
      if (criticalPendingItems.length > 3) {
        recommendations.add('Considere adiar a mudança');
      }
    }

    // Recomendações gerais
    recommendations.add('Tire fotos do resultado final');
    recommendations.add('Guarde todos os manuais e garantias');

    return recommendations;
  }

  /// Determina o status do modo mudança
  MoveInStatus _determineStatus({
    required double overallProgress,
    required List<String> criticalPendingItems,
    required int daysUntilMoveIn,
    required List<MoveInTaskEntity> tasks,
  }) {
    // Atrasado: tem pendências críticas e pouco tempo
    if (criticalPendingItems.isNotEmpty && daysUntilMoveIn <= 7) {
      return MoveInStatus.delayed;
    }

    // Pronto: progresso alto, sem pendências, tarefas concluídas
    final completedTasks = tasks.where((t) => t.isCompleted).length;
    final totalTasks = tasks.length;
    final tasksProgress = totalTasks > 0 ? (completedTasks / totalTasks) : 0;

    if (overallProgress >= 95 &&
        criticalPendingItems.isEmpty &&
        tasksProgress >= 0.8) {
      return MoveInStatus.ready;
    }

    // Quase pronto: progresso alto, poucas pendências
    if (overallProgress >= 90 && criticalPendingItems.length <= 2) {
      return MoveInStatus.almostReady;
    }

    // Não está pronto
    return MoveInStatus.notReady;
  }

  /// Gera tarefas personalizadas baseadas nos itens críticos do usuário
  List<MoveInTaskEntity> _generatePersonalizedTasks(
    List<String> criticalItems,
    int daysUntilMoveIn,
  ) {
    final tasks = <MoveInTaskEntity>[];

    for (final item in criticalItems) {
      switch (item) {
        case 'ar_conditioner':
          tasks.add(
            MoveInTaskEntity(
              id: 'custom_ac',
              title: 'Testar ar-condicionado',
              description:
                  'Ligar e testar todos os aparelhos de ar-condicionado',
              category: MoveInTaskCategory.inspection,
              isCompleted: false,
              isCritical: true,
              dueDate: DateTime.now().add(Duration(days: daysUntilMoveIn - 5)),
            ),
          );
          break;

        case 'wired_internet':
          tasks.add(
            MoveInTaskEntity(
              id: 'custom_internet',
              title: 'Testar pontos de internet',
              description: 'Verificar todos os pontos de rede cabeada',
              category: MoveInTaskCategory.inspection,
              isCompleted: false,
              isCritical: true,
              dueDate: DateTime.now().add(Duration(days: daysUntilMoveIn - 7)),
            ),
          );
          break;

        case 'dishwasher':
          tasks.add(
            MoveInTaskEntity(
              id: 'custom_dishwasher',
              title: 'Instalar lava-louças',
              description: 'Agendar instalação e teste da lava-louças',
              category: MoveInTaskCategory.utilities,
              isCompleted: false,
              isCritical: true,
              dueDate: DateTime.now().add(Duration(days: daysUntilMoveIn - 10)),
            ),
          );
          break;

        case 'water_heater':
          tasks.add(
            MoveInTaskEntity(
              id: 'custom_heater',
              title: 'Testar aquecedor',
              description: 'Verificar funcionamento do aquecedor de água',
              category: MoveInTaskCategory.inspection,
              isCompleted: false,
              isCritical: true,
              dueDate: DateTime.now().add(Duration(days: daysUntilMoveIn - 5)),
            ),
          );
          break;

        case 'home_automation':
          tasks.add(
            MoveInTaskEntity(
              id: 'custom_automation',
              title: 'Configurar automação',
              description:
                  'Instalar e configurar sistema de automação residencial',
              category: MoveInTaskCategory.utilities,
              isCompleted: false,
              isCritical: false,
              dueDate: DateTime.now().add(Duration(days: daysUntilMoveIn - 7)),
            ),
          );
          break;

        case 'smart_lock':
          tasks.add(
            MoveInTaskEntity(
              id: 'custom_lock',
              title: 'Instalar fechadura eletrônica',
              description: 'Instalar e configurar fechadura inteligente',
              category: MoveInTaskCategory.utilities,
              isCompleted: false,
              isCritical: false,
              dueDate: DateTime.now().add(Duration(days: daysUntilMoveIn - 5)),
            ),
          );
          break;

        case 'security_cameras':
          tasks.add(
            MoveInTaskEntity(
              id: 'custom_cameras',
              title: 'Instalar câmeras',
              description:
                  'Instalar e configurar sistema de câmeras de segurança',
              category: MoveInTaskCategory.utilities,
              isCompleted: false,
              isCritical: false,
              dueDate: DateTime.now().add(Duration(days: daysUntilMoveIn - 7)),
            ),
          );
          break;

        case 'ambient_sound':
          tasks.add(
            MoveInTaskEntity(
              id: 'custom_sound',
              title: 'Configurar som ambiente',
              description: 'Instalar e testar sistema de som ambiente',
              category: MoveInTaskCategory.decoration,
              isCompleted: false,
              isCritical: false,
              dueDate: DateTime.now().add(Duration(days: daysUntilMoveIn - 3)),
            ),
          );
          break;

        case 'ev_charger':
          tasks.add(
            MoveInTaskEntity(
              id: 'custom_ev_charger',
              title: 'Instalar carregador de carro elétrico',
              description: 'Instalar e testar carregador veicular',
              category: MoveInTaskCategory.utilities,
              isCompleted: false,
              isCritical: true,
              dueDate: DateTime.now().add(Duration(days: daysUntilMoveIn - 10)),
            ),
          );
          break;

        case 'central_vacuum':
          tasks.add(
            MoveInTaskEntity(
              id: 'custom_vacuum',
              title: 'Testar aspiração central',
              description:
                  'Verificar funcionamento do sistema de aspiração central',
              category: MoveInTaskCategory.inspection,
              isCompleted: false,
              isCritical: false,
              dueDate: DateTime.now().add(Duration(days: daysUntilMoveIn - 5)),
            ),
          );
          break;

        case 'solar_energy':
          tasks.add(
            MoveInTaskEntity(
              id: 'custom_solar',
              title: 'Ativar energia solar',
              description:
                  'Finalizar instalação e ativar sistema de energia solar',
              category: MoveInTaskCategory.utilities,
              isCompleted: false,
              isCritical: true,
              dueDate: DateTime.now().add(Duration(days: daysUntilMoveIn - 15)),
            ),
          );
          break;
      }
    }

    return tasks;
  }

  /// Detecta pendências críticas reais baseadas em dados do Firestore
  Future<List<String>> _detectRealPendingItems(String projectId) async {
    final pendingItems = <String>[];

    // Buscar compras pendentes
    final shoppingResult =
        await _shoppingRepository.getShoppingItems(projectId);
    await shoppingResult.fold(
      (failure) async => null,
      (items) async {
        final pendingPurchases =
            items.where((item) => !item.isPurchased).toList();
        if (pendingPurchases.isNotEmpty) {
          pendingItems.add('${pendingPurchases.length} compras pendentes');
        }
      },
    );

    // Buscar parcelas pendentes
    final installmentsResult =
        await _installmentRepository.getInstallments(projectId);
    await installmentsResult.fold(
      (failure) async => null,
      (installments) async {
        int overduePayments = 0;
        for (final installment in installments) {
          final overduePaymentsInInstallment = installment.payments
              .where((p) => !p.isPaid && p.dueDate.isBefore(DateTime.now()))
              .length;
          overduePayments += overduePaymentsInInstallment;
        }
        if (overduePayments > 0) {
          pendingItems.add('$overduePayments parcelas atrasadas');
        }
      },
    );

    // Buscar problemas críticos abertos
    final problemsResult = await _problemRepository.getProblems(projectId);
    await problemsResult.fold(
      (failure) async => null,
      (problems) async {
        final criticalProblems =
            problems.where((p) => p.isOpen && p.isCritical).toList();
        if (criticalProblems.isNotEmpty) {
          pendingItems.add('${criticalProblems.length} problemas críticos');
        }
      },
    );

    return pendingItems;
  }
}

// Made with Bob
