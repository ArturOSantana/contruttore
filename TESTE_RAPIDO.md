# 🧪 Teste Rápido do Costruttore

## ✅ Firebase está funcionando!

Os logs mostram:
```
I/flutter ( 9084): FCM token salvo com sucesso
```

Isso significa que o Firebase está conectado e funcionando.

---

## 📱 Teste Agora

### 1️⃣ Teste de Login

**Faça:**
1. Abra o app
2. Clique em "Criar conta" (ou "Registrar")
3. Preencha:
   - Email: `teste@costruttore.com`
   - Senha: `teste123456`
4. Clique em "Registrar"

**Logs esperados:**
```
🔵 [AuthCubit] Registrando usuário: teste@costruttore.com
🔵 [AuthCubit] Usuário registrado com sucesso
```

**Se der erro:**
- Copie TODOS os logs e me envie
- Tire screenshot da tela de erro

---

### 2️⃣ Teste de Onboarding

**Faça:**
1. Após registrar, você deve ver a tela de Onboarding
2. Preencha cada step:

**Step 1 - Nome do Projeto:**
- Digite: "Meu Apartamento Teste"
- Clique em "Próximo"

**Step 2 - Dados do Imóvel:**
- Construtora: "Construtora Teste"
- Endereço: "Rua Teste, 123"
- Área: "80"
- Data de entrega: Escolha qualquer data futura
- Data do contrato: Escolha qualquer data passada
- Clique em "Próximo"

**Step 3 - Situação Atual:**
- Escolha qualquer opção (ex: "Acabei de assinar o contrato")
- Clique em "Próximo"

**Step 4 - Orçamento:**
- Escolha "Sim, tenho um valor definido"
- Digite: "100000"
- Clique em "Próximo"

**Step 5 - Resumo:**
- Revise os dados
- Clique em "Criar meu projeto"

**Logs esperados:**
```
🔵 [OnboardingPage] Step 1 - Nome do projeto: Meu Apartamento Teste
🔵 [OnboardingPage] Step 2 - Dados do imóvel preenchidos
🔵 [OnboardingPage] Step 3 - Situação selecionada: just_signed
🔵 [OnboardingPage] Step 4 - Orçamento: 100000.0
🔵 [OnboardingPage] Step 5 - Criando projeto...
🔵 [OnboardingCubit] Criando projeto: Meu Apartamento Teste
🔵 [OnboardingCubit] Projeto criado com sucesso
```

**Se der erro:**
- Copie TODOS os logs
- Me diga em qual step parou

---

### 3️⃣ Verificar no Firebase Console

**Acesse:**
https://console.firebase.google.com/project/contrutore

**Verifique:**

1. **Authentication → Users**
   - [ ] Aparece o usuário `teste@costruttore.com`?

2. **Firestore Database → Data**
   - [ ] Aparece coleção `users`?
   - [ ] Aparece coleção `projects`?
   - [ ] Dentro de `projects`, há um documento?
   - [ ] Dentro desse documento, há subcoleção `phases` com 12 documentos?

**Tire screenshots se possível!**

---

## 🐛 Problemas Comuns

### Erro: "No user currently signed in"
**Solução:** O registro falhou. Verifique:
1. Firebase Authentication está habilitado?
2. Email/Password está ativado?

### Erro: "Missing or insufficient permissions"
**Solução:** As regras do Firestore não foram publicadas.
1. Vá em Firestore Database → Rules
2. Copie o conteúdo de `firestore.rules`
3. Cole lá e clique em "Publicar"

### Erro: "Failed to get document"
**Solução:** Problema de conexão ou Firestore não inicializado.
1. Verifique sua internet
2. Reinicie o app

### App trava ao criar projeto
**Solução:** Erro no código ou regras bloqueando.
1. Copie TODOS os logs
2. Me envie para análise

---

## 📊 Resultado Esperado

Após criar o projeto, você deve:
1. ✅ Ver a tela Home
2. ✅ Ver o nome do projeto no topo
3. ✅ Ver o card "Próxima Ação"
4. ✅ Ver o resumo financeiro
5. ✅ Ver o grid de módulos

**Se chegou até aqui: SUCESSO! 🎉**

---

## 🆘 Precisa de Ajuda?

**Me envie:**
1. TODOS os logs do console (do início ao fim)
2. Em qual step parou
3. Screenshot do erro (se houver)
4. Screenshot do Firebase Console (Authentication + Firestore)

**Formato ideal:**
```
Parei no: [Step X]
Erro: [mensagem de erro]
Logs: [cole aqui]