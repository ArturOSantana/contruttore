import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../../diary/domain/usecases/add_automatic_entry_usecase.dart';
import '../../../diary/domain/entities/diary_entry_entity.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/usecases/add_document_usecase.dart';
import '../../domain/usecases/delete_document_usecase.dart';
import '../../domain/usecases/get_documents_usecase.dart';
import '../../domain/usecases/upload_file_usecase.dart';
import '../../data/models/document_model.dart';
import 'documents_state.dart';

@injectable
class DocumentsCubit extends Cubit<DocumentsState> {
  final GetDocumentsUseCase _getDocumentsUseCase;
  final AddDocumentUseCase _addDocumentUseCase;
  final DeleteDocumentUseCase _deleteDocumentUseCase;
  final UploadFileUseCase _uploadFileUseCase;
  final AddAutomaticEntryUseCase _addAutomaticEntryUseCase;

  DocumentsCubit(
    this._getDocumentsUseCase,
    this._addDocumentUseCase,
    this._deleteDocumentUseCase,
    this._uploadFileUseCase,
    this._addAutomaticEntryUseCase,
  ) : super(DocumentsInitial());

  Future<void> loadDocuments(String projectId) async {
    emit(DocumentsLoading());

    final result = await _getDocumentsUseCase(projectId);

    result.fold(
      (failure) => emit(DocumentsError(failure.message)),
      (documents) => emit(DocumentsLoaded(documents)),
    );
  }

  Future<void> addDocument({
    required String projectId,
    required DocumentType type,
    required String name,
    required String filePath,
    DateTime? expiryDate,
    String? notes,
  }) async {
    emit(DocumentUploadingFile(0.0));

    // Upload file
    final uploadResult = await _uploadFileUseCase(projectId, filePath);

    await uploadResult.fold(
      (failure) async {
        emit(DocumentsError(failure.message));
      },
      (fileUrl) async {
        emit(DocumentUploadingFile(0.5));

        // Create document
        final document = DocumentModel(
          id: const Uuid().v4(),
          projectId: projectId,
          type: type,
          name: name,
          fileUrl: fileUrl,
          expiryDate: expiryDate,
          notes: notes,
          createdAt: DateTime.now(),
        );

        // Add to Firestore
        final addResult = await _addDocumentUseCase(document);

        await addResult.fold(
          (failure) async => emit(DocumentsError(failure.message)),
          (_) async {
            // INTEGRAÇÃO: Adiciona log automático no diário
            await _addAutomaticEntryUseCase(
              projectId: projectId,
              title: 'Documento adicionado',
              description: '${type.displayName} - $name',
              phaseId: null, // Documentos não têm fase específica
              type: DiaryEntryType.daily,
            );

            emit(DocumentAdded());
            await loadDocuments(projectId);
          },
        );
      },
    );
  }

  Future<void> deleteDocument(String projectId, String documentId) async {
    final result = await _deleteDocumentUseCase(projectId, documentId);

    result.fold((failure) => emit(DocumentsError(failure.message)), (_) {
      emit(DocumentDeleted());
      loadDocuments(projectId);
    });
  }

  Map<DocumentType, List<DocumentEntity>> groupDocumentsByType(
    List<DocumentEntity> documents,
  ) {
    final grouped = <DocumentType, List<DocumentEntity>>{};

    for (final type in DocumentType.values) {
      grouped[type] = documents.where((doc) => doc.type == type).toList();
    }

    return grouped;
  }
}

// Made with Bob
