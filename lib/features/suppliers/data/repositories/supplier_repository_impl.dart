import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/supplier_entity.dart';
import '../../domain/entities/quote_entity.dart';
import '../../domain/repositories/supplier_repository.dart';
import '../models/supplier_model.dart';
import '../models/quote_model.dart';

@LazySingleton(as: SupplierRepository)
class SupplierRepositoryImpl implements SupplierRepository {
  final FirebaseFirestore _firestore;
  final http.Client _httpClient;

  SupplierRepositoryImpl(this._firestore, this._httpClient);

  @override
  Future<Either<Failure, List<SupplierEntity>>> getSuppliers(
    String projectId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('suppliers')
          .orderBy('createdAt', descending: true)
          .get();

      final suppliers = snapshot.docs
          .map((doc) => SupplierModel.fromMap(doc.data(), doc.id))
          .toList();

      return Right(suppliers);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar fornecedores: $e'));
    }
  }

  @override
  Future<Either<Failure, SupplierEntity>> getSupplier(
    String projectId,
    String supplierId,
  ) async {
    try {
      final doc = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('suppliers')
          .doc(supplierId)
          .get();

      if (!doc.exists) {
        return Left(ServerFailure('Fornecedor não encontrado'));
      }

      return Right(SupplierModel.fromMap(doc.data()!, doc.id));
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar fornecedor: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addSupplier(SupplierEntity supplier) async {
    try {
      final model = SupplierModel.fromEntity(supplier);
      await _firestore
          .collection('projects')
          .doc(supplier.projectId)
          .collection('suppliers')
          .add(model.toMap());

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao adicionar fornecedor: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateSupplier(SupplierEntity supplier) async {
    try {
      final model = SupplierModel.fromEntity(supplier);
      await _firestore
          .collection('projects')
          .doc(supplier.projectId)
          .collection('suppliers')
          .doc(supplier.id)
          .update(model.toMap());

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao atualizar fornecedor: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSupplier(
    String projectId,
    String supplierId,
  ) async {
    try {
      // Deletar fornecedor
      await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('suppliers')
          .doc(supplierId)
          .delete();

      // Deletar orçamentos relacionados
      final quotesSnapshot = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('quotes')
          .where('supplierId', isEqualTo: supplierId)
          .get();

      final batch = _firestore.batch();
      for (final doc in quotesSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao deletar fornecedor: $e'));
    }
  }

  @override
  Future<Either<Failure, List<QuoteEntity>>> getQuotes(
    String projectId,
    String supplierId,
  ) async {
    try {
      print('🟡 REPOSITORY: getQuotes chamado');
      print('  ProjectId: $projectId');
      print('  SupplierId: $supplierId');
      print('  Path: projects/$projectId/quotes');

      final snapshot = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('quotes')
          .where('supplierId', isEqualTo: supplierId)
          .orderBy('createdAt', descending: true)
          .get();

      print('  Documentos encontrados: ${snapshot.docs.length}');

      final quotes = snapshot.docs.map((doc) {
        print('  - Doc ID: ${doc.id}');
        return QuoteModel.fromMap(doc.data(), doc.id);
      }).toList();

      print('✅ REPOSITORY: ${quotes.length} orçamentos retornados');
      return Right(quotes);
    } catch (e) {
      print('🔴 REPOSITORY: Erro ao buscar orçamentos: $e');
      return Left(ServerFailure('Erro ao buscar orçamentos: $e'));
    }
  }

  @override
  Future<Either<Failure, List<QuoteEntity>>> getAllQuotes(
    String projectId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('quotes')
          .orderBy('createdAt', descending: true)
          .get();

      final quotes = snapshot.docs
          .map((doc) => QuoteModel.fromMap(doc.data(), doc.id))
          .toList();

      return Right(quotes);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar orçamentos: $e'));
    }
  }

  @override
  Future<Either<Failure, QuoteEntity>> getQuoteById(
    String projectId,
    String quoteId,
  ) async {
    try {
      final doc = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('quotes')
          .doc(quoteId)
          .get();

      if (!doc.exists) {
        return Left(NotFoundFailure('Orçamento não encontrado'));
      }

      return Right(QuoteModel.fromMap(doc.data()!, doc.id));
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar orçamento: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addQuote(QuoteEntity quote) async {
    try {
      print('🟡 REPOSITORY: addQuote chamado');
      print('  ProjectId: ${quote.projectId}');
      print('  SupplierId: ${quote.supplierId}');
      print('  Description: ${quote.description}');
      print('  Total: R\$ ${quote.totalValue.toStringAsFixed(2)}');
      print('  Path: projects/${quote.projectId}/quotes');

      final model = QuoteModel.fromEntity(quote);
      final docRef = await _firestore
          .collection('projects')
          .doc(quote.projectId)
          .collection('quotes')
          .add(model.toMap());

      print('✅ REPOSITORY: Orçamento salvo com ID: ${docRef.id}');
      return const Right(null);
    } catch (e) {
      print('🔴 REPOSITORY: Erro ao adicionar orçamento: $e');
      return Left(ServerFailure('Erro ao adicionar orçamento: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateQuoteStatus(
    String projectId,
    String quoteId,
    QuoteStatus status,
  ) async {
    try {
      await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('quotes')
          .doc(quoteId)
          .update({'status': status.name});

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao atualizar status do orçamento: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteQuote(
    String projectId,
    String quoteId,
  ) async {
    try {
      await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('quotes')
          .doc(quoteId)
          .delete();

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao deletar orçamento: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> validateCNPJ(String cnpj) async {
    try {
      // Remover formatação
      final cleanCNPJ = cnpj.replaceAll(RegExp(r'[^\d]'), '');

      // Validar tamanho
      if (cleanCNPJ.length != 14) {
        return const Right(false);
      }

      // Validar via BrasilAPI
      final response = await _httpClient
          .get(Uri.parse('https://brasilapi.com.br/api/cnpj/v1/$cleanCNPJ'))
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              // Se timeout, considera válido para não bloquear o usuário
              return http.Response('{}', 200);
            },
          );

      if (response.statusCode == 200) {
        return const Right(true);
      } else if (response.statusCode == 404) {
        return const Right(false);
      } else {
        // Em caso de erro da API, não bloqueia o cadastro
        return const Right(true);
      }
    } catch (e) {
      // Se a API falhar, não bloqueia o cadastro
      return const Right(true);
    }
  }
}

// Made with Bob
