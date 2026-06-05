# Correções Pendentes - Mapa da Reforma

## Status Atual
- ✅ Entidades corrigidas (ReformProgress, FinancialSnapshot)
- ✅ NextActionModel corrigido
- ✅ ReformMapModel corrigido
- ✅ Firestore rules deployadas
- ⚠️ 43 erros restantes para corrigir

## Erros Restantes (43 total)

### 1. ReformHealthModel (1 erro)
**Arquivo:** `lib/features/reform_map/data/models/reform_health_model.dart:52`
**Erro:** HealthFactorModel precisa adicionar campo `status` no construtor

**Correção:**
```dart
class HealthFactorModel extends HealthFactor {
  const HealthFactorModel({
    required super.name,
    required super.score,
    required super.weight,
    required super.status,  // ADICIONAR
    required super.description,
  });
```

### 2. ReformMapRepositoryImpl (28 erros)

#### 2.1 Métodos faltantes (5 erros)
Implementar métodos:
- `completeAction(String actionId)`
- `skipAction(String actionId, String reason)`
- `getPhaseContext(String projectId, String phaseId)`
- `getOpenProblems(String projectId)`
- `getHealthHistory(String projectId, {int limit = 30})`

#### 2.2 Parâmetros faltantes em ReformProgress (linha 66)
```dart
progress: ReformProgress(
  totalPhases: phases.length,
  completedPhases: completedCount,
  inProgressPhases: inProgressCount,  // ADICIONAR
  completedPercentage: percentage,
  estimatedEndDate: null,
  daysRemaining: 0,  // ADICIONAR
  daysDelayed: 0,    // ADICIONAR
),
```

#### 2.3 Parâmetros faltantes em FinancialSnapshot (linha 77)
```dart
financial: FinancialSnapshot(
  totalBudget: project.budget,
  totalSpent: 0,
  remainingBudget: project.budget,
  percentageSpent: 0,
  pendingPayments: 0,      // ADICIONAR
  nextPaymentAmount: 0,    // ADICIONAR
  nextPaymentDate: null,   // ADICIONAR
),
```

#### 2.4 Parâmetros faltantes em ReformMapModel (linha 89)
```dart
return Right(ReformMapModel(
  projectId: projectId,
  phases: phases,
  currentPhase: currentPhase,  // ADICIONAR
  health: health,
  nextAction: nextAction,
  openProblems: [],           // ADICIONAR (não 'problems')
  progress: progress,
  financial: financial,
  positiveMessages: [],       // ADICIONAR
  lastUpdated: DateTime.now(),
));
```

#### 2.5 Cast de List<dynamic> para List<PhaseEntity> (linha 91)
```dart
phases: phases.cast<PhaseEntity>(),  // Usar .cast()
```

#### 2.6 Métodos addProblem e updateProblem - retorno errado
Mudar retorno de `void` para `ProblemEntity`:
```dart
Future<Either<Failure, ProblemEntity>> addProblem(ProblemEntity problem) async {
  // ... código ...
  return Right(problem);  // Retornar o problema
}
```

#### 2.7 Método resolveProblem - parâmetro faltante
```dart
Future<Either<Failure, void>> resolveProblem(
  String problemId,
  String solution,  // ADICIONAR
) async {
```

#### 2.8 Null safety em phaseId.split() (linhas 181, 199)
```dart
.doc(problem.phaseId?.split('_').first ?? projectId)
```

#### 2.9 Enum HealthStatus.attention não existe (linha 375)
Trocar por `HealthStatus.warning`

#### 2.10 Enum ActionType.solveProblem não existe (linha 422)
Trocar por `ActionType.other`

#### 2.11 Enum ActionCategory.problem não existe (linha 423)
Trocar por `ActionCategory.general`

### 3. Widgets (14 erros)

#### 3.1 current_phase_widget.dart (linha 61)
```dart
// Trocar PhaseStatus.inProgress por PhaseStatus.active
(phase) => phase.status == PhaseStatus.active,
```

#### 3.2 phase_overview_widget.dart (linhas 53, 58, 84, 88, 92, 96)
```dart
// Mapeamento de status:
PhaseStatus.completed → PhaseStatus.done
PhaseStatus.inProgress → PhaseStatus.active
PhaseStatus.pending → PhaseStatus.locked
PhaseStatus.delayed → PhaseStatus.active (com lógica adicional)
```

#### 3.3 problems_list_widget.dart (linhas 153-177)
```dart
// Trocar timeImpactDays por delayDays
if (problem.financialImpact != null && problem.financialImpact! > 0 || 
    problem.delayDays != null && problem.delayDays! > 0) {
  
  if (problem.financialImpact != null && problem.financialImpact! > 0) {
    // ... usar problem.financialImpact!.toStringAsFixed(2)
  }
  
  if (problem.delayDays != null && problem.delayDays! > 0) {
    // ... usar problem.delayDays
  }
}
```

## Script de Correção Rápida

Execute este comando para aplicar todas as correções:

```bash
# 1. Corrigir HealthFactorModel
sed -i '' '52s/const HealthFactorModel({/const HealthFactorModel({\n    required super.status,/' \
  lib/features/reform_map/data/models/reform_health_model.dart

# 2. Corrigir widgets
sed -i '' 's/PhaseStatus\.inProgress/PhaseStatus.active/g' \
  lib/features/reform_map/presentation/widgets/current_phase_widget.dart

sed -i '' 's/PhaseStatus\.completed/PhaseStatus.done/g' \
  lib/features/reform_map/presentation/widgets/phase_overview_widget.dart

sed -i '' 's/PhaseStatus\.inProgress/PhaseStatus.active/g' \
  lib/features/reform_map/presentation/widgets/phase_overview_widget.dart

sed -i '' 's/PhaseStatus\.pending/PhaseStatus.locked/g' \
  lib/features/reform_map/presentation/widgets/phase_overview_widget.dart

sed -i '' 's/PhaseStatus\.delayed/PhaseStatus.active/g' \
  lib/features/reform_map/presentation/widgets/phase_overview_widget.dart

sed -i '' 's/timeImpactDays/delayDays/g' \
  lib/features/reform_map/presentation/widgets/problems_list_widget.dart

# 3. Verificar erros
flutter analyze lib/features/reform_map
```

## Próximos Passos

1. Aplicar correções do HealthFactorModel
2. Implementar 5 métodos faltantes no repository
3. Corrigir parâmetros em ReformMapRepositoryImpl
4. Corrigir enums nos widgets
5. Testar compilação: `flutter analyze lib/features/reform_map`
6. Rodar app: `flutter run`

## Estimativa
- Tempo para correções: 30-45 minutos
- Complexidade: Média (maioria são ajustes simples)