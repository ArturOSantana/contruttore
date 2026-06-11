# Personalização Baseada no Onboarding

Este documento explica como o app utiliza os dados coletados no onboarding para personalizar a experiência do usuário.

## Dados Coletados

Durante o onboarding conversacional, coletamos:

### 1. Prioridade Principal (`mainPriority`)
O que é mais importante para o usuário:
- `save_money` - Economizar
- `finish_fast` - Terminar rápido
- `avoid_problems` - Evitar problemas
- `best_quality` - Melhor acabamento
- `control_spending` - Controlar gastos
- `organize_everything` - Organizar tudo

### 2. Itens Críticos (`criticalItems`)
Itens que o usuário marcou como importantes:
- `ar_conditioner` - Ar-condicionado
- `wired_internet` - Internet cabeada
- `dishwasher` - Lava-louças
- `water_heater` - Aquecedor
- `home_automation` - Automação residencial
- `smart_lock` - Fechadura eletrônica
- `security_cameras` - Câmeras de segurança
- `ambient_sound` - Som ambiente
- `ev_charger` - Carregador de carro elétrico
- `central_vacuum` - Aspiração central
- `solar_energy` - Energia solar

## Como os Dados São Armazenados

Os dados são salvos em dois lugares:

### 1. Durante o Onboarding (SharedPreferences)
```dart
// Salvo automaticamente a cada mudança
final progress = ConversationalOnboardingProgress(
  mainPriority: 'save_money',
  criticalItems: ['ar_conditioner', 'wired_internet'],
  // ... outros campos
);
```

### 2. No Projeto (Firestore)
```dart
final project = ProjectEntity(
  mainPriority: 'save_money',
  criticalItems: ['ar_conditioner', 'wired_internet'],
  // ... outros campos
);
```

## Serviços de Personalização

### PersonalizationService

Localização: `lib/core/services/personalization_service.dart`

#### Uso Básico

```dart
// Injetar o serviço
final personalizationService = getIt<PersonalizationService>();

// Obter recomendações
final recommendations = personalizationService.getRecommendations(project);

// Obter mensagem motivacional
final message = personalizationService.getMotivationalMessage(project.mainPriority);

// Obter alertas personalizados
final alerts = personalizationService.getPersonalizedAlerts(project);
```

#### Métodos Disponíveis

##### 1. `getRecommendations(ProjectEntity project)`
Retorna lista de recomendações baseadas na prioridade.

**Exemplo:**
```dart
// Para usuário com prioridade "save_money"
[
  'Compare preços de pelo menos 3 fornecedores',
  'Considere comprar materiais por conta própria',
  'Negocie descontos para pagamento à vista',
  // ...
]
```

##### 2. `getMotivationalMessage(String? priority)`
Retorna mensagem motivacional personalizada.

**Exemplo:**
```dart
// Para "save_money"
'Economizando em cada etapa 💰'

// Para "finish_fast"
'Acelerando sua mudança 🚀'
```

##### 3. `getPersonalizedAlerts(ProjectEntity project)`
Retorna alertas específicos para a prioridade.

**Exemplo:**
```dart
// Para "avoid_problems"
[
  'Exija nota fiscal de todos os serviços',
  'Fotografe cada etapa da obra',
  'Mantenha contratos por escrito',
]
```

##### 4. `getPhaseSpecificTip(String? priority, String phaseName)`
Retorna dica específica para a fase atual.

**Exemplo:**
```dart
// Para "save_money" na fase de planejamento
'Planeje bem agora para economizar depois. Mudanças durante a obra custam caro.'
```

##### 5. `getAlertUrgencyLevel(String? priority)`
Retorna nível de urgência (1-5) para alertas.

**Exemplo:**
```dart
// Para "finish_fast"
5 // Máxima urgência

// Para "organize_everything"
2 // Baixa urgência
```

##### 6. Flags de Comportamento

```dart
// Deve mostrar comparação de preços?
bool shouldShowPriceComparison(String? priority)
// true para: save_money, control_spending

// Deve mostrar timeline detalhado?
bool shouldShowDetailedTimeline(String? priority)
// true para: finish_fast, organize_everything

// Deve mostrar checklists extras?
bool shouldShowExtraChecklists(String? priority)
// true para: avoid_problems, organize_everything
```

### MoveInModeGenerator

Localização: `lib/features/reform_map/domain/services/move_in_mode_generator.dart`

#### Uso com Itens Críticos

```dart
final moveInMode = moveInModeGenerator.generate(
  phases: phases,
  overallProgress: 85.0,
  plannedMoveInDate: DateTime.now().add(Duration(days: 30)),
  criticalPendingItems: ['elétrica', 'pintura'],
  userCriticalItems: project.criticalItems, // ← NOVO!
);
```

#### Tarefas Personalizadas Geradas

O gerador cria tarefas específicas baseadas nos itens críticos:

**Exemplo:**
```dart
// Se o usuário marcou "ar_conditioner"
MoveInTaskEntity(
  title: 'Testar ar-condicionado',
  description: 'Ligar e testar todos os aparelhos de ar-condicionado',
  category: MoveInTaskCategory.inspection,
  isCritical: true,
)

// Se o usuário marcou "wired_internet"
MoveInTaskEntity(
  title: 'Testar pontos de internet',
  description: 'Verificar todos os pontos de rede cabeada',
  category: MoveInTaskCategory.inspection,
  isCritical: true,
)
```

## Integração na Home Page

### Exemplo de Uso Completo

```dart
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final personalizationService = getIt<PersonalizationService>();
    final project = context.watch<ProjectCubit>().state.project;
    
    return Scaffold(
      body: Column(
        children: [
          // Mensagem motivacional personalizada
          Text(
            personalizationService.getMotivationalMessage(
              project?.mainPriority,
            ),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          
          // Recomendações personalizadas
          if (project != null)
            ...personalizationService
                .getRecommendations(project)
                .map((rec) => ListTile(
                      leading: Icon(Icons.lightbulb),
                      title: Text(rec),
                    )),
          
          // Alertas personalizados
          if (project != null)
            ...personalizationService
                .getPersonalizedAlerts(project)
                .map((alert) => Card(
                      child: ListTile(
                        leading: Icon(Icons.warning),
                        title: Text(alert),
                      ),
                    )),
        ],
      ),
    );
  }
}
```

### Personalização de Cards

```dart
// Mostrar comparação de preços apenas para quem quer economizar
if (personalizationService.shouldShowPriceComparison(project.mainPriority)) {
  PriceComparisonCard(...)
}

// Mostrar timeline detalhado para quem quer terminar rápido
if (personalizationService.shouldShowDetailedTimeline(project.mainPriority)) {
  DetailedTimelineCard(...)
}

// Mostrar checklists extras para quem quer evitar problemas
if (personalizationService.shouldShowExtraChecklists(project.mainPriority)) {
  ExtraChecklistsCard(...)
}
```

## Integração no Mapa da Reforma

### Dicas Específicas por Fase

```dart
class PhaseCard extends StatelessWidget {
  final PhaseEntity phase;
  final ProjectEntity project;
  
  @override
  Widget build(BuildContext context) {
    final personalizationService = getIt<PersonalizationService>();
    final tip = personalizationService.getPhaseSpecificTip(
      project.mainPriority,
      phase.name,
    );
    
    return Card(
      child: Column(
        children: [
          Text(phase.name),
          if (tip.isNotEmpty)
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.blue.shade50,
              child: Row(
                children: [
                  Icon(Icons.tips_and_updates),
                  SizedBox(width: 8),
                  Expanded(child: Text(tip)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
```

### Modo Mudança Personalizado

```dart
// Ao gerar o modo mudança
final moveInMode = moveInModeGenerator.generate(
  phases: phases,
  overallProgress: overallProgress,
  plannedMoveInDate: project.plannedMoveInDate,
  criticalPendingItems: criticalPendingItems,
  userCriticalItems: project.criticalItems, // Adiciona tarefas personalizadas
);

// As tarefas já virão personalizadas
for (final task in moveInMode.tasks) {
  if (task.id.startsWith('custom_')) {
    // Esta é uma tarefa personalizada baseada nos itens críticos do usuário
    print('Tarefa personalizada: ${task.title}');
  }
}
```

## Integração em Notificações

```dart
class NotificationService {
  void scheduleAlert(AlertEntity alert, ProjectEntity project) {
    final personalizationService = getIt<PersonalizationService>();
    
    // Ajusta urgência baseado na prioridade do usuário
    final urgencyLevel = personalizationService.getAlertUrgencyLevel(
      project.mainPriority,
    );
    
    // Usuários com "finish_fast" recebem notificações mais urgentes
    final priority = urgencyLevel >= 4 
        ? Priority.high 
        : Priority.normal;
    
    // Agenda notificação
    flutterLocalNotificationsPlugin.show(
      alert.id.hashCode,
      alert.title,
      alert.description,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'alerts',
          'Alertas',
          priority: priority,
        ),
      ),
    );
  }
}
```

## Boas Práticas

### 1. Sempre Verifique se os Dados Existem

```dart
// ✅ BOM
if (project.mainPriority != null) {
  final recommendations = personalizationService.getRecommendations(project);
}

// ❌ RUIM
final recommendations = personalizationService.getRecommendations(project);
// Pode retornar recomendações genéricas se mainPriority for null
```

### 2. Use Fallbacks

```dart
// ✅ BOM
final message = personalizationService.getMotivationalMessage(
  project.mainPriority,
) ?? 'Vamos organizar sua reforma!';

// O serviço já tem fallback, mas é bom garantir
```

### 3. Combine Múltiplas Fontes

```dart
// ✅ BOM - Combina recomendações gerais com personalizadas
final allRecommendations = [
  ...generalRecommendations,
  ...personalizationService.getRecommendations(project),
];
```

### 4. Respeite a Privacidade

```dart
// ✅ BOM - Não force personalização
if (user.acceptsPersonalization) {
  showPersonalizedContent();
} else {
  showGenericContent();
}
```

## Exemplos de Fluxos Completos

### Fluxo 1: Usuário que Quer Economizar

```dart
// Onboarding
mainPriority: 'save_money'
criticalItems: ['ar_conditioner', 'wired_internet']

// Home Page mostra:
- "Economizando em cada etapa 💰"
- "Compare preços de pelo menos 3 fornecedores"
- Card de comparação de preços
- Alertas sobre gastos

// Mapa da Reforma mostra:
- Dicas de economia em cada fase
- Alertas de urgência média (nível 3)

// Modo Mudança inclui:
- Tarefas padrão
- "Testar ar-condicionado"
- "Testar pontos de internet"
```

### Fluxo 2: Usuário que Quer Terminar Rápido

```dart
// Onboarding
mainPriority: 'finish_fast'
criticalItems: ['dishwasher', 'smart_lock']

// Home Page mostra:
- "Acelerando sua mudança 🚀"
- "Tenha todos os materiais antes de começar"
- Timeline detalhado
- Alertas de alta urgência

// Mapa da Reforma mostra:
- Dicas para acelerar cada fase
- Alertas de urgência máxima (nível 5)

// Modo Mudança inclui:
- Tarefas padrão
- "Instalar lava-louças" (com prazo mais curto)
- "Instalar fechadura eletrônica"
```

## Conclusão

O sistema de personalização transforma dados coletados no onboarding em uma experiência única para cada usuário. Use os serviços fornecidos para criar uma jornada personalizada que realmente ajude o usuário a alcançar seus objetivos.

---

**Criado por Bob** 🤖