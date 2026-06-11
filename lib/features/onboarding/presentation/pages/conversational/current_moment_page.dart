import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../cubit/conversational_onboarding_cubit.dart';
import 'critical_items_page.dart';

/// Tela da pergunta mais importante: Em que momento você está?
/// Define todo o fluxo subsequente do onboarding
class CurrentMomentPage extends StatelessWidget {
  const CurrentMomentPage({super.key});

  @override
  Widget build(BuildContext context) {
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
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.lg,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.maxContentWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Indicador de progresso
                _buildProgressIndicator(),

                SizedBox(height: AppSpacing.xl),

                // Título
                Text(
                  'Em que momento\nvocê está?',
                  style: AppTextStyles.displaySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),

                SizedBox(height: AppSpacing.md),

                // Subtítulo
                Text(
                  'Vamos organizar tudo a partir de onde você está',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                SizedBox(height: AppSpacing.xxl),

                // Opções
                _buildMomentOption(
                  context,
                  icon: Icons.key_off,
                  iconColor: AppColors.blue,
                  title: 'Ainda não recebi as chaves',
                  subtitle: 'Vou receber em breve',
                  value: 'not_received_keys',
                ),

                _buildMomentOption(
                  context,
                  icon: Icons.key,
                  iconColor: AppColors.success,
                  title: 'Recebi as chaves recentemente',
                  subtitle: 'Acabei de receber',
                  value: 'just_received',
                ),

                _buildMomentOption(
                  context,
                  icon: Icons.design_services,
                  iconColor: AppColors.primary,
                  title: 'Estou planejando a reforma',
                  subtitle: 'Pensando no que fazer',
                  value: 'planning',
                ),

                _buildMomentOption(
                  context,
                  icon: Icons.construction,
                  iconColor: AppColors.warning,
                  title: 'A obra já começou',
                  subtitle: 'Já tem gente trabalhando',
                  value: 'work_started',
                ),

                _buildMomentOption(
                  context,
                  icon: Icons.format_paint,
                  iconColor: AppColors.accent,
                  title: 'Estou finalizando',
                  subtitle: 'Acabamentos e detalhes',
                  value: 'finishing',
                ),

                _buildMomentOption(
                  context,
                  icon: Icons.home,
                  iconColor: AppColors.success,
                  title: 'Já estou morando',
                  subtitle: 'Quero organizar o que falta',
                  value: 'living',
                ),

                SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Passo 1 de 5',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '20%',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: LinearProgressIndicator(
            value: 0.2,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildMomentOption(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        elevation: 2,
        shadowColor: AppColors.shadowLight,
        child: InkWell(
          onTap: () {
            final cubit = context.read<ConversationalOnboardingCubit>();
            cubit.updateCurrentMoment(value);

            // Navegar para a próxima tela (itens críticos - a mais valiosa!)
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: cubit,
                  child: const CriticalItemsPage(),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Ícone
                Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: AppSpacing.iconLg,
                  ),
                ),

                SizedBox(width: AppSpacing.md),

                // Textos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xxs),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Seta
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textSecondary,
                  size: AppSpacing.iconSm,
                ),
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
