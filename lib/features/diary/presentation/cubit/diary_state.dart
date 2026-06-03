import 'package:equatable/equatable.dart';
import '../../domain/entities/diary_entry_entity.dart';

abstract class DiaryState extends Equatable {
  const DiaryState();

  @override
  List<Object?> get props => [];
}

class DiaryInitial extends DiaryState {}

class DiaryLoading extends DiaryState {}

class DiaryLoaded extends DiaryState {
  final List<DiaryEntryEntity> entries;
  final bool hasInactivityAlert;

  const DiaryLoaded({required this.entries, this.hasInactivityAlert = false});

  @override
  List<Object?> get props => [entries, hasInactivityAlert];

  DiaryLoaded copyWith({
    List<DiaryEntryEntity>? entries,
    bool? hasInactivityAlert,
  }) {
    return DiaryLoaded(
      entries: entries ?? this.entries,
      hasInactivityAlert: hasInactivityAlert ?? this.hasInactivityAlert,
    );
  }
}

class DiaryError extends DiaryState {
  final String message;

  const DiaryError(this.message);

  @override
  List<Object?> get props => [message];
}

class DiaryUploadingPhoto extends DiaryState {
  final int currentIndex;
  final int totalPhotos;

  const DiaryUploadingPhoto({
    required this.currentIndex,
    required this.totalPhotos,
  });

  @override
  List<Object?> get props => [currentIndex, totalPhotos];
}

class DiaryPhotoUploaded extends DiaryState {
  final String photoUrl;

  const DiaryPhotoUploaded(this.photoUrl);

  @override
  List<Object?> get props => [photoUrl];
}

class DiaryEntryAdded extends DiaryState {}

class DiaryGeneratingPdf extends DiaryState {}

class DiaryPdfGenerated extends DiaryState {
  final String filePath;

  const DiaryPdfGenerated(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

// Made with Bob
