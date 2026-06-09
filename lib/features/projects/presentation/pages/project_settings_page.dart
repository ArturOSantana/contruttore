import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/project_entity.dart';
import '../cubit/project_cubit.dart';
import '../cubit/project_state.dart';

/// Página de configurações do projeto
///
/// Permite ao usuário editar:
/// - Data planejada de mudança
/// - Nome do projeto
/// - Endereço
/// - Outros dados do projeto
class ProjectSettingsPage extends StatefulWidget {
  final ProjectEntity project;

  const ProjectSettingsPage({
    super.key,
    required this.project,
  });

  @override
  State<ProjectSettingsPage> createState() => _ProjectSettingsPageState();
}

class _ProjectSettingsPageState extends State<ProjectSettingsPage> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  DateTime? _plannedMoveInDate;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project.name);
    _addressController = TextEditingController(text: widget.project.address);
    _plannedMoveInDate = widget.project.plannedMoveInDate;

    _nameController.addListener(_onFieldChanged);
    _addressController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    setState(() {
      _hasChanges = true;
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _plannedMoveInDate ?? DateTime.now().add(const Duration(days: 90)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)), // 2 anos
      helpText: 'Selecione a data planejada para mudança',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
      locale: const Locale('pt', 'BR'),
    );

    if (picked != null && picked != _plannedMoveInDate) {
      setState(() {
        _plannedMoveInDate = picked;
        _hasChanges = true;
      });
    }
  }

  void _saveChanges() {
    if (!_hasChanges) {
      Navigator.pop(context);
      return;
    }

    final updatedProject = widget.project.copyWith(
      name: _nameController.text,
      address: _addressController.text,
      plannedMoveInDate: _plannedMoveInDate,
    );

    context.read<ProjectCubit>().updateProject(updatedProject);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return BlocListener<ProjectCubit, ProjectState>(
      listener: (context, state) {
        if (state is ProjectLoaded && _hasChanges) {
          // Projeto foi recarregado após atualização
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Projeto atualizado com sucesso!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          // Aguarda um pouco para garantir que o usuário veja a mensagem
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              Navigator.pop(context,
                  true); // Retorna true para indicar que houve mudanças
            }
          });
          setState(() {
            _hasChanges = false;
          });
        } else if (state is ProjectError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Configurações do Projeto'),
          actions: [
            if (_hasChanges)
              TextButton(
                onPressed: _saveChanges,
                child: const Text(
                  'SALVAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        body: BlocBuilder<ProjectCubit, ProjectState>(
          builder: (context, state) {
            if (state is ProjectLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informações Básicas
                  Text(
                    'Informações Básicas',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nome do Projeto
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome do Projeto',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.home_work),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Endereço
                  TextField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Endereço',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 32),

                  // Planejamento
                  Text(
                    'Planejamento',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Data Planejada de Mudança
                  Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.calendar_today,
                        color: theme.colorScheme.primary,
                      ),
                      title: const Text('Data planejada para mudança'),
                      subtitle: Text(
                        _plannedMoveInDate != null
                            ? dateFormat.format(_plannedMoveInDate!)
                            : 'Não definida',
                        style: TextStyle(
                          color: _plannedMoveInDate != null
                              ? theme.colorScheme.primary
                              : theme.colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Icon(
                        Icons.edit,
                        color: theme.colorScheme.primary,
                      ),
                      onTap: _selectDate,
                    ),
                  ),

                  if (_plannedMoveInDate != null) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Esta data será usada para calcular o tempo restante até a mudança e ajudar no planejamento da reforma.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Informações do Projeto
                  Text(
                    'Informações do Projeto',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildInfoCard(
                    context,
                    icon: Icons.person,
                    title: 'Construtor',
                    value: widget.project.constructorName,
                  ),
                  const SizedBox(height: 8),

                  _buildInfoCard(
                    context,
                    icon: Icons.square_foot,
                    title: 'Área',
                    value: '${widget.project.area.toStringAsFixed(2)} m²',
                  ),
                  const SizedBox(height: 8),

                  _buildInfoCard(
                    context,
                    icon: Icons.calendar_month,
                    title: 'Data de Entrega',
                    value: dateFormat.format(widget.project.deliveryDate),
                  ),
                  const SizedBox(height: 8),

                  _buildInfoCard(
                    context,
                    icon: Icons.description,
                    title: 'Data do Contrato',
                    value: dateFormat.format(widget.project.contractDate),
                  ),

                  const SizedBox(height: 32),

                  // Botão de Salvar (fixo no bottom)
                  if (_hasChanges)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveChanges,
                        icon: const Icon(Icons.save),
                        label: const Text('Salvar Alterações'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title),
        subtitle: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// Made with Bob
