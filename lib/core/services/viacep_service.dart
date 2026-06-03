import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../error/failures.dart';

/// Dados de endereço retornados pela API ViaCEP
class AddressData {
  final String cep;
  final String logradouro;
  final String complemento;
  final String bairro;
  final String localidade;
  final String uf;

  AddressData({
    required this.cep,
    required this.logradouro,
    required this.complemento,
    required this.bairro,
    required this.localidade,
    required this.uf,
  });

  factory AddressData.fromJson(Map<String, dynamic> json) {
    return AddressData(
      cep: json['cep'] ?? '',
      logradouro: json['logradouro'] ?? '',
      complemento: json['complemento'] ?? '',
      bairro: json['bairro'] ?? '',
      localidade: json['localidade'] ?? '',
      uf: json['uf'] ?? '',
    );
  }

  /// Retorna o endereço completo formatado
  String get fullAddress {
    final parts = <String>[];

    if (logradouro.isNotEmpty) parts.add(logradouro);
    if (bairro.isNotEmpty) parts.add(bairro);
    if (localidade.isNotEmpty && uf.isNotEmpty) {
      parts.add('$localidade/$uf');
    }

    return parts.join(', ');
  }

  /// Retorna apenas cidade e estado
  String get cityState {
    return '$localidade/$uf';
  }
}

/// Service para integração com a API ViaCEP
@injectable
class ViaCepService {
  final Dio _dio;

  ViaCepService(this._dio);

  /// Busca dados de endereço pelo CEP
  ///
  /// Retorna [AddressData] com os dados do endereço ou [Failure] em caso de erro
  Future<Either<Failure, AddressData>> getAddress(String cep) async {
    try {
      // Remove caracteres não numéricos do CEP
      final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');

      // Valida o CEP
      if (cleanCep.length != 8) {
        return Left(ValidationFailure('CEP inválido. Deve conter 8 dígitos.'));
      }

      // Faz a requisição para a API
      final response = await _dio.get(
        'https://viacep.com.br/ws/$cleanCep/json/',
      );

      // Verifica se o CEP foi encontrado
      if (response.data['erro'] == true) {
        return Left(NotFoundFailure('CEP não encontrado.'));
      }

      // Converte a resposta para AddressData
      final addressData = AddressData.fromJson(response.data);
      return Right(addressData);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return Left(
          ServerFailure('Tempo de conexão esgotado. Tente novamente.'),
        );
      } else if (e.type == DioExceptionType.connectionError) {
        return Left(ServerFailure('Erro de conexão. Verifique sua internet.'));
      } else {
        return Left(ServerFailure('Erro ao buscar CEP: ${e.message}'));
      }
    } catch (e) {
      return Left(ServerFailure('Erro inesperado ao buscar CEP: $e'));
    }
  }

  /// Valida se um CEP tem formato válido (apenas formato, não verifica se existe)
  bool isValidCepFormat(String cep) {
    final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');
    return cleanCep.length == 8;
  }

  /// Formata um CEP para o padrão brasileiro (00000-000)
  String formatCep(String cep) {
    final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanCep.length != 8) {
      return cep; // Retorna o original se não tiver 8 dígitos
    }

    return '${cleanCep.substring(0, 5)}-${cleanCep.substring(5)}';
  }
}

// Made with Bob
