import 'package:equatable/equatable.dart';
import '../../domain/entities/document_entity.dart';

abstract class DocumentsState extends Equatable {
  const DocumentsState();

  @override
  List<Object?> get props => [];
}

class DocumentsInitial extends DocumentsState {}

class DocumentsLoading extends DocumentsState {}

class DocumentsLoaded extends DocumentsState {
  final List<DocumentEntity> documents;

  const DocumentsLoaded(this.documents);

  @override
  List<Object?> get props => [documents];
}

class DocumentsError extends DocumentsState {
  final String message;

  const DocumentsError(this.message);

  @override
  List<Object?> get props => [message];
}

class DocumentUploadingFile extends DocumentsState {
  final double progress;

  const DocumentUploadingFile(this.progress);

  @override
  List<Object?> get props => [progress];
}

class DocumentAdded extends DocumentsState {}

class DocumentDeleted extends DocumentsState {}

// Made with Bob
