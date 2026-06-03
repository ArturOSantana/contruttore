import 'package:equatable/equatable.dart';

/// Representa informações meteorológicas relevantes para a obra
class WeatherEntity extends Equatable {
  final String condition; // 'sunny', 'cloudy', 'rainy', 'stormy'
  final double temperature;
  final DateTime forecastDate;
  final String warning; // Mensagem de alerta se houver
  final bool isCritical; // Se requer atenção imediata

  const WeatherEntity({
    required this.condition,
    required this.temperature,
    required this.forecastDate,
    required this.warning,
    required this.isCritical,
  });

  @override
  List<Object?> get props => [
    condition,
    temperature,
    forecastDate,
    warning,
    isCritical,
  ];
}

// Made with Bob
