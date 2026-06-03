import 'package:equatable/equatable.dart';
import '../../domain/entities/alert_entity.dart';

abstract class AlertsState extends Equatable {
  const AlertsState();

  @override
  List<Object?> get props => [];
}

class AlertsInitial extends AlertsState {
  const AlertsInitial();
}

class AlertsLoading extends AlertsState {
  const AlertsLoading();
}

class AlertsLoaded extends AlertsState {
  final List<AlertEntity> alerts;
  final int unreadCount;
  final AlertType? filterType;

  const AlertsLoaded({
    required this.alerts,
    required this.unreadCount,
    this.filterType,
  });

  List<AlertEntity> get filteredAlerts {
    if (filterType == null) return alerts;
    return alerts.where((alert) => alert.type == filterType).toList();
  }

  @override
  List<Object?> get props => [alerts, unreadCount, filterType];
}

class AlertsError extends AlertsState {
  final String message;

  const AlertsError(this.message);

  @override
  List<Object?> get props => [message];
}

class AlertMarkedAsRead extends AlertsState {
  final String alertId;

  const AlertMarkedAsRead(this.alertId);

  @override
  List<Object?> get props => [alertId];
}

class AlertSnoozed extends AlertsState {
  final String alertId;

  const AlertSnoozed(this.alertId);

  @override
  List<Object?> get props => [alertId];
}

class AlertsGenerated extends AlertsState {
  const AlertsGenerated();
}

// Made with Bob
