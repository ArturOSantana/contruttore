import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../projects/domain/entities/phase_entity.dart';
import '../../../projects/presentation/cubit/project_cubit.dart';

/// Página de diagnóstico inicial do Mapa da Reforma
///
/// Pergunta ao usuário onde ele está na reforma para
/// configurar automaticamente o estado das fases
class ReformMapOnboardingPage extends StatefulWidget {
  final String projectId;

  const ReformMapOnboardingPage({
    super.key,
    required this.projectId,
  });

  @override
  State<ReformMapOnboardingPage> createState() =>
      _ReformMapOnboardingPageState();
}

class _ReformMapOnboardingPageState extends State<ReformMapOnboardingPage> {
  String? _selectedStage;

  final Map<String, Map<String, dynamic>> _stages = {
    'just_got_keys': {
      'title': 'Acabei de pegar as chaves',
      'description': 'Ainda não comecei nada',
      'icon': Icons.key,
      'completedPhases': <String>[],
    },
    'planning': {
      'title': 'Estou planejando',
      'description': 'Definindo o que fazer',
      'icon': Icons.architecture,
      'completedPhases': <String>[],
    },
    'demolition': {
      'title': 'Já comecei a reforma',
      'description': 'Demolição em andamento',
      'icon': Icons.construction,
      'completedPhases': ['Planejamento'],
    },
    'installations': {
      'title': 'Estou fazendo instalações',
      'description': 'Hidráulica e elétrica',
      'icon': Icons.plumbing,
      'completedPhases': ['Planejamento', 'Demolição'],
    },
    'finishing': {
      'title': 'Estou finalizando',
      'description': 'Revestimentos e pintura',
      'icon': Icons.format_paint,
      'completedPhases': [
        'Planejamento',
        'Demolição',
        'Hidráulica',
        'Elétrica'
      ],
    },
    'furnishing': {
      'title': 'Estou mobiliando',
      'description': 'Marcenaria e acabamentos',
      'icon': Icons.chair,
      'completedPhases': [
        'Planejamento',
        'Demolição',
        'Hidráulica',
        'Elétrica',
        'Revestimentos',
        'Pintura'
      ],
    },
    'moving': {
      'title': 'Estou mudando',
      'description': 'Quase pronto!',
      'icon': Icons.moving,
      'completedPhases': [
        'Planejamento',
        'Demolição',
        'Hidráulica',
        'Elétrica',
        'Revestimentos',
        'Pintura',
        'Marcenaria',
        'Acabamentos'
      ],
    },
  };

  void _handleContinue() {
    if (_selectedStage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione onde você está na reforma'),
        ),
      );
      return;
    }

    final stage = _stages[_selectedStage]!;
    final completedPhases = stage['completedPhases'] as List<String>;

    // Atualizar o projeto com as fases concluídas
    context.read<ProjectCubit>().updateProjectPhases(
          widget.projectId,
          completedPhases,
        );

    // Voltar para o Mapa da Reforma
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Onde você está na reforma?'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vamos configurar seu Mapa da Reforma',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Selecione o estágio atual da sua reforma para que possamos configurar automaticamente o que já foi feito.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _stages.length,
              itemBuilder: (context, index) {
                final entry = _stages.entries.elementAt(index);
                final key = entry.key;
                final stage = entry.value;
                final isSelected = _selectedStage == key;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: isSelected ? 4 : 1,
                  color: isSelected
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : null,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedStage = key;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              stage['icon'] as IconData,
                              color: isSelected ? Colors.white : Colors.grey,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stage['title'] as String,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  stage['description'] as String,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: Theme.of(context).primaryColor,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleContinue,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Continuar'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Made with Bob
