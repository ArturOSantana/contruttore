import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/quick_supplier.dart';
import '../cubit/retroactive_cubit.dart';
import '../cubit/retroactive_state.dart';

/// Step 3: Fornecedores rápidos
class Step3QuickSuppliers extends StatelessWidget {
  final VoidCallback onNext;

  const Step3QuickSuppliers({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RetroactiveCubit, RetroactiveState>(
      builder: (context, state) {
        final suppliers = state is RetroactiveCollecting
            ? state.quickSuppliers
            : <QuickSupplier>[];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quem está trabalhando na obra?',
                style: AppTextStyles.displayMedium,
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                'Adicione os profissionais ativos (opcional)',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Lista de fornecedores
              if (suppliers.isEmpty)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppRadius.m),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.person_add_outlined,
                        size: 48,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: AppSpacing.m),
                      Text(
                        'Nenhum fornecedor adicionado',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s),
                      Text(
                        'Você pode adicionar depois',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: suppliers.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.m),
                  itemBuilder: (context, index) {
                    final supplier = suppliers[index];
                    return _SupplierCard(supplier: supplier);
                  },
                ),

              const SizedBox(height: AppSpacing.l),

              // Botão adicionar
              OutlinedButton.icon(
                onPressed: () => _showAddSupplierDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Adicionar Fornecedor'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.m),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Botão continuar (sempre habilitado - opcional)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
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

  void _showAddSupplierDialog(BuildContext context) {
    final nameController = TextEditingController();
    String selectedType = 'Pedreiro';
    String selectedStatus = 'active';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Adicionar Fornecedor'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Pedreiro', child: Text('Pedreiro')),
                  DropdownMenuItem(
                    value: 'Eletricista',
                    child: Text('Eletricista'),
                  ),
                  DropdownMenuItem(
                    value: 'Encanador',
                    child: Text('Encanador'),
                  ),
                  DropdownMenuItem(value: 'Pintor', child: Text('Pintor')),
                  DropdownMenuItem(
                    value: 'Marceneiro',
                    child: Text('Marceneiro'),
                  ),
                  DropdownMenuItem(value: 'Gesseiro', child: Text('Gesseiro')),
                  DropdownMenuItem(value: 'Outro', child: Text('Outro')),
                ],
                onChanged: (value) => setState(() => selectedType = value!),
              ),
              const SizedBox(height: AppSpacing.m),
              DropdownButtonFormField<String>(
                initialValue: selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'active', child: Text('Ativo')),
                  DropdownMenuItem(value: 'problem', child: Text('Problema')),
                ],
                onChanged: (value) => setState(() => selectedStatus = value!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                final supplier = QuickSupplier(
                  id: const Uuid().v4(),
                  name: nameController.text.trim(),
                  type: selectedType,
                  status: selectedStatus,
                );
                context.read<RetroactiveCubit>().addQuickSupplier(supplier);
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }
}

class _SupplierCard extends StatelessWidget {
  final QuickSupplier supplier;

  const _SupplierCard({required this.supplier});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.m),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: supplier.status == 'active'
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.s),
            ),
            child: Icon(
              Icons.person,
              color: supplier.status == 'active'
                  ? AppColors.success
                  : AppColors.warning,
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(supplier.name, style: AppTextStyles.headingSmall),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  supplier.type,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: AppColors.error,
            onPressed: () {
              context.read<RetroactiveCubit>().removeQuickSupplier(supplier.id);
            },
          ),
        ],
      ),
    );
  }
}

/// Step 4: Resumo e confirmação
class Step4Summary extends StatelessWidget {
  final String userId;
  final String projectName;
  final String address;
  final double area;
  final DateTime deliveryDate;
  final DateTime contractDate;
  final String constructorName;

  const Step4Summary({
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
  Widget build(BuildContext context) {
    return BlocBuilder<RetroactiveCubit, RetroactiveState>(
      builder: (context, state) {
        if (state is! RetroactiveCollecting) {
          return const SizedBox.shrink();
        }

        final phaseNumber = state.selectedPhaseNumber ?? 0;
        final totalSpent = state.calculatedTotalSpent;
        final suppliers = state.quickSuppliers;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tudo pronto!', style: AppTextStyles.displayMedium),
              const SizedBox(height: AppSpacing.s),
              Text(
                'Revise as informações antes de criar o projeto',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Resumo do projeto
              _SummarySection(
                title: 'Projeto',
                icon: Icons.home_work_outlined,
                children: [
                  _SummaryItem(label: 'Nome', value: projectName),
                  _SummaryItem(label: 'Endereço', value: address),
                  _SummaryItem(
                    label: 'Área',
                    value: '${area.toStringAsFixed(0)}m²',
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.l),

              // Fase atual
              _SummarySection(
                title: 'Fase Atual',
                icon: Icons.construction_outlined,
                children: [
                  _SummaryItem(
                    label: 'Fase',
                    value: 'Fase $phaseNumber - ${_getPhaseName(phaseNumber)}',
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.l),

              // Orçamento
              _SummarySection(
                title: 'Orçamento',
                icon: Icons.attach_money_outlined,
                children: [
                  _SummaryItem(
                    label: 'Gasto até agora',
                    value: totalSpent > 0
                        ? 'R\$ ${totalSpent.toStringAsFixed(2)}'
                        : 'Não informado',
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.l),

              // Fornecedores
              _SummarySection(
                title: 'Fornecedores',
                icon: Icons.people_outlined,
                children: [
                  _SummaryItem(
                    label: 'Total',
                    value: suppliers.isEmpty
                        ? 'Nenhum cadastrado'
                        : '${suppliers.length} fornecedor${suppliers.length > 1 ? "es" : ""}',
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Botão criar projeto
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<RetroactiveCubit>().createRetroactiveProject(
                      userId: userId,
                      projectName: projectName,
                      address: address,
                      area: area,
                      deliveryDate: deliveryDate,
                      contractDate: contractDate,
                      constructorName: constructorName,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.m),
                    ),
                  ),
                  child: Text(
                    'Criar Projeto',
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

  String _getPhaseName(int number) {
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
}

class _SummarySection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SummarySection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.m),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: AppSpacing.s),
              Text(
                title,
                style: AppTextStyles.headingSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          ...children,
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(child: Text(value, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}

// Made with Bob
