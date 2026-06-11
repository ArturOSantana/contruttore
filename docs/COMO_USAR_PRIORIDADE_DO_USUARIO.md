# Como Usar a Prioridade do Usuário no App

## Contexto

Durante o onboarding, perguntamos ao usuário: **"O que é mais importante para você?"**

Esta não é apenas uma pergunta de pesquisa. É uma configuração que deve **personalizar toda a experiência** do usuário no app.

---

## As 6 Prioridades

### 1. **Economizar** (`save_money`)
**Foco**: Gastar o mínimo possível

**Como o app deve se comportar:**

- **Home**: Destacar oportunidades de economia
  - "Você pode economizar R$ 2.500 comprando material direto"
  - "3 fornecedores com preços 20% abaixo da média"

- **Alertas**: Priorizar avisos de desperdício
  - "⚠️ Você está pagando 30% a mais neste item"
  - "💡 Dica: Compre cimento em atacado e economize R$ 800"

- **Comparação de Orçamentos**: Sempre mostrar a opção mais barata em destaque

- **Sugestões**: Recomendar alternativas mais baratas
  - "Considere piso laminado ao invés de porcelanato (economia de R$ 4.000)"

---

### 2. **Terminar Rápido** (`finish_fast`)
**Foco**: Mudar o quanto antes

**Como o app deve se comportar:**

- **Home**: Mostrar prazo estimado em destaque
  - "🏃 Faltam 45 dias para conclusão"
  - "Você está 3 dias atrasado no cronograma"

- **Alertas**: Priorizar avisos de atraso
  - "⚠️ Eletricista atrasado há 2 dias"
  - "🚨 Esta etapa pode atrasar a obra em 1 semana"

- **Próximas Ações**: Focar em tarefas críticas do caminho crítico
  - "Urgente: Aprovar projeto elétrico hoje para não atrasar"

- **Sugestões**: Recomendar soluções mais rápidas
  - "Use piso vinílico (instalação em 2 dias) ao invés de porcelanato (7 dias)"

---

### 3. **Evitar Problemas** (`avoid_problems`)
**Foco**: Sem dor de cabeça

**Como o app deve se comportar:**

- **Home**: Destacar riscos e prevenções
  - "🛡️ 2 itens precisam de atenção para evitar problemas"
  - "Tudo sob controle - nenhum risco identificado"

- **Alertas**: Priorizar avisos preventivos
  - "⚠️ Defina pontos de ar-condicionado ANTES da elétrica"
  - "💡 Contrate seguro de obra (R$ 300) para evitar prejuízos"

- **Checklist**: Mostrar itens de validação em destaque
  - "✓ Verificar se a parede está nivelada antes de assentar azulejo"
  - "✓ Testar todos os pontos elétricos antes de fechar parede"

- **Fornecedores**: Destacar avaliações e confiabilidade
  - "⭐ 4.8/5 - 95% de entregas no prazo"
  - "🏆 Recomendado por 12 usuários do app"

---

### 4. **Melhor Acabamento** (`best_finish`)
**Foco**: Qualidade acima de tudo

**Como o app deve se comportar:**

- **Home**: Destacar qualidade dos materiais
  - "✨ 3 itens premium selecionados"
  - "Seu projeto está 85% com materiais de alta qualidade"

- **Sugestões**: Recomendar opções premium
  - "Considere porcelanato retificado (melhor acabamento)"
  - "Tinta premium dura 2x mais e tem melhor cobertura"

- **Comparação**: Destacar qualidade, não apenas preço
  - "Este fornecedor usa materiais 20% superiores"
  - "Acabamento profissional garantido"

- **Alertas**: Avisar sobre economias que comprometem qualidade
  - "⚠️ Este material mais barato pode descascar em 2 anos"

---

### 5. **Controlar Gastos** (`control_costs`)
**Foco**: Saber onde vai cada centavo

**Como o app deve se comportar:**

- **Home**: Dashboard financeiro em destaque
  - "💰 Gastos: R$ 45.230 / R$ 80.000 (56%)"
  - "Você está R$ 2.500 abaixo do orçamento"

- **Relatórios**: Gráficos detalhados de gastos
  - Por categoria (material, mão de obra, etc)
  - Por etapa da obra
  - Comparativo: planejado vs realizado

- **Alertas**: Avisos de desvio de orçamento
  - "⚠️ Categoria 'Elétrica' 15% acima do previsto"
  - "💡 Você pode realocar R$ 3.000 de 'Pintura' para 'Piso'"

- **Pagamentos**: Rastreamento detalhado
  - Histórico completo de cada pagamento
  - Comprovantes anexados
  - Status de cada parcela

---

### 6. **Organizar Tudo** (`organize_everything`)
**Foco**: Ter tudo documentado

**Como o app deve se comportar:**

- **Home**: Destacar completude da documentação
  - "📋 Documentação: 78% completa"
  - "Faltam 3 documentos importantes"

- **Diário de Obra**: Incentivar registros diários
  - "📸 Registre o progresso de hoje"
  - "Última foto há 3 dias - tire uma foto hoje"

- **Checklist**: Listas detalhadas e completas
  - Todos os itens, mesmo os pequenos
  - Subitens e validações

- **Alertas**: Avisos sobre documentação faltante
  - "⚠️ Adicione nota fiscal da compra de cimento"
  - "💡 Tire foto do quadro elétrico antes de fechar"

- **Fornecedores**: Manter contratos e documentos
  - "Anexe contrato do eletricista"
  - "Salve orçamentos para comparação futura"

---

## Implementação Técnica

### 1. Salvar no Projeto

Quando o projeto é criado após o onboarding, salvar:

```dart
final project = ProjectEntity(
  // ... outros campos
  userPriority: progress.mainPriority, // 'save_money', 'finish_fast', etc
);
```

### 2. Usar na Home

```dart
// No HomeCubit
void _loadDashboard() {
  final priority = currentProject.userPriority;
  
  switch (priority) {
    case 'save_money':
      _highlightSavingsOpportunities();
      break;
    case 'finish_fast':
      _highlightDeadlines();
      break;
    case 'avoid_problems':
      _highlightRisks();
      break;
    // ... outros casos
  }
}
```

### 3. Personalizar Alertas

```dart
// No AlertsService
List<Alert> getPrioritizedAlerts(String userPriority) {
  final allAlerts = getAllAlerts();
  
  // Ordenar alertas baseado na prioridade do usuário
  return allAlerts.sorted((a, b) {
    final scoreA = _getAlertScore(a, userPriority);
    final scoreB = _getAlertScore(b, userPriority);
    return scoreB.compareTo(scoreA);
  });
}

int _getAlertScore(Alert alert, String priority) {
  if (priority == 'save_money' && alert.type == AlertType.savings) {
    return 100;
  }
  if (priority == 'finish_fast' && alert.type == AlertType.deadline) {
    return 100;
  }
  // ... outros casos
  return 50; // score padrão
}
```

### 4. Adaptar Sugestões

```dart
// No SuggestionsService
List<Suggestion> getPersonalizedSuggestions(String userPriority) {
  switch (userPriority) {
    case 'save_money':
      return [
        Suggestion(
          title: 'Economize R$ 2.500',
          description: 'Compre material direto da fábrica',
          icon: Icons.savings,
        ),
        // ...
      ];
    case 'finish_fast':
      return [
        Suggestion(
          title: 'Acelere a obra',
          description: 'Contrate mais um ajudante',
          icon: Icons.speed,
        ),
        // ...
      ];
    // ... outros casos
  }
}
```

---

## Benefícios

✅ **Experiência Personalizada**: Cada usuário vê o que é mais importante para ele

✅ **Maior Engajamento**: O app se torna mais relevante

✅ **Melhor Retenção**: Usuário sente que o app "entende" suas necessidades

✅ **Diferencial Competitivo**: Poucos apps fazem isso bem

---

## Próximos Passos

1. ✅ Salvar `mainPriority` no `ProjectEntity`
2. ⏳ Implementar lógica de priorização na Home
3. ⏳ Adaptar sistema de alertas
4. ⏳ Personalizar sugestões
5. ⏳ Criar badges visuais baseados na prioridade
6. ⏳ A/B test para validar impacto

---

**Lembre-se**: A prioridade não é apenas um dado. É a **personalidade do app** para aquele usuário.