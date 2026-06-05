# 🔍 Como Encontrar o Firebase App ID

## ❌ Erro Atual
```
Error: set the --app option to a valid Firebase app id and try again
```

**Causa:** O secret `FIREBASE_APP_ID` está vazio ou incorreto no GitHub.

---

## ✅ Passo a Passo para Encontrar o App ID

### 1️⃣ Acessar Firebase Console

1. Vá em: https://console.firebase.google.com
2. Faça login com sua conta Google
3. Selecione o projeto **"contruttore"**

### 2️⃣ Ir para Project Settings

1. Clique no ícone de **engrenagem ⚙️** (canto superior esquerdo)
2. Clique em **"Project settings"** (Configurações do projeto)

### 3️⃣ Encontrar o App Android

1. Role a página até a seção **"Your apps"** (Seus apps)
2. Você verá uma lista de apps (Web, iOS, Android)
3. Procure pelo app **Android** (ícone do robô verde 🤖)

### 4️⃣ Copiar o App ID

O **App ID** está logo abaixo do nome do app.

**Formato correto:**
```
1:123456789012:android:abc123def456ghi789
```

**Exemplo real:**
```
1:987654321098:android:1a2b3c4d5e6f7g8h9i0j
```

**NÃO confunda com:**
- ❌ Project ID (nome do projeto)
- ❌ Package name (com.example.app)
- ❌ SHA-1 fingerprint

---

## 📝 Adicionar no GitHub

### 1️⃣ Acessar GitHub Secrets

1. Vá em: https://github.com/ArturOSantana/contruttore/settings/secrets/actions
2. Procure por `FIREBASE_APP_ID` na lista

### 2️⃣ Editar ou Criar o Secret

**Se o secret já existe:**
1. Clique nos 3 pontinhos (⋮) ao lado de `FIREBASE_APP_ID`
2. Clique em **"Update"**
3. Cole o App ID copiado
4. Clique em **"Update secret"**

**Se o secret não existe:**
1. Clique em **"New repository secret"**
2. Name: `FIREBASE_APP_ID`
3. Secret: Cole o App ID copiado
4. Clique em **"Add secret"**

---

## ✅ Verificar se Está Correto

O App ID deve:
- ✅ Começar com `1:`
- ✅ Ter números após os dois pontos
- ✅ Ter `:android:` no meio
- ✅ Terminar com letras e números

**Exemplo válido:**
```
1:123456789012:android:abc123def456
```

**Exemplos INVÁLIDOS:**
```
❌ contruttore (nome do projeto)
❌ com.example.contruttore (package name)
❌ 1:123456789012 (incompleto)
❌ android:abc123 (sem o prefixo)
```

---

## 🚀 Testar Após Configurar

```bash
# Fazer qualquer mudança para disparar o workflow
git commit --allow-empty -m "test: Firebase App ID configurado"
git push origin main
```

Acompanhe em: https://github.com/ArturOSantana/contruttore/actions

---

## 🐛 Troubleshooting

### Erro: "App not found"
- O App ID está incorreto
- Copie novamente do Firebase Console
- Verifique se não tem espaços extras

### Erro: "Invalid app id format"
- O formato está errado
- Deve ser: `1:números:android:letras`

### Não encontro o app Android no Firebase
1. Vá em Project Settings
2. Role até "Your apps"
3. Se não tiver app Android, clique em "Add app" → Android
4. Siga o wizard para adicionar o app

---

## 📸 Onde Encontrar (Visual)

```
Firebase Console
└── ⚙️ Project Settings
    └── Your apps
        └── 🤖 Android app
            └── App ID: 1:123...:android:abc...
                        ↑ COPIE ESTE VALOR
```

---

## 📋 Checklist Final

Antes de fazer push, verifique:

- [ ] Acessei o Firebase Console
- [ ] Fui em Project Settings
- [ ] Encontrei o app Android
- [ ] Copiei o App ID completo (formato: `1:...:android:...`)
- [ ] Adicionei/atualizei o secret `FIREBASE_APP_ID` no GitHub
- [ ] O valor não tem espaços extras no início ou fim

---

## 🎯 Resultado Esperado

Após configurar corretamente:
```
✅ Build APK
✅ Upload to Firebase App Distribution
✅ Testadores notificados
```

**Encontre o App ID no Firebase Console e adicione no GitHub!** 🔑