import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../projects/domain/entities/project_entity.dart';
import '../../../projects/presentation/cubit/project_cubit.dart';
import '../../../projects/presentation/cubit/project_state.dart';

/// Página de Edição de Projeto
class EditProjectPage extends StatefulWidget {
  final String projectId;

  const EditProjectPage({super.key, required this.projectId});

  @override
  State<EditProjectPage> createState() => _EditProjectPageState();
}

class _EditProjectPageState extends State<EditProjectPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _constructorNameController = TextEditingController();
  final _areaController = TextEditingController();
  final _totalBudgetController = TextEditingController();
  final _propertyValueController = TextEditingController();
  final _contingencyPercentController = TextEditingController();

  DateTime? _deliveryDate;
  DateTime? _contractDate;
  DateTime? _plannedMoveInDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProjectData();
  }

  void _loadProjectData() {
    context.read<ProjectCubit>().getProject(widget.projectId);
  }

  void _populateFields(ProjectEntity project) {
    _nameController.text = project.name;
    _addressController.text = project.address;
    _constructorNameController.text = project.constructorName;
    _areaController.text = project.area.toString();
    _totalBudgetController.text = project.totalBudget?.toString() ?? '';
    _propertyValueController.text = project.propertyValue?.toString() ?? '';
    _contingencyPercentController.text = project.contingencyPercent.toString();
    _deliveryDate = project.deliveryDate;
    _contractDate = project.contractDate;
    _plannedMoveInDate = project.plannedMoveInDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _constructorNameController.dispose();
    _areaController.dispose();
    _totalBudgetController.dispose();
    _propertyValueController.dispose();
    _contingencyPercentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Editar Projeto'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveProject,
              child: Text(
                'SALVAR',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: BlocConsumer<ProjectCubit, ProjectState>(
        listener: (context, state) {
          if (state is ProjectLoaded && state.project != null) {
            _populateFields(state.project!);
          }
          if (state is ProjectError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProjectLoading) {
            return const LoadingWidget();
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(AppSpacing.md),
              children: [
                // Nome do Projeto
                _buildTextField(
                  controller: _nameController,
                  label: 'Nome do Projeto',
                  hint: 'Ex: Apt Brooklin - Bloco A',
                  icon: Icons.home,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    return null;
                  },
                ),
                SizedBox(height: AppSpacing.md),

                // Endereço
                _buildTextField(
                  controller: _addressController,
                  label: 'Endereço',
                  hint: 'Rua, número, bairro, cidade',
                  icon: Icons.location_on,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    return null;
                  },
                ),
                SizedBox(height: AppSpacing.md),

                // Construtora
                _buildTextField(
                  controller: _constructorNameController,
                  label: 'Nome da Construtora',
                  hint: 'Ex: Construtora ABC',
                  icon: Icons.business,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    return null;
                  },
                ),
                SizedBox(height: AppSpacing.md),

                // Área
                _buildTextField(
                  controller: _areaController,
                  label: 'Área (m²)',
                  hint: 'Ex: 65',
                  icon: Icons.square_foot,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Valor inválido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: AppSpacing.md),

                // Data de Entrega
                _buildDateField(
                  label: 'Data de Entrega Prevista',
                  icon: Icons.calendar_today,
                  date: _deliveryDate,
                  onTap: () => _selectDate(context, isDeliveryDate: true),
                ),
                SizedBox(height: AppSpacing.md),

                // Data do Contrato
                _buildDateField(
                  label: 'Data de Assinatura do Contrato',
                  icon: Icons.edit_calendar,
                  date: _contractDate,
                  onTap: () => _selectDate(context, isDeliveryDate: false),
                ),
                SizedBox(height: AppSpacing.md),

                // Data Planejada de Mudança
                _buildDateField(
                  label: 'Data Planejada de Mudança (opcional)',
                  icon: Icons.moving,
                  date: _plannedMoveInDate,
                  onTap: () => _selectPlannedMoveInDate(context),
                ),
                SizedBox(height: AppSpacing.md),

                // Valor do Imóvel
                _buildTextField(
                  controller: _propertyValueController,
                  label: 'Valor do Imóvel (opcional)',
                  hint: 'Ex: 350000',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.md),

                // Orçamento Total
                _buildTextField(
                  controller: _totalBudgetController,
                  label: 'Orçamento Total para Reforma (opcional)',
                  hint: 'Ex: 50000',
                  icon: Icons.account_balance_wallet,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.md),

                // Contingência
                _buildTextField(
                  controller: _contingencyPercentController,
                  label: 'Reserva de Contingência (%)',
                  hint: 'Ex: 10',
                  icon: Icons.savings,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    final percent = double.tryParse(value);
                    if (percent == null || percent < 0 || percent > 100) {
                      return 'Valor deve estar entre 0 e 100';
                    }
                    return null;
                  },
                ),
                SizedBox(height: AppSpacing.xl),

                // Informação sobre contingência
                Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.infoLight,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: AppColors.info, size: 20),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'A reserva de contingência é recomendada para cobrir imprevistos. O valor sugerido é 10% do orçamento total.',
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
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primary),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: BorderSide(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required IconData icon,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md + 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary),
                SizedBox(width: AppSpacing.md),
                Text(
                  date != null
                      ? DateFormat('dd/MM/yyyy').format(date)
                      : 'Selecione uma data',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: date != null
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(
    BuildContext context, {
    required bool isDeliveryDate,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDeliveryDate
          ? (_deliveryDate ?? DateTime.now())
          : (_contractDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textInverse,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isDeliveryDate) {
          _deliveryDate = picked;
        } else {
          _contractDate = picked;
        }
      });
    }
  }

  Future<void> _selectPlannedMoveInDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _plannedMoveInDate ?? DateTime.now().add(const Duration(days: 90)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      helpText: 'Selecione a data planejada para mudança',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textInverse,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _plannedMoveInDate = picked;
      });
    }
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_deliveryDate == null || _contractDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione todas as datas'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final currentState = context.read<ProjectCubit>().state;
    if (currentState is! ProjectLoaded || currentState.project == null) {
      setState(() => _isLoading = false);
      return;
    }

    final updatedProject = currentState.project!.copyWith(
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      constructorName: _constructorNameController.text.trim(),
      area: double.parse(_areaController.text),
      deliveryDate: _deliveryDate,
      contractDate: _contractDate,
      plannedMoveInDate: _plannedMoveInDate,
      totalBudget: _totalBudgetController.text.isNotEmpty
          ? double.parse(_totalBudgetController.text)
          : null,
      propertyValue: _propertyValueController.text.isNotEmpty
          ? double.parse(_propertyValueController.text)
          : null,
      contingencyPercent: double.parse(_contingencyPercentController.text),
    );

    await context.read<ProjectCubit>().updateProject(updatedProject);

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Projeto atualizado com sucesso!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }
}

// Made with Bob
