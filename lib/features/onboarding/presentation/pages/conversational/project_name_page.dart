import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../cubit/conversational_onboarding_cubit.dart';
import '../../cubit/conversational_onboarding_state.dart';
import 'results_page.dart';

/// Tela para definir o nome do projeto
/// Permite que o usuário nomeie seu projeto de reforma
class ProjectNamePage extends StatefulWidget {
  const ProjectNamePage({super.key});

  @override
  State<ProjectNamePage> createState() => _ProjectNamePageState();
}

class _ProjectNamePageState extends State<ProjectNamePage> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Carregar nome salvo se existir
    final cubit = context.read<ConversationalOnboardingCubit>();
    final state = cubit.state;
    if (state is ConversationalOnboardingInProgress) {
      _controller.text = state.progress.projectName ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _continue() async {
    if (_formKey.currentState!.validate()) {
      final cubit = context.read<ConversationalOnboardingCubit>();
      cubit.updateProjectName(_controller.text.trim());

      try {
        // Gerar resultados
        final results = await cubit.generateResults();

        // Navegar para ResultsPage com os dados
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: cubit,
                child: ResultsPage(
                  nextAction: results['nextAction'] as String,
                  nextActionDescription:
                      results['nextActionDescription'] as String,
                  criticalAlerts:
                      List<String>.from(results['criticalAlerts'] as List),
                  estimatedDurationDays:
                      results['estimatedDurationDays'] as int,
                  estimatedBudget:
                      (results['estimatedBudget'] as double?) ?? 0.0,
                  currentPhase: results['currentPhase'] as String,
                  alertsCount: results['alertsCount'] as int,
                ),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao gerar resultados: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: 0.88, // 88% completo (passo 4.5 de 5)
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.screenPadding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: AppSpacing.xl),

                      // Ícone
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: AppColors.gradientPrimary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.edit_note,
                            size: 40,
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                      ),

                      SizedBox(height: AppSpacing.xl),

                      // Título
                      Text(
                        'Dê um nome para seu projeto',
                        style: AppTextStyles.displaySmall.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      SizedBox(height: AppSpacing.sm),

                      // Subtítulo
                      Text(
                        'Isso ajuda a organizar caso você tenha mais de uma reforma',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),

                      SizedBox(height: AppSpacing.xl),

                      // Campo de texto
                      TextFormField(
                        controller: _controller,
                        decoration: InputDecoration(
                          labelText: 'Nome do projeto',
                          hintText: 'Ex: Apartamento Centro, Casa Praia...',
                          prefixIcon: Icon(Icons.home_work),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                          ),
                          filled: true,
                          fillColor: AppColors.surface,
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, dê um nome ao projeto';
                          }
                          if (value.trim().length < 3) {
                            return 'Nome muito curto (mínimo 3 caracteres)';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => _continue(),
                      ),

                      SizedBox(height: AppSpacing.md),

                      // Dica
                      Container(
                        padding: EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                          border: Border.all(
                            color: AppColors.info.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: AppColors.info,
                              size: 20,
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                'Escolha um nome que faça sentido para você. Você poderá alterá-lo depois.',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.info,
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

            // Botões fixos
            Container(
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
                child: Row(
                  children: [
                    // Botão Voltar
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding:
                              EdgeInsets.symmetric(vertical: AppSpacing.md),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusLg),
                          ),
                        ),
                        child: Text(
                          'Voltar',
                          style: AppTextStyles.titleMedium,
                        ),
                      ),
                    ),

                    SizedBox(width: AppSpacing.md),

                    // Botão Continuar
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _continue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding:
                              EdgeInsets.symmetric(vertical: AppSpacing.md),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusLg),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Continuar',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.textOnPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                      ),
                    ),
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
