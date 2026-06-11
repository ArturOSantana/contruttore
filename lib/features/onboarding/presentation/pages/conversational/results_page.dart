import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../../../injection_container.dart';
import '../../../../../core/data/reform_phases_seed_data.dart';
import '../../../../projects/domain/entities/project_entity.dart';
import '../../../../projects/domain/entities/phase_entity.dart';
import '../../../../projects/domain/usecases/create_project_usecase.dart';
import '../../../../phases/domain/repositories/phase_repository.dart';
import '../../cubit/conversational_onboarding_cubit.dart';
import '../../cubit/conversational_onboarding_state.dart';
import '../../../data/services/onboarding_progress_service.dart';

/// Tela de resultados - Mostra o plano pronto ANTES de salvar
/// O usuário vê o valor que o app vai entregar
class ResultsPage extends StatefulWidget {
  final String nextAction;
  final String nextActionDescription;
  final List<String> criticalAlerts;
  final int estimatedDurationDays;
  final double estimatedBudget;
  final String currentPhase;
  final int alertsCount;

  const ResultsPage({
    super.key,
    required this.nextAction,
    required this.nextActionDescription,
    required this.criticalAlerts,
    required this.estimatedDurationDays,
    required this.estimatedBudget,
    required this.currentPhase,
    required this.alertsCount,
  });

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  bool _isCreating = false;

  Future<void> _createProjectAndNavigate() async {
    if (_isCreating) return;

    setState(() => _isCreating = true);

    try {
      print('🚀 Iniciando criação do projeto...');

      // Pegar dados do cubit
      final cubit = context.read<ConversationalOnboardingCubit>();
      final progress = cubit.state is ConversationalOnboardingInProgress
          ? (cubit.state as ConversationalOnboardingInProgress).progress
          : null;

      if (progress == null) {
        throw Exception('Progresso não encontrado');
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      // Criar projeto com dados do onboarding
      final projectId = const Uuid().v4();

      // Debug: verificar nome do projeto
      print('🔍 DEBUG - Nome do projeto no progress: ${progress.projectName}');
      print('🔍 DEBUG - Progress completo: ${progress.toJson()}');

      final project = ProjectEntity(
        id: projectId,
        userId: user.uid,
        name: progress.projectName ?? 'Meu Projeto',
        address: progress.address ?? 'Não informado',
        constructorName: progress.constructorName ?? 'Não informado',
        area: progress.area ?? 50.0,
        deliveryDate: progress.deliveryDate ??
            DateTime.now().add(const Duration(days: 365)),
        contractDate: progress.contractDate ?? DateTime.now(),
        totalBudget: widget.estimatedBudget,
        contingencyPercent: 10.0,
        propertyValue: 0.0,
        currentSituation: progress.currentMoment ?? 'planning',
        mainPriority: progress.mainPriority, // Salvar prioridade do usuário
        criticalItems: progress.criticalItems, // Salvar itens críticos
        createdAt: DateTime.now(),
      );

      print('📝 Criando projeto: ${project.name}');
      final createProjectUseCase = getIt<CreateProjectUseCase>();
      final result = await createProjectUseCase(project);

      await result.fold(
        (failure) async {
          throw Exception(failure.message);
        },
        (createdProject) async {
          print('✅ Projeto criado com sucesso');

          // Gerar fases usando o repository diretamente
          print('📋 Gerando fases...');
          final phaseRepository = getIt<PhaseRepository>();

          // Criar fases baseadas no seed data
          final phasesData = ReformPhasesSeedData.defaultPhases;
          for (var i = 0; i < phasesData.length; i++) {
            final phaseData = phasesData[i];
            final phase = PhaseEntity(
              id: '', // Firestore vai gerar
              projectId: createdProject.id,
              number: i + 1,
              name: phaseData.name,
              description: phaseData.description,
              status: PhaseStatus.locked,
              estimatedDurationDays: 30, // Valor padrão
              subtasks: phaseData.checklist
                  .map((item) => SubtaskEntity(
                        id: item.id,
                        name: item.name,
                        isRequired: item.mandatory,
                        isDone: false,
                      ))
                  .toList(),
              glossaryTerms: [],
              commonMistake: phaseData.commonMistakes,
              isRetroactive: false,
              estimatedBudget: 0,
              totalSpent: 0,
              totalPending: 0,
              dependsOn: [],
              blockedBy: [],
              expectedSupplierTypes: [],
              expectedPurchaseCategories: [],
              expectedDocumentTypes: [],
            );

            await phaseRepository.updatePhase(phase);
          }

          print('✅ Fases geradas com sucesso');

          // Salvar alertas críticos
          if (progress.criticalItems.isNotEmpty) {
            print('⚠️ Salvando alertas críticos...');
            await _saveCriticalAlerts(
                createdProject.id, progress.criticalItems);
          }

          // Limpar progresso via service
          await getIt<OnboardingProgressService>().clearProgress();
          print('🧹 Progresso limpo');

          // Navegar para home
          if (mounted) {
            print('🏠 Navegando para home...');
            context.go('/home');
          }
        },
      );
    } catch (e) {
      print('❌ Erro ao criar projeto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar projeto: $e'),
            backgroundColor: AppColors.error,
          ),
        );
        setState(() => _isCreating = false);
      }
    }
  }

  Future<void> _saveCriticalAlerts(String projectId, List<String> items) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      for (final item in items) {
        final alert = _createAlertFromItem(item);
        if (alert != null) {
          final docRef = firestore
              .collection('projects')
              .doc(projectId)
              .collection('alerts')
              .doc();
          batch.set(docRef, alert);
        }
      }

      await batch.commit();
      print('✅ Alertas salvos com sucesso');
    } catch (e) {
      print('⚠️ Erro ao salvar alertas: $e');
    }
  }

  Map<String, dynamic>? _createAlertFromItem(String item) {
    final now = DateTime.now();

    switch (item.toLowerCase()) {
      case 'ar-condicionado':
      case 'ar_conditioner':
        return {
          'id': const Uuid().v4(),
          'projectId': '',
          'title': 'Definir pontos de ar-condicionado',
          'description':
              'Planeje os ambientes que receberão ar-condicionado antes do projeto elétrico',
          'type': 'critical',
          'priority': 'high',
          'phase': 'Projeto Elétrico',
          'dueDate': now.add(const Duration(days: 7)),
          'isCompleted': false,
          'createdAt': now,
        };
      case 'internet cabeada':
      case 'wired_internet':
        return {
          'id': const Uuid().v4(),
          'projectId': '',
          'title': 'Planejar pontos de internet cabeada',
          'description':
              'Defina os cômodos que terão internet cabeada antes da elétrica',
          'type': 'critical',
          'priority': 'high',
          'phase': 'Projeto Elétrico',
          'dueDate': now.add(const Duration(days: 7)),
          'isCompleted': false,
          'createdAt': now,
        };
      case 'lava-louças':
      case 'dishwasher':
        return {
          'id': const Uuid().v4(),
          'projectId': '',
          'title': 'Reservar ponto para lava-louças',
          'description': 'Planeje ponto elétrico e hidráulico para lava-louças',
          'type': 'critical',
          'priority': 'medium',
          'phase': 'Projeto Hidráulico',
          'dueDate': now.add(const Duration(days: 7)),
          'isCompleted': false,
          'createdAt': now,
        };
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('📺 ResultsPage construída com dados diretos');
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _buildResults(context),
    );
  }

  Widget _buildResults(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ícone de sucesso
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: AppColors.gradientPrimary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 30,
                              offset: const Offset(0, 15))
                        ],
                      ),
                      child: const Icon(Icons.check,
                          size: 50, color: AppColors.textOnPrimary),
                    ),
                  ),

                  SizedBox(height: AppSpacing.xl),

                  // Título
                  Text('Seu plano está pronto',
                      style: AppTextStyles.displaySmall
                          .copyWith(fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center),

                  SizedBox(height: AppSpacing.xl),

                  // Card de resumo
                  Container(
                    padding: EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      boxShadow: [
                        BoxShadow(color: AppColors.shadowLight, blurRadius: 10)
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Você está na etapa:',
                            style: AppTextStyles.labelMedium
                                .copyWith(color: AppColors.textSecondary)),
                        Text(widget.currentPhase,
                            style: AppTextStyles.titleLarge
                                .copyWith(fontWeight: FontWeight.w700)),
                        SizedBox(height: AppSpacing.md),
                        Divider(),
                        SizedBox(height: AppSpacing.md),
                        Text('Faltam aproximadamente:',
                            style: AppTextStyles.labelMedium
                                .copyWith(color: AppColors.textSecondary)),
                        SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            _buildStat(
                                Icons.calendar_today,
                                '${(widget.estimatedDurationDays / 30).round()} meses',
                                AppColors.primary),
                            SizedBox(width: AppSpacing.md),
                            _buildStat(
                                Icons.attach_money,
                                CurrencyFormatter.format(
                                    widget.estimatedBudget),
                                AppColors.success),
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (widget.criticalAlerts.isNotEmpty) ...[
                    SizedBox(height: AppSpacing.xl),

                    // Alertas críticos
                    Container(
                      padding: EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusLg),
                        border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.warning_amber_rounded,
                                  color: AppColors.warning),
                              SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  'Encontramos ${widget.alertsCount} ${widget.alertsCount == 1 ? 'item que precisa' : 'itens que precisam'} ser planejados antes da elétrica:',
                                  style: AppTextStyles.titleSmall
                                      .copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppSpacing.md),
                          ...widget.criticalAlerts.map((alert) => Padding(
                                padding: EdgeInsets.only(bottom: AppSpacing.xs),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('• ',
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                                color: AppColors.warning)),
                                    Expanded(
                                        child: Text(alert,
                                            style: AppTextStyles.bodyMedium)),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: AppSpacing.xl),

                  // Próxima ação
                  Container(
                    padding: EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.flag, color: AppColors.primary),
                            SizedBox(width: AppSpacing.sm),
                            Text('Sua próxima ação:',
                                style: AppTextStyles.titleSmall
                                    .copyWith(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        SizedBox(height: AppSpacing.sm),
                        Text(widget.nextAction,
                            style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary)),
                        SizedBox(height: AppSpacing.xs),
                        Text(widget.nextActionDescription,
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),

                  SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),

          // Botão fixo
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 10,
                    offset: const Offset(0, -2))
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isCreating ? null : _createProjectAndNavigate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusLg)),
                  ),
                  child: _isCreating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.textOnPrimary),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Ir para o Mapa da Reforma',
                                style: AppTextStyles.titleMedium.copyWith(
                                    color: AppColors.textOnPrimary,
                                    fontWeight: FontWeight.w600)),
                            SizedBox(width: AppSpacing.sm),
                            const Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String text, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: AppSpacing.iconSm),
            SizedBox(width: AppSpacing.xs),
            Expanded(
                child: Text(text,
                    style: AppTextStyles.labelMedium
                        .copyWith(color: color, fontWeight: FontWeight.w700))),
          ],
        ),
      ),
    );
  }
}

// Made with ❤️ by Bob

// Made with Bob
