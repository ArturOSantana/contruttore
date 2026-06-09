# 🗺️ Integração do Mapa da Reforma - Como Tudo se Conecta

## 📊 Visão Geral da Arquitetura

O **Mapa da Reforma** é o **CENTRO INTELIGENTE** do aplicativo. Ele não é apenas uma visualização - é um **agregador de dados** que consome informações de TODOS os outros módulos e gera insights.

```
┌─────────────────────────────────────────────────────────┐
│                   MAPA DA REFORMA                        │
│              (Centro de Inteligência)                    │
└─────────────────────────────────────────────────────────┘
         ▲         ▲         ▲         ▲         ▲
         │         │         │         │         │
    ┌────┴───┐ ┌──┴───┐ ┌───┴───┐ ┌──┴───┐ ┌───┴────┐
    │Finança │ │Compras│ │Parcelas│ │Fases │ │Diário  │
    └────────┘ └───────┘ └────────┘ └──────┘ └────────┘
```

---

## ✅ SIM, TUDO ESTÁ CONECTADO!

### 1. **Financeiro → Mapa**

**O que acontece:**
- Quando você adiciona uma despesa no módulo Financeiro
- O Mapa recalcula automaticamente:
  - ✅ Orçamento restante
  - ✅ Percentual gasto
  - ✅ Saúde da reforma (se estourou orçamento)
  - ✅ Próximas parcelas
  - ✅ Card "Distância até Mudança" (orçamento restante)

**Onde está o código:**
```dart
// lib/features/reform_map/data/repositories/reform_map_repository_impl.dart
// Linha ~89-103

final financial = FinancialSnapshotModel(
  totalBudget: projectData['totalBudget'],
  totalSpent: projectData['totalSpent'],      // ← Vem do Financeiro
  remainingBudget: projectData['remainingBudget'],
  percentageSpent: projectData['percentageSpent'],
  pendingPayments: projectData['pendingPayments'],
  nextPaymentAmount: projectData['nextPaymentAmount'],
);
```

---

### 2. **Compras → Mapa**

**O que acontece:**
- Quando você adiciona um item na lista de compras
- O Mapa detecta automaticamente:
  - ✅ Próximas compras necessárias (Card "Próximas Compras")
  - ✅ Compras pendentes por fase
  - ✅ Alertas de compras urgentes
  - ✅ Preparação da próxima fase

**Onde está o código:**
```dart
// lib/features/reform_map/domain/services/upcoming_purchases_detector.dart

class UpcomingPurchasesDetector {
  List<UpcomingPurchaseEntity> detect(ReformMapEntity reformMap) {
    // Analisa as fases e detecta compras necessárias
    // Baseado no progresso e próximas etapas
  }
}
```

**Integração no Cubit:**
```dart
// lib/features/reform_map/presentation/cubit/reform_map_cubit.dart
// Linha ~82-83

final upcomingPurchases = upcomingPurchasesDetector.detect(reformMap);
```

---

### 3. **Parcelas → Mapa**

**O que acontece:**
- Quando você adiciona uma parcela
- O Mapa atualiza:
  - ✅ Próximas parcelas a vencer
  - ✅ Parcelas vencidas (afeta saúde)
  - ✅ Fluxo de caixa projetado
  - ✅ Alertas de pagamento

**Onde está o código:**
```dart
// lib/features/reform_map/data/repositories/reform_map_repository_impl.dart

nextPaymentAmount: projectData['nextPaymentAmount'],
nextPaymentDate: projectData['nextPaymentDate'],
pendingPayments: projectData['pendingPayments'],
```

---

### 4. **Fases → Mapa**

**O que acontece:**
- Quando você marca uma fase como concluída
- O Mapa recalcula TUDO:
  - ✅ Percentual de conclusão
  - ✅ Dias restantes
  - ✅ Próxima fase
  - ✅ Próxima ação
  - ✅ Marcos (milestones)
  - ✅ Modo Mudança (se >= 80%)
  - ✅ Calendário de eventos

**Onde está o código:**
```dart
// lib/features/reform_map/domain/services/move_in_distance_calculator.dart
// Linha ~55-66

int _calculatePercentageComplete(List<PhaseEntity> phases) {
  final completedPhases = phases
      .where((phase) =>
          phase.status == PhaseStatus.done ||
          phase.status == PhaseStatus.doneNoRecord)
      .length;

  return ((completedPhases / phases.length) * 100).round();
}
```

---

### 5. **Diário → Mapa**

**O que acontece:**
- Quando você adiciona uma entrada no diário
- O Mapa registra:
  - ✅ Progresso visual da reforma
  - ✅ Problemas reportados
  - ✅ Entregas realizadas
  - ✅ Histórico de decisões

---

## 🎯 QUEM GERA O CHECKLIST?

### Resposta: **O Sistema Gera Automaticamente!**

O checklist é gerado por **detectores inteligentes** que analisam o estado da reforma:

### 1. **Decisões Pendentes**
```dart
// lib/features/reform_map/domain/services/pending_decisions_detector.dart

class PendingDecisionsDetector {
  List<PendingDecisionEntity> detect(ReformMapEntity reformMap) {
    final decisions = <PendingDecisionEntity>[];
    
    // Analisa cada fase e detecta decisões necessárias
    for (final phase in reformMap.phases) {
      if (phase.status == PhaseStatus.available) {
        // Gera decisões baseadas na fase
        decisions.addAll(_detectDecisionsForPhase(phase));
      }
    }
    
    return decisions;
  }
}
```

**Exemplo de decisões geradas:**
- "Definir pontos de tomada" (Fase: Infraestrutura)
- "Escolher cor da pintura" (Fase: Pintura)
- "Definir layout da cozinha" (Fase: Marcenaria)

---

### 2. **Próximas Compras**
```dart
// lib/features/reform_map/domain/services/upcoming_purchases_detector.dart

class UpcomingPurchasesDetector {
  List<UpcomingPurchaseEntity> detect(ReformMapEntity reformMap) {
    // Analisa a fase atual e próxima
    // Gera lista de compras necessárias
    
    if (currentPhase.name.contains('Infraestrutura')) {
      return [
        UpcomingPurchaseEntity(
          item: 'Cabos elétricos',
          category: 'Elétrica',
          urgency: 'high',
        ),
        // ...
      ];
    }
  }
}
```

---

### 3. **Preparação da Próxima Fase**
```dart
// lib/features/reform_map/domain/services/next_phase_preparation_detector.dart

class NextPhasePreparationDetector {
  NextPhasePreparationEntity? detect(ReformMapEntity reformMap) {
    final nextPhase = _getNextPhase(reformMap.phases);
    
    if (nextPhase != null) {
      return NextPhasePreparationEntity(
        phaseName: nextPhase.name,
        checklist: _generateChecklistForPhase(nextPhase),
        estimatedDuration: _estimateDuration(nextPhase),
      );
    }
  }
}
```

---

### 4. **Marcos (Milestones)**
```dart
// lib/features/reform_map/domain/services/milestones_detector.dart

class MilestonesDetector {
  List<MilestoneEntity> detect(ReformMapEntity reformMap) {
    // Detecta marcos importantes baseado no progresso
    
    final milestones = <MilestoneEntity>[];
    
    if (reformMap.progress.completedPercentage >= 25) {
      milestones.add(MilestoneEntity(
        title: 'Infraestrutura Concluída',
        achieved: true,
      ));
    }
    
    if (reformMap.progress.completedPercentage >= 50) {
      milestones.add(MilestoneEntity(
        title: 'Metade da Reforma',
        achieved: true,
      ));
    }
    
    // ...
  }
}
```

---

## 🔄 Fluxo de Atualização Completo

```
1. Usuário adiciona despesa no Financeiro
   ↓
2. Firestore atualiza campo 'totalSpent' no projeto
   ↓
3. ReformMapCubit detecta mudança e chama loadReformMap()
   ↓
4. Repository busca dados atualizados do Firestore
   ↓
5. Detectores analisam novo estado:
   - MoveInDistanceCalculator recalcula dias restantes
   - PendingDecisionsDetector verifica novas decisões
   - UpcomingPurchasesDetector atualiza compras
   - MilestonesDetector verifica marcos alcançados
   ↓
6. Mapa atualiza todos os cards automaticamente
   ↓
7. UI reflete mudanças em tempo real
```

---

## 📍 Onde Está Cada Integração

### Arquivo Principal de Integração:
```
lib/features/reform_map/presentation/cubit/reform_map_cubit.dart
```

**Método principal:**
```dart
Future<void> loadReformMap(String projectId) async {
  // 1. Busca dados do repository
  final result = await getReformMapUseCase(projectId);
  
  result.fold(
    (failure) => emit(ReformMapError(failure.message)),
    (reformMap) {
      // 2. Calcula distância até mudança
      final moveInDistance = moveInDistanceCalculator.calculate(reformMap);
      
      // 3. Detecta decisões pendentes
      final pendingDecisions = pendingDecisionsDetector.detect(reformMap);
      
      // 4. Detecta próximas compras
      final upcomingPurchases = upcomingPurchasesDetector.detect(reformMap);
      
      // 5. Detecta preparação da próxima fase
      final nextPhasePreparation = nextPhasePreparationDetector.detect(reformMap);
      
      // 6. Detecta marcos
      final milestones = milestonesDetector.detect(reformMap);
      
      // 7. Detecta eventos do calendário
      final calendar = calendarEventsDetector.detect(reformMap);
      
      // 8. Gera semana da reforma
      final week = reformWeekGenerator.generate(calendar);
      
      // 9. Gera modo mudança
      final moveInMode = moveInModeGenerator.generate(...);
      
      // 10. Atualiza mapa com todos os dados calculados
      final updatedMap = reformMap.copyWith(
        moveInDistance: moveInDistance,
        moveInMode: moveInMode,
        pendingDecisions: pendingDecisions,
        upcomingPurchases: upcomingPurchases,
        nextPhasePreparation: nextPhasePreparation,
        milestones: milestones,
        calendar: calendar,
        week: week,
      );
      
      emit(ReformMapLoaded(updatedMap));
    },
  );
}
```

---

## 🎨 Cards do Mapa e Suas Fontes de Dados

| Card | Fonte de Dados | Detectores |
|------|----------------|------------|
| **Distância até Mudança** | Fases, Financeiro, Data Planejada | `MoveInDistanceCalculator` |
| **Decisões Pendentes** | Fases, Compras, Fornecedores | `PendingDecisionsDetector` |
| **Próximas Compras** | Fases, Lista de Compras | `UpcomingPurchasesDetector` |
| **Preparação Próxima Fase** | Fases, Checklist | `NextPhasePreparationDetector` |
| **Marcos** | Progresso, Fases | `MilestonesDetector` |
| **Calendário** | Fases, Parcelas, Eventos | `CalendarEventsDetector` |
| **Semana da Reforma** | Calendário | `ReformWeekGenerator` |
| **Modo Mudança** | Progresso, Data Planejada | `MoveInModeGenerator` |

---

## 🔧 Como Adicionar Nova Integração

Se você quiser que um novo módulo afete o Mapa:

### 1. Adicione campo no Firestore
```dart
// Exemplo: adicionar campo 'hasArchitect'
await projectDoc.update({
  'hasArchitect': true,
});
```

### 2. Adicione campo na entidade
```dart
// lib/features/projects/domain/entities/project_entity.dart
class ProjectEntity {
  final bool hasArchitect;
  // ...
}
```

### 3. Crie ou atualize detector
```dart
// lib/features/reform_map/domain/services/seu_detector.dart
class SeuDetector {
  List<SuaEntity> detect(ReformMapEntity reformMap) {
    // Analisa reformMap e gera insights
  }
}
```

### 4. Integre no Cubit
```dart
// lib/features/reform_map/presentation/cubit/reform_map_cubit.dart
final seuDado = seuDetector.detect(reformMap);

final updatedMap = reformMap.copyWith(
  seuDado: seuDado,
);
```

---

## 🎯 Resumo Final

### ✅ SIM, tudo está conectado!

- **Financeiro** → Afeta orçamento, saúde, próximas parcelas
- **Compras** → Afeta próximas compras, preparação de fase
- **Parcelas** → Afeta alertas, fluxo de caixa
- **Fases** → Afeta TUDO (progresso, próxima ação, marcos)
- **Diário** → Registra histórico e problemas
- **Fornecedores** → Afeta decisões e orçamentos
- **Wishlist** → Pode gerar alertas de compra

### 🤖 O Checklist é Gerado Automaticamente

Por **8 detectores inteligentes** que analisam:
- Estado das fases
- Progresso da reforma
- Orçamento disponível
- Compras pendentes
- Decisões necessárias
- Próximos marcos
- Eventos futuros
- Proximidade da mudança

### 🔄 Atualização em Tempo Real

Qualquer mudança em qualquer módulo → Mapa recalcula → UI atualiza

**O Mapa da Reforma é o cérebro do aplicativo!** 🧠