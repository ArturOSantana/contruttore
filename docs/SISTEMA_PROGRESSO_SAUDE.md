# 📊 Sistema de Progresso e Saúde da Reforma

## Visão Geral

O sistema de progresso e saúde da reforma é composto por dois serviços principais que trabalham juntos para fornecer uma visão completa do andamento da obra:

1. **ReformHealthService**: Calcula a "saúde" geral da reforma
2. **Cálculo de Progresso**: Determina a % de conclusão da obra

---

## 🏥 Saúde da Reforma

### Como Funciona

A saúde da reforma é calculada através de **4 pilares** que somam até **100 pontos**:

#### 1. Score de Progresso (30 pontos)
- Mede o avanço físico da obra
- Usa pesos diferentes para cada fase
- Fases mais complexas têm maior peso

#### 2. Score Financeiro (25 pontos)
- Compara gastos vs orçamento
- Penaliza estouro de orçamento
- Considera gastos comprometidos (pagos + pendentes)

**Escala:**
- ≤ 80% do orçamento: 25 pontos (Excelente)
- 81-95%: 20 pontos (Bom)
- 96-105%: 15 pontos (Atenção)
- 106-120%: 10 pontos (Ruim)
- > 120%: 5 pontos (Crítico)

#### 3. Score de Prazo (25 pontos)
- Verifica fases atrasadas
- Compara progresso vs data de mudança
- Penaliza atrasos críticos

**Penalidades:**
- -5 pontos por fase atrasada
- -10 pontos se falta < 30 dias e progresso < 80%
- -5 pontos se falta < 60 dias e progresso < 60%

#### 4. Score de Qualidade (20 pontos)
- Conta alertas críticos
- Verifica fases sem registro
- Mede qualidade da execução

**Penalidades:**
- -3 pontos por alerta crítico
- -2 pontos por fase sem registro (doneNoRecord)

### Status de Saúde

| Score | Status | Descrição | Cor |
|-------|--------|-----------|-----|
| 85-100 | Excelente 🎉 | Reforma indo muito bem | Verde #4CAF50 |
| 70-84 | Bom 👍 | Tudo no caminho certo | Verde claro #8BC34A |
| 50-69 | Atenção ⚠️ | Alguns pontos precisam atenção | Amarelo #FFC107 |
| 30-49 | Crítico 🚨 | Situação crítica, ação necessária | Laranja #FF9800 |
| 0-29 | Emergência 🆘 | Intervenção urgente! | Vermelho #F44336 |

### Exemplo de Uso

```dart
// Injetar o serviço
final healthService = getIt<ReformHealthService>();

// Calcular saúde
final healthScore = healthService.calculateHealth(
  project: project,
  phases: phases,
  totalSpent: 45000,
  totalPending: 15000,
  criticalAlertsCount: 2,
  delayedPhasesCount: 1,
);

// Usar os resultados
print('Score total: ${healthScore.totalScore}');
print('Status: ${healthScore.status.label}');
print('Cor: ${healthScore.statusColor}');

// Mostrar recomendações
for (final rec in healthScore.recommendations) {
  print('- $rec');
}
```

---

## 📈 Cálculo de Progresso

### Progresso Ponderado

O progresso da obra **NÃO é uma média simples** das fases. Cada fase tem um peso diferente baseado em sua complexidade e impacto.

### Pesos Padrão (8 fases)

```dart
1. Planejamento:           5%
2. Demolição:             10%
3. Infraestrutura:        15%  // Elétrica + Hidráulica
4. Alvenaria:             15%
5. Revestimentos:         20%  // Maior peso
6. Acabamentos:           15%
7. Instalações finais:    10%
8. Limpeza e entrega:     10%
                        -----
                         100%
```

### Fórmula

```
Progresso Total = Σ (Progresso da Fase × Peso da Fase) / 100
```

### Exemplo Prático

```
Fase 1 (Planejamento): 100% × 5% = 5
Fase 2 (Demolição): 100% × 10% = 10
Fase 3 (Infraestrutura): 60% × 15% = 9
Fase 4 (Alvenaria): 0% × 15% = 0
Fase 5-8: 0%

Progresso Total = 5 + 10 + 9 = 24%
```

### Status das Fases

```dart
enum PhaseStatus {
  locked,        // Fase futura (0% de progresso)
  active,        // Fase atual (usa progressPercentage)
  done,          // Fase concluída (100%)
  doneNoRecord,  // Concluída sem registro (100%)
}
```

### Progresso de Subtarefas

Cada fase tem subtarefas que contribuem para seu progresso:

```dart
progressPercentage = (subtarefas concluídas / total de subtarefas) × 100
```

### Exemplo de Uso

```dart
final healthService = getIt<ReformHealthService>();

// Calcular progresso geral
final overallProgress = healthService.calculateOverallProgress(phases);

print('Progresso da obra: ${overallProgress.toStringAsFixed(1)}%');

// Usar em cards
MoveInDistanceCard(
  overallProgress: overallProgress,
  // ...
);
```

---

## 🎯 Modo Mudança

### Ativação

O Modo Mudança é ativado quando:
- **Progresso ≥ 80%** OU
- **Faltam ≤ 30 dias** para mudança

### Checklist Personalizado

O checklist é gerado dinamicamente baseado em:

1. **Progresso da obra**
   - ≥ 90%: Adiciona tarefas de limpeza
   - ≥ 85%: Adiciona vistoria final
   - ≥ 95%: Adiciona decoração

2. **Dias até mudança**
   - ≤ 15 dias: Transferir contas (água, luz, gás)
   - ≤ 20 dias: Contratar mudança

3. **Itens críticos do usuário** (do onboarding)
   - Ar-condicionado: Testar funcionamento
   - Internet cabeada: Testar pontos
   - Lava-louças: Verificar instalação
   - Aquecedor: Testar aquecimento
   - Automação: Configurar sistema
   - Fechadura eletrônica: Testar acesso
   - Câmeras: Verificar gravação
   - Som ambiente: Testar áudio
   - Carregador elétrico: Testar carregamento
   - Aspiração central: Testar sucção
   - Energia solar: Verificar geração

### Categorias de Tarefas

```dart
enum MoveInTaskCategory {
  cleaning,       // 🧹 Limpeza
  inspection,     // 🔍 Vistoria
  documentation,  // 📄 Documentação
  utilities,      // ⚡ Serviços
  moving,         // 📦 Mudança
  decoration,     // 🎨 Decoração
}
```

### Status do Modo Mudança

```dart
enum MoveInStatus {
  notReady,      // Ainda não está pronto
  almostReady,   // Quase pronto
  ready,         // Pronto para mudar
  delayed,       // Mudança pode atrasar
}
```

**Critérios:**

- **Delayed**: Tem pendências críticas E faltam ≤ 7 dias
- **Ready**: Progresso ≥ 95% E sem pendências E 80%+ tarefas concluídas
- **AlmostReady**: Progresso ≥ 80% E poucas pendências
- **NotReady**: Demais casos

### Exemplo de Uso

```dart
final generator = getIt<MoveInModeGenerator>();

final moveInMode = generator.generate(
  phases: phases,
  overallProgress: overallProgress,
  plannedMoveInDate: project.plannedMoveInDate,
  criticalPendingItems: ['Piso da sala', 'Pintura do quarto'],
  userCriticalItems: project.criticalItems, // Do onboarding
);

// Verificar se está ativo
if (moveInMode.isActive) {
  // Mostrar checklist
  for (final task in moveInMode.tasks) {
    print('${task.isCompleted ? '✓' : '○'} ${task.title}');
  }
  
  // Mostrar status
  print('Status: ${moveInMode.status.label}');
  print('Dias até mudança: ${moveInMode.daysUntilMoveIn}');
  
  // Mostrar recomendações
  for (final rec in moveInMode.recommendations) {
    print('💡 $rec');
  }
}
```

---

## 🔗 Integração com a UI

### Home Page

```dart
// Calcular saúde
final healthScore = healthService.calculateHealth(...);

// Mostrar card de saúde
ReformHealthCard(
  score: healthScore.totalScore,
  status: healthScore.status,
  recommendations: healthScore.recommendations,
);
```

### Mapa da Reforma

```dart
// Calcular progresso
final overallProgress = healthService.calculateOverallProgress(phases);

// Mostrar em cada card
MoveInDistanceCard(
  overallProgress: overallProgress,
  daysUntilMoveIn: daysUntilMoveIn,
);

// Mostrar progresso por fase
for (final phase in phases) {
  PhaseCard(
    name: phase.name,
    progress: phase.progressPercentage,
    status: phase.status,
  );
}
```

### Modo Mudança

```dart
// Gerar modo mudança
final moveInMode = generator.generate(...);

if (moveInMode.isActive) {
  // Mostrar card especial
  MoveInModeCard(
    mode: moveInMode,
    onTaskToggle: (taskId) {
      // Marcar tarefa como concluída
    },
  );
}
```

---

## 📱 Visualização para o Usuário

### Card de Saúde da Reforma

```
┌─────────────────────────────────┐
│ 🏥 Saúde da Reforma             │
├─────────────────────────────────┤
│                                 │
│  Score: 78/100                  │
│  Status: Bom 👍                 │
│                                 │
│  ████████████░░░░░░░ 78%        │
│                                 │
│  📊 Detalhes:                   │
│  • Progresso: 24/30             │
│  • Financeiro: 20/25            │
│  • Prazo: 20/25                 │
│  • Qualidade: 14/20             │
│                                 │
│  💡 Recomendações:              │
│  • Tudo no caminho certo        │
│  • Mantenha o controle          │
│                                 │
└─────────────────────────────────┘
```

### Progresso da Obra

```
┌─────────────────────────────────┐
│ 📈 Progresso da Obra            │
├─────────────────────────────────┤
│                                 │
│  24% concluído                  │
│  ████████░░░░░░░░░░░░░░░░░░░░   │
│                                 │
│  ✓ Planejamento (100%)          │
│  ✓ Demolição (100%)             │
│  ► Infraestrutura (60%)         │
│  ○ Alvenaria (0%)               │
│  ○ Revestimentos (0%)           │
│  ○ Acabamentos (0%)             │
│  ○ Instalações (0%)             │
│  ○ Limpeza (0%)                 │
│                                 │
└─────────────────────────────────┘
```

### Modo Mudança

```
┌─────────────────────────────────┐
│ 🏠 Modo Mudança                 │
├─────────────────────────────────┤
│                                 │
│  Status: Quase pronto 🎯        │
│  Faltam: 18 dias                │
│                                 │
│  Checklist (6/10):              │
│  ✓ Limpeza pós-obra             │
│  ✓ Vistoria final               │
│  ✓ Testar instalações           │
│  ✓ Organizar documentos         │
│  ✓ Testar ar-condicionado       │
│  ✓ Testar internet cabeada      │
│  ○ Transferir contas            │
│  ○ Ativar internet              │
│  ○ Contratar mudança            │
│  ○ Embalar pertences            │
│                                 │
│  💡 Recomendações:              │
│  • Pesquise empresas de mudança │
│  • Organize documentos da obra  │
│                                 │
└─────────────────────────────────┘
```

---

## 🎨 Cores e Ícones

### Cores por Status

```dart
// Saúde
excellent: #4CAF50  // Verde
good: #8BC34A       // Verde claro
attention: #FFC107  // Amarelo
critical: #FF9800   // Laranja
emergency: #F44336  // Vermelho

// Fases
locked: #9E9E9E     // Cinza
active: #2196F3     // Azul
done: #4CAF50       // Verde
```

### Ícones

```dart
// Saúde
excellent: Icons.celebration
good: Icons.thumb_up
attention: Icons.warning
critical: Icons.error
emergency: Icons.sos

// Fases
locked: Icons.lock
active: Icons.play_arrow
done: Icons.check_circle
```

---

## 🔧 Manutenção

### Ajustar Pesos das Fases

Se precisar ajustar os pesos, edite o método `_getPhaseWeights()` em `ReformHealthService`:

```dart
List<double> _getPhaseWeights(int totalPhases) {
  if (totalPhases == 8) {
    return [
      5,  // Planejamento
      10, // Demolição
      15, // Infraestrutura
      15, // Alvenaria
      20, // Revestimentos (MAIOR PESO)
      15, // Acabamentos
      10, // Instalações
      10, // Limpeza
    ];
  }
  // ...
}
```

### Ajustar Critérios de Saúde

Para mudar os critérios de score, edite os métodos `_calculate*Score()`:

```dart
double _calculateFinancialScore({...}) {
  // Ajuste os limites aqui
  if (usagePercentage <= 80) return 25;
  if (usagePercentage <= 95) return 20;
  // ...
}
```

### Adicionar Novas Tarefas ao Modo Mudança

Edite `_generateTasks()` em `MoveInModeGenerator`:

```dart
// Adicionar nova tarefa
tasks.add(
  MoveInTaskEntity(
    id: 'nova_tarefa',
    title: 'Título da tarefa',
    description: 'Descrição',
    category: MoveInTaskCategory.utilities,
    isCompleted: false,
    isCritical: true,
    dueDate: DateTime.now().add(Duration(days: 7)),
  ),
);
```

---

## ✅ Checklist de Implementação

- [x] Criar ReformHealthService
- [x] Implementar cálculo de progresso ponderado
- [x] Implementar cálculo de saúde (4 pilares)
- [x] Criar sistema de status e recomendações
- [x] Integrar com MoveInModeGenerator
- [x] Adicionar tarefas personalizadas baseadas em criticalItems
- [x] Documentar sistema completo
- [ ] Criar widgets de visualização
- [ ] Integrar com Home Page
- [ ] Integrar com Mapa da Reforma
- [ ] Adicionar testes unitários
- [ ] Testar com dados reais

---

## 📚 Referências

- `lib/core/services/reform_health_service.dart`
- `lib/features/reform_map/domain/services/move_in_mode_generator.dart`
- `lib/features/reform_map/domain/entities/move_in_mode_entity.dart`
- `lib/features/projects/domain/entities/phase_entity.dart`
- `lib/features/projects/domain/entities/project_entity.dart`

---

**Made with Bob** 🤖