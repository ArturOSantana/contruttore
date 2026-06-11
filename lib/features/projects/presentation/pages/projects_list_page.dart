import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/project_entity.dart';
import '../cubit/projects_list_cubit.dart';
import '../cubit/projects_list_state.dart';

/// Página de lista de projetos do usuário
class ProjectsListPage extends StatefulWidget {
  const ProjectsListPage({super.key});

  @override
  State<ProjectsListPage> createState() => _ProjectsListPageState();
}

class _ProjectsListPageState extends State<ProjectsListPage> {
  @override
  void initState() {
    super.initState();
    // Carregar projetos após o primeiro frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectsListCubit>().loadProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Meus Projetos'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Navegar para onboarding conversacional para criar novo projeto
          await context.push(RouteNames.conversationalWelcome);
          // Recarregar lista após voltar
          if (mounted) {
            context.read<ProjectsListCubit>().loadProjects();
          }
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textInverse,
        icon: const Icon(Icons.home_work_rounded),
        label: const Text('Nova Reforma'),
      ),
      body: BlocConsumer<ProjectsListCubit, ProjectsListState>(
        listener: (context, state) {
          if (state is ProjectSwitched) {
            // Mostrar mensagem de sucesso
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Projeto alterado com sucesso!'),
                backgroundColor: AppColors.success,
                duration: Duration(seconds: 2),
              ),
            );

            // Voltar para a home após trocar de projeto
            // Adicionar timestamp para forçar rebuild
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                context.go(
                  '${RouteNames.home}?refresh=${DateTime.now().millisecondsSinceEpoch}',
                );
              }
            });
          }

          if (state is ProjectsListError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProjectsListLoading) {
            return const LoadingWidget();
          }

          if (state is ProjectsListError) {
            return ErrorWidgetCustom(
              message: state.message,
              onRetry: () => context.read<ProjectsListCubit>().loadProjects(),
            );
          }

          if (state is ProjectsListLoaded) {
            if (state.projects.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.home_work_rounded,
                title: 'Bem-vindo ao Contruttore!',
                message:
                    'Vamos organizar sua reforma em menos de 3 minutos.\n\nDescubra o que fazer, quanto gastar e quando se mudar.',
                actionLabel: 'Começar Agora',
                onAction: () => context.push(RouteNames.conversationalWelcome),
              );
            }

            return _buildProjectsList(state.projects, state.currentProjectId);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildProjectsList(
    List<ProjectEntity> projects,
    String? currentProjectId,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ProjectsListCubit>().loadProjects();
      },
      child: ListView.builder(
        padding: EdgeInsets.all(AppSpacing.md),
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];
          final isActive = project.id == currentProjectId;

          return _ProjectCard(
            project: project,
            isActive: isActive,
            onTap: () {
              if (!isActive) {
                _showSwitchConfirmation(project);
              }
            },
          );
        },
      ),
    );
  }

  void _showSwitchConfirmation(ProjectEntity project) {
    // Capturar o cubit antes de abrir o dialog
    final cubit = context.read<ProjectsListCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Trocar de Projeto'),
        content: Text('Deseja alternar para o projeto "${project.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              cubit.switchProject(project.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textInverse,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}

/// Card de projeto
class _ProjectCard extends StatelessWidget {
  final ProjectEntity project;
  final bool isActive;
  final VoidCallback onTap;

  const _ProjectCard({
    required this.project,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      elevation: isActive ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: isActive
            ? BorderSide(color: AppColors.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: isActive ? null : onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho com nome e badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: AppTextStyles.headingMedium.copyWith(
                        color: isActive ? AppColors.primary : null,
                      ),
                    ),
                  ),
                  if (isActive)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                      ),
                      child: Text(
                        'ATIVO',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textInverse,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: AppSpacing.sm),

              // Endereço
              if (project.address.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: AppSpacing.xxs),
                    Expanded(
                      child: Text(
                        project.address,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xs),
              ],

              // Construtora
              if (project.constructorName.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(
                      Icons.business,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: AppSpacing.xxs),
                    Expanded(
                      child: Text(
                        project.constructorName,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xs),
              ],

              // Data de entrega
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: AppSpacing.xxs),
                  Text(
                    'Entrega: ${DateFormat('MMM/yyyy', 'pt_BR').format(project.deliveryDate)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              // Orçamento
              if (project.totalBudget != null && project.totalBudget! > 0) ...[
                SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: AppSpacing.xxs),
                    Text(
                      'Orçamento: R\$ ${project.totalBudget!.toStringAsFixed(2)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],

              // Botão de ação
              if (!isActive) ...[
                SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.swap_horiz, size: 18),
                    label: const Text('Alternar para este projeto'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Made with Bob
