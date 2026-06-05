import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/error_widget.dart';

import '../../../../core/widgets/loading_widget.dart';

import '../../../../core/widgets/empty_state_widget.dart';
import '../../domain/entities/alert_entity.dart';
import '../cubit/alerts_cubit.dart';
import '../cubit/alerts_state.dart';

/// Página de Alertas - Feed centralizado de todos os alertas do app
class AlertsPage extends StatelessWidget {
  final String projectId;

  const AlertsPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Alertas'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          // Botão de filtro
          PopupMenuButton<AlertType?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (type) {
              context.read<AlertsCubit>().filterByType(type);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('Todos')),
              ...AlertType.values.map(
                (type) => PopupMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(type.icon, size: 16),
                      SizedBox(width: AppSpacing.xs),
                      Text(type.displayName),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<AlertsCubit, AlertsState>(
        builder: (context, state) {
          if (state is AlertsLoading) {
            return const LoadingWidget();
          }

          if (state is AlertsError) {
            return ErrorWidgetCustom(
              message: state.message,
              onRetry: () => context.read<AlertsCubit>().loadAlerts(projectId),
            );
          }

          if (state is AlertsLoaded) {
            final alerts = state.filteredAlerts;

            if (alerts.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.notifications_none,
                title: state.filterType != null
                    ? 'Nenhum alerta deste tipo'
                    : 'Nenhum alerta',
                message: state.filterType != null
                    ? 'Não há alertas ${state.filterType!.displayName.toLowerCase()} no momento.'
                    : 'Você está em dia! Não há alertas pendentes.',
                actionLabel: 'Atualizar',
                onAction: () =>
                    context.read<AlertsCubit>().loadAlerts(projectId),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<AlertsCubit>().loadAlerts(projectId);
              },
              child: Column(
                children: [
                  // Resumo de alertas não lidos
                  if (state.unreadCount > 0)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(AppSpacing.md),
                      color: AppColors.infoLight,
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.info,
                            size: 20,
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            '${state.unreadCount} ${state.unreadCount == 1 ? "alerta não lido" : "alertas não lidos"}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.info,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Filtro ativo
                  if (state.filterType != null)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      color: AppColors.surfaceVariant,
                      child: Row(
                        children: [
                          Icon(state.filterType!.icon, size: 16),
                          SizedBox(width: AppSpacing.xs),
                          Text(
                            'Filtrando: ${state.filterType!.displayName}',
                            style: AppTextStyles.bodySmall,
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () =>
                                context.read<AlertsCubit>().clearFilter(),
                            child: const Text('Limpar'),
                          ),
                        ],
                      ),
                    ),
                  // Lista de alertas
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(AppSpacing.md),
                      itemCount: alerts.length,
                      itemBuilder: (context, index) {
                        final alert = alerts[index];
                        return _AlertCard(
                          alert: alert,
                          onTap: () {
                            if (!alert.isRead) {
                              context.read<AlertsCubit>().markAsRead(alert.id);
                            }
                            if (alert.actionRoute != null) {
                              context.push(alert.actionRoute!);
                            }
                          },
                          onMarkAsRead: () {
                            context.read<AlertsCubit>().markAsRead(alert.id);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

/// Card de alerta individual
class _AlertCard extends StatelessWidget {
  final AlertEntity alert;
  final VoidCallback onTap;
  final VoidCallback onMarkAsRead;

  const _AlertCard({
    required this.alert,
    required this.onTap,
    required this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(alert.type.colorValue);
    final isUnread = !alert.isRead;

    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      elevation: isUnread ? AppSpacing.elevationMd : AppSpacing.elevationSm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: BorderSide(
          color: isUnread ? color : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho: tipo, título e badge não lido
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ícone do tipo
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Center(
                      child: Icon(
                        alert.type.icon,
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  // Título e tipo
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                alert.title,
                                style: AppTextStyles.titleMedium.copyWith(
                                  fontWeight: isUnread
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                ),
                              ),
                            ),
                            if (isUnread)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.xxs),
                        Text(
                          alert.type.displayName,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sm),
              // Mensagem
              Text(
                alert.message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              // Rodapé: data e ações
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: AppSpacing.xxs),
                  Text(
                    _formatDate(alert.createdAt),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  // Botão marcar como lido
                  if (isUnread)
                    TextButton.icon(
                      onPressed: onMarkAsRead,
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Marcar como lido'),
                      style: TextButton.styleFrom(
                        foregroundColor: color,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xxs,
                        ),
                      ),
                    ),
                  // Indicador de ação disponível
                  if (alert.actionRoute != null)
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Agora';
    } else if (difference.inHours < 1) {
      return 'Há ${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return 'Há ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Há ${difference.inDays} ${difference.inDays == 1 ? "dia" : "dias"}';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }
}

// Made with Bob
