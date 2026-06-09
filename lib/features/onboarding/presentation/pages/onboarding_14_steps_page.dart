import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../injection_container.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';

/// Onboarding completo com 14 steps
class Onboarding14StepsPage extends StatefulWidget {
  const Onboarding14StepsPage({super.key});

  @override
  State<Onboarding14StepsPage> createState() => _Onboarding14StepsPageState();
}

class _Onboarding14StepsPageState extends State<Onboarding14StepsPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Step 1: Tipo de Imóvel
  String? _propertyType;

  // Step 2: Situação Atual
  String? _currentSituation;

  // Step 3: Nível da Reforma
  String? _reformLevel;

  // Step 4: O Que Já Foi Feito
  final Set<String> _completedItems = {};

  // Step 5: Tamanho do Imóvel
  String? _propertySize;

  // Step 6: Ambientes
  final Set<String> _selectedRooms = {};

  // Step 6.5: Ambientes Prioritários
  final Set<String> _priorityRooms = {};

  // Step 7: Quem Vai Morar
  String? _residents;

  // Step 8: Home Office
  bool? _hasHomeOffice;

  // Step 9: Pets
  bool? _hasPets;

  // Step 10: Ar-Condicionado
  String? _hasAirConditioning;

  // Step 11: Planejados
  String? _hasCustomFurniture;

  // Step 12: Orçamento
  String? _budgetRange;

  // Step 12.5: Coordenação da Obra (CRÍTICO)
  String? _projectManagementType;

  // Step 13: Prioridades
  final Set<String> _priorities = {};

  // Step 13.5: Prazo de Mudança
  String? _moveInGoal;

  // Step 14: Infraestrutura Crítica
  final Set<String> _criticalInfrastructure = {};

  // Step 14.5: Itens Já Comprados
  final Set<String> _alreadyPurchasedItems = {};

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 17) {
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

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _propertyType != null;
      case 1:
        return _currentSituation != null;
      case 2:
        return _reformLevel != null;
      case 3:
        return true; // Opcional
      case 4:
        return _propertySize != null;
      case 5:
        return _selectedRooms.isNotEmpty;
      case 6:
        return _priorityRooms.isNotEmpty; // Step 6.5
      case 7:
        return _residents != null;
      case 8:
        return _hasHomeOffice != null;
      case 9:
        return _hasPets != null;
      case 10:
        return _hasAirConditioning != null;
      case 11:
        return _hasCustomFurniture != null;
      case 12:
        return _budgetRange != null;
      case 13:
        return _projectManagementType != null; // Step 12.5 - CRÍTICO
      case 14:
        return _priorities.isNotEmpty;
      case 15:
        return _moveInGoal != null; // Step 13.5
      case 16:
        return true; // Step 14 é opcional mas recomendado
      case 17:
        return true; // Step 14.5 é opcional
      default:
        return false;
    }
  }

  void _completeOnboarding(BuildContext context) {
    final cubit = context.read<OnboardingCubit>();

    // Preparar dados
    final data = {
      'propertyType': _propertyType,
      'currentSituation': _currentSituation,
      'reformLevel': _reformLevel,
      'completedItems': _completedItems.toList(),
      'propertySize': _propertySize,
      'selectedRooms': _selectedRooms.toList(),
      'priorityRooms': _priorityRooms.toList(),
      'residents': _residents,
      'hasHomeOffice': _hasHomeOffice,
      'hasPets': _hasPets,
      'hasAirConditioning': _hasAirConditioning,
      'hasCustomFurniture': _hasCustomFurniture,
      'budgetRange': _budgetRange,
      'projectManagementType': _projectManagementType,
      'priorities': _priorities.toList(),
      'moveInGoal': _moveInGoal,
      'criticalInfrastructure': _criticalInfrastructure.toList(),
      'alreadyPurchasedItems': _alreadyPurchasedItems.toList(),
    };

    cubit.updateStepData(data);
    cubit.completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OnboardingCubit>()..startOnboarding(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocConsumer<OnboardingCubit, OnboardingState>(
            listener: (context, state) {
              print('🔵 [14STEPS] Listener - Estado: ${state.runtimeType}');

              if (state is OnboardingError) {
                print('❌ [14STEPS] Erro: ${state.message}');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              } else if (state is OnboardingResultsReady) {
                print('✅ [14STEPS] Navegando para tela de resultados...');
                context.go('/onboarding-results', extra: {
                  'cubit': context.read<OnboardingCubit>(),
                  'nextAction': state.nextAction,
                  'criticalAlerts': state.criticalAlerts,
                  'checklistsByRoom': state.checklistsByRoom,
                  'healthScore': state.healthScore,
                  'estimatedDuration': state.estimatedDuration,
                });
              } else if (state is OnboardingCompleted) {
                print('✅ [14STEPS] Navegando para home...');
                context.go('/home');
              }
            },
            builder: (context, state) {
              if (state is OnboardingLoading) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: AppSpacing.lg),
                      Text('Criando seu projeto...'),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  _buildProgressIndicator(),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildStep1(), // Tipo de Imóvel
                        _buildStep2(), // Situação Atual
                        _buildStep3(), // Nível da Reforma
                        _buildStep4(), // O Que Já Foi Feito
                        _buildStep5(), // Tamanho do Imóvel
                        _buildStep6(), // Ambientes
                        _buildStep6_5(), // Ambientes Prioritários
                        _buildStep7(), // Quem Vai Morar
                        _buildStep8(), // Home Office
                        _buildStep9(), // Pets
                        _buildStep10(), // Ar-Condicionado
                        _buildStep11(), // Planejados
                        _buildStep12(), // Orçamento
                        _buildStep12_5(), // Coordenação da Obra (CRÍTICO)
                        _buildStep13(), // Prioridades
                        _buildStep13_5(), // Prazo de Mudança
                        _buildStep14(), // Infraestrutura Crítica
                        _buildStep14_5(), // Itens Já Comprados
                      ],
                    ),
                  ),
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Passo ${_currentStep + 1} de 18',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${((_currentStep + 1) / 18 * 100).round()}%',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(
            value: (_currentStep + 1) / 18,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return _buildStepContainer(
      title: 'Qual imóvel você comprou?',
      subtitle: 'Isso nos ajuda a personalizar sua jornada',
      child: Column(
        children: [
          _buildOptionCard(
            'Apartamento na planta',
            'apartment_plant',
            _propertyType,
            (value) => setState(() => _propertyType = value),
            icon: Icons.apartment,
          ),
          _buildOptionCard(
            'Apartamento novo já entregue',
            'apartment_new',
            _propertyType,
            (value) => setState(() => _propertyType = value),
            icon: Icons.apartment,
          ),
          _buildOptionCard(
            'Apartamento usado',
            'apartment_used',
            _propertyType,
            (value) => setState(() => _propertyType = value),
            icon: Icons.apartment,
          ),
          _buildOptionCard(
            'Casa nova',
            'house_new',
            _propertyType,
            (value) => setState(() => _propertyType = value),
            icon: Icons.house,
          ),
          _buildOptionCard(
            'Casa usada',
            'house_used',
            _propertyType,
            (value) => setState(() => _propertyType = value),
            icon: Icons.house,
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return _buildStepContainer(
      title: 'Qual destas situações mais se parece com a sua?',
      subtitle: 'Vamos organizar tudo a partir de onde você está',
      child: Column(
        children: [
          _buildOptionCard(
            'Ainda não recebi as chaves',
            'not_received_keys',
            _currentSituation,
            (value) => setState(() => _currentSituation = value),
            icon: Icons.key_off,
          ),
          _buildOptionCard(
            'Recebi as chaves recentemente',
            'just_received',
            _currentSituation,
            (value) => setState(() => _currentSituation = value),
            icon: Icons.key,
          ),
          _buildOptionCard(
            'Estou planejando a reforma',
            'planning',
            _currentSituation,
            (value) => setState(() => _currentSituation = value),
            icon: Icons.design_services,
          ),
          _buildOptionCard(
            'Já comecei a obra',
            'started',
            _currentSituation,
            (value) => setState(() => _currentSituation = value),
            icon: Icons.construction,
          ),
          _buildOptionCard(
            'Estou finalizando os acabamentos',
            'finishing',
            _currentSituation,
            (value) => setState(() => _currentSituation = value),
            icon: Icons.format_paint,
          ),
          _buildOptionCard(
            'Estou montando os móveis',
            'furnishing',
            _currentSituation,
            (value) => setState(() => _currentSituation = value),
            icon: Icons.weekend,
          ),
          _buildOptionCard(
            'Já estou morando',
            'living',
            _currentSituation,
            (value) => setState(() => _currentSituation = value),
            icon: Icons.home,
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return _buildStepContainer(
      title: 'O que pretende fazer?',
      subtitle: 'Defina o nível da sua reforma',
      child: Column(
        children: [
          _buildOptionCard(
            'Apenas mobiliar',
            'just_furnish',
            _reformLevel,
            (value) => setState(() => _reformLevel = value),
            subtitle: 'Comprar móveis, decorar',
            icon: Icons.chair,
          ),
          _buildOptionCard(
            'Pequenas melhorias',
            'small_improvements',
            _reformLevel,
            (value) => setState(() => _reformLevel = value),
            subtitle: 'Pintura, troca de piso em um cômodo',
            icon: Icons.brush,
          ),
          _buildOptionCard(
            'Reforma parcial',
            'partial',
            _reformLevel,
            (value) => setState(() => _reformLevel = value),
            subtitle: 'Cozinha e banheiro completos',
            icon: Icons.home_repair_service,
          ),
          _buildOptionCard(
            'Reforma completa',
            'complete',
            _reformLevel,
            (value) => setState(() => _reformLevel = value),
            subtitle: 'Tudo do zero',
            icon: Icons.construction,
          ),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return _buildStepContainer(
      title: 'Marque o que já está concluído',
      subtitle: 'Isso nos ajuda a saber onde você está',
      child: Column(
        children: [
          _buildCheckboxTile(
            'Recebi as chaves',
            'received_keys',
            _completedItems,
          ),
          _buildCheckboxTile(
            'Tenho projeto',
            'has_project',
            _completedItems,
          ),
          _buildCheckboxTile(
            'Contratei profissionais',
            'hired_professionals',
            _completedItems,
          ),
          _buildCheckboxTile(
            'Instalações concluídas',
            'installations_done',
            _completedItems,
          ),
          _buildCheckboxTile(
            'Pisos concluídos',
            'floors_done',
            _completedItems,
          ),
          _buildCheckboxTile(
            'Pintura concluída',
            'painting_done',
            _completedItems,
          ),
          _buildCheckboxTile(
            'Marcenaria concluída',
            'carpentry_done',
            _completedItems,
          ),
          _buildCheckboxTile(
            'Já me mudei',
            'moved_in',
            _completedItems,
          ),
        ],
      ),
    );
  }

  Widget _buildStep5() {
    return _buildStepContainer(
      title: 'Qual a metragem aproximada?',
      subtitle: 'Isso ajuda nas estimativas de custo e tempo',
      child: Column(
        children: [
          _buildOptionCard(
            'Até 40 m²',
            'up_to_40',
            _propertySize,
            (value) => setState(() => _propertySize = value),
            icon: Icons.square_foot,
          ),
          _buildOptionCard(
            '40–60 m²',
            '40_to_60',
            _propertySize,
            (value) => setState(() => _propertySize = value),
            icon: Icons.square_foot,
          ),
          _buildOptionCard(
            '60–80 m²',
            '60_to_80',
            _propertySize,
            (value) => setState(() => _propertySize = value),
            icon: Icons.square_foot,
          ),
          _buildOptionCard(
            '80–120 m²',
            '80_to_120',
            _propertySize,
            (value) => setState(() => _propertySize = value),
            icon: Icons.square_foot,
          ),
          _buildOptionCard(
            'Acima de 120 m²',
            'above_120',
            _propertySize,
            (value) => setState(() => _propertySize = value),
            icon: Icons.square_foot,
          ),
        ],
      ),
    );
  }

  Widget _buildStep6() {
    return _buildStepContainer(
      title: 'Quais ambientes serão reformados?',
      subtitle: 'Vamos criar checklists personalizados para cada um',
      child: Column(
        children: [
          _buildCheckboxTile('Sala', 'living_room', _selectedRooms),
          _buildCheckboxTile('Cozinha', 'kitchen', _selectedRooms),
          _buildCheckboxTile('Lavanderia', 'laundry', _selectedRooms),
          _buildCheckboxTile('Banheiro', 'bathroom', _selectedRooms),
          _buildCheckboxTile('Quarto', 'bedroom', _selectedRooms),
          _buildCheckboxTile('Escritório', 'office', _selectedRooms),
          _buildCheckboxTile('Varanda', 'balcony', _selectedRooms),
        ],
      ),
    );
  }

  Widget _buildStep7() {
    return _buildStepContainer(
      title: 'Quem vai morar no imóvel?',
      subtitle: 'Isso personaliza nossas recomendações',
      child: Column(
        children: [
          _buildOptionCard(
            'Sozinho',
            'alone',
            _residents,
            (value) => setState(() => _residents = value),
            icon: Icons.person,
          ),
          _buildOptionCard(
            'Casal',
            'couple',
            _residents,
            (value) => setState(() => _residents = value),
            icon: Icons.people,
          ),
          _buildOptionCard(
            'Casal com filhos',
            'couple_with_kids',
            _residents,
            (value) => setState(() => _residents = value),
            icon: Icons.family_restroom,
          ),
          _buildOptionCard(
            'Família',
            'family',
            _residents,
            (value) => setState(() => _residents = value),
            icon: Icons.family_restroom,
          ),
          _buildOptionCard(
            'Investimento / aluguel',
            'investment',
            _residents,
            (value) => setState(() => _residents = value),
            icon: Icons.business,
          ),
        ],
      ),
    );
  }

  Widget _buildStep8() {
    return _buildStepContainer(
      title: 'Alguém trabalha de casa?',
      subtitle: 'Vamos sugerir pontos de internet extras',
      child: Column(
        children: [
          _buildOptionCard(
            'Sim',
            'yes',
            _hasHomeOffice == true
                ? 'yes'
                : (_hasHomeOffice == false ? 'no' : null),
            (value) => setState(() => _hasHomeOffice = value == 'yes'),
            icon: Icons.computer,
          ),
          _buildOptionCard(
            'Não',
            'no',
            _hasHomeOffice == true
                ? 'yes'
                : (_hasHomeOffice == false ? 'no' : null),
            (value) => setState(() => _hasHomeOffice = value == 'yes'),
            icon: Icons.work_off,
          ),
        ],
      ),
    );
  }

  Widget _buildStep9() {
    return _buildStepContainer(
      title: 'Você possui pets?',
      subtitle: 'Vamos sugerir telas de proteção e pisos resistentes',
      child: Column(
        children: [
          _buildOptionCard(
            'Sim',
            'yes',
            _hasPets == true ? 'yes' : (_hasPets == false ? 'no' : null),
            (value) => setState(() => _hasPets = value == 'yes'),
            icon: Icons.pets,
          ),
          _buildOptionCard(
            'Não',
            'no',
            _hasPets == true ? 'yes' : (_hasPets == false ? 'no' : null),
            (value) => setState(() => _hasPets = value == 'yes'),
            icon: Icons.block,
          ),
        ],
      ),
    );
  }

  Widget _buildStep10() {
    return _buildStepContainer(
      title: 'Pretende instalar ar-condicionado?',
      subtitle: 'A infraestrutura deve ser feita ANTES da pintura',
      child: Column(
        children: [
          _buildOptionCard(
            'Sim',
            'yes',
            _hasAirConditioning,
            (value) => setState(() => _hasAirConditioning = value),
            icon: Icons.ac_unit,
          ),
          _buildOptionCard(
            'Não',
            'no',
            _hasAirConditioning,
            (value) => setState(() => _hasAirConditioning = value),
            icon: Icons.block,
          ),
          _buildOptionCard(
            'Ainda não sei',
            'maybe',
            _hasAirConditioning,
            (value) => setState(() => _hasAirConditioning = value),
            icon: Icons.help_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildStep11() {
    return _buildStepContainer(
      title: 'Pretende fazer móveis planejados?',
      subtitle: 'Isso aumenta o prazo e o custo da reforma',
      child: Column(
        children: [
          _buildOptionCard(
            'Sim',
            'yes',
            _hasCustomFurniture,
            (value) => setState(() => _hasCustomFurniture = value),
            icon: Icons.kitchen,
          ),
          _buildOptionCard(
            'Não',
            'no',
            _hasCustomFurniture,
            (value) => setState(() => _hasCustomFurniture = value),
            icon: Icons.block,
          ),
          _buildOptionCard(
            'Apenas alguns ambientes',
            'some',
            _hasCustomFurniture,
            (value) => setState(() => _hasCustomFurniture = value),
            icon: Icons.check_box_outline_blank,
          ),
        ],
      ),
    );
  }

  Widget _buildStep12() {
    return _buildStepContainer(
      title: 'Qual o orçamento estimado para a reforma?',
      subtitle: 'Isso nos ajuda a dar sugestões adequadas',
      child: Column(
        children: [
          _buildOptionCard(
            'Até R\$ 20 mil',
            'up_to_20k',
            _budgetRange,
            (value) => setState(() => _budgetRange = value),
            icon: Icons.attach_money,
          ),
          _buildOptionCard(
            'R\$ 20 mil a R\$ 50 mil',
            '20k_to_50k',
            _budgetRange,
            (value) => setState(() => _budgetRange = value),
            icon: Icons.attach_money,
          ),
          _buildOptionCard(
            'R\$ 50 mil a R\$ 100 mil',
            '50k_to_100k',
            _budgetRange,
            (value) => setState(() => _budgetRange = value),
            icon: Icons.attach_money,
          ),
          _buildOptionCard(
            'R\$ 100 mil a R\$ 200 mil',
            '100k_to_200k',
            _budgetRange,
            (value) => setState(() => _budgetRange = value),
            icon: Icons.attach_money,
          ),
          _buildOptionCard(
            'Acima de R\$ 200 mil',
            'above_200k',
            _budgetRange,
            (value) => setState(() => _budgetRange = value),
            icon: Icons.attach_money,
          ),
        ],
      ),
    );
  }

  Widget _buildStep13() {
    return _buildStepContainer(
      title: 'O que é mais importante para você?',
      subtitle: 'Selecione todas que se aplicam',
      child: Column(
        children: [
          _buildCheckboxTile('Economizar dinheiro', 'save_money', _priorities),
          _buildCheckboxTile(
              'Terminar mais rápido', 'finish_faster', _priorities),
          _buildCheckboxTile(
              'Ter melhor acabamento', 'better_finish', _priorities),
          _buildCheckboxTile(
              'Evitar dores de cabeça', 'avoid_problems', _priorities),
          _buildCheckboxTile(
              'Organizar tudo em um lugar', 'organize', _priorities),
        ],
      ),
    );
  }

  Widget _buildStep14() {
    return _buildStepContainer(
      title: 'O que você não quer esquecer?',
      subtitle:
          '⚠️ CRÍTICO: Vamos criar alertas antes da infraestrutura para evitar retrabalho',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.warningLight,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.warning, width: 2),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: AppColors.warning, size: 32),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Marque tudo que pretende ter. Fazer depois custa 3-5x mais!',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildCheckboxTile(
              'Ar-condicionado', 'air_conditioning', _criticalInfrastructure),
          _buildCheckboxTile(
              'Lava-louças', 'dishwasher', _criticalInfrastructure),
          _buildCheckboxTile(
              'Aquecedor', 'water_heater', _criticalInfrastructure),
          _buildCheckboxTile('Automação residencial', 'home_automation',
              _criticalInfrastructure),
          _buildCheckboxTile(
              'Energia solar', 'solar_energy', _criticalInfrastructure),
          _buildCheckboxTile('Rede de internet cabeada', 'wired_internet',
              _criticalInfrastructure),
          _buildCheckboxTile(
              'Fechadura eletrônica', 'smart_lock', _criticalInfrastructure),
          _buildCheckboxTile(
              'Câmeras de segurança', 'cameras', _criticalInfrastructure),
          _buildCheckboxTile(
              'Som ambiente', 'ambient_sound', _criticalInfrastructure),
        ],
      ),
    );
  }

  Widget _buildStep6_5() {
    return _buildStepContainer(
      title: 'Quais ambientes são prioridade?',
      subtitle: 'Se fosse necessário priorizar, escolha até 3',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.infoLight,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.info, width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.info, size: 24),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Em caso de orçamento apertado ou atraso, o app vai orientar você a priorizar estes ambientes.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ..._selectedRooms.map((room) {
            final roomNames = {
              'living_room': 'Sala',
              'kitchen': 'Cozinha',
              'laundry': 'Lavanderia',
              'bathroom': 'Banheiro',
              'bedroom': 'Quarto',
              'office': 'Escritório',
              'balcony': 'Varanda',
            };
            return _buildCheckboxTile(
              roomNames[room] ?? room,
              room,
              _priorityRooms,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStep12_5() {
    return _buildStepContainer(
      title: 'Quem vai coordenar a obra?',
      subtitle: '⚠️ CRÍTICO: Isso muda completamente o comportamento do app',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.warningLight,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.warning, width: 2),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: AppColors.warning, size: 32),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'O app vai se adaptar ao seu perfil: mais educacional se você coordena, ou mais focado em tracking se tem profissionais.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildOptionCard(
            'Eu mesmo vou coordenar tudo',
            'self',
            _projectManagementType,
            (value) => setState(() => _projectManagementType = value),
            subtitle: 'Modo educacional: mais dicas e alertas',
            icon: Icons.person,
          ),
          _buildOptionCard(
            'Tenho arquiteto',
            'architect',
            _projectManagementType,
            (value) => setState(() => _projectManagementType = value),
            subtitle: 'Modo tracking: foco em acompanhamento',
            icon: Icons.architecture,
          ),
          _buildOptionCard(
            'Tenho arquiteto e engenheiro',
            'architect_engineer',
            _projectManagementType,
            (value) => setState(() => _projectManagementType = value),
            subtitle: 'Modo tracking avançado',
            icon: Icons.engineering,
          ),
          _buildOptionCard(
            'Contratei empresa de reforma',
            'construction_company',
            _projectManagementType,
            (value) => setState(() => _projectManagementType = value),
            subtitle: 'Foco em orçamento e prazos',
            icon: Icons.business,
          ),
          _buildOptionCard(
            'Ainda não decidi',
            'undecided',
            _projectManagementType,
            (value) => setState(() => _projectManagementType = value),
            icon: Icons.help_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildStep13_5() {
    return _buildStepContainer(
      title: 'Quando você gostaria de se mudar?',
      subtitle: 'Isso nos ajuda a criar metas reais',
      child: Column(
        children: [
          _buildOptionCard(
            'O mais rápido possível',
            'asap',
            _moveInGoal,
            (value) => setState(() => _moveInGoal = value),
            subtitle: 'Vamos priorizar velocidade',
            icon: Icons.flash_on,
          ),
          _buildOptionCard(
            'Até 3 meses',
            '3_months',
            _moveInGoal,
            (value) => setState(() => _moveInGoal = value),
            icon: Icons.calendar_today,
          ),
          _buildOptionCard(
            'Até 6 meses',
            '6_months',
            _moveInGoal,
            (value) => setState(() => _moveInGoal = value),
            icon: Icons.calendar_month,
          ),
          _buildOptionCard(
            'Sem prazo definido',
            'no_deadline',
            _moveInGoal,
            (value) => setState(() => _moveInGoal = value),
            subtitle: 'Foco em qualidade',
            icon: Icons.schedule,
          ),
        ],
      ),
    );
  }

  Widget _buildStep14_5() {
    return _buildStepContainer(
      title: 'Você já comprou algum item?',
      subtitle: 'Vamos registrar automaticamente para você',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.success, width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline,
                    color: AppColors.success, size: 24),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Itens marcados serão automaticamente adicionados ao seu checklist como concluídos.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildCheckboxTile('Piso', 'flooring', _alreadyPurchasedItems),
          _buildCheckboxTile(
              'Porcelanato', 'porcelain', _alreadyPurchasedItems),
          _buildCheckboxTile(
              'Móveis planejados', 'custom_furniture', _alreadyPurchasedItems),
          _buildCheckboxTile(
              'Ar-condicionado', 'air_conditioning', _alreadyPurchasedItems),
          _buildCheckboxTile('Cooktop', 'cooktop', _alreadyPurchasedItems),
          _buildCheckboxTile('Forno', 'oven', _alreadyPurchasedItems),
          _buildCheckboxTile('Geladeira', 'fridge', _alreadyPurchasedItems),
          _buildCheckboxTile('Sofá', 'sofa', _alreadyPurchasedItems),
          _buildCheckboxTile('Cama', 'bed', _alreadyPurchasedItems),
          _buildCheckboxTile('Mesa', 'table', _alreadyPurchasedItems),
          _buildCheckboxTile('Nenhum', 'none', _alreadyPurchasedItems),
        ],
      ),
    );
  }

  Widget _buildStepContainer({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.displaySmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          child,
        ],
      ),
    );
  }

  Widget _buildOptionCard(
    String title,
    String value,
    String? groupValue,
    Function(String) onChanged, {
    String? subtitle,
    IconData? icon,
  }) {
    final isSelected = groupValue == value;
    return InkWell(
      onTap: () => onChanged(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
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
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.border.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(
                  icon,
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxTile(
      String title, String value, Set<String> selectedSet) {
    final isSelected = selectedSet.contains(value);
    return CheckboxListTile(
      title: Text(title),
      value: isSelected,
      onChanged: (bool? checked) {
        setState(() {
          if (checked == true) {
            selectedSet.add(value);
          } else {
            selectedSet.remove(value);
          }
        });
      },
      activeColor: AppColors.primary,
      controlAffinity: ListTileControlAffinity.leading,
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
              onPressed: _canProceed()
                  ? () {
                      if (_currentStep == 17) {
                        _completeOnboarding(context);
                      } else {
                        _nextStep();
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 52),
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textInverse,
              ),
              child: Text(_currentStep == 17 ? 'Finalizar' : 'Continuar'),
            ),
          ),
        ],
      ),
    );
  }
}

// Made with Bob
