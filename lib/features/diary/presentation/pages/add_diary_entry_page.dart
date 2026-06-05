import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/models/diary_entry_model.dart';
import '../../domain/entities/diary_entry_entity.dart';
import '../cubit/diary_cubit.dart';

class AddDiaryEntryPage extends StatefulWidget {
  final String projectId;
  final DiaryEntryEntity? entry;

  const AddDiaryEntryPage({super.key, required this.projectId, this.entry});

  @override
  State<AddDiaryEntryPage> createState() => _AddDiaryEntryPageState();
}

class _AddDiaryEntryPageState extends State<AddDiaryEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();

  DiaryEntryType _selectedType = DiaryEntryType.daily;
  DateTime _selectedDate = DateTime.now();
  List<String> _photoUrls = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _loadEntryData();
    }
  }

  void _loadEntryData() {
    final entry = widget.entry!;
    _titleController.text = entry.title;
    _descriptionController.text = entry.description;
    _selectedType = entry.type;
    _selectedDate = entry.date;
    _photoUrls = List.from(entry.photoUrls);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _photoUrls.add(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar imagem: $e')),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Câmera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (widget.entry == null) {
        await context.read<DiaryCubit>().addDiaryEntry(
              projectId: widget.projectId,
              type: _selectedType,
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              photoPaths: _photoUrls,
            );
      } else {
        // Modo edição - atualizar entrada existente
        final updatedEntry = DiaryEntryModel(
          id: widget.entry!.id,
          projectId: widget.projectId,
          type: _selectedType,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          photoUrls: _photoUrls,
          date: _selectedDate,
          createdAt: widget.entry!.createdAt,
        );

        await context.read<DiaryCubit>().updateDiaryEntry(updatedEntry);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.entry != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Entrada' : 'Nova Entrada'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.m),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _save,
              child: Text(
                'SALVAR',
                style: AppTextStyles.label.copyWith(color: AppColors.primary),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.m),
          children: [
            // Tipo
            DropdownButtonFormField<DiaryEntryType>(
              initialValue: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Tipo *',
                border: OutlineInputBorder(),
              ),
              items: DiaryEntryType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getTypeLabel(type)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),

            const SizedBox(height: AppSpacing.m),

            // Título
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título *',
                hintText: 'Ex: Início da pintura',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe o título';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.m),

            // Descrição
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição *',
                hintText: 'Descreva o que aconteceu',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe a descrição';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.m),

            // Data
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Data',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.m),

            // Fotos
            Text('Fotos (${_photoUrls.length})', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.s),
            if (_photoUrls.isEmpty)
              Container(
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Nenhuma foto adicionada',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _photoUrls.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.s),
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.surfaceVariant,
                            ),
                            child: const Center(
                              child: Icon(Icons.image, size: 48),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _photoUrls.removeAt(index);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: AppSpacing.s),

            OutlinedButton.icon(
              onPressed: _showImageSourceDialog,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Adicionar Foto'),
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeLabel(DiaryEntryType type) {
    switch (type) {
      case DiaryEntryType.daily:
        return 'Registro Diário';
      case DiaryEntryType.visit:
        return 'Visita Técnica';
      case DiaryEntryType.problem:
        return 'Problema';
      case DiaryEntryType.delivery:
        return 'Entrega de Material';
    }
  }
}

// Made with Bob
