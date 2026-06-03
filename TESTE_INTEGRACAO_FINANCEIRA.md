# 🧪 TESTE DE INTEGRAÇÃO FINANCEIRA - Costruttore

## 📋 Objetivo
Validar a integração completa do sistema de Payments com Financial, Suppliers, Shopping e Alerts.

---

## ✅ CHECKLIST DE TESTES

### 1. CRIAÇÃO DE SUPPLIER COM PARCELAS

#### Cenário 1.1: Supplier à vista (sem parcelas)
```
Ação: Criar supplier sem totalValue
Esperado:
  ✓ Supplier criado no Firestore
  ✓ Nenhum payment gerado
  ✓ Financial não afetado
```

#### Cenário 1.2: Supplier parcelado (3x)
```
Ação: Criar supplier com:
  - name: "João Marceneiro"
  - totalValue: 15000.00
  - installments: 3
  - firstPaymentDate: hoje + 30 dias

Esperado:
  ✓ Supplier criado no Firestore
  ✓ 3 payments gerados automaticamente:
    - Payment 1: R$ 5.000 (vence em 30 dias)
    - Payment 2: R$ 5.000 (vence em 60 dias)
    - Payment 3: R$ 5.000 (vence em 90 dias)
  ✓ Cada payment tem:
    - sourceType: 'supplier'
    - sourceId: supplierId
    - installmentNumber: 1, 2, 3
    - totalInstallments: 3
    - paid: false
```

---

### 2. CRIAÇÃO DE SHOPPING PARCELADO

#### Cenário 2.1: Shopping à vista
```
Ação: Criar shopping item e marcar como comprado sem parcelas
Esperado:
  ✓ Shopping item criado
  ✓ isPurchased: true
  ✓ Nenhum payment gerado
```

#### Cenário 2.2: Shopping parcelado (6x)
```
Ação: Criar shopping item e marcar como comprado com:
  - name: "Piso Porcelanato"
  - actualPrice: 12000.00
  - installments: 6
  - firstPaymentDate: hoje + 15 dias

Esperado:
  ✓ Shopping item criado
  ✓ isPurchased: true
  ✓ 6 payments gerados automaticamente:
    - Payment 1: R$ 2.000 (vence em 15 dias)
    - Payment 2: R$ 2.000 (vence em 45 dias)
    - Payment 3: R$ 2.000 (vence em 75 dias)
    - Payment 4: R$ 2.000 (vence em 105 dias)
    - Payment 5: R$ 2.000 (vence em 135 dias)
    - Payment 6: R$ 2.000 (vence em 165 dias)
  ✓ Cada payment tem:
    - sourceType: 'purchase'
    - sourceId: shoppingItemId
```

---

### 3. MARCAR PAYMENT COMO PAGO

#### Cenário 3.1: Pagar primeira parcela do supplier
```
Ação: Marcar Payment 1 do João Marceneiro como pago
Esperado:
  ✓ Payment atualizado:
    - paid: true
    - paidAt: timestamp atual
  ✓ Financial recalculado automaticamente:
    - totalSpent aumenta em R$ 5.000
    - totalPaid aumenta em R$ 5.000
    - remaining diminui em R$ 5.000
```

#### Cenário 3.2: Pagar segunda parcela do shopping
```
Ação: Marcar Payment 2 do Piso Porcelanato como pago
Esperado:
  ✓ Payment atualizado
  ✓ Financial recalculado:
    - totalSpent aumenta em R$ 2.000
```

---

### 4. RECÁLCULO FINANCEIRO AUTOMÁTICO

#### Cenário 4.1: Consultar resumo financeiro
```
Ação: Chamar GetFinancialSummaryUseCase(projectId)
Esperado:
  ✓ Busca todos os payments do projeto
  ✓ Filtra apenas payments pagos
  ✓ Soma valores: totalPaidFromPayments
  ✓ Calcula: totalSpent = expenses + totalPaidFromPayments
  ✓ Retorna FinancialSummaryEntity com valores corretos
```

#### Cenário 4.2: Verificar isolamento por projeto
```
Ação: Criar payments em projeto A e consultar projeto B
Esperado:
  ✓ Projeto B não vê payments do projeto A
  ✓ totalSpent do projeto B não inclui payments do projeto A
```

---

### 5. ALERTAS AUTOMÁTICOS

#### Cenário 5.1: Payment vencendo em 3 dias
```
Ação: Criar payment com dueDate = hoje + 3 dias
       Executar GenerateAlertsUseCase(projectId)
Esperado:
  ✓ Alerta crítico criado:
    - type: AlertType.critical
    - title: "Parcela vence em 3 dias"
    - message: contém nome do fornecedor e valor
    - actionRoute: '/home/payments'
  ✓ Push notification enviada
```

#### Cenário 5.2: Payment vencido
```
Ação: Criar payment com dueDate = hoje - 5 dias
       Executar GenerateAlertsUseCase(projectId)
Esperado:
  ✓ Alerta crítico criado:
    - title: "Parcela vencida"
    - message: "venceu há 5 dias"
  ✓ Push notification enviada
```

#### Cenário 5.3: Payment vencendo em 7 dias
```
Ação: Criar payment com dueDate = hoje + 7 dias
       Executar GenerateAlertsUseCase(projectId)
Esperado:
  ✓ Alerta preventivo criado:
    - type: AlertType.preventive
    - title: "Parcela vence em 7 dias"
  ✓ Push notification NÃO enviada (apenas feed)
```

---

### 6. DELETAR SUPPLIER COM PAYMENTS PENDENTES

#### Cenário 6.1: Deletar supplier com parcelas não pagas
```
Ação: Deletar supplier que tem 2 payments pendentes
Esperado:
  ✓ Supplier deletado do Firestore
  ✓ Payments pendentes cancelados automaticamente
  ✓ Payments pagos mantidos (histórico)
```

---

### 7. CONVERSÃO WISHLIST → SHOPPING → PAYMENTS

#### Cenário 7.1: Fluxo completo
```
Ação: 
  1. Criar item na wishlist
  2. Mover para shopping (MoveToShoppingUseCase)
  3. Marcar como comprado com parcelas

Esperado:
  ✓ Item criado na wishlist
  ✓ Item movido para shopping (isSelected: true)
  ✓ Shopping item criado
  ✓ Ao marcar como comprado com parcelas:
    - Payments gerados automaticamente
    - Financial recalcula ao pagar
```

---

## 🔍 TESTES DE EDGE CASES

### Edge Case 1: Payment com valor zero
```
Ação: Criar payment com amount: 0
Esperado: ✓ Aceito mas não afeta financial
```

### Edge Case 2: Supplier sem firstPaymentDate
```
Ação: Criar supplier com totalValue mas sem firstPaymentDate
Esperado: ✓ Nenhum payment gerado (aguarda data)
```

### Edge Case 3: Marcar payment já pago
```
Ação: Tentar marcar payment que já está paid: true
Esperado: ✓ Operação ignorada ou erro tratado
```

### Edge Case 4: Deletar payment individual
```
Ação: Deletar um payment específico
Esperado: ✓ Payment deletado, outros mantidos
```

---

## 📊 VALIDAÇÃO DE DADOS

### Validação 1: Estrutura do Payment no Firestore
```
/projects/{projectId}/payments/{paymentId}
{
  "id": "uuid",
  "projectId": "project-123",
  "sourceType": "supplier" | "purchase",
  "sourceId": "source-uuid",
  "installmentNumber": 1,
  "totalInstallments": 3,
  "amount": 5000.00,
  "dueDate": Timestamp,
  "paid": false,
  "paidAt": null,
  "createdAt": Timestamp
}
```

### Validação 2: Queries Firestore
```
✓ getPayments(projectId) - filtra por projectId
✓ getPendingPayments(projectId) - filtra paid: false
✓ getUpcomingPayments(projectId) - filtra dueDate próxima
✓ getOverduePayments(projectId) - filtra dueDate < hoje
✓ getPaymentsBySource(projectId, sourceId) - filtra por source
```

---

## 🎯 CRITÉRIOS DE SUCESSO

### ✅ Todos os testes devem passar:
- [ ] Supplier gera payments automaticamente
- [ ] Shopping gera payments automaticamente
- [ ] Payments são isolados por projectId
- [ ] Financial recalcula automaticamente
- [ ] Alertas são gerados corretamente
- [ ] Deletar supplier cancela payments pendentes
- [ ] Push notifications funcionam
- [ ] Nenhum erro de compilação
- [ ] Nenhum erro de runtime

---

## 🚀 EXECUÇÃO DOS TESTES

### Teste Manual (Recomendado):
1. Executar app no emulador
2. Criar projeto de teste
3. Executar cada cenário manualmente
4. Verificar Firestore Console
5. Verificar logs do app

### Teste Automatizado (Futuro):
```dart
// TODO: Implementar testes de integração
// test/integration/financial_integration_test.dart
```

---

## 📝 RESULTADO ESPERADO

Ao final dos testes, o sistema deve:
- ✅ Gerar payments automaticamente
- ✅ Recalcular financial automaticamente
- ✅ Enviar alertas automaticamente
- ✅ Manter dados isolados por projeto
- ✅ Funcionar offline (Hive cache)
- ✅ Sincronizar com Firebase
- ✅ Não apresentar erros

---

**Data do Teste**: _____/_____/_____
**Testador**: _____________________
**Resultado**: ☐ APROVADO  ☐ REPROVADO

---

# Made with Bob