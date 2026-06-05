# Especificação Técnica: Mapa da Reforma

## Visão Geral

O **Mapa da Reforma** é o módulo central do aplicativo Contruttore que transforma a experiência de gerenciar uma reforma de apartamento. Ele não é apenas mais um módulo - é o **cérebro do aplicativo** que conecta todos os outros módulos e guia o usuário leigo através de cada etapa da reforma.

## Objetivo

Substituir o módulo "Fases" por um sistema inteligente que:
- Mostra onde o usuário está na reforma
- Calcula automaticamente a próxima ação recomendada
- Monitora a saúde geral da reforma
- Integra todos os módulos existentes (Financeiro, Fornecedores, Compras, Parcelas, Documentos, Diário, Desejos)
- Traduz complexidade técnica em ações simples

## Arquitetura

### Entidades Criadas

#### 1. ReformHealthEntity
- **Propósito**: Representa a saúde geral da reforma
- **Campos principais**:
  - `healthScore` (0-100): Score geral
  - `status`: excellent | good | warning | critical
  - `factors`: Lista de fatores que contribuem para o score
  - `positivePoints`: Mensagens positivas
  - `concerns`: Preocupações identificadas

#### 2. NextActionEntity
- **Propósito**: Representa a próxima ação recomendada
- **Campos principais**:
  - `title`: Título da ação
  - `description`: Descrição detalhada
  - `type`: decision | purchase | hire | document | payment | etc
  - `priority`: critical | high | medium | low
  - `reason`: Por que esta ação é importante
  - `category`: Para navegação (financial, shopping, supplier, etc)

#### 3. ProblemEntity
- **Propósito**: Representa problemas identificados na reforma
- **Campos principais**:
  - `type`: leak | crack | defect | delay | wrongMaterial | etc
  - `severity`: critical | high | medium | low
  - `financialImpact`: Impacto financeiro
  - `delayDays`: Dias de atraso causados
  - `status`: open | inProgress | resolved | wontFix

#### 4. ReformMapEntity
- **Propósito**: Entidade principal que agrega tudo
- **Campos principais**:
  - `phases`: Lista de fases
  - `currentPhase`: Fase atual
  - `health`: Saúde da reforma
  - `nextAction`: Próxima ação recomendada
  - `openProblems`: Problemas abertos
  - `progress`: Progresso geral
  - `financial`: Snapshot financeiro
  - `positiveMessages`: Mensagens anti-ansiedade

## Integrações com Módulos Existentes

### 1. Financeiro
**O que integrar:**
- Total gasto vs orçamento
- Próximos pagamentos
- Alertas de orçamento

**Como usar no Mapa:**
- Mostrar % do orçamento usado
- Alertar se está acima de 80%
- Sugerir ação se próximo pagamento está vencendo

### 2. Fornecedores
**O que integrar:**
- Fornecedores por fase
- Orçamentos pendentes
- Contratos ativos

**Como usar no Mapa:**
- Sugerir contratação quando fase precisa de profissional
- Mostrar fornecedores relacionados à fase atual
- Alertar sobre orçamentos não respondidos

### 3. Compras
**O que integrar:**
- Itens pendentes por fase
- Compras realizadas
- Sugestões de compra

**Como usar no Mapa:**
- Sugerir compra quando fase precisa de material
- Mostrar compras relacionadas à fase atual
- Alertar sobre itens críticos faltando

### 4. Parcelas
**O que integrar:**
- Parcelas vencendo
- Parcelas atrasadas
- Total de compromissos

**Como usar no Mapa:**
- Alertar sobre parcelas vencendo nos próximos 7 dias
- Impactar saúde da reforma se há atrasos
- Sugerir ação de pagamento

### 5. Documentos
**O que integrar:**
- Documentos por fase
- Documentos faltando
- Documentos vencendo

**Como usar no Mapa:**
- Sugerir guardar documento quando fase é concluída
- Alertar sobre documentos importantes faltando
- Mostrar documentos esperados por fase

### 6. Diário
**O que integrar:**
- Registros automáticos
- Histórico de ações

**Como usar no Mapa:**
- Registrar automaticamente mudanças de fase
- Registrar ações tomadas
- Mostrar linha do tempo

### 7. Desejos
**O que integrar:**
- Itens salvos
- Associação com fases

**Como usar no Mapa:**
- Sugerir associar desejo à fase apropriada
- Alertar quando fase do desejo está próxima
- Converter desejo em compra no momento certo

## Cálculo Inteligente

### Saúde da Reforma (0-100)

**Fatores considerados:**
1. **Prazo** (peso 25%):
   - No prazo: 100
   - Até 7 dias de atraso: 80
   - 8-15 dias: 60
   - 16-30 dias: 40
   - Mais de 30 dias: 20

2. **Orçamento** (peso 30%):
   - Até 80% usado: 100
   - 81-90%: 80
   - 91-100%: 60
   - 101-110%: 40
   - Acima de 110%: 20

3. **Problemas** (peso 20%):
   - Sem problemas: 100
   - 1-2 problemas baixos: 80
   - 3+ problemas ou 1 médio: 60
   - Problema alto: 40
   - Problema crítico: 20

4. **Pendências** (peso 15%):
   - Sem pendências críticas: 100
   - 1-2 pendências: 80
   - 3-5 pendências: 60
   - 6-10 pendências: 40
   - Mais de 10: 20

5. **Pagamentos** (peso 10%):
   - Sem atrasos: 100
   - 1 parcela atrasada: 70
   - 2-3 parcelas: 40
   - Mais de 3: 20

### Próxima Ação Recomendada

**Prioridade de cálculo:**

1. **Crítico** (bloqueia tudo):
   - Parcela vencida há mais de 7 dias
   - Problema crítico aberto
   - Documento obrigatório faltando

2. **Alto** (importante):
   - Parcela vencendo em 3 dias
   - Orçamento de fornecedor pendente há mais de 7 dias
   - Compra crítica para fase atual
   - Decisão bloqueando próxima fase

3. **Médio** (normal):
   - Parcela vencendo em 7 dias
   - Compra recomendada para fase
   - Documento recomendado
   - Fornecedor para contratar

4. **Baixo** (pode esperar):
   - Desejo para associar
   - Sugestão de compra futura
   - Documentação opcional

## Interface do Usuário

### Tela Principal

```
┌─────────────────────────────────┐
│ Mapa da Reforma                 │
├─────────────────────────────────┤
│                                 │
│ 🏠 Você está em:                │
│ Instalações Elétricas           │
│ 45% concluído                   │
│                                 │
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│ 📌 Próxima ação recomendada:    │
│ Solicitar orçamento para        │
│ eletricista                     │
│                                 │
│ [Resolver agora]                │
│                                 │
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│ 💚 Saúde da Reforma: 84%        │
│ Sua reforma está no caminho     │
│ certo!                          │
│                                 │
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│ 📊 Visão Geral                  │
│                                 │
│ ✓ Planejamento                  │
│ ✓ Demolição                     │
│ ◉ Hidráulica                    │
│ ◉ Elétrica                      │
│ ○ Revestimentos                 │
│ ○ Pintura                       │
│ ○ Marcenaria                    │
│ ○ Acabamentos                   │
│ ○ Mudança                       │
│                                 │
└─────────────────────────────────┘
```

### Tela de Detalhes da Fase

```
┌─────────────────────────────────┐
│ ← Instalações Elétricas         │
├─────────────────────────────────┤
│                                 │
│ 📝 Resumo                        │
│ Status: Em andamento            │
│ Conclusão: 45%                  │
│ Prazo: 10 Jul → 18 Jul          │
│ Gasto: R$ 3.200 de R$ 7.500     │
│                                 │
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│ 💡 O que é esta etapa?          │
│ Nesta etapa são instalados os  │
│ fios, tomadas, interruptores e  │
│ quadro elétrico...              │
│                                 │
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│ 👷 Profissionais (1)            │
│ Eletricista - Orçamento         │
│ recebido                        │
│                                 │
│ 🛒 Compras (3)                  │
│ ☐ Quadro elétrico               │
│ ☐ Disjuntores                   │
│ ☐ Tomadas                       │
│                                 │
│ 📄 Documentos (1)               │
│ ⚠ ART - Faltando                │
│                                 │
│ 💰 Financeiro                   │
│ 3 parcelas restantes            │
│ Próximo: 15 de agosto           │
│                                 │
└─────────────────────────────────┘
```

## Mensagens Anti-Ansiedade

O sistema sempre mostra mensagens positivas:

- "Você já concluiu 6 de 9 etapas"
- "Sua reforma está dentro do prazo"
- "Hoje existe apenas 1 ação importante"
- "Nenhuma pendência crítica encontrada"
- "Você está 15% abaixo do orçamento"
- "Parabéns! Mais uma etapa concluída"

## Fluxo de Navegação

### Do Mapa para Módulos

1. **Próxima Ação** → Navega para o módulo apropriado
   - Exemplo: "Pagar parcela" → Tela de Parcelas
   - Exemplo: "Contratar eletricista" → Tela de Fornecedores

2. **Fase Atual** → Detalhes da fase com:
   - Fornecedores relacionados
   - Compras relacionadas
   - Documentos relacionados
   - Parcelas relacionadas

3. **Saúde da Reforma** → Detalhamento dos fatores

### Dos Módulos para o Mapa

Todos os módulos devem ter um botão "Ver no Mapa" que:
- Mostra a fase relacionada
- Destaca o item no contexto da reforma

## Implementação Técnica

### Repositórios Necessários

1. **ReformMapRepository**
   - `getReformMap(projectId)`: Retorna ReformMapEntity completo
   - `calculateHealth(projectId)`: Calcula saúde
   - `calculateNextAction(projectId)`: Calcula próxima ação
   - `getPhaseContext(phaseId)`: Retorna contexto da fase

### Use Cases Necessários

1. **GetReformMapUseCase**: Busca mapa completo
2. **CalculateHealthUseCase**: Calcula saúde
3. **CalculateNextActionUseCase**: Calcula próxima ação
4. **GetPhaseContextUseCase**: Busca contexto da fase
5. **UpdatePhaseProgressUseCase**: Atualiza progresso

### Cubit

**ReformMapCubit** gerencia:
- Estado do mapa
- Carregamento de dados
- Atualização automática
- Navegação contextual

## Benefícios

### Para o Usuário Leigo

1. **Clareza**: Sabe exatamente onde está e o que fazer
2. **Confiança**: Vê que está no caminho certo
3. **Simplicidade**: Uma ação por vez, não dezenas
4. **Contexto**: Entende por que cada ação é importante
5. **Tranquilidade**: Mensagens positivas reduzem ansiedade

### Para o Aplicativo

1. **Engajamento**: Usuário volta para ver próxima ação
2. **Retenção**: Mapa conecta todos os módulos
3. **Valor**: Transforma dados em orientação
4. **Diferencial**: Nenhum concorrente tem isso
5. **Escalabilidade**: Fácil adicionar novas integrações

## Próximos Passos

1. ✅ Criar entidades de domínio
2. ⏳ Criar repositórios e use cases
3. ⏳ Implementar lógica de cálculo
4. ⏳ Criar interface do usuário
5. ⏳ Integrar com módulos existentes
6. ⏳ Testar fluxo completo
7. ⏳ Ajustar UX baseado em feedback

## Notas de Implementação

- Usar cache para evitar recálculos constantes
- Atualizar mapa quando qualquer módulo muda
- Permitir usuário marcar ação como "não aplicável"
- Registrar todas as ações no Diário automaticamente
- Mostrar histórico de saúde da reforma (gráfico)

---

**Made with Bob** 🤖