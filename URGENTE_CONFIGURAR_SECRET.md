# 🚨 URGENTE: Configurar FIREBASE_APP_ID no GitHub

## ❌ Problema Atual

O workflow está falhando porque o secret `FIREBASE_APP_ID` está **VAZIO** no GitHub.

```
Error: set the --app option to a valid Firebase app id and try again
```

O comando está sendo executado assim:
```bash
--app ""  ← VAZIO!
```

## ✅ Solução: Adicionar o App ID no GitHub

### Seu Firebase App ID:
```
1:721464031041:android:edd98fc3ce3f81a2b053c0
```

### Passo a Passo (FAÇA AGORA):

#### 1️⃣ Acessar GitHub Secrets
Abra este link no navegador:
```
https://github.com/ArturOSantana/contruttore/settings/secrets/actions
```

#### 2️⃣ Encontrar FIREBASE_APP_ID
Na lista de secrets, procure por: `FIREBASE_APP_ID`

#### 3️⃣ Editar o Secret
1. Clique nos **3 pontinhos (⋮)** ao lado de `FIREBASE_APP_ID`
2. Clique em **"Update"**
3. No campo **"Secret"**, cole:
   ```
   1:721464031041:android:edd98fc3ce3f81a2b053c0
   ```
4. Clique em **"Update secret"**

#### 4️⃣ Verificar
Após salvar, o secret deve mostrar:
```
FIREBASE_APP_ID
Updated X seconds ago
```

#### 5️⃣ Testar Novamente
```bash
git commit --allow-empty -m "test: Firebase App ID configurado"
git push origin main
```

## 🎯 O Que Vai Acontecer

Após configurar o secret corretamente:

**ANTES (erro):**
```bash
--app ""  ← VAZIO
```

**DEPOIS (correto):**
```bash
--app "1:721464031041:android:edd98fc3ce3f81a2b053c0"  ← PREENCHIDO
```

## ⚠️ IMPORTANTE

**EU (Bob) NÃO POSSO fazer isso por você!**

Você precisa:
1. Abrir o link do GitHub
2. Fazer login (se necessário)
3. Editar o secret manualmente
4. Colar o App ID
5. Salvar

## 📸 Visual

```
GitHub → Settings → Secrets and variables → Actions
└── FIREBASE_APP_ID
    └── [⋮] Update
        └── Secret: [cole aqui: 1:721464031041:android:edd98fc3ce3f81a2b053c0]
        └── [Update secret]
```

## ✅ Checklist

- [ ] Abri o link: https://github.com/ArturOSantana/contruttore/settings/secrets/actions
- [ ] Encontrei o secret `FIREBASE_APP_ID`
- [ ] Cliquei em Update
- [ ] Colei o valor: `1:721464031041:android:edd98fc3ce3f81a2b053c0`
- [ ] Salvei clicando em "Update secret"
- [ ] Fiz push para testar

## 🚀 Após Configurar

O workflow vai funcionar e você verá:
```
✅ Build APK
✅ Upload to Firebase App Distribution
✅ Testadores notificados
```

**CONFIGURE O SECRET AGORA NO GITHUB!** 🔑