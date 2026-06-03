# ⚡ Setup Rápido - 10 Minutos

## 🎯 O que você precisa fazer:

### 1️⃣ Criar Keystore (2 min)

```bash
# No terminal, na raiz do projeto:
keytool -genkey -v -keystore android/app/keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias costruttore

# Anote as senhas que você criar!
# Store password: ________
# Key password: ________
```

### 2️⃣ Converter Keystore para Base64 (1 min)

```bash
# Mac/Linux:
base64 -i android/app/keystore.jks > keystore.txt

# Windows PowerShell:
[Convert]::ToBase64String([IO.File]::ReadAllBytes("android/app/keystore.jks")) | Out-File keystore.txt

# Abra o arquivo keystore.txt e copie TODO o conteúdo
```

### 3️⃣ Firebase Console (3 min)

1. Acesse: https://console.firebase.google.com
2. Selecione seu projeto
3. Vá em **App Distribution**
4. Clique em **Get Started**
5. Crie 2 grupos de testadores:
   - Nome: `testers-development` → Adicione seu email
   - Nome: `testers-production` → Adicione seu email

6. Vá em **Project Settings** (⚙️ no canto superior esquerdo)
7. Role até **Your apps**
8. Copie o **App ID** (formato: `1:123456789:android:abc123`)
   - Você vai precisar de 2 App IDs (development e production)
   - Se só tiver 1 app, use o mesmo ID para ambos por enquanto

### 4️⃣ Service Account do Firebase (2 min)

1. Acesse: https://console.cloud.google.com
2. Selecione seu projeto Firebase
3. Menu **IAM & Admin** → **Service Accounts**
4. Clique **Create Service Account**
   - Nome: `github-actions`
   - Role: **Firebase App Distribution Admin**
5. Clique **Create Key** → **JSON**
6. Salve o arquivo e abra com editor de texto
7. Copie **TODO** o conteúdo do JSON

### 5️⃣ GitHub Secrets (2 min)

1. Acesse: `https://github.com/SEU_USUARIO/SEU_REPO/settings/secrets/actions`
2. Clique **New repository secret** para cada um:

| Nome do Secret | Valor |
|----------------|-------|
| `KEYSTORE_BASE64` | Cole o conteúdo do keystore.txt |
| `KEY_ALIAS` | `costruttore` (ou o que você usou) |
| `KEY_PASSWORD` | A senha da chave que você criou |
| `STORE_PASSWORD` | A senha do keystore que você criou |
| `FIREBASE_SERVICE_ACCOUNT` | Cole TODO o JSON do service account |
| `FIREBASE_APP_ID_ANDROID_DEVELOPMENT` | Cole o App ID do Firebase |
| `FIREBASE_APP_ID_ANDROID_PRODUCTION` | Cole o App ID do Firebase |

## ✅ Pronto! Agora teste:

```bash
# Faça um commit e push
git add .
git commit -m "test: CI/CD setup"
git push origin develop

# Vá para: https://github.com/SEU_USUARIO/SEU_REPO/actions
# Veja o workflow executando!
```

## 📱 Receber o App

1. Verifique seu email (o que você adicionou no grupo de testadores)
2. Você receberá um convite do Firebase App Distribution
3. Aceite o convite
4. Baixe o app pelo link no email

## 🆘 Problemas?

### "Keystore not found"
- Verifique se copiou TODO o conteúdo do keystore.txt
- Não pode ter quebras de linha extras

### "Service account permissions"
- Verifique se deu a role "Firebase App Distribution Admin"

### "App ID not found"
- Verifique se copiou o App ID correto do Firebase Console
- Formato: `1:123456789:android:abc123def456`

### Não recebeu email?
- Verifique spam
- Confirme que adicionou seu email no grupo de testadores
- Aguarde alguns minutos

## 🎉 Funcionou?

Agora toda vez que você fizer push:
- **Branch main** → Build production
- **Qualquer outra branch** → Build development

Você receberá email com link para baixar o app!

---

**Dúvidas?** Leia: `CI_CD_QUICKSTART.md` ou `FIREBASE_APP_DISTRIBUTION_SETUP.md`

**Made with Bob** 🤖