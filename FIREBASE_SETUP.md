# Configuração do Firebase - Costruttore

## ✅ Status: Build Android Funcionando!

O app compilou com sucesso. Agora precisa configurar o Firebase para funcionar completamente.

## Erro Atual

```
Failed to load FirebaseOptions from resource. 
Check that you have defined values.xml correctly.
```

Este erro é **esperado** e significa que o Firebase ainda não foi configurado.

## Passo a Passo para Configurar Firebase

### 1. Criar Projeto no Firebase Console

1. Acesse: https://console.firebase.google.com/
2. Clique em "Adicionar projeto"
3. Nome do projeto: **Costruttore**
4. Aceite os termos e crie o projeto

### 2. Adicionar App Android

1. No console do Firebase, clique no ícone do Android
2. Preencha:
   - **Nome do pacote Android**: `com.example.contruttore`
   - **Apelido do app**: Costruttore Android
   - **SHA-1**: (opcional por enquanto)
3. Clique em "Registrar app"

### 3. Baixar google-services.json

1. Baixe o arquivo `google-services.json`
2. Coloque em: `android/app/google-services.json`   

### 4. Ativar Serviços no Firebase

No console do Firebase, ative:

#### Authentication
1. Vá em **Authentication** → **Sign-in method**
2. Ative **Email/Password**

#### Firestore Database
1. Vá em **Firestore Database**
2. Clique em "Criar banco de dados"
3. Escolha **Modo de teste** (por enquanto)
4. Selecione localização: **southamerica-east1** (São Paulo)

#### Storage
1. Vá em **Storage**
2. Clique em "Começar"
3. Escolha **Modo de teste**
4. Mesma localização do Firestore

#### Cloud Messaging (FCM)
1. Vá em **Cloud Messaging**
2. Já está ativado automaticamente

### 5. Configurar Firestore Rules

No Firestore, vá em **Rules** e cole:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isAuth() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isAuth() && request.auth.uid == userId;
    }

    function ownsProject(projectId) {
      return isAuth() &&
        get(/databases/$(database)/documents/projects/$(projectId))
          .data.userId == request.auth.uid;
    }

    // Usuários
    match /users/{userId} {
      allow read, write: if isOwner(userId);
    }

    // Projetos
    match /projects/{projectId} {
      allow read: if isAuth() && resource.data.userId == request.auth.uid;
      allow create: if isAuth() && request.resource.data.userId == request.auth.uid;
      allow update, delete: if isAuth() && resource.data.userId == request.auth.uid;

      // Todas as subcoleções do projeto
      match /{subcollection}/{docId} {
        allow read, write: if ownsProject(projectId);
      }
    }

    // Glossário (leitura pública para autenticados)
    match /glossary/{termId} {
      allow read: if isAuth();
      allow write: if false; // apenas via console
    }
  }
}
```

### 6. Configurar Storage Rules

No Storage, vá em **Rules** e cole:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /projects/{projectId}/{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 7. Testar o App

Após colocar o `google-services.json`:

```bash
flutter run --debug
```

O app deve iniciar sem erros do Firebase!

## Adicionar App iOS (Futuro)

Quando for testar no iOS:

1. No Firebase Console, adicione um app iOS
2. Bundle ID: `com.example.contruttore`
3. Baixe `GoogleService-Info.plist`
4. Coloque em: `ios/Runner/GoogleService-Info.plist`

## Próximos Passos

- [ ] Configurar Firebase conforme este guia
- [ ] Testar registro de usuário
- [ ] Testar criação de projeto
- [ ] Popular glossário via Firebase Console
- [ ] Configurar notificações push (FCM)
- [ ] Gerar builds de produção

## Notas Importantes

### file_picker Temporariamente Desabilitado

O plugin `file_picker` foi desabilitado porque não suporta Android SDK 36.

**Funcionalidade afetada:**
- Upload de PDF no módulo Documentos

**Alternativas:**
- Use `image_picker` para fotos (funcional)
- Aguarde atualização do plugin
- Ou use alternativa como `flutter_file_picker`

**Para reabilitar quando disponível:**
1. Descomentar no `pubspec.yaml`: `file_picker: ^X.X.X`
2. Descomentar import em `add_document_page.dart`
3. Descomentar código do método `_pickPDF()`

## Troubleshooting

### Erro: "Failed to load FirebaseOptions"
- Verifique se `google-services.json` está em `android/app/`
- Verifique se o package name está correto: `com.example.contruttore`

### Erro: "FirebaseException: Permission denied"
- Verifique as Firestore Rules
- Certifique-se de que o usuário está autenticado

### App não conecta ao Firebase
- Verifique sua conexão com internet
- Certifique-se de que os serviços estão ativados no console

## Suporte

Para mais informações:
- [Firebase Flutter Setup](https://firebase.google.com/docs/flutter/setup)
- [FlutterFire Documentation](https://firebase.flutter.dev/)