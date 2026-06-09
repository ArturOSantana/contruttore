import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../reform_map/domain/entities/problem_entity.dart';
import '../cubit/problems_cubit.dart';
import '../cubit/problems_state.dart';

class ProblemsPage extends StatelessWidget {
  final String projectId;

  const ProblemsPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Problemas da Reforma'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await context.pushNamed(
                'problem-create',
                queryParameters: {'projectId': projectId},
              );
              if (result == true && context.mounted) {
                context.read<ProblemsCubit>().loadProblems(projectId);
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<ProblemsCubit, ProblemsState>(
        builder: (context, state) {
          if (state is ProblemsLoading) {
            return const LoadingWidget(type: LoadingType.list);
          }

          if (state is ProblemsError) {
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
                      context.read<ProblemsCubit>().loadProblems(projectId);
                    },
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          if (state is ProblemsLoaded) {
            if (state.problems.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.check_circle_outline,
                title: 'Nenhum problema registrado',
                message:
                    'Ótimo! Sua reforma está sem problemas no momento. Registre aqui caso algo aconteça.',
                actionLabel: 'Adicionar Problema',
                onAction: () async {
                  final result = await context.pushNamed(
                    'problem-create',
                    queryParameters: {'projectId': projectId},
                  );
                  if (result == true && context.mounted) {
                    context.read<ProblemsCubit>().loadProblems(projectId);
                  }
                },
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProblemsCubit>().loadProblems(projectId);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Resumo
                    _buildSummaryCard(context, state),
                    const SizedBox(height: AppSpacing.lg),

                    // Problemas Críticos
                    if (state.criticalProblems.isNotEmpty) ...[
                      _buildSectionTitle(context, 'Problemas Críticos'),
                      const SizedBox(height: AppSpacing.sm),
                      ...state.criticalProblems.map((problem) =>
                          _buildProblemCard(context, problem, projectId)),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    // Todos os Problemas
                    _buildSectionTitle(context, 'Todos os Problemas'),
                    const SizedBox(height: AppSpacing.sm),
                    ...state.problems.map((problem) =>
                        _buildProblemCard(context, problem, projectId)),
                  ],
                ),
              ),
            );
          }

          return const Center(child: Text('Carregue os problemas'));
        },
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, ProblemsLoaded state) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumo',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Abertos',
                    state.openProblemsCount.toString(),
                    Colors.orange,
                    Icons.warning_amber_rounded,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildStatCard(
                    'Críticos',
                    state.criticalProblems.length.toString(),
                    Colors.red,
                    Icons.error_outline,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildStatCard(
                    'Resolvidos',
                    (state.problems.length - state.openProblemsCount)
                        .toString(),
                    Colors.green,
                    Icons.check_circle_outline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildProblemCard(
      BuildContext context, ProblemEntity problem, String projectId) {
    Color severityColor;
    IconData severityIcon;

    switch (problem.severity) {
      case ProblemSeverity.critical:
        severityColor = Colors.red;
        severityIcon = Icons.error;
        break;
      case ProblemSeverity.high:
        severityColor = Colors.orange;
        severityIcon = Icons.warning;
        break;
      case ProblemSeverity.medium:
        severityColor = Colors.yellow[700]!;
        severityIcon = Icons.info;
        break;
      case ProblemSeverity.low:
        severityColor = Colors.blue;
        severityIcon = Icons.info_outline;
        break;
    }

    final isResolved = problem.status == ProblemStatus.resolved;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () async {
          final result = await context.pushNamed(
            'problem-detail',
            pathParameters: {'id': problem.id},
            queryParameters: {'projectId': projectId},
          );
          if (result == true && context.mounted) {
            context.read<ProblemsCubit>().loadProblems(projectId);
          }
        },
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Ícone de severidade
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: severityColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                    ),
                    child: Icon(severityIcon, color: severityColor, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.sm),

                  // Título
                  Expanded(
                    child: Text(
                      problem.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            decoration:
                                isResolved ? TextDecoration.lineThrough : null,
                          ),
                    ),
                  ),

                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: isResolved
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                    ),
                    child: Text(
                      isResolved ? 'Resolvido' : 'Aberto',
                      style: TextStyle(
                        fontSize: 12,
                        color: isResolved ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // Descrição
              Text(
                problem.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.sm),

              // Informações adicionais
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.xs,
                children: [
                  if (problem.phaseId != null)
                    _buildInfoChip(
                      Icons.construction,
                      problem.phaseName ?? problem.phaseId!,
                      Colors.blue,
                    ),
                  if (problem.financialImpact != null &&
                      problem.financialImpact! > 0)
                    _buildInfoChip(
                      Icons.attach_money,
                      'R\$ ${problem.financialImpact!.toStringAsFixed(2)}',
                      Colors.red,
                    ),
                  if (problem.delayDays != null && problem.delayDays! > 0)
                    _buildInfoChip(
                      Icons.schedule,
                      '${problem.delayDays} dias',
                      Colors.orange,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
          ),
        ),
      ],
    );
  }
}

// Made with Bob
