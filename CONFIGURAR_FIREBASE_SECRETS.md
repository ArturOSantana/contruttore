# 🔐 Configurar Secrets do Firebase para CI/CD

## ❌ Erro Atual
```
Error: Failed to authenticate, have you run firebase login?
```

**Causa:** Faltam os secrets `FIREBASE_APP_ID` e `FIREBASE_SERVICE_ACCOUNT` no GitHub.

## ✅ Solução: Configurar 2 Secrets

### 1️⃣ FIREBASE_APP_ID

#### Como Encontrar:
1. Acesse: https://console.firebase.google.com
2. Selecione o projeto **"contruttore"**
3. Clique no ícone de engrenagem ⚙️ → **Project Settings**
4. Role até a seção **"Your apps"**
5. Encontre o app Android
6. Copie o **App ID** (formato: `1:123456789:android:abc123def456...`)

#### Como Adicionar no GitHub:
1. Vá em: https://github.com/ArturOSantana/contruttore/settings/secrets/actions
2. Clique em **"New repository secret"**
3. Preencha:
   - **Name:** `FIREBASE_APP_ID`
   - **Secret:** Cole o App ID copiado
4. Clique em **"Add secret"**

---

### 2️⃣ FIREBASE_SERVICE_ACCOUNT

#### Como Criar a Service Account:

**Passo 1: Acessar IAM & Admin**
1. Acesse: https://console.cloud.google.com
2. Selecione o projeto **"contruttore"**
3. No menu lateral, vá em: **IAM & Admin** → **Service Accounts**

**Passo 2: Criar Service Account**
1. Clique em **"+ CREATE SERVICE ACCOUNT"**
2. Preencha:
   - **Service account name:** `github-actions-firebase`
   - **Service account ID:** (será preenchido automaticamente)
   - **Description:** `Service account for GitHub Actions to deploy to Firebase App Distribution`
3. Clique em **"CREATE AND CONTINUE"**

**Passo 3: Adicionar Permissões**
1. Na seção **"Grant this service account access to project"**
2. Adicione o role: **Firebase App Distribution Admin**
3. Clique em **"CONTINUE"**
4. Clique em **"DONE"**

**Passo 4: Criar Chave JSON**
1. Na lista de Service Accounts, encontre a que você criou
2. Clique nos 3 pontinhos (⋮) → **"Manage keys"**
3. Clique em **"ADD KEY"** → **"Create new key"**
4. Selecione **JSON**
5. Clique em **"CREATE"**
6. Um arquivo JSON será baixado automaticamente

**Passo 5: Copiar Conteúdo do JSON**
1. Abra o arquivo JSON baixado em um editor de texto
2. Copie **TODO** o conteúdo (incluindo as chaves `{` e `}`)
3. O conteúdo deve ser algo assim:
```json
{
  "type": "service_account",
  "project_id": "contruttore-xxxxx",
  "private_key_id": "abc123...",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
  "client_email": "github-actions-firebase@contruttore-xxxxx.iam.gserviceaccount.com",
  "client_id": "123456789...",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/..."
}
```

#### Como Adicionar no GitHub:
1. Vá em: https://github.com/ArturOSantana/contruttore/settings/secrets/actions
2. Clique em **"New repository secret"**
3. Preencha:
   - **Name:** `FIREBASE_SERVICE_ACCOUNT`
   - **Secret:** Cole **TODO** o conteúdo do JSON
4. Clique em **"Add secret"**

---

## 3️⃣ Configurar Grupo de Testadores (Opcional mas Recomendado)

1. Acesse: https://console.firebase.google.com
2. Selecione o projeto **"contruttore"**
3. No menu lateral, vá em: **App Distribution**
4. Clique na aba **"Testers & Groups"**
5. Clique em **"Add group"**
6. Nome do grupo: `testers`
7. Adicione emails dos testadores
8. Clique em **"Save"**

---

## ✅ Verificar Configuração

Após adicionar os 2 secrets:

1. Vá em: https://github.com/ArturOSantana/contruttore/settings/secrets/actions
2. Você deve ver:
   - ✅ `FIREBASE_APP_ID`
   - ✅ `FIREBASE_SERVICE_ACCOUNT`

---

## 🚀 Testar o Deploy

Após configurar os secrets:

```bash
# Fazer qualquer mudança (pode ser só um comentário)
git commit --allow-empty -m "test: trigger Firebase App Distribution"
git push origin main
```

Acompanhe em: https://github.com/ArturOSantana/contruttore/actions

---

## 🎯 Resultado Esperado

Após o push, o workflow deve:
1. ✅ Fazer build do APK
2. ✅ Autenticar no Firebase (usando o service account)
3. ✅ Fazer upload para Firebase App Distribution
4. ✅ Notificar testadores por email

---

## 🐛 Troubleshooting

### Erro: "Failed to authenticate"
- ❌ Secret `FIREBASE_SERVICE_ACCOUNT` não configurado
- ❌ JSON da service account inválido
- ❌ Service account sem permissões corretas

**Solução:** Verifique se:
1. O secret existe no GitHub
2. O JSON está completo (incluindo `{` e `}`)
3. A service account tem o role "Firebase App Distribution Admin"

### Erro: "App not found"
- ❌ `FIREBASE_APP_ID` incorreto
- ❌ App não existe no Firebase

**Solução:** Verifique o App ID no Firebase Console

### Erro: "Permission denied"
- ❌ Service account sem permissões

**Solução:** Adicione o role "Firebase App Distribution Admin" à service account

---

## 📚 Links Úteis

- Firebase Console: https://console.firebase.google.com
- Google Cloud Console: https://console.cloud.google.com
- GitHub Secrets: https://github.com/ArturOSantana/contruttore/settings/secrets/actions
- GitHub Actions: https://github.com/ArturOSantana/contruttore/actions