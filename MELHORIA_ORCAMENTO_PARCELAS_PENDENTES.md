# 💰 Melhoria: Orçamento Considerando Parcelas Pendentes

## 📋 Resumo

Implementada melhoria no cálculo financeiro do Mapa da Reforma para considerar **parcelas pendentes** (comprometidas mas não pagas) no orçamento disponível.

---

## ❌ Problema Anterior

O sistema calculava o orçamento disponível apenas com base no que já foi **gasto**:

```dart
// ANTES:
remainingBudget = totalBudget - totalSpent

// Exemplo:
// Orçamento: R$ 100.000
// Gasto: R$ 50.000
// Restante: R$ 50.000 ✅

// MAS... e se você tem R$ 20.000 em parcelas pendentes?
// O sistema mostrava R$ 50.000 disponíveis
// Mas na verdade você só tem R$ 30.000 livres! ❌
```

**Problema:** O usuário via um orçamento "disponível" que na verdade já estava comprometido com parcelas futuras.

---

## ✅ Solução Implementada

Agora o sistema diferencia:

1. **Total Gasto** (`totalSpent`): O que já foi pago
2. **Total Pendente** (`totalPending`): Parcelas comprometidas mas não pagas
3. **Total Comprometido** (`totalCommitted`): Gasto + Pendente
4. **Orçamento Disponível** (`availableBudget`): Orçamento - Comprometido

### Novos Campos e Getters

```dart
class FinancialSnapshot {
  final double totalBudget;
  final double totalSpent;
  final double totalPending; // ✨ NOVO
  final double remainingBudget; // Mantido para compatibilidade
  final double percentageSpent;
  
  // ✨ NOVOS GETTERS CALCULADOS
  
  /// Total comprometido (gasto + pendente)
  double get totalCommitted => totalSpent + totalPending;
  
  /// Percentual comprometido (gasto + pendente)
  double get percentageCommitted {
    if (totalBudget == 0) return 0;
    return (totalCommitted / totalBudget) * 100;
  }
  
  /// Orçamento realmente disponível (considerando pendentes)
  double get availableBudget => totalBudget - totalCommitted;
  
  /// Verifica se há risco de estourar o orçamento
  bool get hasRisk => percentageCommitted > 90;
}
```

---

## 📊 Exemplo Prático

### Cenário Real:

```dart
Orçamento Total: R$ 100.000
Já Gasto: R$ 50.000
Parcelas Pendentes: R$ 20.000
```

### ANTES da Melhoria:

```dart
remainingBudget: R$ 50.000 ❌ (enganoso)
percentageSpent: 50% ❌ (não considera pendentes)
isHealthy: true ✅ (parece saudável)
```

### DEPOIS da Melhoria:

```dart
totalSpent: R$ 50.000
totalPending: R$ 20.000
totalCommitted: R$ 70.000 ✨
availableBudget: R$ 30.000 ✨ (valor real disponível)
percentageCommitted: 70% ✨ (visão real)
hasRisk: false ✅
```

---

## 🎯 Benefícios

### 1. Visão Financeira Real
- ✅ Usuário vê quanto **realmente** tem disponível
- ✅ Considera compromissos futuros
- ✅ Evita surpresas desagradáveis

### 2. Alertas Mais Precisos
```dart
// Agora os alertas consideram parcelas pendentes:
if (financial.percentageCommitted > 90) {
  showAlert('⚠️ Atenção! Você já comprometeu 90% do orçamento');
}
```

### 3. Decisões Mais Informadas
```dart
// Antes de fazer uma nova compra:
if (purchaseValue > financial.availableBudget) {
  showWarning('Esta compra excede seu orçamento disponível');
}
```

### 4. Compatibilidade Mantida
- ✅ Campos antigos mantidos (`remainingBudget`, `percentageSpent`)
- ✅ Novos campos são opcionais (default: 0.0)
- ✅ Código existente continua funcionando

---

## 🔧 Arquivos Modificados

### 1. Entity (Domain Layer)
**Arquivo:** `lib/features/reform_map/domain/entities/reform_map_entity.dart`

```dart
class FinancialSnapshot extends Equatable {
  final double totalPending; // ✨ NOVO
  
  // ✨ NOVOS GETTERS
  double get totalCommitted => totalSpent + totalPending;
  double get percentageCommitted { ... }
  double get availableBudget => totalBudget - totalCommitted;
  bool get hasRisk => percentageCommitted > 90;
}
```

### 2. Model (Data Layer)
**Arquivo:** `lib/features/reform_map/data/models/reform_map_model.dart`

```dart
class FinancialSnapshotModel extends FinancialSnapshot {
  const FinancialSnapshotModel({
    super.totalPending = 0.0, // ✨ NOVO (opcional)
    // ...
  });
  
  factory FinancialSnapshotModel.fromMap(Map<String, dynamic> map) {
    return FinancialSnapshotModel(
      totalPending: (map['totalPending'] as num?)?.toDouble() ?? 0.0, // ✨
      // ...
    );
  }
}
```

### 3. Repository (Data Layer)
**Arquivo:** `lib/features/reform_map/data/repositories/reform_map_repository_impl.dart`

```dart
final financial = FinancialSnapshotModel(
  totalPending: (projectData['totalPending'] as num?)?.toDouble() ?? 0.0, // ✨
  // ...
);
```

---

## 📱 Como Usar na UI

### Exemplo 1: Card de Orçamento

```dart
Widget buildBudgetCard(FinancialSnapshot financial) {
  return Card(
    child: Column(
      children: [
        // Mostrar orçamento REAL disponível
        Text('Disponível: ${CurrencyUtils.format(financial.availableBudget)}'),
        
        // Mostrar percentual comprometido
        LinearProgressIndicator(
          value: financial.percentageCommitted / 100,
          color: financial.hasRisk ? Colors.red : Colors.green,
        ),
        
        // Detalhamento
        Text('Gasto: ${CurrencyUtils.format(financial.totalSpent)}'),
        Text('Pendente: ${CurrencyUtils.format(financial.totalPending)}'),
        Text('Comprometido: ${CurrencyUtils.format(financial.totalCommitted)}'),
      ],
    ),
  );
}
```

### Exemplo 2: Validação de Compra

```dart
Future<bool> canAffordPurchase(double amount, FinancialSnapshot financial) {
  if (amount > financial.availableBudget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('⚠️ Orçamento Insuficiente'),
        content: Text(
          'Esta compra de ${CurrencyUtils.format(amount)} '
          'excede seu orçamento disponível de '
          '${CurrencyUtils.format(financial.availableBudget)}.\n\n'
          'Você já comprometeu ${financial.percentageCommitted.toStringAsFixed(1)}% '
          'do orçamento total.'
        ),
      ),
    );
    return false;
  }
  return true;
}
```

### Exemplo 3: Alerta de Risco

```dart
Widget buildRiskAlert(FinancialSnapshot financial) {
  if (!financial.hasRisk) return SizedBox.shrink();
  
  return Container(
    color: Colors.orange.shade100,
    padding: EdgeInsets.all(16),
    child: Row(
      children: [
        Icon(Icons.warning, color: Colors.orange),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            '⚠️ Atenção! Você já comprometeu '
            '${financial.percentageCommitted.toStringAsFixed(1)}% '
            'do seu orçamento. Considere revisar suas despesas.',
          ),
        ),
      ],
    ),
  );
}
```

---

## 🧪 Testes Sugeridos

### Teste 1: Cálculo Correto
```dart
test('deve calcular orçamento disponível considerando pendentes', () {
  final financial = FinancialSnapshot(
    totalBudget: 100000,
    totalSpent: 50000,
    totalPending: 20000,
    remainingBudget: 50000,
    percentageSpent: 50,
    pendingPayments: 5,
    nextPaymentAmount: 5000,
  );
  
  expect(financial.totalCommitted, 70000);
  expect(financial.availableBudget, 30000);
  expect(financial.percentageCommitted, 70);
  expect(financial.hasRisk, false);
});
```

### Teste 2: Detecção de Risco
```dart
test('deve detectar risco quando comprometido > 90%', () {
  final financial = FinancialSnapshot(
    totalBudget: 100000,
    totalSpent: 70000,
    totalPending: 25000,
    // ...
  );
  
  expect(financial.percentageCommitted, 95);
  expect(financial.hasRisk, true);
});
```

---

## 📈 Próximos Passos

### Curto Prazo
- [ ] Atualizar UI dos cards financeiros para usar `availableBudget`
- [ ] Adicionar alertas visuais quando `hasRisk == true`
- [ ] Mostrar breakdown (gasto vs pendente) nos gráficos

### Médio Prazo
- [ ] Criar projeção de fluxo de caixa considerando parcelas futuras
- [ ] Adicionar simulador: "E se eu fizer esta compra?"
- [ ] Gráfico de evolução do orçamento comprometido

### Longo Prazo
- [ ] Sugestões inteligentes de economia baseadas em comprometimento
- [ ] Alertas preditivos: "Com este ritmo, você vai estourar em X dias"
- [ ] Comparação com outras reformas similares

---

## 🎓 Conceitos Financeiros

### Orçamento Disponível vs Orçamento Restante

**Orçamento Restante** (`remainingBudget`):
- Orçamento - Gasto
- Não considera compromissos futuros
- Útil para ver quanto já foi gasto

**Orçamento Disponível** (`availableBudget`):
- Orçamento - (Gasto + Pendente)
- Considera compromissos futuros
- **Mais preciso** para decisões de compra

### Percentual Gasto vs Percentual Comprometido

**Percentual Gasto** (`percentageSpent`):
- (Gasto / Orçamento) × 100
- Mostra quanto já saiu do bolso

**Percentual Comprometido** (`percentageCommitted`):
- ((Gasto + Pendente) / Orçamento) × 100
- **Mais realista** para avaliar saúde financeira

---

## ✅ Conclusão

Esta melhoria torna o sistema financeiro do Contruttore **mais preciso e confiável**, ajudando os usuários a:

1. ✅ Tomar decisões financeiras mais informadas
2. ✅ Evitar estourar o orçamento
3. ✅ Ter visão real do que está disponível
4. ✅ Planejar melhor as próximas compras

**Status:** ✅ Implementado e pronto para uso

---

**Implementado em:** 11/06/2026  
**Por:** Bob - Arquiteto de Software  
**Versão:** 1.0.0