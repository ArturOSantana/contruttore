import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../injection_container.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../domain/entities/diary_entry_entity.dart';
import '../cubit/diary_cubit.dart';
import '../cubit/diary_state.dart';

class DiaryPage extends StatelessWidget {
  final String projectId;
  final String projectName;

  const DiaryPage({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<DiaryCubit>()..loadDiaryEntries(projectId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Diário de Obra'),
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: () => _showPdfOptions(context),
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showFilterOptions(context),
            ),
          ],
        ),
        body: BlocConsumer<DiaryCubit, DiaryState>(
          listener: (context, state) {
            if (state is DiaryError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            } else if (state is DiaryEntryAdded) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Entrada adicionada com sucesso!'),
                ),
              );
            } else if (state is DiaryPdfGenerated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('PDF gerado: ${state.filePath}')),
              );
            }
          },
          builder: (context, state) {
            if (state is DiaryLoading) {
              return const LoadingWidget(type: LoadingType.list);
            }

            if (state is DiaryUploadingPhoto) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Enviando foto ${state.currentIndex} de ${state.totalPhotos}',
                    ),
                  ],
                ),
              );
            }

            if (state is DiaryGeneratingPdf) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Gerando PDF...'),
                  ],
                ),
              );
            }

            if (state is DiaryLoaded) {
              if (state.entries.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.book,
                  title: 'Nenhuma entrada no diário',
                  message: state.hasInactivityAlert
                      ? 'Comece registrando o progresso da sua obra.\n\n⚠️ Registrar a obra protege você em caso de disputas com fornecedores.'
                      : 'Comece registrando o progresso da sua obra',
                  actionLabel: 'Nova Entrada',
                  onAction: () => _showAddEntryDialog(context),
                );
              }

              final groupedEntries = context
                  .read<DiaryCubit>()
                  .groupEntriesByDate(state.entries);

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: groupedEntries.length,
                itemBuilder: (context, index) {
                  final dateKey = groupedEntries.keys.elementAt(index);
                  final entries = groupedEntries[dateKey]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          dateKey,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...entries.map((entry) => _buildEntryCard(entry)),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddEntryDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Nova Entrada'),
        ),
      ),
    );
  }

  Widget _buildEntryCard(DiaryEntryEntity entry) {
    return Builder(
      builder: (context) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(entry.type.icon, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.type.displayName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          entry.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        await context.push(
                          '${RouteNames.diaryCreate}?projectId=$projectId',
                          extra: entry,
                        );

                        if (context.mounted) {
                          context.read<DiaryCubit>().loadDiaryEntries(
                            projectId,
                          );
                        }
                      } else if (value == 'delete') {
                        final confirmed = await ConfirmationDialog.show(
                          context,
                          title: 'Excluir Entrada',
                          message:
                              'Tem certeza que deseja excluir "${entry.title}"?',
                          confirmLabel: 'Excluir',
                          cancelLabel: 'Cancelar',
                          isDestructive: true,
                        );

                        if (confirmed && context.mounted) {
                          await context.read<DiaryCubit>().deleteDiaryEntry(
                            projectId,
                            entry.id,
                          );

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Entrada excluída com sucesso'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Excluir'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(entry.description),
              if (entry.photoUrls.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: entry.photoUrls.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(entry.photoUrls[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              if (entry.problemSeverity != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getSeverityColor(entry.problemSeverity!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Gravidade: ${entry.problemSeverity!.displayName}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getSeverityColor(ProblemSeverity severity) {
    switch (severity) {
      case ProblemSeverity.low:
        return Colors.green;
      case ProblemSeverity.medium:
        return Colors.orange;
      case ProblemSeverity.high:
        return Colors.red;
    }
  }

  void _showAddEntryDialog(BuildContext context) {
    // TODO: Implementar dialog para adicionar entrada
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
    );
  }

  void _showFilterOptions(BuildContext context) {
    // TODO: Implementar filtros
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Filtros em desenvolvimento')));
  }

  void _showPdfOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Gerar PDF'),
        content: const Text('Deseja gerar o PDF do diário completo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              final state = context.read<DiaryCubit>().state;
              if (state is DiaryLoaded) {
                context.read<DiaryCubit>().generatePdf(
                  projectName: projectName,
                  entries: state.entries,
                );
              }
            },
            child: const Text('Gerar'),
          ),
        ],
      ),
    );
  }
}

// Made with Bob
