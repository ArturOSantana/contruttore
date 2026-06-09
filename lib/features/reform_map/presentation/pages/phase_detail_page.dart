import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../projects/domain/entities/phase_entity.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../cubit/reform_map_cubit.dart';
import '../cubit/reform_map_state.dart';

/// Página de detalhes de uma fase específica do Mapa da Reforma
///
/// Esta página é o coração da experiência do usuário leigo.
/// Ela traduz a complexidade da construção civil em informações
/// simples e acionáveis.
///
/// Mostra:
/// - Status e progresso da fase
/// - Resumo financeiro (orçado vs gasto)
/// - Explicação para leigos
/// - O que acontece nesta etapa
/// - Erros comuns a evitar
/// - Fornecedores relacionados (com dados reais)
/// - Compras necessárias (com dados reais)
/// - Documentos esperados
/// - Parcelas vinculadas (com dados reais)
/// - Próximos passos recomendados
class PhaseDetailPage extends StatefulWidget {
  final String projectId;
  final PhaseEntity phase;

  const PhaseDetailPage({
    super.key,
    required this.projectId,
    required this.phase,
  });

  @override
  State<PhaseDetailPage> createState() => _PhaseDetailPageState();
}

class _PhaseDetailPageState extends State<PhaseDetailPage> {
  @override
  void initState() {
    super.initState();
    // Carrega dados atualizados ao abrir a página
    context.read<ReformMapCubit>().loadReformMap(widget.projectId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.phase.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ReformMapCubit>().refreshAll(widget.projectId);
            },
          ),
        ],
      ),
      body: BlocBuilder<ReformMapCubit, ReformMapState>(
        builder: (context, state) {
          if (state is ReformMapLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ReformMapError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<ReformMapCubit>()
                          .loadReformMap(widget.projectId);
                    },
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          // Busca a fase atualizada do estado
          PhaseEntity currentPhase = widget.phase;
          if (state is ReformMapLoaded) {
            final updatedPhase = state.reformMap.phases
                .where((p) => p.id == widget.phase.id)
                .firstOrNull;
            if (updatedPhase != null) {
              currentPhase = updatedPhase;
            }
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Status Card
              _buildStatusCard(context, currentPhase),
              const SizedBox(height: 16),

              // Resumo Financeiro (NOVO)
              if (currentPhase.estimatedBudget > 0)
                _buildFinancialSummaryCard(context, currentPhase),
              if (currentPhase.estimatedBudget > 0) const SizedBox(height: 16),

              // Explicação
              _buildExplanationCard(context, currentPhase),
              const SizedBox(height: 16),

              // O que acontece
              _buildWhatHappensCard(context, currentPhase),
              const SizedBox(height: 16),

              // Erros comuns
              _buildCommonMistakesCard(context, currentPhase),
              const SizedBox(height: 16),

              // Próximos Passos (NOVO)
              _buildNextStepsCard(context, currentPhase),
              const SizedBox(height: 16),

              // Fornecedores
              _buildSuppliersCard(context, currentPhase),
              const SizedBox(height: 16),

              // Compras
              _buildShoppingCard(context, currentPhase),
              const SizedBox(height: 16),

              // Documentos
              _buildDocumentsCard(context, currentPhase),
              const SizedBox(height: 16),

              // Parcelas
              _buildInstallmentsCard(context, currentPhase),
              const SizedBox(height: 16),

              // Diário
              _buildDiaryCard(context, currentPhase),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, PhaseEntity phase) {
    final statusInfo = _getStatusInfo(phase);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: statusInfo['color'] as Color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    statusInfo['icon'] as IconData,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusInfo['title'] as String,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        statusInfo['subtitle'] as String,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (phase.progressPercentage > 0) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Progresso',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: phase.progressPercentage / 100,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            statusInfo['color'] as Color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${phase.progressPercentage.toStringAsFixed(0)}% concluído',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            if (phase.startDate != null || phase.endDate != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (phase.startDate != null)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Início',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            _formatDate(phase.startDate!),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  if (phase.endDate != null)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Término',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            _formatDate(phase.endDate!),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// NOVO: Card com resumo financeiro da fase
  Widget _buildFinancialSummaryCard(BuildContext context, PhaseEntity phase) {
    final budgetUsed = phase.budgetUsedPercentage;
    final isOverBudget = phase.isOverBudget;

    return Card(
      color: isOverBudget ? Colors.red[50] : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isOverBudget
                      ? Icons.warning_amber
                      : Icons.account_balance_wallet,
                  color: isOverBudget
                      ? Colors.red
                      : Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Resumo Financeiro',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Orçado',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        CurrencyFormatter.format(phase.estimatedBudget),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gasto',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        CurrencyFormatter.format(phase.totalSpent),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: isOverBudget ? Colors.red : null,
                                ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: budgetUsed / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${budgetUsed.toStringAsFixed(0)}% utilizado',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (phase.totalPending > 0)
                  Text(
                    'Pendente: ${CurrencyFormatter.format(phase.totalPending)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange,
                        ),
                  ),
              ],
            ),
            if (isOverBudget) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, size: 16, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Orçamento excedido em ${CurrencyFormatter.format(phase.totalSpent - phase.estimatedBudget)}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationCard(BuildContext context, PhaseEntity phase) {
    final explanation = _getPhaseExplanation(phase);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'O que é esta etapa?',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              explanation,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhatHappensCard(BuildContext context, PhaseEntity phase) {
    final activities = _getPhaseActivities(phase);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.checklist, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'O que acontece nesta etapa',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...activities.map((activity) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_outline, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          activity,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildCommonMistakesCard(BuildContext context, PhaseEntity phase) {
    final mistakes = _getCommonMistakes(phase);

    return Card(
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Erros comuns',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...mistakes.map((mistake) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.close, size: 20, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          mistake,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  /// NOVO: Card com próximos passos recomendados
  Widget _buildNextStepsCard(BuildContext context, PhaseEntity phase) {
    final nextSteps = _getNextSteps(phase);

    if (nextSteps.isEmpty) return const SizedBox.shrink();

    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Próximos passos',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...nextSteps.map((step) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.arrow_forward,
                          size: 20, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          step,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildSuppliersCard(BuildContext context, PhaseEntity phase) {
    final expectedTypes = phase.expectedSupplierTypes;

    return FutureBuilder<int>(
      future: _getSupplierCount(phase.id),
      builder: (context, snapshot) {
        return _buildNavigationCard(
          context,
          title: 'Fornecedores',
          subtitle: expectedTypes.isNotEmpty
              ? 'Profissionais necessários: ${expectedTypes.join(", ")}'
              : 'Profissionais desta etapa',
          icon: Icons.people,
          count: snapshot.data ?? 0,
          onTap: () {
            context.push('${RouteNames.suppliers}?phase=${phase.id}');
          },
        );
      },
    );
  }

  Widget _buildShoppingCard(BuildContext context, PhaseEntity phase) {
    final expectedCategories = phase.expectedPurchaseCategories;

    return FutureBuilder<int>(
      future: _getShoppingCount(phase.id),
      builder: (context, snapshot) {
        return _buildNavigationCard(
          context,
          title: 'Compras',
          subtitle: expectedCategories.isNotEmpty
              ? 'Categorias: ${expectedCategories.join(", ")}'
              : 'Materiais necessários',
          icon: Icons.shopping_cart,
          count: snapshot.data ?? 0,
          onTap: () {
            context.push('${RouteNames.shopping}?phase=${phase.id}');
          },
        );
      },
    );
  }

  Widget _buildDocumentsCard(BuildContext context, PhaseEntity phase) {
    final expectedDocs = phase.expectedDocumentTypes.isNotEmpty
        ? phase.expectedDocumentTypes
        : _getExpectedDocuments(phase);

    return Card(
      child: InkWell(
        onTap: () {
          context.push('${RouteNames.documents}?phase=${phase.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.description,
                      color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Documentos',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  FutureBuilder<int>(
                    future: _getDocumentsCount(phase.id),
                    builder: (context, snapshot) {
                      final count = snapshot.data ?? 0;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          count.toString(),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Documentos esperados:',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 8),
              ...expectedDocs.map((doc) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.fiber_manual_record, size: 8),
                        const SizedBox(width: 8),
                        Text(doc),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstallmentsCard(BuildContext context, PhaseEntity phase) {
    return FutureBuilder<int>(
      future: _getInstallmentsCount(phase.id),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return _buildNavigationCard(
          context,
          title: 'Parcelas',
          subtitle: phase.totalPending > 0
              ? 'Pendente: ${CurrencyFormatter.format(phase.totalPending)}'
              : 'Pagamentos vinculados',
          icon: Icons.payment,
          count: count,
          onTap: () {
            context.push('${RouteNames.payments}?phase=${phase.id}');
          },
        );
      },
    );
  }

  Widget _buildDiaryCard(BuildContext context, PhaseEntity phase) {
    return FutureBuilder<int>(
      future: _getDiaryCount(phase.id),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return _buildNavigationCard(
          context,
          title: 'Diário',
          subtitle: 'Registros desta etapa',
          icon: Icons.book,
          count: count,
          onTap: () {
            context.push('${RouteNames.diary}?phase=${phase.id}');
          },
        );
      },
    );
  }

  Widget _buildNavigationCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required int count,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(PhaseEntity phase) {
    switch (phase.status) {
      case PhaseStatus.done:
        return {
          'title': 'Concluída',
          'subtitle': 'Esta etapa foi finalizada',
          'icon': Icons.check_circle,
          'color': Colors.green,
        };
      case PhaseStatus.doneNoRecord:
        return {
          'title': 'Concluída sem registro',
          'subtitle': 'Finalizada antes do app',
          'icon': Icons.check_circle_outline,
          'color': Colors.blue,
        };
      case PhaseStatus.active:
        return {
          'title': 'Em andamento',
          'subtitle': 'Trabalhando nesta etapa',
          'icon': Icons.play_circle,
          'color': Colors.orange,
        };
      case PhaseStatus.locked:
        return {
          'title': 'Bloqueada',
          'subtitle': 'Aguardando etapas anteriores',
          'icon': Icons.lock,
          'color': Colors.grey,
        };
    }
  }

  String _getPhaseExplanation(PhaseEntity phase) {
    final explanations = {
      'Planejamento': 'Nesta etapa você define o que será feito na reforma, '
          'cria o projeto, escolhe materiais e contrata profissionais.',
      'Demolição': 'Aqui são removidas paredes, pisos e revestimentos antigos '
          'para preparar o espaço para as novas instalações.',
      'Hidráulica': 'Instalação ou reforma de tubulações de água e esgoto. '
          'Deve ser feita antes dos revestimentos.',
      'Elétrica':
          'Instalação de fios, tomadas, interruptores e quadro elétrico. '
              'Também deve ser feita antes dos revestimentos.',
      'Revestimentos': 'Aplicação de pisos, azulejos e outros revestimentos. '
          'Uma das etapas mais visíveis da reforma.',
      'Pintura': 'Preparação e pintura de paredes e tetos. '
          'Geralmente feita após os revestimentos.',
      'Marcenaria': 'Instalação de armários, portas e móveis planejados.',
      'Acabamentos':
          'Instalação de louças, metais, luminárias e outros detalhes finais.',
      'Mudança': 'Limpeza final e preparação para a mudança.',
    };

    return explanations[phase.name] ??
        'Esta é uma etapa importante da sua reforma.';
  }

  List<String> _getPhaseActivities(PhaseEntity phase) {
    final activities = {
      'Planejamento': [
        'Definir escopo da reforma',
        'Criar projeto arquitetônico',
        'Escolher materiais',
        'Solicitar orçamentos',
        'Contratar profissionais',
      ],
      'Demolição': [
        'Proteger áreas que não serão reformadas',
        'Remover revestimentos antigos',
        'Quebrar paredes (se necessário)',
        'Remover entulho',
        'Limpar o local',
      ],
      'Hidráulica': [
        'Definir pontos de água',
        'Instalar tubulações',
        'Fazer testes de vazamento',
        'Solicitar ART do encanador',
      ],
      'Elétrica': [
        'Definir pontos de tomadas e interruptores',
        'Instalar eletrodutos e fios',
        'Instalar quadro elétrico',
        'Testar circuitos',
        'Solicitar ART do eletricista',
      ],
    };

    return activities[phase.name] ?? ['Executar as atividades desta etapa'];
  }

  List<String> _getCommonMistakes(PhaseEntity phase) {
    final mistakes = {
      'Planejamento': [
        'Não fazer projeto detalhado',
        'Não solicitar múltiplos orçamentos',
        'Não verificar referências dos profissionais',
        'Subestimar o orçamento',
      ],
      'Hidráulica': [
        'Poucas torneiras de jardim',
        'Não prever ponto para máquina de lavar',
        'Não fazer teste de vazamento',
        'Não solicitar ART',
      ],
      'Elétrica': [
        'Poucas tomadas',
        'Não prever pontos para internet',
        'Não dimensionar circuitos corretamente',
        'Comprar luminárias antes do projeto',
      ],
    };

    return mistakes[phase.name] ?? ['Não planejar adequadamente'];
  }

  List<String> _getExpectedDocuments(PhaseEntity phase) {
    final documents = {
      'Planejamento': ['Projeto arquitetônico', 'Orçamentos', 'Contratos'],
      'Hidráulica': [
        'ART do encanador',
        'Nota fiscal de materiais',
        'Garantia'
      ],
      'Elétrica': [
        'ART do eletricista',
        'Nota fiscal de materiais',
        'Garantia'
      ],
      'Marcenaria': ['Projeto executivo', 'Contrato', 'Garantia'],
    };

    return documents[phase.name] ?? ['Contratos', 'Notas fiscais', 'Garantias'];
  }

  /// NOVO: Próximos passos baseados no status da fase
  List<String> _getNextSteps(PhaseEntity phase) {
    if (phase.status == PhaseStatus.locked) {
      return [
        'Aguarde a conclusão das etapas anteriores',
        'Você pode começar a pesquisar fornecedores',
        'Aproveite para definir materiais e acabamentos',
      ];
    }

    if (phase.status == PhaseStatus.active) {
      final steps = <String>[];

      if (phase.expectedSupplierTypes.isNotEmpty && phase.totalSpent == 0) {
        steps.add('Contratar ${phase.expectedSupplierTypes.first}');
      }

      if (phase.expectedPurchaseCategories.isNotEmpty) {
        steps.add('Comprar materiais necessários');
      }

      if (phase.expectedDocumentTypes.isNotEmpty) {
        steps.add('Solicitar ${phase.expectedDocumentTypes.first}');
      }

      if (steps.isEmpty) {
        steps.add('Acompanhar o andamento dos trabalhos');
        steps.add('Registrar o progresso no diário');
      }
      return steps;
    }

    if (phase.status == PhaseStatus.done ||
        phase.status == PhaseStatus.doneNoRecord) {
      return [
        'Etapa concluída! Parabéns!',
        'Você pode revisar os registros no diário',
      ];
    }

    return [];
  }

  // Métodos para buscar contagens reais do Firebase
  Future<int> _getSupplierCount(String phaseId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('projects')
          .doc(widget.projectId)
          .collection('suppliers')
          .where('phaseId', isEqualTo: phaseId)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getShoppingCount(String phaseId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('projects')
          .doc(widget.projectId)
          .collection('shopping')
          .where('phaseId', isEqualTo: phaseId)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getDocumentsCount(String phaseId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('projects')
          .doc(widget.projectId)
          .collection('documents')
          .where('phaseId', isEqualTo: phaseId)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getInstallmentsCount(String phaseId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('projects')
          .doc(widget.projectId)
          .collection('installments')
          .where('phaseId', isEqualTo: phaseId)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getDiaryCount(String phaseId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('projects')
          .doc(widget.projectId)
          .collection('diary')
          .where('phaseId', isEqualTo: phaseId)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

// Made with Bob
