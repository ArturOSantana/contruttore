# ✅ Checklist de Configuração do Firebase - Costruttore

## 📋 Status Atual

### ✅ Arquivos de Configuração
- [x] `android/app/google-services.json` - Presente e configurado
- [x] `ios/GoogleService-Info.plist` - Presente e configurado
- [x] `firestore.rules` - Regras de segurança definidas

### ✅ Regras do Firestore
As regras estão **CORRETAS** e seguem o princípio de segurança:

```javascript
// ✅ Usuários: apenas o próprio usuário acessa seus dados
match /users/{userId} {
  allow read, write: if request.auth.uid == userId;
}

// ✅ Projetos: apenas o dono do projeto acessa
match /projects/{projectId} {
  allow read, write: if resource.data.userId == request.auth.uid;
  
  // ✅ Subcoleções: apenas o dono do projeto acessa
  match /{subcollection}/{docId} {
    allow read, write: if ownsProject(projectId);
  }
}

// ✅ Glossário: leitura pública, escrita apenas admin
match /glossary/{termId} {
  allow read: if isAuth();
  allow write: if false;
}
```

## 🔧 Configuração Necessária no Firebase Console

### 1. Authentication (Autenticação)

**Acesse:** https://console.firebase.google.com/project/contrutore/authentication

**Verifique:**
- [ ] **Email/Password** está habilitado
- [ ] Há pelo menos 1 usuário de teste criado
- [ ] O usuário está com status "Enabled"

**Como habilitar Email/Password:**
1. Vá em Authentication → Sign-in method
2. Clique em "Email/Password"
3. Ative o primeiro toggle (Email/Password)
4. Salve

**Como criar usuário de teste:**
1. Vá em Authentication → Users
2. Clique em "Add user"
3. Email: `teste@costruttore.com`
4. Senha: `teste123456`
5. Clique em "Add user"

### 2. Firestore Database

**Acesse:** https://console.firebase.google.com/project/contrutore/firestore

**Verifique:**
- [ ] Database está criado (modo production ou test)
- [ ] Regras estão publicadas (copie de `firestore.rules`)
- [ ] Não há erros nas regras

**Como publicar as regras:**
1. Vá em Firestore Database → Rules
2. Copie TODO o conteúdo de `firestore.rules`
3. Cole no editor
4. Clique em "Publish"

**Estrutura esperada do Firestore:**
```
/users/{userId}
  - name: string
  - email: string
  - currentProjectId: string
  - createdAt: timestamp

/projects/{projectId}
  - userId: string
  - name: string
  - constructorName: string
  - address: string
  - area: number
  - deliveryDate: timestamp
  - contractDate: timestamp
  - totalBudget: number
  - propertyValue: number
  - currentSituation: string
  - createdAt: timestamp
  
  /phases/{phaseId}
    - number: int
    - name: string
    - status: string
    - ...
```

### 3. Storage (Armazenamento)

**Acesse:** https://console.firebase.google.com/project/contrutore/storage

**Verifique:**
- [ ] Storage está habilitado
- [ ] Regras de segurança estão configuradas

**Regras recomendadas para Storage:**
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Apenas usuários autenticados podem fazer upload
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /projects/{projectId}/{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 4. Cloud Messaging (Notificações)

**Acesse:** https://console.firebase.google.com/project/contrutore/settings/cloudmessaging

**Verifique:**
- [ ] Cloud Messaging API está habilitado
- [ ] Há uma Server Key (para envio de notificações)

## 🧪 Testes de Verificação

### Teste 1: Autenticação Funciona?

```dart
// No app, tente fazer login
Email: teste@costruttore.com
Senha: teste123456
```

**Resultado esperado:** Login bem-sucedido, redirecionado para onboarding

### Teste 2: Firestore Aceita Escrita?

```dart
// Ao criar projeto no onboarding
// Deve criar documento em /projects/{projectId}
```

**Resultado esperado:** Projeto criado sem erro de permissão

### Teste 3: Regras Bloqueiam Acesso Não Autorizado?

```dart
// Tente acessar projeto de outro usuário
// Deve retornar erro de permissão
```

**Resultado esperado:** `[cloud_firestore/permission-denied]`

## 🐛 Problemas Comuns e Soluções

### Problema 1: "No user currently signed in"

**Causa:** Usuário não está autenticado
**Solução:** 
1. Fazer logout completo
2. Fazer login novamente
3. Verificar se `FirebaseAuth.instance.currentUser` não é null

### Problema 2: "Missing or insufficient permissions"

**Causa:** Regras do Firestore bloqueando acesso
**Solução:**
1. Verificar se as regras foram publicadas no Console
2. Verificar se o usuário está autenticado
3. Verificar se o `userId` no documento corresponde ao usuário logado

### Problema 3: "Failed to get document because the client is offline"

**Causa:** App está offline ou Firebase não inicializou
**Solução:**
1. Verificar conexão com internet
2. Verificar se `Firebase.initializeApp()` foi chamado no `main.dart`
3. Verificar se `google-services.json` está correto

### Problema 4: Projeto criado mas não aparece no Firestore

**Causa:** Erro silencioso ou cache local
**Solução:**
1. Verificar logs do console (procurar por erros)
2. Abrir Firebase Console e verificar se documento foi criado
3. Fazer logout e login novamente

## 📱 Como Verificar se Está Funcionando

### No App:

1. **Faça login** com usuário de teste
2. **Preencha o onboarding** com dados válidos
3. **Clique em "Criar Projeto"**
4. **Observe os logs:**

```
✅ Logs esperados (SUCESSO):
🔵 [ONBOARDING] Botão Criar Projeto pressionado
🔵 [ONBOARDING] Cubit obtido: OnboardingCubit
🔵 [ONBOARDING] Preparando dados do projeto...
🔵 [ONBOARDING] Chamando completeOnboarding...
(sem erros)
→ Redireciona para /home

❌ Logs de erro (PROBLEMA):
[ERROR] [cloud_firestore/permission-denied] Missing or insufficient permissions
→ Problema nas regras do Firestore

[ERROR] [firebase_auth/no-current-user] No user currently signed in
→ Usuário não está autenticado
```

### No Firebase Console:

1. **Abra Firestore Database**
2. **Verifique se apareceu:**
   - Coleção `projects`
   - Documento com ID aleatório (UUID)
   - Subcoleção `phases` com 12 documentos

3. **Verifique os dados do projeto:**
   - `userId` = UID do usuário logado
   - `name` = nome que você digitou
   - `constructorName` = construtora que você digitou
   - `createdAt` = timestamp atual

## 🚀 Comandos Úteis

```bash
# Ver logs em tempo real
flutter logs

# Reinstalar app
flutter clean
flutter pub get
flutter run --debug

# Ver status do Firebase
firebase projects:list
firebase use contrutore
```

## 📞 Suporte

Se ainda houver problemas:

1. **Copie TODOS os logs** do console
2. **Tire screenshot** do erro no Firebase Console (se houver)
3. **Informe:**
   - O que você fez (passo a passo)
   - O que esperava acontecer
   - O que realmente aconteceu
   - Logs completos

---

**Última atualização:** 2026-06-02
**Projeto:** Costruttore
**Firebase Project ID:** contrutore