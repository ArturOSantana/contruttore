# Novo Onboarding Conversacional - Especificação Técnica

## Objetivo
Transformar o onboarding atual (formulário) em uma experiência conversacional que:
1. Descobre o momento atual do usuário
2. Personaliza o mapa da reforma
3. Cria alertas inteligentes
4. Mantém progresso se usuário sair

---

## Arquitetura

### 1. Entidades de Domínio

```dart
// lib/features/onboarding/domain/entities/onboarding_progress_entity.dart
class OnboardingProgressEntity {
  final String userId;
  final int currentStep;
  final Map<String, dynamic> answers;
  final DateTime lastUpdated;
  final bool isCompleted;
}
```

### 2. Fluxo de Telas

#### Tela 1: Boas-vindas
- **Objetivo**: Apresentar valor
- **Conteúdo**:
  - Título: "Vamos organizar sua reforma"
  - Benefícios (4 itens com ícones)
  - Tempo estimado: "menos de 3 minutos"
- **Ação**: Botão "Começar"

#### Tela 2: Momento Atual (MAIS IMPORTANTE)
- **Pergunta**: "Qual destas situações mais parece com você?"
- **Opções** (6):
  1. `not_received_keys` - "Ainda não recebi as chaves"
  2. `just_received` - "Recebi as chaves recentemente"
  3. `planning` - "Estou planejando a reforma"
  4. `work_started` - "A obra já começou"
  5. `finishing` - "Estou finalizando"
  6. `living` - "Já estou morando"

#### Tela 3+: Fluxo Condicional
Baseado na resposta da Tela 2, seguir um dos 3 caminhos:

---

## Caminho A: Ainda não recebi as chaves

### Tela 3A: Prazo de Entrega
- **Pergunta**: "Quando você recebe as chaves?"
- **Opções**:
  - `up_to_30_days` - "Até 30 dias"
  - `1_to_3_months` - "1 a 3 meses"
  - `3_to_6_months` - "3 a 6 meses"
  - `more_than_6_months` - "Mais de 6 meses"
  - `dont_know` - "Não sei"

### Tela 4A: Intenção de Reforma
- **Pergunta**: "Você pretende reformar?"
- **Opções**:
  - `just_furnish` - "Só mobiliar"
  - `small_changes` - "Pequenas mudanças"
  - `complete_reform` - "Reforma completa"
  - `dont_know` - "Ainda não sei"

### Tela 5A: Itens Críticos (MAIS VALIOSA)
- **Pergunta**: "Já existe algum item que você sabe que vai querer?"
- **Tipo**: Checklist múltipla seleção
- **Opções**:
  - `air_conditioning` - "Ar-condicionado"
  - `wired_internet` - "Internet cabeada"
  - `automation` - "Automação"
  - `dishwasher` - "Lava-louças"
  - `water_heater` - "Aquecedor"
  - `smart_lock` - "Fechadura eletrônica"
  - `cameras` - "Câmeras"
  - `sound_system` - "Som ambiente"
  - `ev_charger` - "Carregador para carro elétrico"
  - `central_vacuum` - "Aspiração central"
  - `other` - "Outro"

**Resultado**: Cria alertas automáticos para planejar antes da elétrica

---

## Caminho B: Recebi as chaves / Planejando

### Tela 3B: Apartamento Vazio
- **Pergunta**: "O apartamento está vazio?"
- **Opções**: Sim / Não

### Tela 4B: Contratações
- **Pergunta**: "Você já contratou alguém?"
- **Opções**: Sim / Não

### Tela 5B: Projeto Existente
- **Pergunta**: "Já existe projeto?"
- **Opções**: Sim / Não

### Tela 6B: Itens Críticos
(Mesma da Tela 5A)

**Resultado**: Mapa começa em "Planejamento da Reforma"

---

## Caminho C: Obra já começou

### Tela 3C: O que já foi feito
- **Pergunta**: "O que já foi feito?"
- **Tipo**: Checklist múltipla seleção
- **Opções**:
  - `project` - "Projeto"
  - `demolition` - "Demolição"
  - `electrical` - "Elétrica"
  - `plumbing` - "Hidráulica"
  - `flooring` - "Pisos"
  - `painting` - "Pintura"
  - `carpentry` - "Marcenaria"

### Tela 4C: O que está acontecendo hoje
- **Pergunta**: "O que está acontecendo hoje?"
- **Tipo**: Seleção única
- **Opções**:
  - `electrician_working` - "Eletricista trabalhando"
  - `plumbing` - "Hidráulica"
  - `flooring` - "Pisos"
  - `painting` - "Pintura"
  - `carpentry` - "Marcenaria"
  - `finishing` - "Acabamentos"

**Resultado**: Sistema reconstrói o mapa marcando fases como concluídas

---

## Perguntas Comuns (Todos os Caminhos)

### Sobre o Imóvel

#### Tipo de Imóvel
- **Opções**:
  - `apartment_new` - "Apartamento na planta"
  - `apartment_used` - "Apartamento usado"
  - `house` - "Casa"

#### Tamanho
- **Opções**:
  - `up_to_40` - "Até 40m²"
  - `40_to_60` - "40-60m²"
  - `60_to_80` - "60-80m²"
  - `80_to_120` - "80-120m²"
  - `120_plus` - "120m²+"

#### Quartos
- **Opções**: 1, 2, 3, 4+

#### Varanda
- **Opções**: Sim / Não

#### Suíte
- **Opções**: Sim / Não

---

### Sobre Quem Vai Morar

#### Composição
- **Opções**:
  - `alone` - "Sozinho"
  - `couple` - "Casal"
  - `couple_with_kids` - "Casal com filhos"
  - `family` - "Família"
  - `investment` - "Investimento"

#### Pets
- **Opções**: Sim / Não

#### Home Office
- **Opções**: Sim / Não

---

### Prioridade Principal

#### O que é mais importante?
- **Opções**:
  - `save_money` - "Economizar"
  - `finish_fast` - "Terminar rápido"
  - `avoid_problems` - "Evitar problemas"
  - `best_finish` - "Ter melhor acabamento"
  - `control_costs` - "Controlar gastos"
  - `organize_everything` - "Organizar tudo"

**Resultado**: Influencia personalidade do app

---

## Tela Final: Resultado Personalizado

### Estrutura

```
🏠 Seu plano está pronto

Você está na etapa:
[Nome da Etapa Atual]

Faltam aproximadamente:
• X meses
• Y etapas
• R$ Z.ZZZ

⚠️ Encontramos N itens que precisam ser planejados antes da elétrica:
• Item 1
• Item 2
• Item 3

🎯 Sua próxima ação:
[Ação específica baseada no momento]

[Botão: Ir para o Mapa da Reforma]
```

---

## Persistência de Progresso

### Estratégia
1. **Local Storage** (SharedPreferences)
   - Salvar a cada resposta
   - Chave: `onboarding_progress_${userId}`
   
2. **Firestore** (backup)
   - Salvar ao completar cada tela
   - Collection: `onboarding_progress`

### Recuperação
- Ao abrir onboarding, verificar se existe progresso
- Se sim, mostrar modal:
  ```
  Você já começou o cadastro.
  Deseja continuar de onde parou?
  
  [Recomeçar] [Continuar]
  ```

---

## Estrutura de Arquivos

```
lib/features/onboarding/
├── domain/
│   ├── entities/
│   │   ├── onboarding_progress_entity.dart
│   │   └── onboarding_answer_entity.dart
│   ├── repositories/
│   │   └── onboarding_repository.dart
│   └── usecases/
│       ├── save_progress_usecase.dart
│       ├── get_progress_usecase.dart
│       └── complete_onboarding_usecase.dart
├── data/
│   ├── models/
│   │   └── onboarding_progress_model.dart
│   ├── datasources/
│   │   ├── onboarding_local_datasource.dart
│   │   └── onboarding_remote_datasource.dart
│   └── repositories/
│       └── onboarding_repository_impl.dart
└── presentation/
    ├── cubit/
    │   ├── onboarding_cubit.dart
    │   └── onboarding_state.dart
    ├── pages/
    │   ├── onboarding_welcome_page.dart
    │   ├── onboarding_current_moment_page.dart
    │   ├── onboarding_result_page.dart
    │   └── onboarding_flow_page.dart (gerencia fluxo)
    └── widgets/
        ├── onboarding_progress_bar.dart
        ├── onboarding_option_card.dart
        └── onboarding_checklist_item.dart
```

---

## Integração com Sistema Existente

### 1. Criar Projeto com Dados do Onboarding
```dart
final project = ProjectEntity(
  // ... dados básicos
  currentSituation: onboardingData.currentMoment,
  criticalItems: onboardingData.selectedCriticalItems,
  propertyType: onboardingData.propertyType,
  // ...
);
```

### 2. Personalizar Fases
- Usar `currentSituation` para determinar fase ativa
- Usar `criticalItems` para adicionar subtasks na fase de Infraestrutura
- Marcar fases como concluídas se `work_started`

### 3. Criar Alertas Automáticos
```dart
if (criticalItems.contains('air_conditioning')) {
  createAlert(
    title: 'Definir pontos de ar-condicionado',
    description: 'Antes da elétrica começar',
    priority: 'high',
  );
}
```

---

## Métricas de Sucesso

1. **Taxa de Conclusão**: > 80%
2. **Tempo Médio**: < 3 minutos
3. **Taxa de Retorno**: > 60% (usuários que saem e voltam)
4. **Satisfação**: Feedback positivo sobre clareza

---

## Próximos Passos

1. ✅ Corrigir criação de fases personalizadas
2. ⏳ Testar criação de projeto
3. 🔜 Implementar entidades de onboarding
4. 🔜 Implementar Cubit de onboarding
5. 🔜 Criar telas do novo fluxo
6. 🔜 Implementar persistência de progresso
7. 🔜 Integrar com criação de projeto
8. 🔜 Testar fluxo completo

---

**Observação Importante**: Remover "Energia Solar" das opções de itens críticos, pois não é comum para a maioria dos usuários que compraram apartamento na planta.