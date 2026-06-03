# 🔄 Onboarding Retroativo - Plano de Implementação Completo

## 🎯 Objetivo
Permitir que usuários com obra em andamento entrem no app sem fricção, marcando fases passadas como concluídas sem exigir dados retroativos.

---

## 📊 Status Atual vs. Necessário

### ✅ Já Existe
- `RetroactiveOnboardingPage` básica (4 steps)
- Estrutura de navegação
- PhaseModel com subtasks

### ❌ Falta Implementar
1. **PhaseStatus.done_no_record** - novo status para fases retroativas
2. **RetroactiveCubit** - gerencia todo o fluxo
3. **Distribuição automática de orçamento** - quando usuário informa total gasto
4. **Grid de seleção de fase** - UI visual para escolher fase atual
5. **Cadastro rápido de fornecedores** - 3 campos apenas
6. **Empty state para fases retroativas** - diferente de fases normais

---

## 🏗️ Arquitetura

### 1. Enum PhaseStatus (MODIFICAR)
```dart
// lib/features/phases/domain/entities/phase_entity.dart
enum PhaseStatus {
  locked,           // Bloqueada (futura)
  active,           // Em andamento
  done,             // Concluída com registro
  done_no_record,   // ← NOVO: Concluída sem registro (retroativo)
  paused,           // Pausada manualmente
}
```

### 2. PhaseEntity (ADICIONAR CAMPOS)
```dart
class PhaseEntity {
  // ... campos existentes
  final bool isRetroactive;              // ← NOVO
  final DateTime? retroactiveMarkedAt;   // ← NOVO
  
  bool get canComplete {
    if (isRetroactive) return true;  // ← NOVO: não exige subtasks
    return subtasks.where((s) => s.isRequired).every((s) => s.isDone);
  }
  
  bool get hasRecord => 
      status == PhaseStatus.done || 
      subtasks.any((s) => s.isDone);
}
```

### 3. RetroactiveState (CRIAR)
```dart
// lib/features/onboarding/presentation/cubit/retroactive_state.dart
enum BudgetOption { total, receipts, zero }

class RetroactiveState extends Equatable {
  final int currentStep;                    // 1-4
  final int? selectedPhaseNumber;           // fase atual escolhida
  final BudgetOption? budgetOption;         
  final double? totalSpent;                 
  final List<RetroactiveExpenseEntry> entries;
  final List<QuickSupplier> suppliers;
  final bool isCreating;
  final String? error;
}
```

### 4. RetroactiveCubit (CRIAR)
```dart
// lib/features/onboarding/presentation/cubit/retroactive_cubit.dart
class RetroactiveCubit extends Cubit<RetroactiveState> {
  final CreateProjectUseCase _createProjectUseCase;
  final CreatePhaseUseCase _createPhaseUseCase;
  final AddExpenseUseCase _addExpenseUseCase;
  final AddSupplierUseCase _addSupplierUseCase;
  
  // Step 1: Selecionar fase atual
  void selectCurrentPhase(int phaseNumber);
  
  // Step 2: Opção de orçamento
  void setBudgetOption(BudgetOption option);
  void setTotalSpent(double amount);
  void addExpenseEntry(RetroactiveExpenseEntry entry);
  
  // Step 3: Fornecedores rápidos
  void addQuickSupplier(QuickSupplier supplier);
  
  // Step 4: Criar tudo
  Future<void> createRetroactiveProject({
    required String projectName,
    required String address,
    required double area,
  });
}
```

### 5. RetroactiveBudgetDistributor (CRIAR)
```dart
// lib/features/onboarding/domain/services/retroactive_budget_distributor.dart
class RetroactiveBudgetDistributor {
  static const Map<int, double> phaseWeights = {
    6: 0.05,  // Regularização
    7: 0.08,  // Projeto
    8: 0.08,  // Demolição
    9: 0.25,  // Instalações
    10: 0.22, // Revestimentos
    11: 0.18, // Gesso e pintura
    12: 0.14, // Marcenaria
  };
  
  static Map<String, double> distribute({
    required double totalAmount,
    required List<int> completedPhaseNumbers,
  });
}
```

---

## 🎨 UI Components

### 1. PhaseSelectionGrid (CRIAR)
Grid 3x4 com as 12 fases. Toque em uma fase:
- Marca ela como verde (atual)
- Marca todas anteriores com check cinza
- Feedback visual imediato

### 2. BudgetOptionCards (CRIAR)
3 cards grandes:
- "Sei o total" → campo de valor
- "Tenho recibos" → lista de entradas
- "Não sei" → pula

### 3. QuickSupplierForm (CRIAR)
Formulário mínimo:
- Nome
- Tipo (dropdown)
- Status (ativo/problema)

### 4. RetroactiveSummaryCard (CRIAR)
Resumo final antes de criar:
- Fase atual
- Fases marcadas como concluídas
- Total gasto (se informado)
- Fornecedores cadastrados

---

## 📝 Fluxo de Implementação

### FASE 1: Estrutura Base (1-2h)
1. ✅ Adicionar `done_no_record` ao enum PhaseStatus
2. ✅ Adicionar campos `isRetroactive` e `retroactiveMarkedAt` ao PhaseEntity
3. ✅ Atualizar PhaseModel.toMap() e fromMap()
4. ✅ Criar RetroactiveState
5. ✅ Criar RetroactiveCubit (estrutura básica)

### FASE 2: Lógica de Negócio (2-3h)
6. ✅ Implementar RetroactiveBudgetDistributor
7. ✅ Criar RetroactiveExpenseEntry model
8. ✅ Criar QuickSupplier model
9. ✅ Implementar createRetroactiveProject() no cubit
10. ✅ Implementar _createPhasesWithStatus()
11. ✅ Implementar _distributeRetroactiveBudget()

### FASE 3: UI - Step 1 (1-2h)
12. ✅ Criar PhaseSelectionGrid widget
13. ✅ Integrar com RetroactiveCubit
14. ✅ Animações de seleção

### FASE 4: UI - Step 2 (2-3h)
15. ✅ Criar BudgetOptionCards
16. ✅ Formulário de valor total
17. ✅ Lista de entradas de recibos
18. ✅ Validações

### FASE 5: UI - Step 3 (1-2h)
19. ✅ Criar QuickSupplierForm
20. ✅ Lista de fornecedores adicionados
21. ✅ Permitir pular

### FASE 6: UI - Step 4 (1h)
22. ✅ Criar RetroactiveSummaryCard
23. ✅ Botão "Começar a organizar"
24. ✅ Loading state durante criação

### FASE 7: Integração (1-2h)
25. ✅ Conectar OnboardingPage ao fluxo retroativo
26. ✅ Navegação condicional no Step 3
27. ✅ Redirecionar para Home após conclusão

### FASE 8: Empty States (1h)
28. ✅ Criar RetroactivePhaseEmptyState
29. ✅ Mostrar em PhaseDetailPage quando done_no_record
30. ✅ Opção de enriquecer depois

### FASE 9: Testes (1-2h)
31. ✅ Testar fluxo completo
32. ✅ Testar com diferentes fases selecionadas
33. ✅ Testar distribuição de orçamento
34. ✅ Testar navegação

---

## 🎯 Melhorias Futuras (Não Bloqueantes)

### Melhoria 1: Detecção Inteligente de Fase
Perguntas simples para deduzir a fase automaticamente.

### Melhoria 2: OCR de Notas Fiscais
Google ML Kit para extrair dados de fotos de NF.

### Melhoria 3: Progresso de Enriquecimento
Gamificação leve para incentivar completar dados.

### Melhoria 4: Estimativa do Que Falta
Mostrar prazo e custo estimado das fases restantes.

### Melhoria 5: Detectar "Obra com Problema"
Fluxo especial se fornecedor marcado como "problema".

---

## 📋 Checklist de Implementação

- [ ] Fase 1: Estrutura Base
- [ ] Fase 2: Lógica de Negócio
- [ ] Fase 3: UI Step 1
- [ ] Fase 4: UI Step 2
- [ ] Fase 5: UI Step 3
- [ ] Fase 6: UI Step 4
- [ ] Fase 7: Integração
- [ ] Fase 8: Empty States
- [ ] Fase 9: Testes

---

## 🚀 Ordem de Execução

1. Começar pela Fase 1 (estrutura)
2. Implementar Fase 2 (lógica)
3. UI por step (Fases 3-6)
4. Integrar tudo (Fase 7)
5. Polir (Fases 8-9)

**Tempo estimado total: 12-18 horas**