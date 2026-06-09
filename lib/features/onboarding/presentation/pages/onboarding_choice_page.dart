import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Página de escolha entre onboarding simples ou completo
class OnboardingChoicePage extends StatelessWidget {
  const OnboardingChoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),

              // Título
              Text(
                'Como você quer começar?',
                style: AppTextStyles.headlineLarge,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.sm),

              Text(
                'Escolha a melhor opção para você',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Opção 1: Onboarding Completo (14 steps)
              _buildOptionCard(
                context,
                title: '🎯 Configuração Completa',
                subtitle: 'Recomendado para quem está começando',
                description: 'Responda 14 perguntas e receba:\n'
                    '• Alertas preventivos personalizados\n'
                    '• Checklists por ambiente\n'
                    '• Score de saúde do projeto\n'
                    '• Estimativa de duração',
                duration: '5-7 minutos',
                color: AppColors.primary,
                onTap: () => context.go('/onboarding-14'),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Opção 2: Onboarding Simples (5 steps)
              _buildOptionCard(
                context,
                title: '⚡ Início Rápido',
                subtitle: 'Para quem quer começar logo',
                description: 'Apenas 5 perguntas básicas:\n'
                    '• Nome do projeto\n'
                    '• Dados da construtora\n'
                    '• Situação atual\n'
                    '• Orçamento',
                duration: '2-3 minutos',
                color: AppColors.secondary,
                onTap: () => context.go('/onboarding'),
              ),

              const Spacer(),

              // Botão "Já tenho obra"
              OutlinedButton.icon(
                onPressed: () => context.go('/retroactive-onboarding'),
                icon: const Icon(Icons.construction),
                label: const Text('Já tenho obra em andamento'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  side: const BorderSide(color: AppColors.primary),
                ),
              ),

              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String description,
    required String duration,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: BorderSide(color: color.withOpacity(0.3), width: 2),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style:
                              AppTextStyles.titleLarge.copyWith(color: color),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          subtitle,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      duration,
                      style: AppTextStyles.caption.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                description,
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Começar',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(Icons.arrow_forward, color: color, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Made with Bob
