import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart' as core;
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/document_entity.dart';
import '../cubit/documents_cubit.dart';
import '../cubit/documents_state.dart';

class DocumentsPage extends StatelessWidget {
  final String projectId;

  const DocumentsPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DocumentsCubit>()..loadDocuments(projectId),
      child: Scaffold(
        appBar: AppBar(title: const Text('Documentos')),
        body: BlocConsumer<DocumentsCubit, DocumentsState>(
          listener: (context, state) {
            if (state is DocumentsError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            } else if (state is DocumentAdded) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Documento adicionado com sucesso'),
                ),
              );
            } else if (state is DocumentDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Documento removido com sucesso')),
              );
            }
          },
          builder: (context, state) {
            if (state is DocumentsLoading) {
              return const LoadingWidget();
            }

            if (state is DocumentsError) {
              return EmptyStateWidget(
                icon: Icons.error_outline,
                title: 'Erro ao carregar documentos',
                message: state.message,
                actionLabel: 'Tentar novamente',
                onAction: () =>
                    context.read<DocumentsCubit>().loadDocuments(projectId),
              );
            }

            if (state is DocumentsLoaded) {
              if (state.documents.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.description_outlined,
                  title: 'Nenhum documento cadastrado',
                  message:
                      'Adicione contratos, plantas e outros documentos importantes',
                  actionLabel: 'Adicionar Documento',
                  onAction: () =>
                      context.push('/documents/add', extra: projectId),
                );
              }

              final grouped = context
                  .read<DocumentsCubit>()
                  .groupDocumentsByType(state.documents);

              return ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: DocumentType.values.map((type) {
                  final docs = grouped[type] ?? [];
                  if (docs.isEmpty) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                        ),
                        child: Row(
                          children: [
                            Text(
                              type.icon,
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              type.displayName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...docs.map(
                        (doc) =>
                            _DocumentCard(document: doc, projectId: projectId),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  );
                }).toList(),
              );
            }

            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.push('/documents/add', extra: projectId);
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final DocumentEntity document;
  final String projectId;

  const _DocumentCard({required this.document, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(document.type.icon, style: const TextStyle(fontSize: 20)),
        ),
        title: Text(document.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Adicionado em ${DateFormat('dd/MM/yyyy').format(document.createdAt)}',
            ),
            if (document.expiryDate != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    document.isExpired
                        ? Icons.error
                        : document.isExpiringSoon
                        ? Icons.warning
                        : Icons.check_circle,
                    size: 16,
                    color: document.isExpired
                        ? Colors.red
                        : document.isExpiringSoon
                        ? Colors.orange
                        : Colors.green,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    document.isExpired
                        ? 'Vencido'
                        : 'Vence em ${DateFormat('dd/MM/yyyy').format(document.expiryDate!)}',
                    style: TextStyle(
                      color: document.isExpired
                          ? Colors.red
                          : document.isExpiringSoon
                          ? Colors.orange
                          : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('Visualizar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share),
                  SizedBox(width: 8),
                  Text('Compartilhar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Excluir', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'view':
                _viewDocument(context);
                break;
              case 'share':
                _shareDocument();
                break;
              case 'delete':
                _deleteDocument(context);
                break;
            }
          },
        ),
      ),
    );
  }

  Future<void> _viewDocument(BuildContext context) async {
    final uri = Uri.parse(document.fileUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o documento')),
        );
      }
    }
  }

  Future<void> _shareDocument() async {
    await Share.share(
      'Confira este documento: ${document.name}\n${document.fileUrl}',
      subject: document.name,
    );
  }

  Future<void> _deleteDocument(BuildContext context) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Excluir documento',
      message: 'Deseja realmente excluir "${document.name}"?',
      confirmLabel: 'Excluir',
      isDestructive: true,
    );

    if (confirmed && context.mounted) {
      context.read<DocumentsCubit>().deleteDocument(projectId, document.id);
    }
  }
}

// Made with Bob
