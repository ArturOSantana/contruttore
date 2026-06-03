import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/diary_entry_entity.dart';
import '../../domain/usecases/add_diary_entry_usecase.dart';
import '../../domain/usecases/check_inactivity_usecase.dart';
import '../../domain/usecases/generate_pdf_usecase.dart';
import '../../domain/usecases/get_diary_entries_usecase.dart';
import '../../domain/usecases/upload_photo_usecase.dart';
import '../../domain/usecases/delete_diary_entry_usecase.dart';
import '../../domain/usecases/update_diary_entry_usecase.dart';
import '../../../diary/data/models/diary_entry_model.dart';
import 'diary_state.dart';

@injectable
class DiaryCubit extends Cubit<DiaryState> {
  final GetDiaryEntriesUseCase _getDiaryEntriesUseCase;
  final AddDiaryEntryUseCase _addDiaryEntryUseCase;
  final UpdateDiaryEntryUseCase _updateDiaryEntryUseCase;
  final UploadPhotoUseCase _uploadPhotoUseCase;
  final CheckInactivityUseCase _checkInactivityUseCase;
  final GeneratePdfUseCase _generatePdfUseCase;
  final DeleteDiaryEntryUseCase _deleteDiaryEntryUseCase;

  DiaryCubit(
    this._getDiaryEntriesUseCase,
    this._addDiaryEntryUseCase,
    this._updateDiaryEntryUseCase,
    this._uploadPhotoUseCase,
    this._checkInactivityUseCase,
    this._generatePdfUseCase,
    this._deleteDiaryEntryUseCase,
  ) : super(DiaryInitial());

  Future<void> loadDiaryEntries(String projectId) async {
    emit(DiaryLoading());

    final result = await _getDiaryEntriesUseCase(projectId);

    result.fold((failure) => emit(DiaryError(failure.message)), (
      entries,
    ) async {
      // Check for inactivity
      final inactivityResult = await _checkInactivityUseCase(projectId);
      final hasInactivityAlert = inactivityResult.fold(
        (failure) => false,
        (isInactive) => isInactive,
      );

      emit(
        DiaryLoaded(entries: entries, hasInactivityAlert: hasInactivityAlert),
      );
    });
  }

  Future<void> addDiaryEntry({
    required String projectId,
    required DiaryEntryType type,
    String? phaseId,
    required String title,
    required String description,
    required List<String> photoPaths,
    String? supplierId,
    String? visitType,
    ProblemSeverity? problemSeverity,
    bool? isResolved,
  }) async {
    emit(DiaryLoading());

    try {
      // Upload photos first
      final photoUrls = <String>[];
      for (int i = 0; i < photoPaths.length; i++) {
        emit(
          DiaryUploadingPhoto(
            currentIndex: i + 1,
            totalPhotos: photoPaths.length,
          ),
        );

        final result = await _uploadPhotoUseCase(projectId, photoPaths[i]);
        result.fold(
          (failure) => throw Exception(failure.message),
          (url) => photoUrls.add(url),
        );
      }

      // Create diary entry
      final entry = DiaryEntryModel(
        id: const Uuid().v4(),
        projectId: projectId,
        type: type,
        phaseId: phaseId,
        title: title,
        description: description,
        photoUrls: photoUrls,
        date: DateTime.now(),
        supplierId: supplierId,
        visitType: visitType,
        problemSeverity: problemSeverity,
        isResolved: isResolved,
        createdAt: DateTime.now(),
      );

      final result = await _addDiaryEntryUseCase(entry);

      result.fold((failure) => emit(DiaryError(failure.message)), (_) {
        emit(DiaryEntryAdded());
        loadDiaryEntries(projectId);
      });
    } catch (e) {
      emit(DiaryError('Erro ao adicionar entrada: $e'));
    }
  }

  Future<void> generatePdf({
    required String projectName,
    required List<DiaryEntryEntity> entries,
    String? phaseFilter,
  }) async {
    emit(DiaryGeneratingPdf());

    final result = await _generatePdfUseCase(
      projectName: projectName,
      entries: entries,
      phaseFilter: phaseFilter,
    );

    result.fold(
      (failure) => emit(DiaryError(failure.message)),
      (file) => emit(DiaryPdfGenerated(file.path)),
    );
  }

  List<DiaryEntryEntity> filterEntries({
    required List<DiaryEntryEntity> entries,
    String? phaseId,
    DiaryEntryType? type,
    DateTime? month,
  }) {
    var filtered = entries;

    if (phaseId != null) {
      filtered = filtered.where((e) => e.phaseId == phaseId).toList();
    }

    if (type != null) {
      filtered = filtered.where((e) => e.type == type).toList();
    }

    if (month != null) {
      filtered = filtered.where((e) {
        return e.date.year == month.year && e.date.month == month.month;
      }).toList();
    }

    return filtered;
  }

  Map<String, List<DiaryEntryEntity>> groupEntriesByDate(
    List<DiaryEntryEntity> entries,
  ) {
    final grouped = <String, List<DiaryEntryEntity>>{};

    for (final entry in entries) {
      final dateKey =
          '${entry.date.day}/${entry.date.month}/${entry.date.year}';
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(entry);
    }

    return grouped;
  }

  Future<void> deleteDiaryEntry(String projectId, String entryId) async {
    final result = await _deleteDiaryEntryUseCase(
      DeleteDiaryEntryParams(projectId: projectId, entryId: entryId),
    );

    result.fold(
      (failure) => emit(DiaryError(failure.message)),
      (_) => loadDiaryEntries(projectId),
    );
  }

  Future<void> updateDiaryEntry(DiaryEntryEntity entry) async {
    emit(DiaryLoading());

    final result = await _updateDiaryEntryUseCase(entry);

    result.fold((failure) => emit(DiaryError(failure.message)), (_) {
      emit(DiaryEntryAdded()); // Reutiliza o mesmo estado de sucesso
      loadDiaryEntries(entry.projectId);
    });
  }
}

// Made with Bob
