import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/router/route_names.dart';
import '../../domain/entities/critical_alert_entity.dart';
import '../../domain/entities/checklist_item_entity.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';

/// Tela de resultados do onboarding
class OnboardingResultsPage extends StatelessWidget {
  final String nextAction;
  final List<CriticalAlertEntity> criticalAlerts;
  final Map<String, List<ChecklistItemEntity>> checklistsByRoom;
  final int healthScore;
  final int estimatedDuration;
  final OnboardingCubit cubit;

  const OnboardingResultsPage({
    super.key,
    required this.nextAction,
    required this.criticalAlerts,
    required this.checklistsByRoom,
    required this.healthScore,
    required this.estimatedDuration,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingCubit, OnboardingState>(
      bloc: cubit,
      listener: (context, state) {
        print('🔵 [RESULTS] Listener - Estado: ${state.runtimeType}');

        if (state is OnboardingCompleted) {
          print(
              '✅ [RESULTS] OnboardingCompleted recebido - Navegando para home...');
          if (context.mounted) {
            context.go('/home');
          }
        } else if (state is OnboardingError) {
          print('❌ [RESULTS] Erro: ${state.message}');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSuccessCard(),
                      const SizedBox(height: AppSpacing.xl),
                      _buildHealthScore(),
                      const SizedBox(height: AppSpacing.xl),
                      _buildEstimatedDuration(),
                      const SizedBox(height: AppSpacing.xl),
                      _buildNextAction(),
                      const SizedBox(height: AppSpacing.xl),
                      if (criticalAlerts.isNotEmpty) ...[
                        _buildCriticalAlerts(),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                      _buildChecklistsSummary(),
                      const SizedBox(height: AppSpacing.xl),
                      _buildActionButtons(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.go('/home'),
          ),
          Expanded(
            child: Text(
              'Seu Plano Personalizado',
              style: AppTextStyles.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // Balance the close button
        ],
      ),
    );
  }

  Widget _buildSuccessCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              size: 64,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Tudo Pronto!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Criamos um plano personalizado para sua reforma',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHealthScore() {
    Color scoreColor;
    String scoreLabel;
    IconData scoreIcon;

    if (healthScore >= 80) {
      scoreColor = AppColors.success;
      scoreLabel = 'Excelente';
      scoreIcon = Icons.sentiment_very_satisfied;
    } else if (healthScore >= 60) {
      scoreColor = AppColors.warning;
      scoreLabel = 'Bom';
      scoreIcon = Icons.sentiment_satisfied;
    } else {
      scoreColor = AppColors.error;
      scoreLabel = 'Atenção Necessária';
      scoreIcon = Icons.sentiment_dissatisfied;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.favorite, color: scoreColor, size: 24),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Saúde da Reforma',
                style: AppTextStyles.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: healthScore / 100,
                  strokeWidth: 12,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                ),
              ),
              Column(
                children: [
                  Text(
                    '$healthScore',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                  Icon(scoreIcon, color: scoreColor, size: 32),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            scoreLabel,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: scoreColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstimatedDuration() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: const Icon(
              Icons.schedule,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Duração Estimada',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  '$estimatedDuration dias',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Aproximadamente ${(estimatedDuration / 30).ceil()} meses',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextAction() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.infoLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.info, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb, color: AppColors.info, size: 24),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Próximo Passo',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            nextAction,
            style: AppTextStyles.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildCriticalAlerts() {
    final criticalCount = criticalAlerts
        .where((a) => a.priority == AlertPriority.critical)
        .length;
    final highCount =
        criticalAlerts.where((a) => a.priority == AlertPriority.high).length;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: AppColors.error, size: 24),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Alertas Críticos',
                style: AppTextStyles.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.errorLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Column(
              children: [
                Text(
                  'Identificamos ${criticalAlerts.length} alertas importantes',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '$criticalCount críticos • $highCount alta prioridade',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...criticalAlerts.take(3).map((alert) => _buildAlertPreview(alert)),
          if (criticalAlerts.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                '+ ${criticalAlerts.length - 3} alertas adicionais',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAlertPreview(CriticalAlertEntity alert) {
    Color priorityColor;
    switch (alert.priority) {
      case AlertPriority.critical:
        priorityColor = AppColors.error;
        break;
      case AlertPriority.high:
        priorityColor = AppColors.warning;
        break;
      case AlertPriority.medium:
        priorityColor = AppColors.info;
        break;
      case AlertPriority.low:
        priorityColor = AppColors.success;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: priorityColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: priorityColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: priorityColor, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              alert.title,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistsSummary() {
    final totalItems = checklistsByRoom.values.fold<int>(
      0,
      (sum, items) => sum + items.length,
    );
    final criticalItems = checklistsByRoom.values.fold<int>(
      0,
      (sum, items) => sum + items.where((item) => item.isCritical).length,
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.checklist, color: AppColors.primary, size: 24),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Checklists Personalizados',
                style: AppTextStyles.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Column(
              children: [
                Text(
                  'Criamos $totalItems itens em ${checklistsByRoom.length} ambientes',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '$criticalItems itens críticos identificados',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...checklistsByRoom.entries.map((entry) {
            final roomName = _getRoomDisplayName(entry.key);
            final itemCount = entry.value.length;
            final criticalCount =
                entry.value.where((item) => item.isCritical).length;

            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Row(
                children: [
                  Icon(_getRoomIcon(entry.key),
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      roomName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '$itemCount itens',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (criticalCount > 0) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Text(
                        '$criticalCount críticos',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            print(
                '🔵 [RESULTS] Botão pressionado - Chamando confirmResults...');
            // Chamar confirmResults e aguardar conclusão
            await cubit.confirmResults();

            // Navegar diretamente após salvar tudo
            // (o listener pode não funcionar se o cubit estiver fechado)
            print(
                '🔵 [RESULTS] confirmResults concluído - Navegando para home...');
            if (context.mounted) {
              context.go('/home');
            }
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textInverse,
          ),
          child: const Text('Começar Minha Reforma'),
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton(
          onPressed: () {
            // Navegar para página de riscos identificados
            final resultsState = cubit.state as OnboardingResultsReady;
            context.push(
              RouteNames.reformRisks,
              extra: {
                'risks': resultsState.reformRisks,
                'onContinue': () {
                  // Após ver os riscos, voltar para esta página
                  context.pop();
                },
              },
            );
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
          ),
          child: const Text('Ver Detalhes Completos'),
        ),
      ],
    );
  }

  String _getRoomDisplayName(String roomKey) {
    const roomNames = {
      'living_room': 'Sala',
      'kitchen': 'Cozinha',
      'laundry': 'Lavanderia',
      'bathroom': 'Banheiro',
      'bedroom': 'Quarto',
      'office': 'Escritório',
      'balcony': 'Varanda',
    };
    return roomNames[roomKey] ?? roomKey;
  }

  IconData _getRoomIcon(String roomKey) {
    const roomIcons = {
      'living_room': Icons.weekend,
      'kitchen': Icons.kitchen,
      'laundry': Icons.local_laundry_service,
      'bathroom': Icons.bathroom,
      'bedroom': Icons.bed,
      'office': Icons.computer,
      'balcony': Icons.balcony,
    };
    return roomIcons[roomKey] ?? Icons.room;
  }
}

// Made with Bob
