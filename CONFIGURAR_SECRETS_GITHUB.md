# 🔐 Configurar Secrets no GitHub

Este documento explica como configurar os secrets necessários para o CI/CD funcionar corretamente.

## 📋 Secrets Necessários

### 1. FIREBASE_APP_ID
**Valor:** `1:721464031041:android:edd98fc3ce3f81a2b053c0`

Este é o ID do app Android no Firebase, encontrado em:
- `android/app/google-services.json` → `client[0].client_info.mobilesdk_app_id`
- Console do Firebase → Configurações do Projeto → Seus apps → Android

### 2. FIREBASE_TOKEN
**Como obter:**
```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# Fazer login
firebase login

# Gerar token
firebase login:ci
```

O comando `firebase login:ci` irá:
1. Abrir o navegador para autenticação
2. Gerar um token de CI/CD
3. Exibir o token no terminal

**⚠️ IMPORTANTE:** Guarde este token em local seguro, ele não pode ser recuperado depois.

## 🔧 Como Configurar no GitHub

### Passo 1: Acessar Configurações do Repositório
1. Vá para o repositório no GitHub
2. Clique em **Settings** (Configurações)
3. No menu lateral, clique em **Secrets and variables** → **Actions**

### Passo 2: Adicionar FIREBASE_APP_ID
1. Clique em **New repository secret**
2. Name: `FIREBASE_APP_ID`
3. Secret: `1:721464031041:android:edd98fc3ce3f81a2b053c0`
4. Clique em **Add secret**

### Passo 3: Adicionar FIREBASE_TOKEN
1. Clique em **New repository secret**
2. Name: `FIREBASE_TOKEN`
3. Secret: Cole o token gerado pelo comando `firebase login:ci`
4. Clique em **Add secret**

## ✅ Verificar Configuração

Após configurar os secrets:

1. Faça um commit e push para qualquer branch
2. Vá para **Actions** no GitHub
3. Verifique se o workflow está executando
4. O build deve:
   - ✅ Usar o FIREBASE_APP_ID do secret
   - ✅ Fazer upload para Firebase App Distribution
   - ✅ Não mostrar erros de autenticação

## 🔍 Troubleshooting

### Erro: "Secret FIREBASE_APP_ID não está configurado"
- Verifique se o secret foi criado com o nome exato: `FIREBASE_APP_ID`
- Verifique se o valor está correto (sem espaços extras)

### Erro: "Authentication error" no Firebase
- O FIREBASE_TOKEN pode ter expirado
- Gere um novo token com `firebase login:ci`
- Atualize o secret no GitHub

### Erro: "App not found"
- Verifique se o FIREBASE_APP_ID está correto
- Confirme que o app existe no Firebase Console
- Verifique se o package name corresponde: `com.example.contruttore`

## 📱 Informações do App

- **Package Name:** `com.example.contruttore`
- **Firebase Project ID:** `contrutore`
- **Firebase App ID:** `1:721464031041:android:edd98fc3ce3f81a2b053c0`
- **Project Number:** `721464031041`

## 🔗 Links Úteis

- [Firebase Console](https://console.firebase.google.com/project/contrutore)
- [Firebase CLI Documentation](https://firebase.google.com/docs/cli)
- [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)