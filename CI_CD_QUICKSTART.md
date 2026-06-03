# 🚀 CI/CD Quick Start - Costruttore

Guia rápido para configurar o CI/CD com Firebase App Distribution.

## ⚡ Setup Rápido (5 minutos)

### 1. Execute o Script de Setup
```bash
./scripts/setup-firebase-distribution.sh
```

### 2. Configure GitHub Secrets

Acesse: `Settings > Secrets and variables > Actions`

| Secret | Onde Obter |
|--------|------------|
| `KEYSTORE_BASE64` | Gerado pelo script ou converta manualmente |
| `KEY_ALIAS` | Nome usado ao criar keystore (padrão: costruttore) |
| `KEY_PASSWORD` | Senha da chave do keystore |
| `STORE_PASSWORD` | Senha do keystore |
| `FIREBASE_SERVICE_ACCOUNT` | Google Cloud Console > Service Accounts |
| `FIREBASE_APP_ID_ANDROID_STAGING` | Firebase Console > Project Settings |
| `FIREBASE_APP_ID_ANDROID_PRODUCTION` | Firebase Console > Project Settings |

### 3. Configure Firebase Console

1. Acesse [Firebase Console](https://console.firebase.google.com)
2. Vá em `App Distribution`
3. Crie grupos de testadores:
   - `testers-staging`
   - `testers-production`

### 4. Teste o Workflow

```bash
# Criar branch de teste
git checkout -b test/ci-cd

# Commit e push
git add .
git commit -m "test: CI/CD setup"
git push origin test/ci-cd

# Criar Pull Request no GitHub
```

## 📦 Comandos Úteis

### Build Local
```bash
# Debug
flutter build apk --debug --flavor development

# Staging
flutter build apk --release --flavor staging

# Production
flutter build apk --release --flavor production
```

### Distribuição Manual
```bash
# Via Firebase CLI
firebase appdistribution:distribute \
  build/app/outputs/flutter-apk/app-production-release.apk \
  --app YOUR_APP_ID \
  --groups "testers-production"
```

### Converter Keystore para Base64
```bash
# Linux/Mac
base64 -i android/app/keystore.jks > keystore.base64.txt

# Windows PowerShell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("android/app/keystore.jks")) | Out-File keystore.base64.txt
```

## 🔄 Fluxo Automático

| Ação | Resultado |
|------|-----------|
| Push para `main` | Build production + Firebase Distribution |
| Push para `develop` | Build staging + Firebase Distribution |
| Pull Request | Build debug (sem distribuição) |
| Manual trigger | Build conforme branch selecionada |

## 🔒 Checklist de Segurança

- [ ] Keystore NÃO está no repositório
- [ ] `android/key.properties` está no .gitignore
- [ ] Service Account JSON NÃO está no repositório
- [ ] Todos os secrets configurados no GitHub
- [ ] `.env` files estão no .gitignore
- [ ] Senhas anotadas em local seguro

## 📚 Documentação Completa

Para informações detalhadas, consulte:
- [FIREBASE_APP_DISTRIBUTION_SETUP.md](./FIREBASE_APP_DISTRIBUTION_SETUP.md)
- [DEPLOY_GUIDE.md](./DEPLOY_GUIDE.md)

## 🐛 Problemas Comuns

### Build falha: "Keystore not found"
```bash
# Verifique se o secret KEYSTORE_BASE64 está configurado
# Verifique o formato do Base64 (sem quebras de linha)
```

### Build falha: "Service account permissions"
```bash
# Service Account precisa da role:
# "Firebase App Distribution Admin"
```

### APK não aparece no Firebase
```bash
# Verifique se o App ID está correto
# Verifique se os grupos de testadores existem
# Veja os logs do workflow no GitHub Actions
```

## 🎯 Próximos Passos

1. [ ] Configurar versionamento automático
2. [ ] Adicionar changelog automático
3. [ ] Configurar notificações de build
4. [ ] Implementar testes automatizados
5. [ ] Adicionar build iOS

## 📞 Suporte

- Issues: [GitHub Issues](https://github.com/SEU_USUARIO/SEU_REPO/issues)
- Docs: [Firebase App Distribution](https://firebase.google.com/docs/app-distribution)

---

**Made with Bob** 🤖