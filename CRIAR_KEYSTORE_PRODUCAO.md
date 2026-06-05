# 🔐 Criar Keystore de Produção - App Seguro

Este guia mostra como criar um keystore de produção para que o Google reconheça seu app como seguro.

## 🎯 O Que Vamos Fazer

1. Criar um keystore de produção (certificado oficial)
2. Configurar o projeto para usar esse keystore
3. Gerar APK assinado com certificado de produção
4. Configurar CI/CD para usar o keystore

## 📋 Passo 1: Criar o Keystore de Produção

### No Terminal (Mac/Linux):

```bash
# Navegue até a pasta do projeto
cd /Users/artur.santana/estudos/contrutor/contruttore

# Crie o keystore de produção
keytool -genkey -v -keystore android/app/upload-keystore.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias upload
```

### Você será perguntado:

1. **Senha do keystore:** Digite uma senha forte (ex: `Contruttore@2024`)
   - ⚠️ **GUARDE ESTA SENHA!** Você vai precisar dela sempre
   
2. **Confirme a senha:** Digite novamente

3. **Nome e sobrenome:** Seu nome ou nome da empresa (ex: `Artur Santana`)

4. **Unidade organizacional:** Nome do departamento (ex: `Desenvolvimento`)

5. **Organização:** Nome da empresa (ex: `Contruttore`)

6. **Cidade:** Sua cidade (ex: `São Paulo`)

7. **Estado:** Seu estado (ex: `SP`)

8. **Código do país:** BR

9. **Está correto?** Digite `sim`

10. **Senha da chave:** Pressione ENTER para usar a mesma senha do keystore

### Resultado:

Será criado o arquivo: `android/app/upload-keystore.jks`

## 📋 Passo 2: Criar Arquivo de Configuração

Crie o arquivo `android/key.properties` com o seguinte conteúdo:

```properties
storePassword=SUA_SENHA_AQUI
keyPassword=SUA_SENHA_AQUI
keyAlias=upload
storeFile=upload-keystore.jks
```

**Substitua `SUA_SENHA_AQUI` pela senha que você criou!**

### Exemplo:
```properties
storePassword=Contruttore@2024
keyPassword=Contruttore@2024
keyAlias=upload
storeFile=upload-keystore.jks
```

## 📋 Passo 3: Atualizar .gitignore

Adicione estas linhas ao `.gitignore` para não commitar senhas:

```
# Keystore e senhas
android/key.properties
android/app/upload-keystore.jks
android/app/debug.keystore
*.jks
*.keystore
```

## 📋 Passo 4: Testar o Build

```bash
# Limpar build anterior
flutter clean

# Obter dependências
flutter pub get

# Gerar APK de produção
flutter build apk --release
```

O APK será gerado em: `build/app/outputs/flutter-apk/app-release.apk`

## 📋 Passo 5: Verificar Assinatura

```bash
# Verificar se o APK está assinado corretamente
jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-release.apk
```

Deve mostrar:
```
jar verified.
```

E informações do certificado com seu nome/empresa.

## 📋 Passo 6: Configurar CI/CD (GitHub Actions)

### Opção A: Usar Secrets do GitHub (RECOMENDADO)

1. **Converter keystore para Base64:**
```bash
base64 -i android/app/upload-keystore.jks | pbcopy
```

2. **No GitHub:**
   - Vá em Settings → Secrets and variables → Actions
   - Adicione os seguintes secrets:

| Nome | Valor |
|------|-------|
| `KEYSTORE_BASE64` | Cole o conteúdo copiado |
| `KEYSTORE_PASSWORD` | Sua senha do keystore |
| `KEY_ALIAS` | `upload` |
| `KEY_PASSWORD` | Sua senha da chave |

3. **Atualizar workflow** (já está configurado no projeto)

### Opção B: Commitar Keystore Criptografado

```bash
# Criptografar keystore
gpg --symmetric --cipher-algo AES256 android/app/upload-keystore.jks

# Isso cria: android/app/upload-keystore.jks.gpg
# Commite apenas o .gpg, nunca o .jks original
```

## 🎯 Passo 7: Publicar na Play Store (Opcional mas Recomendado)

Para que o Google reconheça completamente o app como seguro:

1. **Criar conta no Google Play Console**
   - https://play.google.com/console
   - Taxa única de $25 USD

2. **Criar novo app**
   - Nome: Contruttore
   - Categoria: Produtividade
   - Tipo: App

3. **Upload do APK**
   - Vá em "Teste interno" ou "Teste fechado"
   - Faça upload do APK assinado
   - Adicione testadores (emails)

4. **Benefícios:**
   - ✅ Google verifica e aprova o app
   - ✅ Play Protect reconhece como seguro
   - ✅ Testadores podem instalar sem bloqueios
   - ✅ Updates automáticos
   - ✅ Estatísticas e crash reports

## 🔐 Segurança do Keystore

### ⚠️ MUITO IMPORTANTE:

1. **NUNCA commite o keystore (.jks) no Git**
   - Se perder, não consegue mais atualizar o app na Play Store
   - Se vazar, qualquer um pode assinar apps em seu nome

2. **Faça backup do keystore em local seguro:**
   - Google Drive (pasta privada)
   - Dropbox
   - Pen drive em local seguro
   - Gerenciador de senhas (1Password, LastPass)

3. **Guarde as senhas em local seguro:**
   - Gerenciador de senhas
   - Documento criptografado
   - Cofre físico

4. **Se perder o keystore:**
   - Não consegue mais atualizar o app na Play Store
   - Terá que criar novo app com novo package name
   - Usuários perdem dados e precisam reinstalar

## ✅ Checklist Final

- [ ] Keystore de produção criado
- [ ] Arquivo key.properties configurado
- [ ] .gitignore atualizado
- [ ] Build de teste funcionando
- [ ] Assinatura verificada
- [ ] Backup do keystore feito
- [ ] Senhas guardadas em local seguro
- [ ] CI/CD configurado (opcional)
- [ ] Play Store configurada (opcional)

## 🎉 Resultado

Após seguir todos os passos:

✅ **App assinado com certificado de produção**
✅ **Mais seguro e profissional**
✅ **Pronto para Play Store**
✅ **Google Play Protect não bloqueia** (após publicar na Play Store)

## 📞 Comandos Úteis

```bash
# Ver informações do keystore
keytool -list -v -keystore android/app/upload-keystore.jks -alias upload

# Verificar assinatura do APK
jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-release.apk

# Extrair certificado
keytool -export -rfc -keystore android/app/upload-keystore.jks -alias upload -file upload_cert.pem

# Ver SHA-1 e SHA-256 (necessário para Firebase)
keytool -list -v -keystore android/app/upload-keystore.jks -alias upload
```

## 🔗 Links Úteis

- [Google Play Console](https://play.google.com/console)
- [Documentação Android - Assinar App](https://developer.android.com/studio/publish/app-signing)
- [Firebase - Adicionar SHA](https://firebase.google.com/docs/android/setup)

---

**Lembre-se:** O keystore de produção é como a "identidade" do seu app. Proteja-o como se fosse a senha do seu banco! 🔐