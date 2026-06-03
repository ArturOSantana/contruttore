# 🚨 URGENTE: Corrigir Vazamento de API Keys

## ⚠️ Problema Detectado

As API Keys do Firebase foram expostas publicamente no GitHub:
- `android/app/google-services.json` 
- `ios/GoogleService-Info.plist`

## 🔧 Solução Imediata (5 minutos)

### 1. Remover arquivos do histórico do Git

```bash
# Remover do histórico (CUIDADO: isso reescreve o histórico)
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch android/app/google-services.json ios/GoogleService-Info.plist" \
  --prune-empty --tag-name-filter cat -- --all

# Forçar push (isso sobrescreve o repositório remoto)
git push origin --force --all
git push origin --force --tags
```

**OU use a ferramenta BFG (mais rápido):**

```bash
# Instalar BFG
brew install bfg  # Mac
# ou baixe de: https://rtyley.github.io/bfg-repo-cleaner/

# Remover arquivos
bfg --delete-files google-services.json
bfg --delete-files GoogleService-Info.plist

# Limpar
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# Push forçado
git push origin --force --all
```

### 2. Regenerar API Keys no Firebase

**IMPORTANTE:** As keys expostas devem ser revogadas!

1. Acesse: https://console.firebase.google.com
2. Selecione seu projeto
3. Vá em **Project Settings** (⚙️)
4. Aba **General**
5. Role até **Your apps**
6. Para cada app (Android e iOS):
   - Clique nos 3 pontinhos → **Delete app**
   - Clique **Add app** → Recrie o app
   - Baixe os novos arquivos de configuração

### 3. Adicionar novos arquivos (localmente apenas)

```bash
# Baixe os novos arquivos do Firebase Console
# Coloque em:
# - android/app/google-services.json
# - ios/GoogleService-Info.plist

# Verifique que estão no .gitignore
git status

# Deve mostrar:
# nothing to commit (os arquivos não devem aparecer)
```

### 4. Verificar .gitignore

O `.gitignore` já foi corrigido para bloquear esses arquivos:

```gitignore
# Firebase - IMPORTANT: Never commit these files!
**/android/app/google-services.json
**/ios/GoogleService-Info.plist
```

### 5. Testar

```bash
# Tentar adicionar (deve ser ignorado)
git add android/app/google-services.json
git status

# Se aparecer no status, algo está errado!
```

## 🔐 Segurança Adicional

### Restringir API Keys no Firebase

1. Acesse: https://console.cloud.google.com
2. Selecione seu projeto
3. Menu **APIs & Services** → **Credentials**
4. Para cada API Key:
   - Clique na key
   - **Application restrictions**: Escolha "Android apps" ou "iOS apps"
   - **API restrictions**: Selecione apenas as APIs necessárias
   - Salve

### Monitorar uso

1. Firebase Console → **Usage and billing**
2. Configure alertas de uso
3. Monitore requisições suspeitas

## 📋 Checklist de Segurança

- [ ] Remover arquivos do histórico Git
- [ ] Fazer push forçado
- [ ] Deletar e recriar apps no Firebase
- [ ] Baixar novos arquivos de configuração
- [ ] Colocar arquivos localmente (não commitar!)
- [ ] Verificar que .gitignore está correto
- [ ] Restringir API Keys no Google Cloud Console
- [ ] Configurar alertas de uso
- [ ] Testar que arquivos não são commitados

## 🚀 Para o Futuro

### Use variáveis de ambiente

Em vez de commitar arquivos de configuração, use:

```dart
// lib/core/config/firebase_config.dart
class FirebaseConfig {
  static const String apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const String appId = String.fromEnvironment('FIREBASE_APP_ID');
  // ...
}
```

E passe na compilação:
```bash
flutter build apk --dart-define=FIREBASE_API_KEY=sua_key
```

### Use Firebase App Check

Protege suas APIs contra uso não autorizado:
https://firebase.google.com/docs/app-check

## ❓ Perguntas Frequentes

**Q: As keys antigas ainda funcionam?**
A: Sim, até você deletar os apps no Firebase Console.

**Q: Preciso fazer push forçado?**
A: Sim, é a única forma de remover do histórico público.

**Q: Vai quebrar algo?**
A: Não, desde que você baixe os novos arquivos de configuração.

**Q: E se alguém já clonou o repo?**
A: As keys antigas continuam expostas. Por isso é crítico regenerá-las.

## 🆘 Ajuda

Se tiver problemas, siga este guia do GitHub:
https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository

---

**AÇÃO IMEDIATA NECESSÁRIA!** 🚨