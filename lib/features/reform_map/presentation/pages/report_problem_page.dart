import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/problem_entity.dart';
import '../cubit/reform_map_cubit.dart';

/// Página para reportar um problema na reforma
class ReportProblemPage extends StatefulWidget {
  final String projectId;
  final String? phaseId;
  final String? phaseName;

  const ReportProblemPage({
    super.key,
    required this.projectId,
    this.phaseId,
    this.phaseName,
  });

  @override
  State<ReportProblemPage> createState() => _ReportProblemPageState();
}

class _ReportProblemPageState extends State<ReportProblemPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  ProblemSeverity _severity = ProblemSeverity.medium;
  ProblemType _selectedType = ProblemType.other;

  final Map<ProblemType, String> _problemTypes = {
    ProblemType.leak: 'Infiltração',
    ProblemType.wrongMaterial: 'Material errado',
    ProblemType.delay: 'Atraso de fornecedor',
    ProblemType.defect: 'Defeito na execução',
    ProblemType.damage: 'Problema estrutural',
    ProblemType.quality: 'Problema de qualidade',
    ProblemType.other: 'Outro',
  };

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportar Problema'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Informação da fase (se fornecida)
            if (widget.phaseName != null) ...[
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Etapa: ${widget.phaseName}',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Tipo do Problema
            DropdownButtonFormField<ProblemType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Tipo do Problema *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _problemTypes.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Título
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
                hintText: 'Ex: Vazamento na cozinha',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Digite um título';
                }
                if (value.length < 3) {
                  return 'Título muito curto';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Descrição
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                hintText: 'Descreva o problema em detalhes',
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Digite uma descrição';
                }
                if (value.length < 10) {
                  return 'Descrição muito curta';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Gravidade
            const Text(
              'Gravidade *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            _buildSeveritySelector(),
            const SizedBox(height: 24),

            // Botão de salvar
            ElevatedButton.icon(
              onPressed: _saveProblem,
              icon: const Icon(Icons.save),
              label: const Text('Reportar Problema'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeveritySelector() {
    return Column(
      children: [
        _buildSeverityOption(
          severity: ProblemSeverity.low,
          title: 'Baixa',
          description: 'Não afeta o andamento da obra',
          icon: Icons.info_outline,
          color: Colors.blue,
        ),
        const SizedBox(height: 8),
        _buildSeverityOption(
          severity: ProblemSeverity.medium,
          title: 'Média',
          description: 'Pode causar atrasos se não resolvido',
          icon: Icons.warning_amber,
          color: Colors.orange,
        ),
        const SizedBox(height: 8),
        _buildSeverityOption(
          severity: ProblemSeverity.critical,
          title: 'Crítica',
          description: 'Precisa ser resolvido imediatamente',
          icon: Icons.error,
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildSeverityOption({
    required ProblemSeverity severity,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _severity == severity;

    return InkWell(
      onTap: () {
        setState(() {
          _severity = severity;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? color.withOpacity(0.1) : null,
        ),
        child: Row(
          children: [
            Radio<ProblemSeverity>(
              value: severity,
              groupValue: _severity,
              onChanged: (value) {
                setState(() {
                  _severity = value!;
                });
              },
              activeColor: color,
            ),
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : null,
                    ),
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveProblem() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final problem = ProblemEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      projectId: widget.projectId,
      phaseId: widget.phaseId,
      phaseName: widget.phaseName,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      type: _selectedType,
      severity: _severity,
      status: ProblemStatus.open,
      reportedAt: DateTime.now(),
    );

    // Adicionar problema via cubit
    context.read<ReformMapCubit>().addProblem(problem);

    // Mostrar mensagem de sucesso
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Problema reportado com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );

    // Voltar para a tela anterior
    Navigator.of(context).pop();
  }
}

// Made with Bob
