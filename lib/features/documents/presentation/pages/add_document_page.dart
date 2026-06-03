import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:file_picker/file_picker.dart';  // Temporariamente desabilitado
import 'package:image_picker/image_picker.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/document_entity.dart';
import '../cubit/documents_cubit.dart';
import '../cubit/documents_state.dart';

class AddDocumentPage extends StatefulWidget {
  final String projectId;

  const AddDocumentPage({super.key, required this.projectId});

  @override
  State<AddDocumentPage> createState() => _AddDocumentPageState();
}

class _AddDocumentPageState extends State<AddDocumentPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();

  DocumentType _selectedType = DocumentType.other;
  String? _filePath;
  String? _fileName;
  DateTime? _expiryDate;

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DocumentsCubit>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Adicionar Documento')),
        body: BlocConsumer<DocumentsCubit, DocumentsState>(
          listener: (context, state) {
            if (state is DocumentsError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            } else if (state is DocumentAdded) {
              Navigator.pop(context);
            }
          },
          builder: (context, state) {
            if (state is DocumentUploadingFile) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Enviando documento...',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              );
            }

            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  DropdownButtonFormField<DocumentType>(
                    initialValue: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Documento',
                      border: OutlineInputBorder(),
                    ),
                    items: DocumentType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Row(
                          children: [
                            Text(
                              type.icon,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Text(type.displayName),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                        if (_selectedType.requiresExpiryDate &&
                            _expiryDate == null) {
                          _expiryDate = DateTime.now().add(
                            const Duration(days: 365),
                          );
                        }
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome do Documento',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o nome do documento';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.attach_file),
                      title: Text(_fileName ?? 'Selecionar arquivo'),
                      subtitle: _filePath != null
                          ? const Text('Arquivo selecionado')
                          : const Text('PDF ou Imagem'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.photo_library),
                            onPressed: _pickImage,
                            tooltip: 'Selecionar imagem',
                          ),
                          IconButton(
                            icon: const Icon(Icons.picture_as_pdf),
                            onPressed: _pickPDF,
                            tooltip: 'Selecionar PDF',
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_selectedType.requiresExpiryDate ||
                      _expiryDate != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    ListTile(
                      title: const Text('Data de Vencimento'),
                      subtitle: _expiryDate != null
                          ? Text(
                              '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}',
                            )
                          : const Text('Selecione a data'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _selectExpiryDate,
                    ),
                    if (_selectedType.requiresExpiryDate && _expiryDate == null)
                      const Padding(
                        padding: EdgeInsets.only(left: 16, top: 4),
                        child: Text(
                          'Data de vencimento obrigatória para este tipo',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Observações (opcional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ElevatedButton(
                    onPressed: _submit,
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Adicionar Documento'),
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final result = await picker.pickImage(source: ImageSource.gallery);

    if (result != null) {
      setState(() {
        _filePath = result.path;
        _fileName = result.name;
      });
    }
  }

  Future<void> _pickPDF() async {
    // TODO: Reabilitar quando file_picker suportar SDK 36
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Seleção de PDF temporariamente desabilitada'),
      ),
    );
    // final result = await FilePicker.platform.pickFiles(
    //   type: FileType.custom,
    //   allowedExtensions: ['pdf'],
    // );
    //
    // if (result != null && result.files.isNotEmpty) {
    //   setState(() {
    //     _filePath = result.files.first.path;
    //     _fileName = result.files.first.name;
    //   });
    // }
  }

  Future<void> _selectExpiryDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (date != null) {
      setState(() {
        _expiryDate = date;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_filePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione um arquivo')),
      );
      return;
    }

    if (_selectedType.requiresExpiryDate && _expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Data de vencimento obrigatória para este tipo de documento',
          ),
        ),
      );
      return;
    }

    context.read<DocumentsCubit>().addDocument(
      projectId: widget.projectId,
      type: _selectedType,
      name: _nameController.text,
      filePath: _filePath!,
      expiryDate: _expiryDate,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );
  }
}

// Made with Bob
