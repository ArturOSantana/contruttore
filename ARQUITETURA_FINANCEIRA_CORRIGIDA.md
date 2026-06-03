# 🏗️ ARQUITETURA FINANCEIRA CORRIGIDA
## Versão 2.0 - Com Correções de Problemas Críticos

---

## ⚠️ PROBLEMAS CRÍTICOS IDENTIFICADOS E CORRIGIDOS

### 🔴 PROBLEMA 1: Escritas sem Firestore Transaction (BLOQUEADOR)

**Problema**: Duas operações separadas podem falhar no meio, causando inconsistência silenciosa.

```dart
// ❌ ERRADO - PERIGOSO
Future<void> markPaymentAsPaid(...) async {
  await _installmentRepository.markAsPaid(id, paymentId);
  // ← Se travar aqui, parcela marcada mas sem lançamento
  await _transactionRepository.create(...);
}
```

**Solução**: Usar `WriteBatch` do Firestore para operações atômicas.

```dart
// ✅ CORRETO - ATÔMICO
Future<void> markPaymentAsPaid(
  String installmentId,
  String paymentId,
  double paidAmount,
) async {
  final batch = _firestore.batch();

  // 1. Atualizar parcela
  final installmentRef = _firestore
      .collection('projects')
      .doc(projectId)
      .collection('installments')
      .doc(installmentId);

  batch.update(installmentRef, {
    'payments': FieldValue.arrayRemove([/* old payment */]),
  });
  batch.update(installmentRef, {
    'payments': FieldValue.arrayUnion([/* updated payment */]),
  });

  // 2. Criar transaction
  final transactionRef = _firestore
      .collection('projects')
      .doc(projectId)
      .collection('transactions')
      .doc();

  batch.set(transactionRef, {
    'type': 'expense',
    'source': 'installment',
    'amount': paidAmount,
    'signedAmount': paidAmount,
    'installmentId': installmentId,
    'paymentId': paymentId,
    'date': Timestamp.now(),
    'createdAt': Timestamp.now(),
  });

  // Ambas ou nenhuma — atomicamente
  await batch.commit();
}
```

---

### 🔴 PROBLEMA 2: Contagem Dupla de Compromisso (BLOQUEADOR)

**Problema**: Somar commitment + expense do mesmo contrato duplica o valor.

```dart
// ❌ ERRADO
Contrato: R$ 15.000 (commitment)
Parcela paga: R$ 3.000 (expense)
Total exibido: R$ 18.000 ← DUPLICADO!
```

**Solução**: Commitment representa o TOTAL do contrato. Expenses são subconjunto dele.

```dart
// ✅ CORRETO
class FinancialSummary {
  final double confirmed;          // Gastos reais (expenses)
  final double pendingContracts;   // Parcelas futuras
  final double estimated;          // Estimativas

  static FinancialSummary from(List<TransactionEntity> txs) {
    // 1. Gastos confirmados (expenses + reversals)
    final confirmed = txs
        .where((t) => t.type == TransactionType.expense
            || t.type == TransactionType.reversal)
        .fold(0.0, (s, t) => s + t.signedAmount);

    // 2. Total de contratos ativos
    final committed = txs
        .where((t) => t.type == TransactionType.commitment)
        .fold(0.0, (s, t) => s + t.signedAmount);

    // 3. Quanto JÁ FOI PAGO dos contratos
    final paidFromContracts = txs
        .where((t) => t.source == TransactionSource.installment
            && t.type == TransactionType.expense)
        .fold(0.0, (s, t) => s + t.amount);

    // 4. Pendente = Total do contrato - O que já foi pago
    final pendingContracts = committed - paidFromContracts;

    // 5. Estimativas (itens não comprados)
    final estimated = txs
        .where((t) => t.type == TransactionType.estimate)
        .fold(0.0, (s, t) => s + t.amount);

    return FinancialSummary(
      confirmed: confirmed,
      pendingContracts: pendingContracts,
      estimated: estimated,
      // NUNCA somar committed aqui!
      total: confirmed + pendingContracts + estimated,
    );
  }
}
```

**Dashboard Correto**:
```
Contrato Marceneiro: R$ 15.000 (5x R$ 3.000)
├─ Pago: R$ 3.000 (1/5)
└─ Falta: R$ 12.000 (4/5)

Total Comprometido: R$ 15.000 ← UM NÚMERO SÓ
```

---

### 🟡 PROBLEMA 3: Sem Estados de Reversão (IMPORTANTE)

**Problema**: Usuário não pode corrigir erros (cancelar parcela, devolver compra).

**Solução**: Adicionar `TransactionType.reversal` e `signedAmount`.

```dart
enum TransactionType {
  expense,      // Confirmado — dinheiro saiu
  commitment,   // Comprometido — vai sair no futuro
  estimate,     // Estimado — pode mudar
  reversal,     // NOVO: Estorno/cancelamento
}

enum TransactionSource {
  manual,
  installment,
  installment_reversal,  // NOVO: Cancelar parcela
  shopping,
  shopping_reversal,     // NOVO: Devolver compra
  contract,
  contract_cancel,       // NOVO: Cancelar contrato
}

class TransactionEntity {
  final String id;
  final String projectId;
  final TransactionType type;
  final TransactionSource source;
  final double amount;              // SEMPRE positivo
  final double signedAmount;        // NOVO: Negativo se reversal
  final DateTime date;
  final String description;
  
  // Rastreabilidade
  final String? supplierId;
  final String? installmentId;
  final String? paymentId;
  final String? shoppingItemId;
  final String? relatedTransactionId;  // NOVO: Para reversals
  final String? phaseId;
  final String? categoryId;
  
  // Comprovação
  final String? invoicePhotoUrl;
  final String? notes;
  
  final DateTime createdAt;
  
  // Helper
  bool get isReversal => type == TransactionType.reversal;
}
```

**Exemplo de Cancelamento**:
```dart
// Usuário pagou parcela por engano
Future<void> cancelPayment(
  String installmentId,
  String paymentId,
) async {
  final batch = _firestore.batch();

  // 1. Desmarcar parcela como paga
  final installmentRef = _getInstallmentRef(installmentId);
  batch.update(installmentRef, {
    'payments': FieldValue.arrayRemove([/* payment with isPaid=true */]),
  });
  batch.update(installmentRef, {
    'payments': FieldValue.arrayUnion([/* payment with isPaid=false */]),
  });

  // 2. Criar transaction de reversão (valor negativo)
  final transactionRef = _getNewTransactionRef();
  batch.set(transactionRef, {
    'type': 'reversal',
    'source': 'installment_reversal',
    'amount': paidAmount,
    'signedAmount': -paidAmount,  // NEGATIVO!
    'installmentId': installmentId,
    'paymentId': paymentId,
    'relatedTransactionId': originalTransactionId,
    'description': 'Cancelamento: Marcenaria - Parcela 1/5',
    'date': Timestamp.now(),
    'createdAt': Timestamp.now(),
  });

  await batch.commit();
}
```

---

### 🟡 PROBLEMA 4: Shopping Ambíguo (MELHORIA)

**Problema**: Atualizar estimate para expense perde histórico de economia.

**Solução**: Criar novo expense e manter estimate como referência.

```dart
// ❌ ERRADO - Perde histórico
Future<void> markAsPurchased(String itemId, double actualPrice) async {
  // Atualiza o mesmo documento
  await _transactionRepository.update(transactionId, {
    'type': 'expense',  // Mudou de estimate
    'amount': actualPrice,  // Mudou o valor
  });
  // Perdeu a informação de quanto era estimado!
}

// ✅ CORRETO - Preserva histórico
Future<void> markAsPurchased(
  String itemId,
  double actualPrice,
  double estimatedPrice,
) async {
  final batch = _firestore.batch();

  // 1. Marcar estimate como "fulfilled" (não deletar!)
  final estimateRef = _getTransactionRef(estimateTransactionId);
  batch.update(estimateRef, {
    'status': 'fulfilled',  // NOVO campo
    'fulfilledBy': newExpenseId,
  });

  // 2. Criar novo expense
  final expenseRef = _getNewTransactionRef();
  batch.set(expenseRef, {
    'type': 'expense',
    'source': 'shopping',
    'amount': actualPrice,
    'signedAmount': actualPrice,
    'shoppingItemId': itemId,
    'relatedTransactionId': estimateTransactionId,
    'description': 'Piso Porcelanato - 50m² (Leroy Merlin)',
    'date': Timestamp.now(),
    'createdAt': Timestamp.now(),
  });

  await batch.commit();

  // Agora podemos calcular economia:
  // economia = estimatedPrice - actualPrice
  // R$ 4.000 - R$ 3.750 = R$ 250 economizados!
}
```

---

## ✅ O QUE A PROPOSTA ACERTOU (MANTER)

### 1. TransactionEntity como Hub Central
✅ Um único ponto de verdade para toda movimentação financeira

### 2. TransactionSource para Rastreabilidade
✅ Saber origem de cada gasto (parcela, compra, manual)

### 3. Três Tipos: expense / commitment / estimate
✅ Separação clara entre gasto, compromisso e estimativa

### 4. Hooks Automáticos nos Cubits
✅ Criar transactions automaticamente ao pagar/comprar

### 5. Visão "Próximos Compromissos 30 dias"
✅ Recurso mais prático do financeiro

### 6. Adapter Pattern para Migração
✅ Manter ExpenseEntity e migrar gradualmente

---

## 🔧 IMPLEMENTAÇÃO CORRIGIDA

### TransactionEntity Completa

```dart
import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final String id;
  final String projectId;
  final TransactionType type;
  final TransactionSource source;
  
  // Valores
  final double amount;              // SEMPRE positivo
  final double signedAmount;        // Negativo se reversal
  final DateTime date;
  final String description;
  
  // Rastreabilidade
  final String? supplierId;
  final String? installmentId;
  final String? paymentId;
  final String? shoppingItemId;
  final String? relatedTransactionId;  // Para reversals e fulfillments
  final String? phaseId;
  final String? categoryId;
  
  // Comprovação
  final String? invoicePhotoUrl;
  final String? notes;
  
  // Status (para estimates)
  final TransactionStatus status;
  
  final DateTime createdAt;

  const TransactionEntity({
    required this.id,
    required this.projectId,
    required this.type,
    required this.source,
    required this.amount,
    required this.signedAmount,
    required this.date,
    required this.description,
    this.supplierId,
    this.installmentId,
    this.paymentId,
    this.shoppingItemId,
    this.relatedTransactionId,
    this.phaseId,
    this.categoryId,
    this.invoicePhotoUrl,
    this.notes,
    this.status = TransactionStatus.active,
    required this.createdAt,
  });

  bool get isReversal => type == TransactionType.reversal;
  bool get isActive => status == TransactionStatus.active;

  @override
  List<Object?> get props => [
    id,
    projectId,
    type,
    source,
    amount,
    signedAmount,
    date,
    description,
    supplierId,
    installmentId,
    paymentId,
    shoppingItemId,
    relatedTransactionId,
    phaseId,
    categoryId,
    invoicePhotoUrl,
    notes,
    status,
    createdAt,
  ];
}

enum TransactionType {
  expense,      // Gasto confirmado
  commitment,   // Compromisso futuro
  estimate,     // Estimativa
  reversal,     // Estorno/cancelamento
}

enum TransactionSource {
  manual,
  installment,
  installment_reversal,
  shopping,
  shopping_reversal,
  contract,
  contract_cancel,
}

enum TransactionStatus {
  active,      // Ativo
  fulfilled,   // Cumprido (para estimates)
  cancelled,   // Cancelado
}
```

---

### TransactionRepository com WriteBatch

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/transaction_entity.dart';
import '../models/transaction_model.dart';

abstract class TransactionRepository {
  Future<Either<Failure, void>> createFromPayment({
    required String projectId,
    required String installmentId,
    required String paymentId,
    required double amount,
    required String supplierId,
    required String description,
  });

  Future<Either<Failure, void>> cancelPayment({
    required String projectId,
    required String installmentId,
    required String paymentId,
    required String originalTransactionId,
    required double amount,
  });

  Future<Either<Failure, void>> createFromShopping({
    required String projectId,
    required String shoppingItemId,
    required double actualPrice,
    required String estimateTransactionId,
    required String description,
  });

  Future<Either<Failure, List<TransactionEntity>>> getAll(String projectId);
  
  Future<Either<Failure, FinancialSummary>> getSummary(String projectId);
}

class TransactionRepositoryImpl implements TransactionRepository {
  final FirebaseFirestore _firestore;

  TransactionRepositoryImpl(this._firestore);

  @override
  Future<Either<Failure, void>> createFromPayment({
    required String projectId,
    required String installmentId,
    required String paymentId,
    required double amount,
    required String supplierId,
    required String description,
  }) async {
    try {
      final batch = _firestore.batch();

      // 1. Atualizar parcela (feito no InstallmentRepository)
      // Aqui apenas criamos a transaction

      // 2. Criar transaction
      final transactionRef = _firestore
          .collection('projects')
          .doc(projectId)
          .collection('transactions')
          .doc();

      batch.set(transactionRef, {
        'type': 'expense',
        'source': 'installment',
        'amount': amount,
        'signedAmount': amount,
        'date': Timestamp.now(),
        'description': description,
        'supplierId': supplierId,
        'installmentId': installmentId,
        'paymentId': paymentId,
        'status': 'active',
        'createdAt': Timestamp.now(),
      });

      await batch.commit();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelPayment({
    required String projectId,
    required String installmentId,
    required String paymentId,
    required String originalTransactionId,
    required double amount,
  }) async {
    try {
      final batch = _firestore.batch();

      // Criar transaction de reversão
      final transactionRef = _firestore
          .collection('projects')
          .doc(projectId)
          .collection('transactions')
          .doc();

      batch.set(transactionRef, {
        'type': 'reversal',
        'source': 'installment_reversal',
        'amount': amount,
        'signedAmount': -amount,  // NEGATIVO!
        'date': Timestamp.now(),
        'description': 'Cancelamento: $description',
        'installmentId': installmentId,
        'paymentId': paymentId,
        'relatedTransactionId': originalTransactionId,
        'status': 'active',
        'createdAt': Timestamp.now(),
      });

      await batch.commit();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FinancialSummary>> getSummary(
    String projectId,
  ) async {
    try {
      final result = await getAll(projectId);
      
      return result.fold(
        (failure) => Left(failure),
        (transactions) {
          // Gastos confirmados (expenses + reversals)
          final confirmed = transactions
              .where((t) => t.status == TransactionStatus.active)
              .where((t) => t.type == TransactionType.expense
                  || t.type == TransactionType.reversal)
              .fold(0.0, (s, t) => s + t.signedAmount);

          // Total de contratos ativos
          final committed = transactions
              .where((t) => t.status == TransactionStatus.active)
              .where((t) => t.type == TransactionType.commitment)
              .fold(0.0, (s, t) => s + t.signedAmount);

          // Quanto já foi pago dos contratos
          final paidFromContracts = transactions
              .where((t) => t.status == TransactionStatus.active)
              .where((t) => t.source == TransactionSource.installment
                  && t.type == TransactionType.expense)
              .fold(0.0, (s, t) => s + t.amount);

          // Pendente = Total do contrato - O que já foi pago
          final pendingContracts = committed - paidFromContracts;

          // Estimativas ativas (não fulfilled)
          final estimated = transactions
              .where((t) => t.status == TransactionStatus.active)
              .where((t) => t.type == TransactionType.estimate)
              .fold(0.0, (s, t) => s + t.amount);

          return Right(FinancialSummary(
            confirmed: confirmed,
            pendingContracts: pendingContracts,
            estimated: estimated,
            total: confirmed + pendingContracts + estimated,
          ));
        },
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

class FinancialSummary {
  final double confirmed;
  final double pendingContracts;
  final double estimated;
  final double total;

  const FinancialSummary({
    required this.confirmed,
    required this.pendingContracts,
    required this.estimated,
    required this.total,
  });
}
```

---

## 📋 ORDEM DE IMPLEMENTAÇÃO CORRIGIDA

### 1. TransactionEntity com Campos de Reversão (3h)
- Criar entity completa com `signedAmount`, `relatedTransactionId`, `status`
- Criar model com `toMap()` e `fromMap()`
- Testes unitários

### 2. TransactionRepository com WriteBatch (4h)
- Implementar todos os métodos com `batch.commit()`
- Criar método utilitário `executeInBatch()`
- Testes de integração com Firestore

### 3. Migrar InstallmentsCubit (3h)
- `markPaymentAsPaid()` → batch com update + create
- `cancelPayment()` → batch com update + reversal
- Testes de cenários de erro

### 4. Migrar ShoppingCubit (3h)
- `markAsPurchased()` → criar expense + marcar estimate como fulfilled
- Preservar histórico de economia
- Testes

### 5. FinancialSummary com Lógica Corrigida (2h)
- Implementar cálculo correto (sem duplicar commitment)
- Testar com cenário do João Marceneiro
- Validar todos os casos de uso

### 6. Dashboard Unificado (4h)
- UI com visão por origem
- Gráficos
- Lista de próximos compromissos
- Testes de UI

### 7. Testes de Cenários de Erro (3h)
- Conexão caindo durante operação
- Parcela cancelada após pagamento
- Item devolvido após compra
- Contrato cancelado com parcelas pagas

**Total Estimado: 22 horas** (realista, incluindo testes de erro)

---

## 🎯 RESULTADO ESPERADO

Um sistema financeiro que:
- ✅ Usa WriteBatch para operações atômicas (sem inconsistências)
- ✅ Calcula corretamente (sem duplicar valores)
- ✅ Permite reversões (usuário pode corrigir erros)
- ✅ Preserva histórico (sabe quanto economizou/gastou a mais)
- ✅ Rastreia TODA movimentação de dinheiro
- ✅ Dá visão real do quanto foi gasto e quanto falta

**Pronto para implementação segura!** 🚀