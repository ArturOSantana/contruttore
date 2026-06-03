import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../error/failures.dart';

/// Previsão diária do tempo
class DailyForecast {
  final DateTime date;
  final int precipitationProbability;
  final double precipitationSum;

  DailyForecast({
    required this.date,
    required this.precipitationProbability,
    required this.precipitationSum,
  });

  /// Verifica se há risco de chuva (probabilidade > 60% OU precipitação > 5mm)
  bool get hasRainRisk {
    return precipitationProbability > 60 || precipitationSum > 5.0;
  }

  /// Retorna o nível de risco de chuva
  RainRiskLevel get rainRiskLevel {
    if (precipitationProbability >= 80 || precipitationSum >= 10.0) {
      return RainRiskLevel.high;
    } else if (precipitationProbability >= 60 || precipitationSum >= 5.0) {
      return RainRiskLevel.medium;
    } else if (precipitationProbability >= 40 || precipitationSum >= 2.0) {
      return RainRiskLevel.low;
    } else {
      return RainRiskLevel.none;
    }
  }

  /// Retorna descrição do risco de chuva
  String get rainRiskDescription {
    switch (rainRiskLevel) {
      case RainRiskLevel.high:
        return 'Alto risco de chuva';
      case RainRiskLevel.medium:
        return 'Risco moderado de chuva';
      case RainRiskLevel.low:
        return 'Baixo risco de chuva';
      case RainRiskLevel.none:
        return 'Sem risco de chuva';
    }
  }
}

/// Níveis de risco de chuva
enum RainRiskLevel { none, low, medium, high }

/// Previsão do tempo completa
class WeatherForecast {
  final List<DailyForecast> daily;

  WeatherForecast({required this.daily});

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    final dailyData = json['daily'] as Map<String, dynamic>;
    final dates = List<String>.from(dailyData['time'] ?? []);
    final precipProb = List<int>.from(
      (dailyData['precipitation_probability_max'] ?? []).map((e) => e as int),
    );
    final precipSum = List<double>.from(
      (dailyData['precipitation_sum'] ?? []).map((e) => (e as num).toDouble()),
    );

    final daily = List.generate(dates.length, (i) {
      return DailyForecast(
        date: DateTime.parse(dates[i]),
        precipitationProbability: precipProb[i],
        precipitationSum: precipSum[i],
      );
    });

    return WeatherForecast(daily: daily);
  }

  /// Retorna a previsão de hoje
  DailyForecast? get today {
    if (daily.isEmpty) return null;
    return daily.first;
  }

  /// Retorna a previsão de amanhã
  DailyForecast? get tomorrow {
    if (daily.length < 2) return null;
    return daily[1];
  }

  /// Retorna dias com risco de chuva
  List<DailyForecast> get daysWithRainRisk {
    return daily.where((forecast) => forecast.hasRainRisk).toList();
  }

  /// Verifica se há risco de chuva nos próximos N dias
  bool hasRainRiskInNextDays(int days) {
    final nextDays = daily.take(days).toList();
    return nextDays.any((forecast) => forecast.hasRainRisk);
  }
}

/// Service para integração com a API Open-Meteo
@injectable
class WeatherService {
  final Dio _dio;

  WeatherService(this._dio);

  /// Busca previsão do tempo para uma localização
  ///
  /// Retorna [WeatherForecast] com previsão de 7 dias ou [Failure] em caso de erro
  Future<Either<Failure, WeatherForecast>> getForecast({
    required double latitude,
    required double longitude,
    int forecastDays = 7,
  }) async {
    try {
      // Valida os parâmetros
      if (latitude < -90 || latitude > 90) {
        return Left(ValidationFailure('Latitude inválida.'));
      }
      if (longitude < -180 || longitude > 180) {
        return Left(ValidationFailure('Longitude inválida.'));
      }
      if (forecastDays < 1 || forecastDays > 16) {
        return Left(
          ValidationFailure('Dias de previsão deve estar entre 1 e 16.'),
        );
      }

      // Faz a requisição para a API
      final response = await _dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'daily': 'precipitation_probability_max,precipitation_sum',
          'forecast_days': forecastDays,
          'timezone': 'America/Sao_Paulo',
        },
      );

      // Converte a resposta para WeatherForecast
      final forecast = WeatherForecast.fromJson(response.data);
      return Right(forecast);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return Left(
          ServerFailure('Tempo de conexão esgotado. Tente novamente.'),
        );
      } else if (e.type == DioExceptionType.connectionError) {
        return Left(ServerFailure('Erro de conexão. Verifique sua internet.'));
      } else {
        return Left(ServerFailure('Erro ao buscar previsão: ${e.message}'));
      }
    } catch (e) {
      return Left(ServerFailure('Erro inesperado ao buscar previsão: $e'));
    }
  }

  /// Verifica se vai chover amanhã
  ///
  /// Retorna true se houver risco de chuva amanhã
  Future<Either<Failure, bool>> willRainTomorrow({
    required double latitude,
    required double longitude,
  }) async {
    final result = await getForecast(
      latitude: latitude,
      longitude: longitude,
      forecastDays: 2,
    );

    return result.fold((failure) => Left(failure), (forecast) {
      final tomorrow = forecast.tomorrow;
      if (tomorrow == null) return const Right(false);
      return Right(tomorrow.hasRainRisk);
    });
  }

  /// Verifica se há risco de chuva nos próximos N dias
  Future<Either<Failure, bool>> hasRainRiskInNextDays({
    required double latitude,
    required double longitude,
    required int days,
  }) async {
    final result = await getForecast(
      latitude: latitude,
      longitude: longitude,
      forecastDays: days,
    );

    return result.fold(
      (failure) => Left(failure),
      (forecast) => Right(forecast.hasRainRiskInNextDays(days)),
    );
  }

  /// Retorna dias com risco de chuva nos próximos N dias
  Future<Either<Failure, List<DailyForecast>>> getDaysWithRainRisk({
    required double latitude,
    required double longitude,
    int days = 7,
  }) async {
    final result = await getForecast(
      latitude: latitude,
      longitude: longitude,
      forecastDays: days,
    );

    return result.fold(
      (failure) => Left(failure),
      (forecast) => Right(forecast.daysWithRainRisk),
    );
  }

  /// Verifica se é seguro realizar atividades sensíveis à chuva
  /// (concretagem, pintura externa, etc.)
  Future<Either<Failure, bool>> isSafeForOutdoorWork({
    required double latitude,
    required double longitude,
    int daysToCheck = 3,
  }) async {
    final result = await hasRainRiskInNextDays(
      latitude: latitude,
      longitude: longitude,
      days: daysToCheck,
    );

    return result.fold(
      (failure) => Left(failure),
      (hasRisk) => Right(!hasRisk), // Seguro se NÃO houver risco
    );
  }
}

// Made with Bob
