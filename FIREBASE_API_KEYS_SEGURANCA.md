# 🔐 Segurança das API Keys do Firebase

## ⚠️ IMPORTANTE: Você NÃO precisa esconder essas chaves!

As API keys do Firebase que aparecem no `firebase_options.dart` são **PÚBLICAS POR DESIGN** e **NÃO são secretas**.

## Por que essas chaves são públicas?

### 1. **Elas identificam seu projeto, não autenticam**

```dart
apiKey: 'AIzaSyAOSJvvfakZXGbxDi4rQZCojC5KxeknOMs'  // ✅ PODE SER PÚBLICA
```

Esta chave apenas diz ao Firebase: "Este app pertence ao projeto 'contrutore'".

Ela **NÃO dá acesso** aos seus dados.

### 2. **A segurança real está no Firebase Console**

A proteção dos seus dados vem de:

- **Firestore Rules** (já configuradas)
- **Authentication** (login obrigatório)
- **App Check** (opcional, para apps em produção)

## 📋 Onde está a segurança real?

### 1. Firestore Rules (`firestore.rules`)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Usuário só acessa seus próprios dados
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Projetos só acessíveis pelo dono
    match /projects/{projectId} {
      allow read, write: if request.auth != null && 
                           request.auth.uid == resource.data.userId;
    }
  }
}
```

✅ **Estas regras impedem acesso não autorizado, mesmo com a API key**

### 2. Firebase Authentication

```dart
// Usuário precisa estar logado
final user = FirebaseAuth.instance.currentUser;
if (user == null) {
  // Sem acesso aos dados
}
```

### 3. Restrições de API Key (Firebase Console)

Você pode restringir a API key para:
- Apenas seu app (via SHA-256 fingerprint no Android)
- Apenas seu bundle ID (no iOS)
- Apenas domínios específicos (na web)

## 🛡️ Como configurar restrições adicionais

### Passo 1: Acesse o Firebase Console

1. Vá para: https://console.firebase.google.com
2. Selecione seu projeto: **contrutore**
3. Clique em ⚙️ **Configurações do projeto**
4. Vá para a aba **Geral**

### Passo 2: Configure App Check (Recomendado para produção)

App Check protege contra:
- Bots
- Abuso de API
- Tráfego não autorizado

```bash
# Instalar App Check
flutter pub add firebase_app_check
```

```dart
// No main.dart
await FirebaseAppCheck.instance.activate(
  androidProvider: AndroidProvider.playIntegrity,
  appleProvider: AppleProvider.appAttest,
);
```

### Passo 3: Restrinja a API Key no Google Cloud Console

1. Acesse: https://console.cloud.google.com
2. Selecione o projeto **contrutore**
3. Vá em **APIs e Serviços** → **Credenciais**
4. Clique na API key do Android
5. Em **Restrições de aplicativo**, adicione:
   - **SHA-256 fingerprint** do seu app
   - **Nome do pacote**: `com.example.contruttore`

## 🚫 O que NUNCA deve ser público

Estas SIM devem ser mantidas secretas:

### ❌ Service Account Keys (JSON)

```json
{
  "type": "service_account",
  "project_id": "contrutore",
  "private_key_id": "...",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...",  // ⚠️ NUNCA COMMITAR
  "client_email": "firebase-adminsdk@contrutore.iam.gserviceaccount.com"
}
```

**Onde usar**: Apenas no CI/CD como GitHub Secret

### ❌ Firebase Admin SDK Credentials

Usadas para operações administrativas no backend.

### ❌ Tokens de API de terceiros

- Tokens do OpenAI
- Chaves do Stripe
- Credenciais de pagamento

## 📊 Comparação: O que é público vs secreto

| Item | Público? | Motivo |
|------|----------|--------|
| `apiKey` do firebase_options.dart | ✅ SIM | Identifica o projeto, não autentica |
| `appId` | ✅ SIM | Identificador público do app |
| `messagingSenderId` | ✅ SIM | Para notificações push |
| `projectId` | ✅ SIM | Nome público do projeto |
| Service Account JSON | ❌ NÃO | Dá acesso administrativo total |
| Firebase Admin SDK | ❌ NÃO | Bypass de todas as regras |
| Keystore password | ❌ NÃO | Assina o APK de produção |

## 🎯 Resumo: O que fazer

### ✅ Faça isso:

1. **Commite o `firebase_options.dart`** (já fizemos)
2. **Configure Firestore Rules** (já configuradas)
3. **Use Firebase Authentication** (já implementado)
4. **Ative App Check em produção** (recomendado)
5. **Restrinja API keys no Console** (opcional, mas bom)

### ❌ Não faça isso:

1. ~~Tentar esconder a API key do firebase_options.dart~~
2. ~~Usar variáveis de ambiente para essas chaves~~
3. ~~Criar secrets no GitHub para firebase_options.dart~~

## 📚 Referências Oficiais

- [Firebase: API Keys são seguras?](https://firebase.google.com/docs/projects/api-keys)
- [Firebase App Check](https://firebase.google.com/docs/app-check)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)

## 💡 Conclusão

**As API keys do Firebase no `firebase_options.dart` são PÚBLICAS por design.**

A segurança real vem de:
1. ✅ Firestore Rules (implementadas)
2. ✅ Authentication (implementado)
3. ✅ App Check (recomendado para produção)

**Seu app está seguro!** 🎉

---

**Criado por Bob** 🤖