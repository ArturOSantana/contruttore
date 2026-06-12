import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/move_in_task_entity.dart';
import '../cubit/move_in_cubit.dart';

/// Diálogo para adicionar ou editar uma tarefa de mudança
class AddTaskDialog extends StatefulWidget {
  final MoveInTaskEntity? taskToEdit;

  const AddTaskDialog({
    super.key,
    this.taskToEdit,
  });

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late MoveInTaskCategory _selectedCategory;
  late bool _isCritical;
  DateTime? _dueDate;

  final List<Map<String, dynamic>> _categories = [
    {
      'value': MoveInTaskCategory.essentials,
      'label': 'Essenciais',
      'icon': Icons.home
    },
    {
      'value': MoveInTaskCategory.utilities,
      'label': 'Serviços',
      'icon': Icons.build
    },
    {
      'value': MoveInTaskCategory.cleaning,
      'label': 'Limpeza',
      'icon': Icons.cleaning_services
    },
    {
      'value': MoveInTaskCategory.inspection,
      'label': 'Vistoria',
      'icon': Icons.search
    },
    {
      'value': MoveInTaskCategory.documentation,
      'label': 'Documentação',
      'icon': Icons.description
    },
    {
      'value': MoveInTaskCategory.moving,
      'label': 'Mudança',
      'icon': Icons.local_shipping
    },
    {
      'value': MoveInTaskCategory.decoration,
      'label': 'Decoração',
      'icon': Icons.palette
    },
  ];

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.taskToEdit?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.taskToEdit?.description ?? '');
    _selectedCategory =
        widget.taskToEdit?.category ?? MoveInTaskCategory.essentials;
    _isCritical = widget.taskToEdit?.isCritical ?? false;
    _dueDate = widget.taskToEdit?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.taskToEdit != null;

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título do diálogo
                  Row(
                    children: [
                      Icon(
                        isEditing ? Icons.edit : Icons.add,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isEditing ? 'Editar Tarefa' : 'Nova Tarefa',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Campo de título
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Título *',
                      hintText: 'Ex: Contratar internet',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'O título é obrigatório';
                      }
                      if (value.trim().length < 3) {
                        return 'O título deve ter pelo menos 3 caracteres';
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 16),

                  // Campo de descrição
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descrição',
                      hintText: 'Detalhes adicionais sobre a tarefa',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.notes),
                    ),
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 16),

                  // Seletor de categoria
                  DropdownButtonFormField<MoveInTaskCategory>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Categoria *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem<MoveInTaskCategory>(
                        value: category['value'] as MoveInTaskCategory,
                        child: Row(
                          children: [
                            Icon(category['icon'] as IconData, size: 20),
                            const SizedBox(width: 8),
                            Text(category['label'] as String),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedCategory = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Seletor de data
                  InkWell(
                    onTap: () => _selectDate(context),
                    borderRadius: BorderRadius.circular(4),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Data de Vencimento',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _dueDate != null
                                ? '${_dueDate!.day.toString().padLeft(2, '0')}/${_dueDate!.month.toString().padLeft(2, '0')}/${_dueDate!.year}'
                                : 'Selecione uma data',
                            style: TextStyle(
                              color: _dueDate != null
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (_dueDate != null)
                            IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                setState(() => _dueDate = null);
                              },
                              tooltip: 'Limpar data',
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Switch de tarefa crítica
                  SwitchListTile(
                    value: _isCritical,
                    onChanged: (value) {
                      setState(() => _isCritical = value);
                    },
                    title: const Text('Tarefa Crítica'),
                    subtitle: const Text(
                      'Tarefas críticas têm prioridade máxima',
                    ),
                    secondary: Icon(
                      Icons.priority_high,
                      color: _isCritical ? theme.colorScheme.error : null,
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 24),

                  // Botões de ação
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: _saveTask,
                        child: Text(isEditing ? 'Salvar' : 'Adicionar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = _dueDate ?? now;

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(now) ? now : initialDate,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
      locale: const Locale('pt', 'BR'),
      helpText: 'Selecione a data de vencimento',
      cancelText: 'Cancelar',
      confirmText: 'OK',
    );

    if (selectedDate != null) {
      setState(() => _dueDate = selectedDate);
    }
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (widget.taskToEdit != null) {
      // Editar tarefa existente
      final updatedTask = widget.taskToEdit!.copyWith(
        title: title,
        description: description,
        category: _selectedCategory,
        isCritical: _isCritical,
        dueDate: _dueDate,
      );
      context.read<MoveInCubit>().updateTask(updatedTask);
    } else {
      // Adicionar nova tarefa - criar Entity completa
      final newTask = MoveInTaskEntity(
        id: '', // Será gerado pelo repository
        title: title,
        description: description,
        category: _selectedCategory,
        isCompleted: false,
        isCritical: _isCritical,
        isCustom: true,
        dueDate: _dueDate,
        completedAt: null,
      );
      context.read<MoveInCubit>().addTask(newTask);
    }

    Navigator.of(context).pop();
  }
}

// Made with Bob
