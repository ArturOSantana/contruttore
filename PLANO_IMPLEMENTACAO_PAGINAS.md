# 📋 Plano de Implementação das Páginas Restantes

## 🎯 Objetivo
Implementar todas as páginas placeholder para que funcionem com dados reais do Firebase.

---

## 📊 Status Atual

### ✅ Implementado
- Home (funcional com BlocProvider)
- Onboarding (funcional)
- Auth (funcional)

### ⚠️ Pendente
1. Fases
2. Financeiro
3. Fornecedores
4. Compras (Shopping)
5. Diário
6. Parcelas (Installments/Payments)
7. Alertas

---

## 🔧 Padrão de Implementação

Para cada página, seguir este padrão:

### 1. Obter projectId do usuário atual
```dart
// No router, buscar o projectId do usuário logado
final user = await authRepository.getCurrentUser();
final projectId = user?.currentProjectId ?? '';
```

### 2. Adicionar BlocProvider na rota
```dart
GoRoute(
  path: RouteNames.pagina,
  name: 'pagina',
  builder: (context, state) => BlocProvider(
    create: (context) => getIt<PaginaCubit>()..loadData(projectId),
    child: PaginaPage(projectId: projectId),
  ),
),
```

### 3. Atualizar a página para aceitar projectId
```dart
class PaginaPage extends StatelessWidget {
  final String projectId;
  
  const PaginaPage({super.key, required this.projectId});
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaginaCubit, PaginaState>(
      builder: (context, state) {
        if (state is PaginaLoading) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (state is PaginaError) {
          return ErrorWidget(message: state.message);
        }
        
        if (state is PaginaLoaded) {
          return _buildContent(state.data);
        }
        
        return SizedBox.shrink();
      },
    );
  }
}
```

---

## 📄 Implementação Detalhada por Página

### 1. FASES (Phases)

**Arquivo:** `lib/features/phases/presentation/pages/phases_page.dart`

**Cubit:** `PhasesCubit` (já existe)
- Método: `loadPhases(String projectId)`

**UI Necessária:**
- Lista das 12 fases
- Status de cada fase (locked, active, done, done_no_record)
- Progresso visual
- Tap para ver detalhes da fase

**Dados a mostrar:**
- Nome da fase
- Número da fase (1-12)
- Status
- Subtarefas (obrigatórias e opcionais)
- Progresso (% de subtarefas concluídas)

---

### 2. FINANCEIRO (Financial)

**Arquivo:** `lib/features/financial/presentation/pages/financial_page.dart`

**Cubit:** `FinancialCubit` (já existe)
- Método: `loadFinancialData(String projectId)`

**UI Necessária:**
- Resumo geral (orçamento vs gasto)
- Gráfico de rosca por categoria
- Lista de categorias com progresso
- Botão para adicionar despesa

**Dados a mostrar:**
- Total orçado
- Total gasto (confirmed)
- Total comprometido (committed)
- Total estimado (estimated)
- Progresso por categoria
- Lista de despesas recentes

---

### 3. FORNECEDORES (Suppliers)

**Arquivo:** `lib/features/suppliers/presentation/pages/suppliers_page.dart`

**Cubit:** `SuppliersCubit` (já existe)
- Método: `loadSuppliers(String projectId)`

**UI Necessária:**
- Lista de fornecedores
- Status de cada fornecedor (active, completed, problem)
- Avaliação (estrelas)
- Botão para adicionar fornecedor

**Dados a mostrar:**
- Nome do fornecedor
- Tipo (eletricista, pedreiro, etc)
- Telefone
- Status
- Avaliação
- Fase vinculada

---

### 4. COMPRAS (Shopping)

**Arquivo:** `lib/features/shopping/presentation/pages/shopping_page.dart`

**Cubit:** `ShoppingCubit` (já existe)
- Método: `loadShoppingItems(String projectId)`

**UI Necessária:**
- Lista de itens de compra
- Filtro por fase
- Checkbox para marcar como comprado
- Total estimado vs total pago
- Botão para adicionar item

**Dados a mostrar:**
- Nome do item
- Quantidade e unidade
- Preço estimado
- Preço real (se comprado)
- Fase vinculada
- Status (comprado ou não)

---

### 5. DIÁRIO (Diary)

**Arquivo:** `lib/features/diary/presentation/pages/diary_page.dart`

**Cubit:** `DiaryCubit` (já existe)
- Método: `loadDiaryEntries(String projectId)`

**UI Necessária:**
- Timeline de entradas
- Filtro por tipo (daily, visit, problem, delivery)
- Fotos das entradas
- Botão para adicionar entrada

**Dados a mostrar:**
- Data da entrada
- Tipo
- Título
- Descrição
- Fotos
- Fase vinculada

---

### 6. PARCELAS (Installments/Payments)

**Arquivo:** `lib/features/payments/payments_page.dart`

**Cubit:** `InstallmentsCubit` (já existe)
- Método: `loadInstallments(String projectId)`

**UI Necessária:**
- Lista de contratos com parcelas
- Status de cada parcela (pago, vence em breve, vencido, futuro)
- Total pendente nos próximos 30 dias
- Botão para marcar como pago
- Botão para adicionar contrato

**Dados a mostrar:**
- Nome do fornecedor
- Descrição do serviço
- Valor total
- Número de parcelas
- Lista de cada parcela com:
  - Número
  - Valor
  - Data de vencimento
  - Status (pago/pendente)

---

### 7. ALERTAS (Alerts)

**Arquivo:** `lib/features/alerts/presentation/pages/alerts_page.dart`

**Cubit:** `AlertsCubit` (já existe)
- Método: `loadAlerts(String projectId)`

**UI Necessária:**
- Lista de alertas
- Filtro por tipo (critical, preventive, info, educational)
- Marcar como lido
- Ação do alerta (navegar para tela relacionada)

**Dados a mostrar:**
- Tipo do alerta (ícone e cor)
- Título
- Mensagem
- Data de criação
- Status (lido/não lido)
- Rota de ação (se houver)

---

## 🔄 Ordem de Implementação Sugerida

1. **Fases** - Mais simples, apenas lista
2. **Alertas** - Simples, apenas lista
3. **Compras** - Lista com checkbox
4. **Fornecedores** - Lista com avaliação
5. **Parcelas** - Lista com status complexo
6. **Diário** - Timeline com fotos
7. **Financeiro** - Mais complexo, com gráficos

---

## 🛠️ Ferramentas e Widgets Necessários

### Widgets Comuns (criar em `lib/core/widgets/`)
1. `loading_widget.dart` - Shimmer ou CircularProgressIndicator
2. `error_widget.dart` - Tela de erro com botão de retry
3. `empty_state_widget.dart` - Tela vazia com ilustração e CTA
4. `status_badge.dart` - Badge colorido para status
5. `progress_bar.dart` - Barra de progresso customizada

### Packages Úteis
- `fl_chart` - Para gráficos (já no pubspec)
- `shimmer` - Para loading states (já no pubspec)
- `cached_network_image` - Para fotos (já no pubspec)

---

## ⚠️ Pontos de Atenção

### 1. ProjectId Obrigatório
TODAS as páginas precisam receber `projectId` como parâmetro obrigatório.

### 2. BlocProvider no Router
TODAS as rotas precisam ter BlocProvider configurado.

### 3. Estados do Cubit
Sempre tratar os 3 estados:
- Loading
- Error
- Loaded

### 4. Empty State
Sempre mostrar empty state quando não houver dados.

### 5. Pull to Refresh
Adicionar RefreshIndicator em todas as listas.

---

## 📝 Checklist de Implementação

Para cada página:
- [ ] Atualizar a classe da página para aceitar `projectId`
- [ ] Adicionar BlocProvider na rota
- [ ] Implementar UI com BlocBuilder
- [ ] Tratar estado Loading
- [ ] Tratar estado Error
- [ ] Tratar estado Loaded
- [ ] Adicionar Empty State
- [ ] Adicionar Pull to Refresh
- [ ] Testar navegação
- [ ] Testar carregamento de dados
- [ ] Testar com dados vazios

---

## 🚀 Próximos Passos

1. Implementar página de Fases (exemplo completo)
2. Usar o padrão da página de Fases para implementar as outras
3. Testar cada página após implementação
4. Ajustar UI conforme necessário

---

**Nota:** Este documento serve como guia para implementação. Cada página deve seguir o padrão estabelecido para manter consistência no código.