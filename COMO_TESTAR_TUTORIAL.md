# 🎓 Como Testar o Tutorial - 2 Minutos

## ✅ O tutorial JÁ ESTÁ FUNCIONANDO!

Você não precisa configurar nada. Basta rodar o app!

## 🚀 Passo a Passo:

### 1. Limpar dados do app (para simular primeiro acesso)

```bash
# No terminal:
flutter clean
flutter pub get
```

### 2. Rodar o app

```bash
# Android:
flutter run

# Ou escolha o dispositivo:
flutter devices
flutter run -d <device-id>
```

### 3. O que vai acontecer:

1. **Splash Screen** aparece
2. **Tutorial** abre automaticamente (8 telas interativas)
3. Você pode:
   - Navegar com os botões "Próximo" e "Anterior"
   - Pular o tutorial clicando em "Pular"
   - Ver o progresso com os indicadores na parte inferior
4. Ao finalizar, vai para a tela de login

### 4. Testar novamente (sem tutorial)

Depois de completar o tutorial uma vez, ele não aparece mais!

Para ver o tutorial novamente:

**Opção A - Desinstalar o app:**
```bash
# Android
adb uninstall com.example.contruttore

# Depois rodar novamente
flutter run
```

**Opção B - Limpar dados do app no dispositivo:**
- Configurações → Apps → Contruttore → Limpar dados

**Opção C - Forçar tutorial (para desenvolvimento):**
Edite `lib/features/auth/presentation/pages/splash_page.dart`:

```dart
// Linha ~45, mude de:
final tutorialCompleted = box.get(AppConstants.keyTutorialCompleted, defaultValue: false);

// Para:
final tutorialCompleted = false; // Sempre mostra tutorial
```

## 📱 O que você vai ver no Tutorial:

1. **Bem-vindo** - Introdução ao app
2. **Projetos** - Como gerenciar obras
3. **Diário de Obra** - Registro diário
4. **Financeiro** - Controle de gastos
5. **Fornecedores** - Comparação de preços
6. **Lista de Desejos** - Planejamento de compras
7. **Fases da Obra** - Acompanhamento
8. **Alertas** - Notificações importantes

Cada tela tem:
- ✨ Ícone ilustrativo
- 📝 Título e descrição
- 🎯 Destaques dos recursos
- ⏭️ Navegação fácil

## 🎨 Personalizar o Tutorial

Quer mudar os textos ou adicionar mais telas?

Edite: `lib/features/tutorial/domain/entities/tutorial_step.dart`

```dart
static final List<TutorialStep> steps = [
  TutorialStep(
    title: 'Seu Título',
    description: 'Sua descrição',
    icon: Icons.seu_icone,
    highlights: [
      'Destaque 1',
      'Destaque 2',
    ],
  ),
  // Adicione mais steps aqui...
];
```

## 🐛 Problemas?

### Tutorial não aparece?
- Verifique se limpou os dados do app
- Confirme que é a primeira vez rodando

### Erro de compilação?
```bash
flutter clean
flutter pub get
flutter run
```

### Quer desabilitar o tutorial temporariamente?
Comente a verificação em `splash_page.dart`:

```dart
// if (!tutorialCompleted) {
//   context.go(RouteNames.tutorial);
//   return;
// }
```

## 🎉 Pronto!

O tutorial está funcionando e aparecerá automaticamente para todos os novos usuários!

**Não precisa configurar nada de CI/CD ou Firebase para testar o tutorial.**

---

**Dúvidas?** O tutorial é 100% local, usa apenas Hive para salvar que foi completado.