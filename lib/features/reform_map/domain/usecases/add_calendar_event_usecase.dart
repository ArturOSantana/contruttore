import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reform_calendar_entity.dart';
import '../repositories/reform_map_repository.dart';

/// Use case para adicionar um evento customizado ao calendário
@injectable
class AddCalendarEventUseCase implements UseCase<void, AddCalendarEventParams> {
  final ReformMapRepository repository;

  AddCalendarEventUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AddCalendarEventParams params) async {
    return await repository.addCalendarEvent(
      projectId: params.projectId,
      event: params.event,
    );
  }
}

class AddCalendarEventParams {
  final String projectId;
  final CalendarEventEntity event;

  AddCalendarEventParams({
    required this.projectId,
    required this.event,
  });
}

// Made with Bob
