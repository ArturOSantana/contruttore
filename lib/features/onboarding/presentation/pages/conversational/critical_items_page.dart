import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../cubit/conversational_onboarding_cubit.dart';
import 'priorities_page.dart';

/// Tela da pergunta mais valiosa: O que você não quer esquecer?
/// Essa pergunta sozinha pode economizar milhares de reais
class CriticalItemsPage extends StatefulWidget {
  const CriticalItemsPage({super.key});

  @override
  State<CriticalItemsPage> createState() => _CriticalItemsPageState();
}

class _CriticalItemsPageState extends State<CriticalItemsPage> {
  final Set<String> _selectedItems = {};

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
        child: Column(
          children: [
            Expanded(
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
                        'O que você não\nquer esquecer?',
                        style: AppTextStyles.displaySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),

                      SizedBox(height: AppSpacing.md),

                      // Subtítulo com destaque
                      Container(
                        padding: EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                          border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: AppColors.warning,
                              size: AppSpacing.iconMd,
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                'Tudo isso precisa ser planejado ANTES do projeto elétrico',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: AppSpacing.xl),

                      // Itens críticos
                      _buildCriticalItem(
                        icon: Icons.ac_unit,
                        title: 'Ar-condicionado',
                        subtitle: 'Defina os ambientes antes da elétrica',
                        value: 'air_conditioning',
                        savings: 'Economize até R\$ 3.000 em retrabalho',
                      ),

                      _buildCriticalItem(
                        icon: Icons.wifi,
                        title: 'Internet cabeada',
                        subtitle: 'Planeje os pontos de rede',
                        value: 'wired_internet',
                        savings: 'Evite cabos aparentes depois',
                      ),

                      _buildCriticalItem(
                        icon: Icons.kitchen,
                        title: 'Lava-louças',
                        subtitle: 'Reserve espaço e ponto elétrico',
                        value: 'dishwasher',
                        savings: 'Economize R\$ 1.500 em adaptações',
                      ),

                      _buildCriticalItem(
                        icon: Icons.water_drop,
                        title: 'Aquecedor',
                        subtitle: 'Defina tipo antes da hidráulica',
                        value: 'water_heater',
                        savings: 'Evite quebrar paredes depois',
                      ),

                      _buildCriticalItem(
                        icon: Icons.home_outlined,
                        title: 'Automação residencial',
                        subtitle: 'Interruptores inteligentes, sensores',
                        value: 'automation',
                        savings: 'Economize R\$ 2.000 em retrofit',
                      ),

                      _buildCriticalItem(
                        icon: Icons.lock_outline,
                        title: 'Fechadura eletrônica',
                        subtitle: 'Planeje alimentação elétrica',
                        value: 'smart_lock',
                        savings: 'Evite gambiarras',
                      ),

                      _buildCriticalItem(
                        icon: Icons.videocam_outlined,
                        title: 'Câmeras de segurança',
                        subtitle: 'Pontos de rede e energia',
                        value: 'cameras',
                        savings: 'Instalação profissional',
                      ),

                      SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
            ),

            // Botão fixo no rodapé
            _buildBottomButton(context),
          ],
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
              'Passo 2 de 5',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '40%',
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
            value: 0.4,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildCriticalItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required String savings,
  }) {
    final isSelected = _selectedItems.contains(value);

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.05)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        elevation: isSelected ? 4 : 2,
        shadowColor: isSelected
            ? AppColors.primary.withValues(alpha: 0.3)
            : AppColors.shadowLight,
        child: InkWell(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedItems.remove(value);
              } else {
                _selectedItems.add(value);
              }
            });
          },
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Checkbox
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: AppColors.textOnPrimary,
                        )
                      : null,
                ),

                SizedBox(width: AppSpacing.md),

                // Ícone
                Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: AppSpacing.iconMd,
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
                      SizedBox(height: AppSpacing.xs),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: Text(
                          savings,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_selectedItems.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  '${_selectedItems.length} ${_selectedItems.length == 1 ? 'item selecionado' : 'itens selecionados'}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final cubit = context.read<ConversationalOnboardingCubit>();
                  cubit.updateCriticalItems(_selectedItems.toList());

                  // Navegar para prioridades
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: cubit,
                        child: const PrioritiesPage(),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                  elevation: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _selectedItems.isEmpty ? 'Pular' : 'Continuar',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    const Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Made with ❤️ by Bob

// Made with Bob
