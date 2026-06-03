import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../error/failures.dart';

/// Dados de CNPJ retornados pela BrasilAPI
class CnpjData {
  final String cnpj;
  final String razaoSocial;
  final String nomeFantasia;
  final String situacao;
  final String logradouro;
  final String numero;
  final String bairro;
  final String municipio;
  final String uf;
  final String cep;

  CnpjData({
    required this.cnpj,
    required this.razaoSocial,
    required this.nomeFantasia,
    required this.situacao,
    required this.logradouro,
    required this.numero,
    required this.bairro,
    required this.municipio,
    required this.uf,
    required this.cep,
  });

  factory CnpjData.fromJson(Map<String, dynamic> json) {
    return CnpjData(
      cnpj: json['cnpj'] ?? '',
      razaoSocial: json['razao_social'] ?? '',
      nomeFantasia: json['nome_fantasia'] ?? '',
      situacao: json['descricao_situacao_cadastral'] ?? '',
      logradouro: json['logradouro'] ?? '',
      numero: json['numero'] ?? '',
      bairro: json['bairro'] ?? '',
      municipio: json['municipio'] ?? '',
      uf: json['uf'] ?? '',
      cep: json['cep'] ?? '',
    );
  }

  /// Verifica se a empresa está ativa
  bool get isActive => situacao.toLowerCase().contains('ativa');

  /// Retorna o endereço completo formatado
  String get fullAddress {
    final parts = <String>[];

    if (logradouro.isNotEmpty) {
      parts.add('$logradouro${numero.isNotEmpty ? ', $numero' : ''}');
    }
    if (bairro.isNotEmpty) parts.add(bairro);
    if (municipio.isNotEmpty && uf.isNotEmpty) {
      parts.add('$municipio/$uf');
    }
    if (cep.isNotEmpty) parts.add('CEP: $cep');

    return parts.join(', ');
  }

  /// Retorna o nome para exibição (fantasia ou razão social)
  String get displayName {
    return nomeFantasia.isNotEmpty ? nomeFantasia : razaoSocial;
  }
}

/// Dados de feriado retornados pela BrasilAPI
class Holiday {
  final DateTime date;
  final String name;
  final String type;

  Holiday({required this.date, required this.name, required this.type});

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      date: DateTime.parse(json['date']),
      name: json['name'] ?? '',
      type: json['type'] ?? '',
    );
  }

  /// Verifica se é feriado nacional
  bool get isNational => type.toLowerCase() == 'national';

  /// Retorna descrição formatada do feriado
  String get description {
    final typeLabel = isNational ? 'Nacional' : 'Facultativo';
    return '$name ($typeLabel)';
  }
}

/// Service para integração com a BrasilAPI
@injectable
class BrasilApiService {
  final Dio _dio;

  BrasilApiService(this._dio);

  /// Busca dados de uma empresa pelo CNPJ
  ///
  /// Retorna [CnpjData] com os dados da empresa ou [Failure] em caso de erro
  Future<Either<Failure, CnpjData>> getCnpjData(String cnpj) async {
    try {
      // Remove caracteres não numéricos do CNPJ
      final cleanCnpj = cnpj.replaceAll(RegExp(r'[^0-9]'), '');

      // Valida o CNPJ
      if (cleanCnpj.length != 14) {
        return Left(
          ValidationFailure('CNPJ inválido. Deve conter 14 dígitos.'),
        );
      }

      // Faz a requisição para a API
      final response = await _dio.get(
        'https://brasilapi.com.br/api/cnpj/v1/$cleanCnpj',
      );

      // Converte a resposta para CnpjData
      final cnpjData = CnpjData.fromJson(response.data);
      return Right(cnpjData);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Left(NotFoundFailure('CNPJ não encontrado.'));
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return Left(
          ServerFailure('Tempo de conexão esgotado. Tente novamente.'),
        );
      } else if (e.type == DioExceptionType.connectionError) {
        return Left(ServerFailure('Erro de conexão. Verifique sua internet.'));
      } else {
        return Left(ServerFailure('Erro ao validar CNPJ: ${e.message}'));
      }
    } catch (e) {
      return Left(ServerFailure('Erro inesperado ao validar CNPJ: $e'));
    }
  }

  /// Busca feriados nacionais de um ano específico
  ///
  /// Retorna lista de [Holiday] ou [Failure] em caso de erro
  Future<Either<Failure, List<Holiday>>> getHolidays(int year) async {
    try {
      // Valida o ano
      if (year < 1900 || year > 2100) {
        return Left(ValidationFailure('Ano inválido.'));
      }

      // Faz a requisição para a API
      final response = await _dio.get(
        'https://brasilapi.com.br/api/feriados/v1/$year',
      );

      // Converte a resposta para lista de Holiday
      final holidays = (response.data as List)
          .map((json) => Holiday.fromJson(json))
          .toList();

      // Ordena por data
      holidays.sort((a, b) => a.date.compareTo(b.date));

      return Right(holidays);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return Left(
          ServerFailure('Tempo de conexão esgotado. Tente novamente.'),
        );
      } else if (e.type == DioExceptionType.connectionError) {
        return Left(ServerFailure('Erro de conexão. Verifique sua internet.'));
      } else {
        return Left(ServerFailure('Erro ao buscar feriados: ${e.message}'));
      }
    } catch (e) {
      return Left(ServerFailure('Erro inesperado ao buscar feriados: $e'));
    }
  }

  /// Verifica se uma data é feriado
  Future<Either<Failure, bool>> isHoliday(DateTime date) async {
    final holidaysResult = await getHolidays(date.year);

    return holidaysResult.fold((failure) => Left(failure), (holidays) {
      final isHoliday = holidays.any(
        (holiday) =>
            holiday.date.year == date.year &&
            holiday.date.month == date.month &&
            holiday.date.day == date.day,
      );
      return Right(isHoliday);
    });
  }

  /// Valida se um CNPJ tem formato válido (apenas formato, não verifica se existe)
  bool isValidCnpjFormat(String cnpj) {
    final cleanCnpj = cnpj.replaceAll(RegExp(r'[^0-9]'), '');
    return cleanCnpj.length == 14;
  }

  /// Formata um CNPJ para o padrão brasileiro (00.000.000/0000-00)
  String formatCnpj(String cnpj) {
    final cleanCnpj = cnpj.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanCnpj.length != 14) {
      return cnpj; // Retorna o original se não tiver 14 dígitos
    }

    return '${cleanCnpj.substring(0, 2)}.${cleanCnpj.substring(2, 5)}.${cleanCnpj.substring(5, 8)}/${cleanCnpj.substring(8, 12)}-${cleanCnpj.substring(12)}';
  }
}

// Made with Bob
