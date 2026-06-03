# 🏗️ ARQUITETURA FINANCEIRA UNIFICADA
## Análise e Proposta de Integração: Financeiro, Parcelas, Fornecedores e Compras

---

## 📊 SITUAÇÃO ATUAL

### Módulos Existentes

#### 1. **FINANCEIRO** (`ExpenseEntity`)
```dart
- id, projectId, categoryId
- amount, date, description
- status: confirmed | committed | estimated
- supplierId (opcional)
- invoicePhotoUrl (opcional)
- phaseId (opcional)
```

**Propósito**: Registrar todas as despesas do projeto

#### 2. **PARCELAS** (`InstallmentEntity` + `PaymentEntity`)
```dart
InstallmentEntity:
- id, projectId, supplierId, supplierName
- serviceDescription, phaseId
- totalValue, totalInstallments
- contractDate, status
- payments: List<PaymentEntity>

PaymentEntity:
- id, number, amount, dueDate
- isPaid, paidAt, paidAmount
```

**Propósito**: Gerenciar contratos parcelados com fornecedores

#### 3. **FORNECEDORES** (`SupplierEntity`)
```dart
- id, projectId, name, type
- phone, email, cnpj, cpf
- rating, notes, phaseId
- status: active | completed | problem
```

**Propósito**: Cadastro de profissionais e lojas

#### 4. **COMPRAS** (`ShoppingItemEntity`)
```dart
- id, projectId, phaseId
- name, category
- estimatedPrice, actualPrice
- quantity, unit
- isPurchased, store, purchaseDate
- wishlistItemId (opcional)
```

**Propósito**: Lista de materiais a comprar

---

## ⚠️ PROBLEMAS IDENTIFICADOS

### 1. **Duplicação de Dados Financeiros**
- Quando pago uma parcela → cria expense no financeiro
- Quando compro um item → deveria criar expense mas não cria
- **Resultado**: dados financeiros espalhados e inconsistentes

### 2. **Falta de Rastreabilidade**
- Expense tem `supplierId` mas não tem `installmentId`
- ShoppingItem tem preços mas não vira expense automaticamente
- **Resultado**: difícil saber de onde veio cada gasto

### 3. **Lógica de Negócio Fragmentada**
- Marcar parcela como paga → cria expense (em InstallmentsCubit)
- Marcar compra como feita → NÃO cria expense
- **Resultado**: comportamento inconsistente

### 4. **Falta de Visão Unificada**
- Financeiro mostra expenses
- Parcelas mostra contratos
- Compras mostra itens
- **Resultado**: usuário não vê o total real comprometido

---

## 💡 PROPOSTA DE ARQUITETURA UNIFICADA

### Conceito Central: **Transaction-Based Architecture**

Toda movimentação financeira é uma **Transaction** com origem rastreável.

### Nova Estrutura de Dados

#### **TransactionEntity** (novo)
```dart
class TransactionEntity {
  final String id;
  final String projectId;
  final TransactionType type;
  final TransactionSource source;
  
  // Valores
  final double amount;
  final DateTime date;
  final String description;
  
  // Rastreabilidade
  final String? supplierId;
  final String? installmentId;
  final String? paymentId;
  final String? shoppingItemId;
  final String? phaseId;
  final String? categoryId;
  
  // Comprovação
  final String? invoicePhotoUrl;
  final String? notes;
  
  final DateTime createdAt;
}

enum TransactionType {
  expense,      // Gasto realizado
  commitment,   // Compromisso futuro (orçamento aceito)
  estimate,     // Estimativa
}

enum TransactionSource {
  manual,           // Criado manualmente pelo usuário
  installment,      // Gerado ao pagar parcela
  shopping,         // Gerado ao comprar item
  contract,         // Gerado ao aceitar orçamento
}
```

---

## 🔄 FLUXOS UNIFICADOS

### FLUXO 1: Contratar Fornecedor com Parcelas

```
1. Usuário cria Supplier (João Marceneiro)
2. Usuário cria Installment:
   - supplierId: joão_id
   - totalValue: R$ 15.000
   - totalInstallments: 5
   - payments: [
       { number: 1, amount: 3000, dueDate: 2026-07-01 },
       { number: 2, amount: 3000, dueDate: 2026-08-01 },
       ...
     ]

3. Sistema cria Transaction (commitment):
   ✅ type: commitment
   ✅ source: contract
   ✅ amount: 15000
   ✅ supplierId: joão_id
   ✅ installmentId: contrato_id
   ✅ description: "Marcenaria - 5x R$ 3.000"

4. Usuário paga parcela 1:
   - Marca payment.isPaid = true
   - payment.paidAt = now
   - payment.paidAmount = 3000

5. Sistema cria Transaction (expense):
   ✅ type: expense
   ✅ source: installment
   ✅ amount: 3000
   ✅ supplierId: joão_id
   ✅ installmentId: contrato_id
   ✅ paymentId: parcela_1_id
   ✅ description: "Marcenaria - Parcela 1/5"
   ✅ invoicePhotoUrl: (se anexou nota)
```

**Resultado**: 
- Financeiro mostra R$ 15.000 comprometidos
- Ao pagar, mostra R$ 3.000 gastos
- Total pendente: R$ 12.000

---

### FLUXO 2: Comprar Material

```
1. Usuário cria ShoppingItem:
   - name: "Piso Porcelanato"
   - category: flooring
   - estimatedPrice: 80
   - quantity: 50
   - unit: m²
   - isPurchased: false

2. Sistema cria Transaction (estimate):
   ✅ type: estimate
   ✅ source: shopping
   ✅ amount: 4000 (80 × 50)
   ✅ shoppingItemId: item_id
   ✅ description: "Piso Porcelanato - 50m²"

3. Usuário marca como comprado:
   - isPurchased = true
   - actualPrice = 75
   - store = "Leroy Merlin"
   - purchaseDate = now

4. Sistema ATUALIZA Transaction:
   ✅ type: expense (mudou de estimate para expense)
   ✅ amount: 3750 (75 × 50)
   ✅ description: "Piso Porcelanato - 50m² (Leroy Merlin)"
   ✅ invoicePhotoUrl: (se anexou nota)
```

**Resultado**:
- Antes de comprar: R$ 4.000 estimados
- Depois de comprar: R$ 3.750 gastos (economizou R$ 250!)

---

### FLUXO 3: Despesa Manual (sem parcela nem compra)

```
1. Usuário vai em Financeiro → Adicionar Despesa
2. Preenche:
   - description: "Aluguel de betoneira"
   - amount: 350
   - date: hoje
   - category: "Equipamentos"
   - supplierId: (opcional)

3. Sistema cria Transaction:
   ✅ type: expense
   ✅ source: manual
   ✅ amount: 350
   ✅ description: "Aluguel de betoneira"
   ✅ categoryId: equipamentos_id
```

**Resultado**:
- Despesa avulsa registrada normalmente

---

## 📈 VISÃO FINANCEIRA UNIFICADA

### Dashboard Financeiro

```
┌─────────────────────────────────────────────────────┐
│  RESUMO FINANCEIRO                                  │
├─────────────────────────────────────────────────────┤
│                                                     │
│  💰 Total Gasto (confirmed)         R$ 45.200      │
│  📋 Total Comprometido (committed)  R$ 38.500      │
│  📊 Total Estimado (estimated)      R$ 12.300      │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│  🎯 TOTAL PREVISTO                  R$ 96.000      │
│                                                     │
│  Orçamento: R$ 120.000                             │
│  [████████████████░░░░] 80%                        │
│                                                     │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│  ORIGEM DOS GASTOS                                  │
├─────────────────────────────────────────────────────┤
│                                                     │
│  👷 Fornecedores (parcelas)    R$ 45.200  (47%)    │
│  🛒 Compras (materiais)        R$ 38.500  (40%)    │
│  ✍️  Manual (diversos)          R$ 12.300  (13%)    │
│                                                     │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│  PRÓXIMOS COMPROMISSOS (30 dias)                   │
├─────────────────────────────────────────────────────┤
│                                                     │
│  📅 05/06 - João Marceneiro      R$ 3.000          │
│  📅 10/06 - Leroy Merlin         R$ 2.500          │
│  📅 15/06 - Maria Pintora        R$ 1.800          │
│                                                     │
│  Total: R$ 7.300                                   │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## 🔧 IMPLEMENTAÇÃO TÉCNICA

### Fase 1: Criar TransactionEntity e Repository

```dart
// lib/features/financial/domain/entities/transaction_entity.dart
class TransactionEntity extends Equatable {
  final String id;
  final String projectId;
  final TransactionType type;
  final TransactionSource source;
  final double amount;
  final DateTime date;
  final String description;
  final String? supplierId;
  final String? installmentId;
  final String? paymentId;
  final String? shoppingItemId;
  final String? phaseId;
  final String? categoryId;
  final String? invoicePhotoUrl;
  final String? notes;
  final DateTime createdAt;
  
  // ... constructor, props, etc
}
```

### Fase 2: Migrar ExpenseEntity → TransactionEntity

- Manter ExpenseEntity por compatibilidade
- Criar adapter: `ExpenseEntity.fromTransaction()`
- Gradualmente migrar código

### Fase 3: Hooks Automáticos

```dart
// InstallmentsCubit
Future<void> markPaymentAsPaid(String installmentId, String paymentId) async {
  // 1. Marca parcela como paga
  await _installmentRepository.markAsPaid(installmentId, paymentId);
  
  // 2. Cria transaction automaticamente
  await _transactionRepository.createFromPayment(
    installmentId: installmentId,
    paymentId: paymentId,
  );
  
  // 3. Recarrega dados
  loadInstallments(projectId);
}

// ShoppingCubit
Future<void> markAsPurchased(String itemId, double actualPrice) async {
  // 1. Marca item como comprado
  await _shoppingRepository.markAsPurchased(itemId, actualPrice);
  
  // 2. Atualiza transaction (de estimate para expense)
  await _transactionRepository.updateFromShopping(itemId);
  
  // 3. Recarrega dados
  loadItems(projectId);
}
```

### Fase 4: Queries Otimizadas

```dart
// TransactionRepository
Future<FinancialSummary> getSummary(String projectId) async {
  final transactions = await getAll(projectId);
  
  final confirmed = transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);
  
  final committed = transactions
      .where((t) => t.type == TransactionType.commitment)
      .fold(0.0, (sum, t) => sum + t.amount);
  
  final estimated = transactions
      .where((t) => t.type == TransactionType.estimate)
      .fold(0.0, (sum, t) => sum + t.amount);
  
  return FinancialSummary(
    confirmed: confirmed,
    committed: committed,
    estimated: estimated,
    total: confirmed + committed + estimated,
  );
}

Future<Map<TransactionSource, double>> getBySource(String projectId) async {
  final transactions = await getAll(projectId);
  
  return {
    TransactionSource.installment: transactions
        .where((t) => t.source == TransactionSource.installment)
        .fold(0.0, (sum, t) => sum + t.amount),
    TransactionSource.shopping: transactions
        .where((t) => t.source == TransactionSource.shopping)
        .fold(0.0, (sum, t) => sum + t.amount),
    TransactionSource.manual: transactions
        .where((t) => t.source == TransactionSource.manual)
        .fold(0.0, (sum, t) => sum + t.amount),
  };
}
```

---

## 📋 CASO DE USO COMPLETO

### Cenário: João contrata marceneiro e compra materiais

```
DIA 1 - Contratação
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. João cadastra "Marcenaria Silva" como fornecedor
2. Cria contrato: R$ 15.000 em 5x R$ 3.000
3. Sistema cria Transaction (commitment): R$ 15.000

📊 Financeiro mostra:
   Comprometido: R$ 15.000
   Gasto: R$ 0
   Total: R$ 15.000

DIA 2 - Compra de Materiais
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. João adiciona "MDF 15mm" na lista de compras
   - Estimativa: R$ 80/chapa × 20 = R$ 1.600
2. Sistema cria Transaction (estimate): R$ 1.600

📊 Financeiro mostra:
   Comprometido: R$ 15.000
   Estimado: R$ 1.600
   Gasto: R$ 0
   Total: R$ 16.600

DIA 5 - Compra Realizada
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. João marca MDF como comprado
   - Preço real: R$ 75/chapa × 20 = R$ 1.500
2. Sistema atualiza Transaction:
   - estimate → expense
   - R$ 1.600 → R$ 1.500

📊 Financeiro mostra:
   Comprometido: R$ 15.000
   Gasto: R$ 1.500
   Total: R$ 16.500
   (Economizou R$ 100!)

DIA 10 - Primeira Parcela
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. João paga parcela 1/5: R$ 3.000
2. Sistema cria Transaction (expense): R$ 3.000
3. Sistema mantém commitment original

📊 Financeiro mostra:
   Comprometido: R$ 15.000 (contrato total)
   Gasto: R$ 4.500 (1.500 + 3.000)
   Pendente: R$ 12.000 (15.000 - 3.000)
   Total: R$ 16.500

DIA 15 - Despesa Avulsa
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. João registra "Aluguel betoneira": R$ 350
2. Sistema cria Transaction (expense, manual): R$ 350

📊 Financeiro mostra:
   Comprometido: R$ 15.000
   Gasto: R$ 4.850 (1.500 + 3.000 + 350)
   Pendente: R$ 12.000
   Total: R$ 16.850

VISÃO POR ORIGEM:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
👷 Fornecedores: R$ 3.000 (62%)
🛒 Compras: R$ 1.500 (31%)
✍️  Manual: R$ 350 (7%)
Total Gasto: R$ 4.850
```

---

## ✅ BENEFÍCIOS DA ARQUITETURA UNIFICADA

### 1. **Rastreabilidade Total**
- Cada centavo tem origem clara
- Fácil auditar gastos
- Relatórios precisos

### 2. **Consistência**
- Comportamento uniforme em todos os módulos
- Regras de negócio centralizadas
- Menos bugs

### 3. **Visão Financeira Real**
- Usuário vê o total comprometido
- Sabe exatamente quanto falta pagar
- Pode planejar melhor

### 4. **Flexibilidade**
- Fácil adicionar novos tipos de transação
- Queries otimizadas
- Escalável

### 5. **UX Melhorada**
- Dashboard unificado
- Menos confusão
- Mais confiança nos números

---

## 🚀 PLANO DE IMPLEMENTAÇÃO

### Etapa 1: Criar TransactionEntity (2h)
- Entity, Model, Repository
- Testes unitários

### Etapa 2: Migrar Expenses → Transactions (3h)
- Adapter pattern
- Manter compatibilidade
- Migração de dados

### Etapa 3: Hooks Automáticos (4h)
- InstallmentsCubit → cria transaction ao pagar
- ShoppingCubit → cria/atualiza transaction ao comprar
- Testes de integração

### Etapa 4: Dashboard Unificado (3h)
- Novo FinancialPage com visão completa
- Gráficos por origem
- Lista de próximos compromissos

### Etapa 5: Testes e Ajustes (2h)
- Testar fluxos completos
- Ajustar UI
- Documentar

**Total: ~14 horas de desenvolvimento**

---

## 🎯 RESULTADO ESPERADO

Um sistema financeiro que:
- ✅ Rastreia TODA movimentação de dinheiro
- ✅ Mostra origem clara de cada gasto
- ✅ Calcula automaticamente compromissos futuros
- ✅ Unifica parcelas, compras e despesas avulsas
- ✅ Dá visão real do quanto já foi gasto e quanto falta

**O usuário finalmente terá controle total sobre o dinheiro da obra!**