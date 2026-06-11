# 🗺️ Redesign do Mapa da Reforma

## 🎯 Problema Identificado

**"Não sei por onde começar quando abro o mapa"**

### Problemas Atuais:
1. ❌ Todas as 9 fases aparecem iguais
2. ❌ Não fica claro qual é a fase atual
3. ❌ Não há um "call to action" claro
4. ❌ Usuário precisa rolar e procurar informação
5. ❌ Falta hierarquia visual

---

## ✅ Solução Proposta

### Estrutura Visual Nova

```
┌─────────────────────────────────────────┐
│  🎯 SUA PRÓXIMA AÇÃO                    │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│  Definir orçamento da reforma           │
│  📍 Planejamento da Reforma             │
│  [Começar Agora →]                      │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  📍 VOCÊ ESTÁ AQUI                      │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│  Fase 1: Planejamento da Reforma        │
│  ████████░░ 80% concluído               │
│  4 de 5 tarefas completas               │
│  [Ver Detalhes]                         │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  ✅ FASES CONCLUÍDAS (0)                │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│  Nenhuma fase concluída ainda           │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  🔒 PRÓXIMAS FASES (8)                  │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│  2. Aprovações e Preparação             │
│  3. Demolição e Remoções                │
│  4. Infraestrutura (Elétrica/Hidráulica)│
│  ... (ver todas)                        │
└─────────────────────────────────────────┘
```

---

## 🎨 Hierarquia Visual

### 1. Topo: Próxima Ação (HERO)
- **Tamanho**: Grande, destaque máximo
- **Cor**: Gradiente chamativo (laranja/amarelo)
- **Conteúdo**: 
  - Ação específica (ex: "Definir orçamento")
  - Fase relacionada
  - Botão de ação primário
- **Objetivo**: Responder "O que eu faço AGORA?"

### 2. Fase Atual (DESTAQUE)
- **Tamanho**: Médio-grande
- **Cor**: Azul/roxo (cor primária)
- **Conteúdo**:
  - Nome da fase
  - Progresso visual (barra)
  - Tarefas completas/total
  - Botão para ver detalhes
- **Objetivo**: Responder "Onde eu estou?"

### 3. Fases Concluídas (SUCESSO)
- **Tamanho**: Compacto, colapsável
- **Cor**: Verde
- **Conteúdo**:
  - Lista de fases concluídas
  - Data de conclusão
  - Celebração visual
- **Objetivo**: Mostrar progresso

### 4. Próximas Fases (FUTURO)
- **Tamanho**: Compacto, colapsável
- **Cor**: Cinza (desabilitado)
- **Conteúdo**:
  - Lista de fases futuras
  - Ícone de cadeado
  - Dependências
- **Objetivo**: Mostrar o caminho

---

## 🔄 Lógica de Ordenação

### Regras de Exibição:

1. **Próxima Ação** (sempre visível)
   - Primeira tarefa não concluída da fase atual
   - Se fase atual 100% → primeira tarefa da próxima fase

2. **Fase Atual** (sempre visível)
   - Primeira fase com status `inProgress`
   - Se nenhuma `inProgress` → primeira fase `notStarted`

3. **Fases Concluídas** (colapsável)
   - Todas com status `completed`
   - Ordenadas por data de conclusão (mais recente primeiro)
   - Inicialmente colapsado se > 2 fases

4. **Próximas Fases** (colapsável)
   - Todas com status `notStarted` ou `locked`
   - Ordenadas por número da fase
   - Inicialmente colapsado se > 3 fases

---

## 📱 Interações

### Card "Próxima Ação"
- **Tap no card**: Abre detalhes da tarefa
- **Tap no botão**: Marca tarefa como concluída OU abre formulário
- **Swipe left**: Adiar para depois
- **Swipe right**: Marcar como concluída

### Card "Fase Atual"
- **Tap**: Abre página de detalhes da fase
- **Tap na barra de progresso**: Mostra breakdown das tarefas
- **Long press**: Menu de ações rápidas

### Seções Colapsáveis
- **Tap no header**: Expandir/colapsar
- **Estado salvo**: Lembrar preferência do usuário

---

## 🎯 Integração com Onboarding

### Dados do Onboarding que Afetam o Mapa:

1. **Momento Atual** (`currentMoment`)
   - `notReceivedKeys` → Fase 1 bloqueada, mostrar preparação
   - `receivedRecently` → Fase 1 ativa
   - `planning` → Fase 1 ativa
   - `workStarted` → Detectar fase atual automaticamente
   - `finishing` → Fases finais ativas
   - `living` → Modo mudança ativo

2. **Itens Críticos** (`criticalItems`)
   - Criar alertas automáticos nas fases relevantes
   - Ex: "Ar-condicionado" → Alerta na Fase 4 (Infraestrutura)

3. **Prioridade Principal** (`mainPriority`)
   - `save_money` → Destacar alternativas econômicas
   - `finish_fast` → Mostrar cronograma agressivo
   - `avoid_problems` → Destacar riscos e cuidados
   - `best_finish` → Sugerir acabamentos premium
   - `control_spending` → Enfatizar orçamento
   - `organize_all` → Mostrar checklists completos

---

## 🚀 Implementação

### Fase 1: Redesign Visual
- [ ] Criar widget `NextActionHeroCard`
- [ ] Criar widget `CurrentPhaseCard` melhorado
- [ ] Criar widget `CompletedPhasesSection` colapsável
- [ ] Criar widget `UpcomingPhasesSection` colapsável
- [ ] Atualizar `PhasesPage` com nova estrutura

### Fase 2: Lógica Inteligente
- [ ] Criar `PhaseOrderingService`
- [ ] Implementar detecção automática de fase atual
- [ ] Implementar cálculo de próxima ação
- [ ] Integrar com dados do onboarding

### Fase 3: Interações
- [ ] Implementar gestos de swipe
- [ ] Implementar colapsar/expandir seções
- [ ] Salvar preferências do usuário
- [ ] Adicionar animações de transição

### Fase 4: Testes
- [ ] Testar com usuário novo (fase 1)
- [ ] Testar com obra em andamento (fase 5)
- [ ] Testar com obra quase pronta (fase 9)
- [ ] Testar transições entre fases

---

## 📊 Métricas de Sucesso

### Antes (Problema):
- ❌ Usuário não sabe por onde começar
- ❌ Precisa rolar para encontrar informação
- ❌ Não fica claro o que fazer

### Depois (Solução):
- ✅ Próxima ação visível em 0 segundos
- ✅ Fase atual destacada visualmente
- ✅ Hierarquia clara: Agora → Atual → Passado → Futuro
- ✅ Usuário sabe exatamente o que fazer

---

## 🎨 Referências Visuais

### Inspirações:
- **Duolingo**: Caminho de aprendizado com fase atual destacada
- **Trello**: Cards com progresso visual
- **Todoist**: Próxima tarefa em destaque
- **Habitica**: Gamificação de progresso

### Cores:
- **Próxima Ação**: Gradiente laranja/amarelo (urgência + otimismo)
- **Fase Atual**: Azul/roxo (foco + confiança)
- **Concluídas**: Verde (sucesso)
- **Futuras**: Cinza claro (neutro)

---

## 📝 Notas de Implementação

### Prioridade Alta:
1. Card "Próxima Ação" no topo
2. Card "Fase Atual" destacado
3. Seções colapsáveis

### Prioridade Média:
4. Integração com onboarding
5. Gestos de swipe
6. Animações

### Prioridade Baixa:
7. Gamificação
8. Celebrações
9. Conquistas

---

**Criado em**: 2026-06-10
**Problema**: Usuário não sabe por onde começar
**Solução**: Hierarquia visual clara com próxima ação em destaque