# Como Executar o FlutterFire Configure

## 🔴 Problema
```bash
flutterfire configure
zsh: command not found: flutterfire
```

## ✅ Solução Rápida

### Opção 1: Usar o Caminho Completo (Mais Rápido)
```bash
$HOME/.pub-cache/bin/flutterfire configure
```

### Opção 2: Adicionar ao PATH (Permanente)

1. **Abrir o arquivo de configuração do shell:**
```bash
nano ~/.zshrc
```

2. **Adicionar esta linha no final:**
```bash
export PATH="$PATH:$HOME/.pub-cache/bin"
```

3. **Salvar e sair:**
- Pressione `Ctrl + X`
- Pressione `Y` para confirmar
- Pressione `Enter`

4. **Recarregar o shell:**
```bash
source ~/.zshrc
```

5. **Agora pode usar:**
```bash
flutterfire configure
```

## 🚀 Executando a Configuração

Depois de executar o comando, você verá:

```
i Found 1 Firebase projects.
? Select a Firebase project to configure your Flutter application with ›
❯ contruttore (contruttore-app)
```

**Passos:**
1. Selecione seu projeto Firebase
2. Selecione as plataformas (Android e iOS)
3. Aguarde a geração do arquivo
4. Pronto!

## 📝 O que o Comando Faz

1. Conecta ao Firebase
2. Busca as configurações do projeto
3. Gera o arquivo `lib/firebase_options.dart` completo
4. Inclui configurações para Android e iOS

## ✅ Verificar se Funcionou

Depois de executar, verifique:

```bash
cat lib/firebase_options.dart | grep "static const FirebaseOptions android"
```

Deve mostrar as configurações do Android.

## 🔄 Alternativa: Configuração Manual

Se preferir não usar o FlutterFire CLI, você pode:

1. Ir ao [Firebase Console](https://console.firebase.google.com/)
2. Selecionar seu projeto
3. Ir em Project Settings
4. Copiar as configurações de cada plataforma
5. Adicionar manualmente ao arquivo `lib/firebase_options.dart`

## 📞 Precisa de Ajuda?

Se o comando não funcionar:
1. Verifique se o Dart está instalado: `dart --version`
2. Verifique se o Flutter está instalado: `flutter --version`
3. Reinstale o FlutterFire CLI: `dart pub global activate flutterfire_cli`

---

**Nota:** Este é um passo necessário para corrigir o erro de build no CI/CD. O Mapa da Reforma já está 100% implementado e funcionando!