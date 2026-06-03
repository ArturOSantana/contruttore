# Tutorial Feature

Tela de tutorial interativa para novos usuários do Costruttore.

## Estrutura

```
tutorial/
├── domain/
│   └── entities/
│       └── tutorial_step.dart          # Entidade dos passos do tutorial
├── presentation/
│   ├── pages/
│   │   └── tutorial_page.dart          # Página principal do tutorial
│   └── widgets/
│       ├── tutorial_step_content.dart  # Widget de conteúdo de cada passo
│       └── tutorial_page_indicator.dart # Indicador de progresso
└── README.md
```

## Funcionalidades

### 8 Passos Interativos

1. **Bem-vindo** - Introdução ao app
2. **Fases** - Organização por 12 fases
3. **Financeiro** - Controle de despesas e pagamentos
4. **Fornecedores** - Comparação de orçamentos
5. **Diário** - Registro fotográfico
6. **Lista de Compras** - Organização de materiais
7. **Alertas** - Notificações inteligentes
8. **Começar** - Finalização e início

### Características

- **PageView** com animações suaves
- **Indicadores de progresso** animados
- **Ícones coloridos** para cada funcionalidade
- **Highlights** dos principais recursos
- **Botão "Pular"** para usuários experientes
- **Persistência** usando SharedPreferences

## Uso

### Navegação para o Tutorial

```dart
context.go(RouteNames.tutorial);
```

### Verificar se Tutorial foi Completado

```dart
final prefs = await SharedPreferences.getInstance();
final tutorialCompleted = prefs.getBool(AppConstants.keyTutorialCompleted) ?? false;

if (!tutorialCompleted) {
  context.go(RouteNames.tutorial);
} else {
  context.go(RouteNames.login);
}
```

### Integração com Splash Screen

A splash page deve verificar se é a primeira vez do usuário e mostrar o tutorial:

```dart
// Em splash_page.dart
Future<void> _checkFirstTime() async {
  final prefs = await SharedPreferences.getInstance();
  final tutorialCompleted = prefs.getBool(AppConstants.keyTutorialCompleted) ?? false;
  
  if (!tutorialCompleted) {
    context.go(RouteNames.tutorial);
  } else {
    // Continuar fluxo normal
    _checkAuthStatus();
  }
}
```

## Personalização

### Adicionar Novos Passos

Edite `TutorialSteps.steps` em `tutorial_step.dart`:

```dart
const TutorialStep(
  title: 'Novo Recurso',
  description: 'Descrição do recurso...',
  imagePath: 'assets/tutorial/novo.png',
  iconData: 'icon_name',
  highlights: [
    'Ponto 1',
    'Ponto 2',
    'Ponto 3',
  ],
),
```

### Cores dos Ícones

As cores são definidas automaticamente baseadas na posição:
- Primeiro passo: `AppColors.primary`
- Último passo: `AppColors.success`
- Demais: Cores variadas das fases

### Ícones Disponíveis

- `home_work` - Casa/Obra
- `timeline` - Linha do tempo
- `account_balance_wallet` - Carteira
- `store` - Loja
- `photo_camera` - Câmera
- `shopping_cart` - Carrinho
- `notifications_active` - Notificações
- `rocket_launch` - Foguete

## Dependências

- `shared_preferences` - Para persistir estado do tutorial
- `go_router` - Para navegação
- Material Icons - Para ícones

## Notas

- O tutorial usa apenas ícones (sem imagens reais) para manter o app leve
- A flag `keyTutorialCompleted` é salva em SharedPreferences
- O tutorial pode ser pulado a qualquer momento
- Após completar, o usuário é direcionado para login/onboarding

## Made with Bob