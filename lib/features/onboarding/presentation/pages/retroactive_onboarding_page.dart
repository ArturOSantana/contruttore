import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/budget_option.dart';
import '../../domain/entities/retroactive_expense_entry.dart';
import '../cubit/retroactive_cubit.dart';
import '../cubit/retroactive_state.dart';
import 'retroactive_steps_3_4.dart';

/// Página de onboarding retroativo (4 steps)
class RetroactiveOnboardingPage extends StatefulWidget {
  final String userId;
  final String projectName;
  final String address;
  final double area;
  final DateTime deliveryDate;
  final DateTime contractDate;
  final String constructorName;

  const RetroactiveOnboardingPage({
    super.key,
    required this.userId,
    required this.projectName,
    required this.address,
    required this.area,
    required this.deliveryDate,
    required this.contractDate,
    required this.constructorName,
  });

  @override
  State<RetroactiveOnboardingPage> createState() =>
      _RetroactiveOnboardingPageState();
}

class _RetroactiveOnboardingPageState extends State<RetroactiveOnboardingPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    context.read<RetroactiveCubit>().start();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                ),
                onPressed: _previousStep,
              )
            : null,
        title: Text('Obra em Andamento', style: AppTextStyles.headingMedium),
      ),
      body: BlocConsumer<RetroactiveCubit, RetroactiveState>(
        listener: (context, state) {
          if (state is RetroactiveSuccess) {
            // Navegar para home com o novo projeto usando GoRouter
            context.go('/home');
          } else if (state is RetroactiveError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is RetroactiveCreating) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          return Column(
            children: [
              // Progress indicator
              _buildProgressIndicator(),

              // Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _Step1PhaseSelection(onNext: _nextStep),
                    _Step2BudgetOption(onNext: _nextStep),
                    Step3QuickSuppliers(onNext: _nextStep),
                    Step4Summary(
                      userId: widget.userId,
                      projectName: widget.projectName,
                      address: widget.address,
                      area: widget.area,
                      deliveryDate: widget.deliveryDate,
                      contractDate: widget.contractDate,
                      constructorName: widget.constructorName,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      color: AppColors.surface,
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < 3 ? AppSpacing.xs : 0),
              decoration: BoxDecoration(
                color: isCompleted || isActive
                    ? AppColors.primary
                    : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Step 1: Seleção da fase atual
class _Step1PhaseSelection extends StatelessWidget {
  final VoidCallback onNext;

  const _Step1PhaseSelection({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RetroactiveCubit, RetroactiveState>(
      builder: (context, state) {
        final selectedPhase = state is RetroactiveCollecting
            ? state.selectedPhaseNumber
            : null;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Em qual fase sua obra está?',
                style: AppTextStyles.displayMedium,
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                'Selecione a fase atual para configurarmos o app corretamente',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Grid de fases (3 colunas x 4 linhas)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: AppSpacing.m,
                  mainAxisSpacing: AppSpacing.m,
                  childAspectRatio: 0.8,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final phaseNumber = index + 1;
                  final isSelected = selectedPhase == phaseNumber;

                  return _PhaseCard(
                    phaseNumber: phaseNumber,
                    isSelected: isSelected,
                    onTap: () {
                      context.read<RetroactiveCubit>().selectCurrentPhase(
                        phaseNumber,
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: AppSpacing.xl),

              // Botão continuar
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: selectedPhase != null ? onNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.border,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.m),
                    ),
                  ),
                  child: Text(
                    'Continuar',
                    style: AppTextStyles.headingSmall.copyWith(
                      color: AppColors.textInverse,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Card de fase individual
class _PhaseCard extends StatelessWidget {
  final int phaseNumber;
  final bool isSelected;
  final VoidCallback onTap;

  const _PhaseCard({
    required this.phaseNumber,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final phaseName = _getPhaseShortName(phaseNumber);
    final phaseColor = _getPhaseColor(phaseNumber);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? phaseColor.withValues(alpha: 0.1)
              : AppColors.surface,
          border: Border.all(
            color: isSelected ? phaseColor : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppRadius.m),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: phaseColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? phaseColor : AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$phaseNumber',
                  style: AppTextStyles.headingMedium.copyWith(
                    color: isSelected
                        ? AppColors.textInverse
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Text(
                phaseName,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? phaseColor : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPhaseShortName(int number) {
    const names = {
      1: 'Assinatura',
      2: 'Acompanhamento',
      3: 'Personalização',
      4: 'Preparação',
      5: 'Vistoria',
      6: 'Regularização',
      7: 'Projeto',
      8: 'Demolição',
      9: 'Instalações',
      10: 'Revestimentos',
      11: 'Pintura',
      12: 'Marcenaria',
    };
    return names[number] ?? 'Fase $number';
  }

  Color _getPhaseColor(int number) {
    if (number <= 5) return AppColors.phaseBlue;
    if (number <= 8) return AppColors.phaseGreen;
    if (number <= 10) return AppColors.phaseOrange;
    return AppColors.phasePurple;
  }
}

/// Step 2: Opção de orçamento
class _Step2BudgetOption extends StatelessWidget {
  final VoidCallback onNext;

  const _Step2BudgetOption({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RetroactiveCubit, RetroactiveState>(
      builder: (context, state) {
        final selectedOption = state is RetroactiveCollecting
            ? state.budgetOption
            : null;
        final totalSpent = state is RetroactiveCollecting
            ? state.totalSpent
            : null;
        final expenseEntries = state is RetroactiveCollecting
            ? state.expenseEntries
            : <RetroactiveExpenseEntry>[];

        final canProceed = state is RetroactiveCollecting && state.canProceed;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quanto você já gastou?',
                style: AppTextStyles.displayMedium,
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                'Escolha como quer informar os gastos até agora',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Opção 1: Sei o total
              _BudgetOptionCard(
                option: BudgetOption.total,
                isSelected: selectedOption == BudgetOption.total,
                icon: Icons.calculate_outlined,
                onTap: () {
                  context.read<RetroactiveCubit>().setBudgetOption(
                    BudgetOption.total,
                  );
                },
              ),

              // Campo de valor (se opção 1 selecionada)
              if (selectedOption == BudgetOption.total) ...[
                const SizedBox(height: AppSpacing.m),
                _TotalSpentField(
                  initialValue: totalSpent,
                  onChanged: (value) {
                    context.read<RetroactiveCubit>().setTotalSpent(value);
                  },
                ),
              ],

              const SizedBox(height: AppSpacing.m),

              // Opção 2: Tenho notas fiscais
              _BudgetOptionCard(
                option: BudgetOption.receipts,
                isSelected: selectedOption == BudgetOption.receipts,
                icon: Icons.receipt_long_outlined,
                onTap: () {
                  context.read<RetroactiveCubit>().setBudgetOption(
                    BudgetOption.receipts,
                  );
                },
              ),

              // Lista de despesas (se opção 2 selecionada)
              if (selectedOption == BudgetOption.receipts) ...[
                const SizedBox(height: AppSpacing.m),
                _ExpenseEntriesList(entries: expenseEntries),
              ],

              const SizedBox(height: AppSpacing.m),

              // Opção 3: Não sei
              _BudgetOptionCard(
                option: BudgetOption.zero,
                isSelected: selectedOption == BudgetOption.zero,
                icon: Icons.not_interested_outlined,
                onTap: () {
                  context.read<RetroactiveCubit>().setBudgetOption(
                    BudgetOption.zero,
                  );
                },
              ),

              const SizedBox(height: AppSpacing.xl),

              // Botão continuar
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: canProceed ? onNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.border,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.m),
                    ),
                  ),
                  child: Text(
                    'Continuar',
                    style: AppTextStyles.headingSmall.copyWith(
                      color: AppColors.textInverse,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Card de opção de orçamento
class _BudgetOptionCard extends StatelessWidget {
  final BudgetOption option;
  final bool isSelected;
  final IconData icon;
  final VoidCallback onTap;

  const _BudgetOptionCard({
    required this.option,
    required this.isSelected,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surface,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppRadius.m),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppRadius.s),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? AppColors.textInverse
                    : AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.displayName,
                    style: AppTextStyles.headingSmall.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    option.description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

/// Campo para informar valor total gasto
class _TotalSpentField extends StatefulWidget {
  final double? initialValue;
  final ValueChanged<double> onChanged;

  const _TotalSpentField({this.initialValue, required this.onChanged});

  @override
  State<_TotalSpentField> createState() => _TotalSpentFieldState();
}

class _TotalSpentFieldState extends State<_TotalSpentField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialValue != null
          ? widget.initialValue!.toStringAsFixed(2)
          : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.m),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Valor total aproximado',
            style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.s),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            style: AppTextStyles.moneyLarge,
            decoration: InputDecoration(
              prefixText: 'R\$ ',
              prefixStyle: AppTextStyles.moneyLarge,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.s),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.s),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: AppColors.surface,
            ),
            onChanged: (value) {
              final amount = double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
              widget.onChanged(amount);
            },
          ),
        ],
      ),
    );
  }
}

/// Lista de despesas retroativas
class _ExpenseEntriesList extends StatelessWidget {
  final List<RetroactiveExpenseEntry> entries;

  const _ExpenseEntriesList({required this.entries});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.m),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Despesas adicionadas',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  // TODO: Abrir dialog para adicionar despesa
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Adicionar'),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          if (entries.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: Text(
                  'Nenhuma despesa adicionada',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s),
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.s),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.description,
                              style: AppTextStyles.bodyMedium,
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              'R\$ ${entry.amount.toStringAsFixed(2)}',
                              style: AppTextStyles.moneyMedium.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: AppColors.error,
                        onPressed: () {
                          context.read<RetroactiveCubit>().removeExpenseEntry(
                            entry.id,
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          if (entries.isNotEmpty) ...[
            const Divider(height: AppSpacing.l),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: AppTextStyles.headingSmall),
                Text(
                  'R\$ ${entries.fold(0.0, (sum, e) => sum + e.amount).toStringAsFixed(2)}',
                  style: AppTextStyles.moneyMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// Made with Bob
