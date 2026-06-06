# Como Corrigir o Erro de firebase_options.dart no CI/CD

## 🔴 Problema

O build no CI/CD está falando com o erro:
```
lib/main.dart:9:8: Error: Error when reading 'lib/firebase_options.dart': No such file or directory
```

## 🔍 Causa

O arquivo `lib/firebase_options.dart` existe localmente mas está **incompleto**. Ele foi gerado pelo FlutterFire CLI mas faltam as configurações específicas de Android e iOS.

## ✅ Solução

### Opção 1: Regenerar o Arquivo Completo (Recomendado)

1. **Instalar o FlutterFire CLI:**
```bash
dart pub global activate flutterfire_cli
```

2. **Configurar o Firebase:**
```bash
flutterfire configure
```

3. **Selecionar as plataformas:**
   - Android
   - iOS

4. **O comando irá:**
   - Conectar ao seu projeto Firebase
   - Gerar o arquivo `lib/firebase_options.dart` completo
   - Incluir todas as configurações necessárias

### Opção 2: Adicionar Configurações Manualmente

Se você já tem as configurações do Firebase, adicione-as ao arquivo `lib/firebase_options.dart`:

```dart
// Adicione após a linha 50:

static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'SUA_API_KEY_ANDROID',
  appId: 'SEU_APP_ID_ANDROID',
  messagingSenderId: 'SEU_SENDER_ID',
  projectId: 'SEU_PROJECT_ID',
  storageBucket: 'SEU_STORAGE_BUCKET',
);

static const FirebaseOptions ios = FirebaseOptions(
  apiKey: 'SUA_API_KEY_IOS',
  appId: 'SEU_APP_ID_IOS',
  messagingSenderId: 'SEU_SENDER_ID',
  projectId: 'SEU_PROJECT_ID',
  storageBucket: 'SEU_STORAGE_BUCKET',
  iosBundleId: 'SEU_BUNDLE_ID',
);
```

### Opção 3: Usar Secrets no GitHub Actions

Para CI/CD, você pode usar GitHub Secrets:

1. **Criar o arquivo completo localmente**
2. **Adicionar ao .gitignore** (se contém dados sensíveis)
3. **Criar um GitHub Secret:**
   - Nome: `FIREBASE_OPTIONS`
   - Valor: Conteúdo completo do arquivo

4. **Modificar o workflow do GitHub Actions:**

```yaml
- name: Create firebase_options.dart
  run: |
    echo "${{ secrets.FIREBASE_OPTIONS }}" > lib/firebase_options.dart
```

## 🔐 Segurança

### Dados Sensíveis no firebase_options.dart

O arquivo `firebase_options.dart` contém:
- ✅ **API Keys** - Podem ser públicas (têm restrições no Firebase Console)
- ✅ **App IDs** - Podem ser públicos
- ✅ **Project ID** - Pode ser público

**Recomendação:** Você PODE commitar o arquivo no Git, pois as API Keys do Firebase são protegidas por:
- Restrições de domínio
- Restrições de pacote (Android)
- Restrições de Bundle ID (iOS)

## 📝 Checklist de Verificação

- [ ] Arquivo `lib/firebase_options.dart` existe
- [ ] Contém configurações para Android
- [ ] Contém configurações para iOS
- [ ] Arquivo está commitado no Git (ou configurado como secret)
- [ ] Build local funciona
- [ ] Build no CI/CD funciona

## 🚀 Comandos Rápidos

### Verificar se o arquivo está completo:
```bash
cat lib/firebase_options.dart | grep "static const FirebaseOptions android"
cat lib/firebase_options.dart | grep "static const FirebaseOptions ios"
```

### Testar o build localmente:
```bash
flutter clean
flutter pub get
flutter build apk --release
```

### Verificar no CI/CD:
```bash
# O arquivo deve estar presente no repositório
git ls-files | grep firebase_options.dart
```

## 🔗 Links Úteis

- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/)
- [Firebase Console](https://console.firebase.google.com/)
- [Configurar Firebase no Flutter](https://firebase.flutter.dev/docs/overview)

## 📞 Suporte

Se o problema persistir:
1. Verifique se o projeto Firebase está configurado corretamente
2. Confirme que as plataformas Android e iOS estão habilitadas no Firebase Console
3. Execute `flutterfire configure` novamente
4. Verifique os logs do CI/CD para mais detalhes

---

**Nota:** Este erro NÃO está relacionado ao Mapa da Reforma. É um problema de configuração do Firebase que precisa ser resolvido antes de qualquer build.