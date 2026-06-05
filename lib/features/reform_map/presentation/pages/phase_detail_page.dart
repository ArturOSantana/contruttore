import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../projects/domain/entities/phase_entity.dart';
import '../../../../app/router/route_names.dart';

/// Página de detalhes de uma fase específica
///
/// Mostra todas as informações contextuais da fase:
/// - Explicação para leigos
/// - O que acontece nesta etapa
/// - O que pode dar errado
/// - Fornecedores relacionados
/// - Compras necessárias
/// - Documentos esperados
/// - Parcelas vinculadas
/// - Diário de registros
class PhaseDetailPage extends StatelessWidget {
  final String projectId;
  final PhaseEntity phase;

  const PhaseDetailPage({
    super.key,
    required this.projectId,
    required this.phase,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(phase.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Implementar edição de fase
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status Card
          _buildStatusCard(context),
          const SizedBox(height: 16),

          // Explicação
          _buildExplanationCard(context),
          const SizedBox(height: 16),

          // O que acontece
          _buildWhatHappensCard(context),
          const SizedBox(height: 16),

          // Erros comuns
          _buildCommonMistakesCard(context),
          const SizedBox(height: 16),

          // Fornecedores
          _buildSuppliersCard(context),
          const SizedBox(height: 16),

          // Compras
          _buildShoppingCard(context),
          const SizedBox(height: 16),

          // Documentos
          _buildDocumentsCard(context),
          const SizedBox(height: 16),

          // Parcelas
          _buildInstallmentsCard(context),
          const SizedBox(height: 16),

          // Diário
          _buildDiaryCard(context),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    final statusInfo = _getStatusInfo();

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

  Widget _buildExplanationCard(BuildContext context) {
    final explanation = _getPhaseExplanation();

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

  Widget _buildWhatHappensCard(BuildContext context) {
    final activities = _getPhaseActivities();

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

  Widget _buildCommonMistakesCard(BuildContext context) {
    final mistakes = _getCommonMistakes();

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

  Widget _buildSuppliersCard(BuildContext context) {
    return _buildNavigationCard(
      context,
      title: 'Fornecedores',
      subtitle: 'Profissionais desta etapa',
      icon: Icons.people,
      count: 0, // TODO: Buscar do Firebase
      onTap: () {
        context.push('${RouteNames.suppliers}?phase=${phase.id}');
      },
    );
  }

  Widget _buildShoppingCard(BuildContext context) {
    return _buildNavigationCard(
      context,
      title: 'Compras',
      subtitle: 'Materiais necessários',
      icon: Icons.shopping_cart,
      count: 0, // TODO: Buscar do Firebase
      onTap: () {
        context.push('${RouteNames.shopping}?phase=${phase.id}');
      },
    );
  }

  Widget _buildDocumentsCard(BuildContext context) {
    final expectedDocs = _getExpectedDocuments();

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

  Widget _buildInstallmentsCard(BuildContext context) {
    return _buildNavigationCard(
      context,
      title: 'Parcelas',
      subtitle: 'Pagamentos vinculados',
      icon: Icons.payment,
      count: 0, // TODO: Buscar do Firebase
      onTap: () {
        context.push('${RouteNames.payments}?phase=${phase.id}');
      },
    );
  }

  Widget _buildDiaryCard(BuildContext context) {
    return _buildNavigationCard(
      context,
      title: 'Diário',
      subtitle: 'Registros desta etapa',
      icon: Icons.book,
      count: 0, // TODO: Buscar do Firebase
      onTap: () {
        context.push('${RouteNames.diary}?phase=${phase.id}');
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
                      '$count $subtitle',
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

  Map<String, dynamic> _getStatusInfo() {
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

  String _getPhaseExplanation() {
    // TODO: Buscar do Firebase ou usar dados estáticos
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

  List<String> _getPhaseActivities() {
    // TODO: Buscar do Firebase ou usar dados estáticos
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

  List<String> _getCommonMistakes() {
    // TODO: Buscar do Firebase ou usar dados estáticos
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

  List<String> _getExpectedDocuments() {
    // TODO: Buscar do Firebase ou usar dados estáticos
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

// Made with Bob
