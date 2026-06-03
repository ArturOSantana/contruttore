import 'package:equatable/equatable.dart';
import 'package:contruttore/features/auth/domain/entities/user_entity.dart';
import 'package:contruttore/features/projects/domain/entities/project_entity.dart';
import 'package:contruttore/features/home/domain/entities/next_action_entity.dart';
import 'package:contruttore/features/home/domain/entities/financial_summary_entity.dart';
import 'package:contruttore/features/home/domain/entities/alert_entity.dart';
import 'package:contruttore/features/home/domain/entities/weather_entity.dart';

/// Representa todos os dados necessários para a tela Home
class HomeDataEntity extends Equatable {
  final UserEntity user;
  final ProjectEntity project;
  final NextActionEntity? nextAction;
  final FinancialSummaryEntity financialSummary;
  final List<AlertEntity> activeAlerts;
  final WeatherEntity? weather;

  const HomeDataEntity({
    required this.user,
    required this.project,
    this.nextAction,
    required this.financialSummary,
    required this.activeAlerts,
    this.weather,
  });

  @override
  List<Object?> get props => [
    user,
    project,
    nextAction,
    financialSummary,
    activeAlerts,
    weather,
  ];
}

// Made with Bob
