import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/alert_entity.dart';
import '../../domain/usecases/add_alert_usecase.dart';
import '../../domain/usecases/generate_alerts_usecase.dart';
import '../../domain/usecases/get_alerts_usecase.dart';
import '../../domain/usecases/get_unread_count_usecase.dart';
import '../../domain/usecases/mark_as_read_usecase.dart';
import 'alerts_state.dart';

@injectable
class AlertsCubit extends Cubit<AlertsState> {
  final GetAlertsUseCase _getAlertsUseCase;
  final AddAlertUseCase _addAlertUseCase;
  final MarkAsReadUseCase _markAsReadUseCase;
  final GetUnreadCountUseCase _getUnreadCountUseCase;
  final GenerateAlertsUseCase _generateAlertsUseCase;

  AlertsCubit(
    this._getAlertsUseCase,
    this._addAlertUseCase,
    this._markAsReadUseCase,
    this._getUnreadCountUseCase,
    this._generateAlertsUseCase,
  ) : super(const AlertsInitial());

  String? _currentProjectId;
  AlertType? _currentFilter;

  Future<void> loadAlerts(String projectId) async {
    _currentProjectId = projectId;
    emit(const AlertsLoading());

    final alertsResult = await _getAlertsUseCase(projectId);
    final countResult = await _getUnreadCountUseCase(projectId);

    alertsResult.fold((failure) => emit(AlertsError(failure.message)), (
      alerts,
    ) {
      countResult.fold(
        (failure) => emit(AlertsError(failure.message)),
        (count) => emit(
          AlertsLoaded(
            alerts: alerts,
            unreadCount: count,
            filterType: _currentFilter,
          ),
        ),
      );
    });
  }

  Future<void> addAlert(AlertEntity alert) async {
    final result = await _addAlertUseCase(alert);

    result.fold((failure) => emit(AlertsError(failure.message)), (_) {
      if (_currentProjectId != null) {
        loadAlerts(_currentProjectId!);
      }
    });
  }

  Future<void> markAsRead(String alertId) async {
    if (_currentProjectId == null) return;

    final result = await _markAsReadUseCase(_currentProjectId!, alertId);

    result.fold((failure) => emit(AlertsError(failure.message)), (_) {
      emit(AlertMarkedAsRead(alertId));
      loadAlerts(_currentProjectId!);
    });
  }

  Future<void> generateAlerts(String projectId) async {
    final result = await _generateAlertsUseCase(projectId);

    result.fold((failure) => emit(AlertsError(failure.message)), (_) {
      emit(const AlertsGenerated());
      loadAlerts(projectId);
    });
  }

  Future<int> getUnreadCount(String projectId) async {
    final result = await _getUnreadCountUseCase(projectId);

    return result.fold((failure) => 0, (count) => count);
  }

  void filterByType(AlertType? type) {
    _currentFilter = type;

    if (state is AlertsLoaded) {
      final currentState = state as AlertsLoaded;
      emit(
        AlertsLoaded(
          alerts: currentState.alerts,
          unreadCount: currentState.unreadCount,
          filterType: type,
        ),
      );
    }
  }

  void clearFilter() {
    filterByType(null);
  }
}

// Made with Bob
