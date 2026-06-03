# 🚀 Guia de Deploy - Costruttore

## 📋 Pré-requisitos

### Contas Necessárias
- [ ] Conta Google (Firebase Console)
- [ ] Conta Apple Developer (iOS)
- [ ] Conta Google Play Console (Android)
- [ ] Domínio para política de privacidade (opcional: GitHub Pages)

### Ferramentas Instaladas
- [ ] Flutter SDK 3.x
- [ ] Xcode 14+ (macOS, para iOS)
- [ ] Android Studio / Android SDK
- [ ] Firebase CLI: `npm install -g firebase-tools`
- [ ] CocoaPods (iOS): `sudo gem install cocoapods`

---

## 🔥 Configuração do Firebase

### 1. Criar Projeto Firebase

```bash
# Login no Firebase
firebase login

# Criar projeto (ou usar existente)
# Acesse: https://console.firebase.google.com
# Clique em "Adicionar projeto"
# Nome: Costruttore
# Ative Google Analytics (recomendado)
```

### 2. Configurar Aplicativos

#### Android
```bash
# No Firebase Console:
# 1. Adicionar app Android
# 2. Package name: com.costruttore.app (ou seu domínio)
# 3. Baixar google-services.json
# 4. Colocar em: android/app/google-services.json
```

#### iOS
```bash
# No Firebase Console:
# 1. Adicionar app iOS
# 2. Bundle ID: com.costruttore.app (mesmo do Android)
# 3. Baixar GoogleService-Info.plist
# 4. Colocar em: ios/Runner/GoogleService-Info.plist
```

### 3. Ativar Serviços Firebase

No Firebase Console, ative:
- [x] **Authentication** → Email/Password
- [x] **Firestore Database** → Modo produção
- [x] **Storage** → Modo produção
- [x] **Cloud Messaging** → Ativado automaticamente

### 4. Deploy das Firestore Rules

```bash
# Inicializar Firebase no projeto
firebase init firestore

# Quando perguntado, use os arquivos:
# - firestore.rules (já existe no projeto)
# - firestore.indexes.json (será criado)

# Deploy das rules
firebase deploy --only firestore:rules

# Verificar no console se as rules foram aplicadas
```

### 5. Criar Índices Firestore

Acesse Firebase Console → Firestore → Índices e crie:

```
Collection: projects/{projectId}/expenses
Fields: date (Descending), createdAt (Descending)

Collection: projects/{projectId}/diary
Fields: date (Descending), type (Ascending)

Collection: projects/{projectId}/alerts
Fields: createdAt (Descending), isRead (Ascending)
```

Ou aguarde os erros de índice no console e clique nos links para criar automaticamente.

---

## 📱 Build Android

### 1. Configurar Assinatura

Crie o keystore:
```bash
keytool -genkey -v -keystore ~/costruttore-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias costruttore
```

Crie `android/key.properties`:
```properties
storePassword=SUA_SENHA_AQUI
keyPassword=SUA_SENHA_AQUI
keyAlias=costruttore
storeFile=/Users/seu-usuario/costruttore-key.jks
```

Adicione ao `.gitignore`:
```
android/key.properties
*.jks
```

### 2. Configurar build.gradle

Já configurado no projeto. Verifique:
- `android/app/build.gradle` → signingConfigs
- `android/app/build.gradle` → buildTypes.release

### 3. Atualizar Versão

Em `pubspec.yaml`:
```yaml
version: 1.0.0+1  # Formato: MAJOR.MINOR.PATCH+BUILD_NUMBER
```

### 4. Build Release

```bash
# Limpar builds anteriores
flutter clean
flutter pub get

# Build APK (para testes)
flutter build apk --release

# Build App Bundle (para Play Store)
flutter build appbundle --release

# Arquivos gerados:
# - build/app/outputs/flutter-apk/app-release.apk
# - build/app/outputs/bundle/release/app-release.aab
```

### 5. Testar APK

```bash
# Instalar em dispositivo conectado
flutter install --release

# Ou manualmente
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## 🍎 Build iOS

### 1. Configurar Certificados

```bash
# Abrir Xcode
open ios/Runner.xcworkspace

# No Xcode:
# 1. Selecionar Runner no navegador
# 2. Aba "Signing & Capabilities"
# 3. Team: Selecionar sua conta Apple Developer
# 4. Bundle Identifier: com.costruttore.app
# 5. Provisioning Profile: Automatic
```

### 2. Configurar Info.plist

Já configurado. Verifique permissões em `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>Precisamos acessar a câmera para registrar fotos da obra</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Precisamos acessar suas fotos para anexar documentos</string>
```

### 3. Atualizar Versão

Mesmo que Android, em `pubspec.yaml`.

### 4. Build Release

```bash
# Limpar
flutter clean
flutter pub get

# Build iOS
flutter build ios --release

# Ou via Xcode:
# Product → Archive
# Distribute App → App Store Connect
```

### 5. Upload para App Store Connect

```bash
# Via Xcode Organizer:
# Window → Organizer
# Selecionar o archive
# Distribute App → App Store Connect → Upload
```

---

## 🏪 Publicação nas Lojas

### Google Play Store

#### 1. Criar Aplicativo

1. Acesse [Google Play Console](https://play.google.com/console)
2. Criar aplicativo
3. Preencher informações básicas

#### 2. Listing da Loja

**Detalhes do app:**
- Nome: Costruttore
- Descrição curta: Gerencie sua obra do início ao fim
- Descrição completa: (ver template abaixo)
- Ícone: 512x512px
- Gráfico de recursos: 1024x500px
- Screenshots: Mínimo 2, recomendado 8

**Template de Descrição:**
```
🏗️ Costruttore - Seu Parceiro na Obra

Comprou um apartamento na planta? O Costruttore te ajuda a:

✅ Acompanhar todas as fases da obra
💰 Controlar gastos e orçamento
👷 Gerenciar fornecedores e parcelas
📓 Registrar o progresso com fotos
📋 Organizar documentos importantes
🔔 Receber alertas de prazos

RECURSOS PRINCIPAIS:
• 12 fases guiadas (da assinatura à entrega das chaves)
• Controle financeiro completo
• Diário de obra com fotos
• Lista de compras e desejos
• Glossário de termos técnicos
• Alertas inteligentes

SEGURANÇA:
• Seus dados são privados e seguros
• Backup automático na nuvem
• Acesso offline

Baixe agora e tenha controle total da sua obra! 🚀
```

#### 3. Classificação de Conteúdo

- Categoria: Produtividade
- Classificação etária: Livre
- Sem anúncios
- Sem compras no app

#### 4. Política de Privacidade

Crie em: `https://seu-dominio.com/privacy-policy`

Template básico:
```markdown
# Política de Privacidade - Costruttore

Última atualização: [DATA]

## Dados Coletados
- Email e senha (autenticação)
- Dados do projeto (nome, endereço, datas)
- Fotos e documentos (armazenados no Firebase)

## Uso dos Dados
- Fornecer funcionalidades do app
- Backup e sincronização
- Melhorar a experiência

## Compartilhamento
Não compartilhamos seus dados com terceiros.

## Segurança
Dados criptografados e armazenados no Firebase (Google Cloud).

## Seus Direitos
- Acessar seus dados
- Deletar sua conta
- Exportar dados

Contato: contato@costruttore.app
```

#### 5. Upload do App Bundle

1. Produção → Criar nova versão
2. Upload do AAB
3. Preencher notas da versão
4. Enviar para revisão

### Apple App Store

#### 1. Criar App no App Store Connect

1. Acesse [App Store Connect](https://appstoreconnect.apple.com)
2. Meus Apps → + → Novo App
3. Plataforma: iOS
4. Nome: Costruttore
5. Bundle ID: com.costruttore.app

#### 2. Informações do App

**Descrição:**
(Usar mesmo template do Android, adaptado)

**Palavras-chave:**
```
obra,construção,reforma,apartamento,gestão,orçamento,fornecedores
```

**Screenshots:**
- iPhone 6.7": 1290x2796px (mínimo 3)
- iPhone 6.5": 1242x2688px (mínimo 3)
- iPad Pro 12.9": 2048x2732px (opcional)

#### 3. Build e Envio

1. Upload via Xcode (já feito no passo anterior)
2. Selecionar build no App Store Connect
3. Preencher informações de revisão
4. Enviar para revisão

#### 4. Tempo de Revisão

- Android: 1-3 dias
- iOS: 1-7 dias

---

## 🧪 Testes Pré-Deploy

### Checklist Crítico

```bash
# 1. Testes funcionais
[ ] Login/Registro funciona
[ ] Criar projeto funciona
[ ] Adicionar despesa funciona
[ ] Upload de foto funciona
[ ] Notificações funcionam
[ ] Trocar projeto funciona

# 2. Testes de segurança
[ ] Firestore Rules bloqueiam acesso não autorizado
[ ] Dados isolados por projectId
[ ] Não há vazamento de dados entre usuários

# 3. Testes de performance
[ ] App inicia em < 2 segundos
[ ] Navegação fluida (60fps)
[ ] Imagens carregam com cache
[ ] Sem memory leaks

# 4. Testes de compatibilidade
[ ] Android 8.0+ funciona
[ ] iOS 12.0+ funciona
[ ] Diferentes tamanhos de tela
[ ] Modo escuro (se implementado)

# 5. Testes offline
[ ] App funciona sem internet
[ ] Sincroniza ao voltar online
[ ] Mensagem clara quando offline
```

### Comandos de Teste

```bash
# Análise estática
flutter analyze

# Formatação
flutter format .

# Testes unitários
flutter test

# Build de teste
flutter build apk --debug
flutter build ios --debug
```

---

## 📊 Monitoramento Pós-Deploy

### 1. Firebase Console

Monitore diariamente:
- **Authentication**: Novos usuários
- **Firestore**: Leituras/escritas
- **Storage**: Uso de armazenamento
- **Crashlytics**: Crashes (se configurado)

### 2. Play Console / App Store Connect

Monitore:
- Downloads
- Avaliações e reviews
- Crashes e ANRs
- Estatísticas de uso

### 3. Responder Reviews

Template de resposta:
```
Olá [NOME]! Obrigado pelo feedback. 
[RESPOSTA ESPECÍFICA]
Estamos sempre melhorando o Costruttore. 
Se tiver sugestões, entre em contato: contato@costruttore.app
```

---

## 🔄 Atualizações Futuras

### Versionamento Semântico

```
MAJOR.MINOR.PATCH+BUILD

Exemplo: 1.2.3+15
- MAJOR (1): Mudanças incompatíveis
- MINOR (2): Novas funcionalidades
- PATCH (3): Correções de bugs
- BUILD (15): Número sequencial
```

### Processo de Atualização

```bash
# 1. Atualizar versão
# pubspec.yaml: version: 1.1.0+2

# 2. Criar changelog
# CHANGELOG.md

# 3. Build
flutter build appbundle --release  # Android
flutter build ios --release         # iOS

# 4. Upload nas lojas

# 5. Criar tag no Git
git tag v1.1.0
git push origin v1.1.0
```

---

## 🆘 Troubleshooting

### Erro: "Firestore permission denied"
```bash
# Verificar Firestore Rules
firebase deploy --only firestore:rules

# Testar no simulador do Firebase Console
```

### Erro: "Build failed - signing"
```bash
# Android: Verificar key.properties
# iOS: Verificar certificados no Xcode
```

### Erro: "App crashes on startup"
```bash
# Verificar google-services.json (Android)
# Verificar GoogleService-Info.plist (iOS)
# Verificar Firebase initialization no main.dart
```

### Notificações não funcionam
```bash
# Verificar FCM token no Firestore
# Verificar permissões no AndroidManifest.xml / Info.plist
# Testar com Firebase Console → Cloud Messaging → Send test message
```

---

## 📞 Suporte

### Documentação
- Flutter: https://docs.flutter.dev
- Firebase: https://firebase.google.com/docs
- Play Console: https://support.google.com/googleplay
- App Store: https://developer.apple.com/support

### Comunidade
- Flutter Brasil: https://t.me/flutterbr
- Stack Overflow: https://stackoverflow.com/questions/tagged/flutter

---

## ✅ Checklist Final

Antes de enviar para as lojas:

### Código
- [ ] Versão atualizada no pubspec.yaml
- [ ] Changelog atualizado
- [ ] Código formatado (`flutter format .`)
- [ ] Sem warnings (`flutter analyze`)
- [ ] Testes passando (`flutter test`)

### Firebase
- [ ] Firestore Rules em produção
- [ ] Índices criados
- [ ] Storage Rules configuradas
- [ ] Authentication configurado

### Builds
- [ ] APK/AAB assinado (Android)
- [ ] IPA assinado (iOS)
- [ ] Testado em dispositivos reais
- [ ] Ícones e splash screens configurados

### Lojas
- [ ] Listing completo (título, descrição, screenshots)
- [ ] Política de privacidade publicada
- [ ] Termos de uso (se necessário)
- [ ] Classificação etária definida
- [ ] Categorias selecionadas

### Pós-Deploy
- [ ] Monitoramento configurado
- [ ] Plano de resposta a crashes
- [ ] Plano de resposta a reviews
- [ ] Backup do keystore (Android)

---

**Boa sorte com o deploy! 🚀**

**Made with Bob** 🤖