import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../cubit/conversational_onboarding_cubit.dart';
import '../../cubit/conversational_onboarding_state.dart';
import 'current_moment_page.dart';

/// Tela de boas-vindas do onboarding conversacional
/// Primeira impressão - deve ser acolhedora e clara
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<ConversationalOnboardingCubit,
          ConversationalOnboardingState>(
        listener: (context, state) {
          if (state is ConversationalOnboardingResumePrompt) {
            _showResumeDialog(context, state);
          } else if (state is ConversationalOnboardingInProgress) {
            // Capturar o Cubit antes de navegar
            final cubit = context.read<ConversationalOnboardingCubit>();
            // Navegar para a próxima tela
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: cubit,
                  child: const CurrentMomentPage(),
                ),
              ),
            );
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
                vertical: AppSpacing.xl,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSpacing.maxContentWidth,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Ícone principal
                    _buildHeroIcon(),

                    SizedBox(height: AppSpacing.xxl),

                    // Título
                    Text(
                      'Vamos organizar\nsua reforma',
                      style: AppTextStyles.displaySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: AppSpacing.lg),

                    // Subtítulo
                    Text(
                      'Em menos de 3 minutos vamos descobrir:',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: AppSpacing.xl),

                    // Benefícios
                    _buildBenefitsList(),

                    SizedBox(height: AppSpacing.xxl),

                    // Botão principal
                    _buildStartButton(context),

                    SizedBox(height: AppSpacing.md),

                    // Texto de segurança
                    Text(
                      'Você pode sair e voltar a qualquer momento.\nSeu progresso será salvo automaticamente.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: AppColors.gradientPrimary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: const Icon(
        Icons.home_work_rounded,
        size: 60,
        color: AppColors.textOnPrimary,
      ),
    );
  }

  Widget _buildBenefitsList() {
    final benefits = [
      {
        'icon': Icons.check_circle_outline,
        'text': 'O que falta fazer',
        'color': AppColors.success,
      },
      {
        'icon': Icons.attach_money,
        'text': 'Quanto você pode gastar',
        'color': AppColors.primary,
      },
      {
        'icon': Icons.warning_amber_rounded,
        'text': 'O que não pode esquecer',
        'color': AppColors.warning,
      },
      {
        'icon': Icons.calendar_today,
        'text': 'Quando poderá se mudar',
        'color': AppColors.accent,
      },
    ];

    return Column(
      children: benefits.map((benefit) {
        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.md),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: (benefit['color'] as Color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(
                  benefit['icon'] as IconData,
                  color: benefit['color'] as Color,
                  size: AppSpacing.iconMd,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  benefit['text'] as String,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          context.read<ConversationalOnboardingCubit>().startOnboarding();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          padding: EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.xl,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          elevation: 4,
          shadowColor: AppColors.primary.withValues(alpha: 0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Começar',
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            const Icon(Icons.arrow_forward, size: 24),
          ],
        ),
      ),
    );
  }

  void _showResumeDialog(
      BuildContext context, ConversationalOnboardingResumePrompt state) {
    final daysSince = DateTime.now().difference(state.lastUpdate).inDays;
    final timeText = daysSince == 0
        ? 'hoje'
        : daysSince == 1
            ? 'ontem'
            : 'há $daysSince dias';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: const Icon(
                Icons.history,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            const Expanded(
              child: Text('Continuar de onde parou?'),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Encontramos um cadastro iniciado $timeText.',
              style: AppTextStyles.bodyMedium,
            ),
            SizedBox(height: AppSpacing.md),
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progresso salvo:',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    state.savedProgress.nextStepHint,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<ConversationalOnboardingCubit>().startFresh();
            },
            child: Text(
              'Começar do zero',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<ConversationalOnboardingCubit>().resumeProgress();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }
}

// Made with ❤️ by Bob

// Made with Bob
