import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/tutorial_step.dart';
import '../widgets/tutorial_page_indicator.dart';
import '../widgets/tutorial_step_content.dart';

/// Página de tutorial para novos usuários
class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLastPage = false;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged() {
    final page = _pageController.page?.round() ?? 0;
    if (page != _currentPage) {
      setState(() {
        _currentPage = page;
        _isLastPage = page == TutorialSteps.steps.length - 1;
      });
    }
  }

  Future<void> _completeTutorial() async {
    // Marcar tutorial como concluído usando Hive
    final box = await Hive.openBox('app_settings');
    await box.put(AppConstants.keyTutorialCompleted, true);

    if (!mounted) return;

    // Navegar para login
    context.go(RouteNames.login);
  }

  void _skipTutorial() {
    _completeTutorial();
  }

  void _nextPage() {
    if (_isLastPage) {
      _completeTutorial();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header com botão de pular
            _buildHeader(),

            // Conteúdo do tutorial
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: TutorialSteps.steps.length,
                itemBuilder: (context, index) {
                  return TutorialStepContent(
                    step: TutorialSteps.steps[index],
                    isFirstPage: index == 0,
                    isLastPage: index == TutorialSteps.steps.length - 1,
                  );
                },
              ),
            ),

            // Footer com indicadores e botões
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo ou título
          Text(
            'Costruttore',
            style: AppTextStyles.headingLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Botão pular (não mostrar na última página)
          if (!_isLastPage)
            TextButton(
              onPressed: _skipTutorial,
              child: Text(
                'Pular',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicadores de página
          TutorialPageIndicator(
            currentPage: _currentPage,
            pageCount: TutorialSteps.steps.length,
          ),

          const SizedBox(height: AppSpacing.l),

          // Botões de navegação
          Row(
            children: [
              // Botão voltar (não mostrar na primeira página)
              if (_currentPage > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _previousPage,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.m,
                      ),
                      side: const BorderSide(
                        color: AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      'Voltar',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),

              if (_currentPage > 0) const SizedBox(width: AppSpacing.m),

              // Botão próximo/começar
              Expanded(
                flex: _currentPage > 0 ? 1 : 2,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
                    elevation: 2,
                  ),
                  child: Text(
                    _isLastPage ? 'Começar' : 'Próximo',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Made with Bob
