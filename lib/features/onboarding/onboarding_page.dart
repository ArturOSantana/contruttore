import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import '../../injection_container.dart';
import 'presentation/cubit/onboarding_cubit.dart';
import 'presentation/cubit/onboarding_state.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Step 1
  final _projectNameController = TextEditingController();

  // Step 2
  final _constructorNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _areaController = TextEditingController();
  DateTime? _deliveryDate;
  DateTime? _contractDate;

  // Step 3
  String? _currentSituation;

  // Step 4
  String? _budgetOption;
  final _budgetValueController = TextEditingController();
  final _budgetMinController = TextEditingController();
  final _budgetMaxController = TextEditingController();

  // Step 5
  final _propertyValueController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _projectNameController.dispose();
    _constructorNameController.dispose();
    _addressController.dispose();
    _areaController.dispose();
    _budgetValueController.dispose();
    _budgetMinController.dispose();
    _budgetMaxController.dispose();
    _propertyValueController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 4) {
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

  void _createProject(BuildContext context) {
    print('🔵 [ONBOARDING] Botão Criar Projeto pressionado');

    // Validações básicas
    if (_projectNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, informe o nome do projeto')),
      );
      return;
    }

    if (_constructorNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, informe o nome da construtora'),
        ),
      );
      return;
    }

    if (_currentSituation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione sua situação atual'),
        ),
      );
      return;
    }

    final cubit = context.read<OnboardingCubit>();
    print('🔵 [ONBOARDING] Cubit obtido: ${cubit.runtimeType}');

    // Calcular orçamento total
    double? totalBudget;
    if (_budgetOption == 'exact' && _budgetValueController.text.isNotEmpty) {
      totalBudget = double.tryParse(_budgetValueController.text);
    } else if (_budgetOption == 'range' &&
        _budgetMaxController.text.isNotEmpty) {
      totalBudget = double.tryParse(_budgetMaxController.text);
    }

    print('🔵 [ONBOARDING] Preparando dados do projeto...');
    print('  - Nome: ${_projectNameController.text}');
    print('  - Construtora: ${_constructorNameController.text}');
    print('  - Situação: $_currentSituation');
    print('  - Orçamento: $totalBudget');

    // Inicializar o estado se necessário
    if (cubit.state is! OnboardingInProgress) {
      print('🔵 [ONBOARDING] Inicializando estado InProgress');
      cubit.startOnboarding();
    }

    // Preparar dados para o cubit
    final projectData = {
      'projectName': _projectNameController.text,
      'constructorName': _constructorNameController.text,
      'address': _addressController.text.isEmpty
          ? 'Não informado'
          : _addressController.text,
      'area': double.tryParse(_areaController.text) ?? 50.0,
      'deliveryDate':
          _deliveryDate ?? DateTime.now().add(const Duration(days: 365)),
      'contractDate': _contractDate ?? DateTime.now(),
      'totalBudget': totalBudget ?? 0.0,
      'propertyValue': double.tryParse(_propertyValueController.text) ?? 0.0,
      'currentSituation': _currentSituation ?? 'a',
    };

    print('🔵 [ONBOARDING] Atualizando dados no cubit...');
    cubit.updateStepData(projectData);

    print('🔵 [ONBOARDING] Chamando completeOnboarding...');
    cubit.completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OnboardingCubit>(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocConsumer<OnboardingCubit, OnboardingState>(
            listener: (context, state) {
              if (state is OnboardingError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              } else if (state is OnboardingCompleted) {
                // Usar GoRouter ao invés de Navigator
                context.go('/home');
              }
            },
            builder: (context, state) {
              if (state is OnboardingLoading) {
                return const Center(child: CircularProgressIndicator());
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
                        _buildStep1(),
                        _buildStep2(),
                        _buildStep3(),
                        _buildStep4(),
                        _buildStep5(),
                      ],
                    ),
                  ),

                  // Navigation buttons
                  _buildNavigationButtons(context),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: List.generate(5, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < 4 ? AppSpacing.xs : 0),
              decoration: BoxDecoration(
                color: index <= _currentStep
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

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Passo 1 de 5',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('Nome do Projeto', style: AppTextStyles.displayMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Como você quer chamar este projeto?',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          TextField(
            controller: _projectNameController,
            decoration: const InputDecoration(
              labelText: 'Nome do projeto',
              hintText: 'Ex: Apt Brooklin Bloco A',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Botão para onboarding retroativo
          OutlinedButton.icon(
            onPressed: () {
              context.push('/retroactive-onboarding');
            },
            icon: const Icon(Icons.construction),
            label: const Text('Já tenho obra em andamento'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              side: const BorderSide(color: AppColors.primary, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.infoLight,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: AppColors.info),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Use um nome que te ajude a identificar rapidamente',
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
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Passo 2 de 5',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('Dados do Imóvel', style: AppTextStyles.displayMedium),
          const SizedBox(height: AppSpacing.xl),

          TextField(
            controller: _constructorNameController,
            decoration: const InputDecoration(
              labelText: 'Nome da construtora',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          TextField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Endereço',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          TextField(
            controller: _areaController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Área (m²)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          ListTile(
            title: const Text('Data de entrega prevista'),
            subtitle: Text(
              _deliveryDate != null
                  ? '${_deliveryDate!.day}/${_deliveryDate!.month}/${_deliveryDate!.year}'
                  : 'Selecione a data',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 365)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 3650)),
              );
              if (date != null) setState(() => _deliveryDate = date);
            },
          ),

          ListTile(
            title: const Text('Data de assinatura do contrato'),
            subtitle: Text(
              _contractDate != null
                  ? '${_contractDate!.day}/${_contractDate!.month}/${_contractDate!.year}'
                  : 'Selecione a data',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 3650)),
                lastDate: DateTime.now(),
              );
              if (date != null) setState(() => _contractDate = date);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Passo 3 de 5',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('Situação Atual', style: AppTextStyles.displayMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Em que momento você está?',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          _buildSituationCard(
            'a',
            'Acabei de assinar o contrato',
            'Vou acompanhar a construção',
          ),
          const SizedBox(height: AppSpacing.md),

          _buildSituationCard(
            'b',
            'Obra em andamento',
            'Acompanho a construtora',
          ),
          const SizedBox(height: AppSpacing.md),

          _buildSituationCard('c', 'Recebi as chaves', 'Vou reformar'),
          const SizedBox(height: AppSpacing.md),

          _buildSituationCard(
            'd',
            'Reforma em andamento',
            'Já estou reformando',
          ),
        ],
      ),
    );
  }

  Widget _buildSituationCard(String value, String title, String subtitle) {
    final isSelected = _currentSituation == value;
    return InkWell(
      onTap: () => setState(() => _currentSituation = value),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryLight.withValues(alpha: 0.1)
              : AppColors.surface,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.headlineSmall),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Passo 4 de 5',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('Orçamento', style: AppTextStyles.displayMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Você tem uma ideia de quanto vai gastar na reforma e mobília?',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          RadioListTile<String>(
            title: const Text('Sim, tenho um valor exato'),
            value: 'exact',
            groupValue: _budgetOption,
            onChanged: (value) => setState(() => _budgetOption = value),
          ),
          if (_budgetOption == 'exact') ...[
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.xl),
              child: TextField(
                controller: _budgetValueController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Valor total (R\$)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],

          RadioListTile<String>(
            title: const Text('Tenho uma faixa de valores'),
            value: 'range',
            groupValue: _budgetOption,
            onChanged: (value) => setState(() => _budgetOption = value),
          ),
          if (_budgetOption == 'range') ...[
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.xl),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _budgetMinController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'De (R\$)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextField(
                      controller: _budgetMaxController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Até (R\$)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          RadioListTile<String>(
            title: const Text('Ainda não sei'),
            value: 'unknown',
            groupValue: _budgetOption,
            onChanged: (value) => setState(() => _budgetOption = value),
          ),

          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.infoLight,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.info),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      'Nota educativa',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Além do valor do imóvel, costumam aparecer: ITBI (~2,5%), escritura (~1%), reforma e mobília. O Costruttore vai te ajudar a ver o total real.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep5() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Passo 5 de 5',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('Resumo', style: AppTextStyles.displayMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Confirme os dados do seu projeto',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          _buildSummaryItem('Projeto', _projectNameController.text),
          _buildSummaryItem('Construtora', _constructorNameController.text),
          _buildSummaryItem('Endereço', _addressController.text),
          _buildSummaryItem('Área', '${_areaController.text} m²'),
          _buildSummaryItem(
            'Entrega',
            _deliveryDate != null
                ? '${_deliveryDate!.day}/${_deliveryDate!.month}/${_deliveryDate!.year}'
                : 'Não informado',
          ),

          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _propertyValueController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Valor do imóvel (R\$) - Opcional',
              border: OutlineInputBorder(),
              helperText: 'Para calcular o custo total real',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52)),
                child: const Text('Voltar'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                if (_currentStep == 4) {
                  _createProject(context);
                } else {
                  _nextStep();
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 52),
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textInverse,
              ),
              child: Text(_currentStep == 4 ? 'Criar Projeto' : 'Continuar'),
            ),
          ),
        ],
      ),
    );
  }
}

// Made with Bob
