# 🚀 Deploy do Tutorial para Firebase App Distribution

## Status Atual

✅ Tutorial implementado e funcionando
✅ CI/CD configurado no GitHub Actions
✅ Flutter atualizado para 3.44.1
⏳ **Aguardando commit e push para disparar o deploy**

## Como Fazer o Deploy

### 1. Verificar Mudanças
```bash
git status
```

### 2. Adicionar Todos os Arquivos
```bash
git add .
```

### 3. Fazer Commit
```bash
git commit -m "feat: adiciona tutorial interativo para novos usuários

- Implementa 8 telas de tutorial explicando funcionalidades
- Adiciona navegação com indicadores de progresso
- Integra com splash page para exibir apenas no primeiro acesso
- Atualiza Flutter para 3.44.1
- Corrige configurações de build Android
- Habilita CI/CD para Firebase App Distribution"
```

### 4. Fazer Push
```bash
git push origin main
```

### 5. Acompanhar o Deploy

Após o push, o GitHub Actions será disparado automaticamente:

1. Acesse: https://github.com/SEU_USUARIO/contruttore/actions
2. Você verá o workflow "Firebase App Distribution" rodando
3. O processo leva cerca de 5-10 minutos
4. Quando concluir, o APK estará no Firebase App Distribution

## O Que o CI/CD Faz

1. ✅ Checkout do código
2. ✅ Configura Java 17
3. ✅ Instala Flutter 3.44.1
4. ✅ Instala dependências (`flutter pub get`)
5. ✅ Faz build do APK release
6. ✅ Envia para Firebase App Distribution
7. ✅ Notifica testadores via email

## Verificar no Firebase

Após o deploy bem-sucedido:

1. Acesse: https://console.firebase.google.com
2. Selecione o projeto "contruttore"
3. Vá em **App Distribution** no menu lateral
4. Você verá o novo build listado
5. Os testadores receberão email com link para download

## Testadores Configurados

Os testadores que receberão o app estão configurados no Firebase Console:
- Vá em App Distribution → Testers & Groups
- Adicione emails dos testadores
- Eles receberão convite automaticamente

## Comandos Úteis

### Ver logs do último deploy
```bash
# No GitHub Actions, clique no workflow e veja os logs
```

### Fazer deploy manual (sem CI/CD)
```bash
# Build local
flutter build apk --release

# O APK estará em:
# build/app/outputs/flutter-apk/app-release.apk

# Upload manual no Firebase Console
```

### Testar localmente antes do deploy
```bash
flutter clean
flutter pub get
flutter run --release
```

## Troubleshooting

### Se o workflow falhar:

1. **Erro de keystore**: Verifique se `android/key.properties` existe
2. **Erro de Firebase**: Verifique se `FIREBASE_APP_ID` está nos secrets do GitHub
3. **Erro de build**: Execute `flutter build apk --release` localmente primeiro

### Verificar secrets do GitHub:

1. Vá em: Settings → Secrets and variables → Actions
2. Verifique se existe: `FIREBASE_APP_ID`
3. Se não existir, adicione com o App ID do Firebase

## Próximos Passos

1. ✅ Reinicie o terminal (para aplicar correções do PATH)
2. ✅ Execute `flutter doctor` (deve estar tudo OK)
3. ✅ Teste localmente: `flutter run`
4. ✅ Faça commit e push
5. ✅ Acompanhe o deploy no GitHub Actions
6. ✅ Verifique no Firebase App Distribution
7. ✅ Teste o app com o tutorial funcionando

## Observações Importantes

⚠️ **Primeira vez**: O deploy pode demorar mais (download de dependências)
⚠️ **Keystore**: Faça backup do arquivo `android/app/contruttore-key.jks`
⚠️ **Secrets**: Não commite o arquivo `android/key.properties` (já está no .gitignore)

## Resultado Esperado

Após o push, em 5-10 minutos:
- ✅ Build concluído no GitHub Actions
- ✅ APK disponível no Firebase App Distribution
- ✅ Testadores notificados por email
- ✅ Tutorial funcionando no app distribuído