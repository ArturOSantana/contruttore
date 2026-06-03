# 🔧 Erros de Compilação - Guia de Correção

## Status: 16 erros críticos impedem a compilação

---

## 1. ErrorWidgetCustom - 5 ocorrências

**Problema**: Chamando `ErrorWidgetCustom` como método em vez de usar como widget

**Arquivos afetados**:
- `lib/features/phases/presentation/pages/phases_page.dart:39`
- `lib/features/installments/presentation/pages/installments_page.dart:59`
- `lib/features/suppliers/presentation/pages/suppliers_page.dart:74`
- `lib/features/shopping/presentation/pages/shopping_page.dart:78`
- `lib/features/alerts/presentation/pages/alerts_page.dart:61`

**Solução**: Adicionar import do widget

```dart
// Adicionar no topo de cada arquivo:
import '../../../../core/widgets/error_widget.dart';
```

---

## 2. InstallmentStatus - 1 ocorrência

**Problema**: Passando enum `InstallmentStatus` em vez de String

**Arquivo**: `lib/features/installments/presentation/pages/installments_page.dart:233`

**Código atual**:
```dart
StatusBadge.payment(installment.status),
```

**Solução**: Converter enum para string
```dart
StatusBadge.payment(installment.status.name),
```

---

## 3. SupplierStatus - 2 ocorrências

**Problema**: Passando enum `SupplierStatus` em vez de String

**Arquivos**:
- `lib/features/suppliers/presentation/pages/suppliers_page.dart:314`
- `lib/features/suppliers/presentation/pages/suppliers_page.dart:606`

**Código atual**:
```dart
StatusBadge.forSupplier(supplier.status),
```

**Solução**: Converter enum para string
```dart
StatusBadge.forSupplier(supplier.status.name),
```

---

## 4. Syntax Error - 3 ocorrências

**Problema**: Erro de sintaxe na linha 413

**Arquivo**: `lib/features/suppliers/presentation/pages/suppliers_page.dart:413`

**Código atual** (provavelmente):
```dart
_selectedTypeFilter = selected ? type : null,
```

**Solução**: Verificar o contexto e corrigir. Provavelmente está dentro de um `setState`:
```dart
setState(() {
  _selectedTypeFilter = selected ? type : null;
});
```

---

## 5. ExpenseStatus Switch - 4 ocorrências

**Problema**: Switch não é exaustivo e cases não são constantes

**Arquivo**: `lib/features/financial/presentation/pages/financial_page.dart:315-324`

**Código atual**:
```dart
switch (expense.status) {
  case ExpenseStatus.confirmed:
    // ...
  case ExpenseStatus.committed:
    // ...
  case ExpenseStatus.estimated:
    // ...
}
```

**Solução**: Adicionar default case ou usar if-else
```dart
if (expense.status == ExpenseStatus.confirmed) {
  // ...
} else if (expense.status == ExpenseStatus.committed) {
  // ...
} else if (expense.status == ExpenseStatus.estimated) {
  // ...
} else {
  // default
}
```

---

## 6. Constant Expression - 1 ocorrência

**Problema**: Usando variável `index` em contexto const

**Arquivo**: `lib/features/shopping/presentation/pages/shopping_page.dart:307`

**Código atual**:
```dart
top: index > 0 ? AppSpacing.m : 0,
```

**Solução**: Remover const do EdgeInsets ou usar valor fixo
```dart
// Se está dentro de EdgeInsets.only():
padding: EdgeInsets.only(  // SEM const
  top: index > 0 ? AppSpacing.m : 0,
),
```

---

## 📋 Checklist de Correção

### Prioridade Alta (Impedem Compilação)
- [ ] Adicionar imports de ErrorWidgetCustom (5 arquivos)
- [ ] Converter InstallmentStatus para string (1 local)
- [ ] Converter SupplierStatus para string (2 locais)
- [ ] Corrigir syntax error linha 413 (1 local)
- [ ] Substituir switch por if-else no ExpenseStatus (1 local)
- [ ] Remover const do EdgeInsets (1 local)

### Prioridade Média (Warnings)
- [ ] Remover imports não utilizados (7 arquivos)
- [ ] Remover variáveis não utilizadas (5 locais)

---

## 🚀 Ordem de Execução Sugerida

1. **Adicionar imports** - Mais rápido, resolve 5 erros
2. **Converter enums** - Simples, resolve 3 erros
3. **Corrigir switch** - Médio, resolve 4 erros
4. **Corrigir syntax** - Requer análise, resolve 3 erros
5. **Remover const** - Simples, resolve 1 erro

**Total**: 16 erros → 0 erros

---

## ✅ Após Correções

Execute para verificar:
```bash
flutter analyze lib/
flutter build apk --debug
```

Se compilar com sucesso, o app está pronto para testes!