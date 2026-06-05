# 🔑 Gerar Firebase Token para CI/CD

## Método Mais Simples: Firebase CLI Token

Este método é mais fácil que criar Service Account!

### 1️⃣ Instalar Firebase CLI

```bash
npm install -g firebase-tools
```

### 2️⃣ Fazer Login no Firebase

```bash
firebase login:ci
```

Isso vai:
1. Abrir o navegador
2. Pedir para você fazer login com sua conta Google
3. Autorizar o Firebase CLI
4. **Gerar um token** no terminal

### 3️⃣ Copiar o Token

Após o login, você verá algo assim no terminal:

```
✔  Success! Use this token to login on a CI server:

1//0abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ

Example: firebase deploy --token "$FIREBASE_TOKEN"
```

**Copie esse token!**

### 4️⃣ Adicionar no GitHub

1. Vá em: https://github.com/ArturOSantana/contruttore/settings/secrets/actions
2. Clique em **"New repository secret"**
3. Preencha:
   - **Name:** `FIREBASE_TOKEN`
   - **Secret:** Cole o token copiado
4. Clique em **"Add secret"**

---

## ✅ Secrets Necessários

Você precisa de 2 secrets:

1. ✅ **FIREBASE_APP_ID** (você já tem)
   - Formato: `1:123456789:android:abc123...`
   - Encontre em: Firebase Console → Project Settings → Your apps

2. ✅ **FIREBASE_TOKEN** (gere agora)
   - Use o comando: `firebase login:ci`
   - Cole o token gerado

---

## 🚀 Testar

Após adicionar o `FIREBASE_TOKEN`:

```bash
git commit --allow-empty -m "test: Firebase distribution with token"
git push origin main
```

Acompanhe em: https://github.com/ArturOSantana/contruttore/actions

---

## 🎯 Resultado Esperado

O workflow deve:
1. ✅ Fazer build do APK
2. ✅ Autenticar no Firebase (usando o token)
3. ✅ Fazer upload para Firebase App Distribution
4. ✅ Notificar testadores

---

## 🐛 Troubleshooting

### Erro: "command not found: firebase"
```bash
npm install -g firebase-tools
```

### Erro: "Invalid authentication credentials"
- Token expirado ou inválido
- Gere um novo token: `firebase login:ci`

### Erro: "App not found"
- Verifique se o `FIREBASE_APP_ID` está correto
- Formato deve ser: `1:123456789:android:abc123...`

---

## 📝 Observações

- ✅ Este método é **mais simples** que Service Account
- ✅ O token **não expira** (a menos que você revogue)
- ✅ Funciona para **todos os projetos** da sua conta
- ⚠️ Mantenha o token **seguro** (não commite no código)

---

## 🔄 Alternativa: Service Account (Mais Complexo)

Se preferir usar Service Account em vez de token:

1. Remova o secret `FIREBASE_TOKEN`
2. Mantenha o `FIREBASE_SERVICE_ACCOUNT` (JSON completo)
3. Use a action `wzieba/Firebase-Distribution-Github-Action@v1`

Mas o método com token é **mais simples e recomendado**!