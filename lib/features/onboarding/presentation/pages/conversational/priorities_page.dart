import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../cubit/conversational_onboarding_cubit.dart';
import '../../cubit/conversational_onboarding_state.dart';
import 'project_name_page.dart';
import 'results_page.dart';

/// Tela de prioridades: O que é mais importante para você?
class PrioritiesPage extends StatelessWidget {
  const PrioritiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    print('🏗️ PrioritiesPage build chamado');

    return BlocListener<ConversationalOnboardingCubit,
        ConversationalOnboardingState>(
      listenWhen: (previous, current) {
        print(
            '🎧 listenWhen - previous: ${previous.runtimeType}, current: ${current.runtimeType}');
        return current is ConversationalOnboardingResultsReady;
      },
      listener: (context, state) {
        print('🎧 BlocListener - estado: ${state.runtimeType}');
        if (state is ConversationalOnboardingResultsReady) {
          print('🎯 Navegando para ResultsPage...');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<ConversationalOnboardingCubit>(),
                child: ResultsPage(
                  nextAction: state.nextAction,
                  nextActionDescription: state.nextActionDescription,
                  criticalAlerts: state.criticalAlerts,
                  estimatedDurationDays: state.estimatedDurationDays,
                  estimatedBudget: state.estimatedBudget,
                  currentPhase: state.currentPhase,
                  alertsCount: state.alertsCount,
                ),
              ),
            ),
          );
        }
      },
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progresso
              Row(
                children: [
                  Text('Passo 3 de 5', style: AppTextStyles.labelMedium),
                  const Spacer(),
                  Text('60%',
                      style: AppTextStyles.labelMedium
                          .copyWith(color: AppColors.primary)),
                ],
              ),
              SizedBox(height: AppSpacing.sm),
              LinearProgressIndicator(
                  value: 0.6, backgroundColor: AppColors.surfaceVariant),

              SizedBox(height: AppSpacing.xl),

              Text('O que é mais\nimportante para você?',
                  style: AppTextStyles.displaySmall
                      .copyWith(fontWeight: FontWeight.w700)),
              SizedBox(height: AppSpacing.md),
              Text('Isso vai personalizar as recomendações',
                  style: AppTextStyles.bodyLarge
                      .copyWith(color: AppColors.textSecondary)),

              SizedBox(height: AppSpacing.xxl),

              _buildOption(context, Icons.savings_outlined, 'Economizar',
                  'Gastar o mínimo possível', 'save_money', AppColors.success),
              _buildOption(context, Icons.speed, 'Terminar rápido',
                  'Mudar o quanto antes', 'finish_fast', AppColors.warning),
              _buildOption(context, Icons.shield_outlined, 'Evitar problemas',
                  'Sem dor de cabeça', 'avoid_problems', AppColors.blue),
              _buildOption(context, Icons.star_outline, 'Melhor acabamento',
                  'Qualidade acima de tudo', 'best_finish', AppColors.accent),
              _buildOption(
                  context,
                  Icons.account_balance_wallet_outlined,
                  'Controlar gastos',
                  'Saber onde vai cada centavo',
                  'control_costs',
                  AppColors.primary),
              _buildOption(
                  context,
                  Icons.checklist,
                  'Organizar tudo',
                  'Ter tudo documentado',
                  'organize_everything',
                  AppColors.success),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, IconData icon, String title,
      String subtitle, String value, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        elevation: 2,
        child: InkWell(
          onTap: () async {
            print('🖱️ Botão clicado: $value');
            final cubit = context.read<ConversationalOnboardingCubit>();
            cubit.updateMainPriority(value);

            if (!context.mounted) return;

            // Navegar para a página de nome do projeto
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: cubit,
                  child: const ProjectNamePage(),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                  child: Icon(icon, color: color, size: AppSpacing.iconLg),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: AppTextStyles.titleMedium
                              .copyWith(fontWeight: FontWeight.w600)),
                      Text(subtitle,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    color: AppColors.textSecondary, size: AppSpacing.iconSm),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Made with ❤️ by Bob

// Made with Bob
