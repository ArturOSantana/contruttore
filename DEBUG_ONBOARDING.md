# 🔍 Debug do Onboarding - Costruttore

## Problema Atual
O botão "Criar Projeto" não está funcionando quando pressionado.

## ✅ O que já foi feito

1. **Validações adicionadas** - O botão agora valida:
   - Nome do projeto obrigatório
   - Nome da construtora obrigatório
   - Situação atual obrigatória

2. **Logs de debug adicionados** - Cada etapa imprime no console:
   ```
   🔵 [ONBOARDING] Botão Criar Projeto pressionado
   🔵 [ONBOARDING] Cubit obtido: OnboardingCubit
   🔵 [ONBOARDING] Preparando dados do projeto...
   ```

3. **Valores padrão** - Campos vazios recebem valores padrão inteligentes

## 🧪 Como Testar

### Opção 1: Via VS Code (Recomendado)

1. **Pare o app atual** (se estiver rodando)

2. **Limpe o build**:
   ```bash
   flutter clean
   flutter pub get
   ```

3. **Rode em modo debug**:
   ```bash
   flutter run --debug
   ```

4. **Observe o console do VS Code** - Os logs 🔵 devem aparecer quando você clicar em "Criar Projeto"

### Opção 2: Via Android Studio

1. **Pare o app atual**

2. **Limpe o projeto**: Build → Clean Project

3. **Rode em modo debug**: Run → Debug 'app'

4. **Abra o Logcat**: View → Tool Windows → Logcat

5. **Filtre por "ONBOARDING"** na barra de busca do Logcat

6. **Clique em "Criar Projeto"** e observe os logs

### Opção 3: Hot Restart Manual

Se o app já está rodando:

1. **No terminal onde o Flutter está rodando**, pressione:
   - `R` (maiúsculo) para Hot Restart completo
   - Ou `r` (minúsculo) para Hot Reload

2. **Navegue até o onboarding** novamente

3. **Preencha os campos** e clique em "Criar Projeto"

4. **Observe o console** do terminal

## 🔍 O que Procurar nos Logs

### ✅ Logs Esperados (Sucesso)
```
🔵 [ONBOARDING] Botão Criar Projeto pressionado
🔵 [ONBOARDING] Cubit obtido: OnboardingCubit
🔵 [ONBOARDING] Preparando dados do projeto...
  - Nome: Apt Brooklin
  - Construtora: Construtora XYZ
  - Situação: a
  - Orçamento: 50000.0
🔵 [ONBOARDING] Inicializando estado InProgress
🔵 [ONBOARDING] Atualizando dados no cubit...
🔵 [ONBOARDING] Chamando completeOnboarding...
```

### ❌ Possíveis Erros

**1. Nenhum log aparece:**
- O app não foi recompilado com as mudanças
- Solução: Fazer Hot Restart (R maiúsculo) ou recompilar

**2. Aparece erro de Firebase:**
```
[ERROR:flutter/runtime/dart_vm_initializer.cc(41)] Unhandled Exception: 
[firebase_auth/no-current-user] No user currently signed in.
```
- O usuário não está autenticado
- Solução: Fazer login antes de acessar o onboarding

**3. Aparece erro de Firestore:**
```
[ERROR:flutter/runtime/dart_vm_initializer.cc(41)] Unhandled Exception:
[cloud_firestore/permission-denied] Missing or insufficient permissions.
```
- Regras do Firestore estão bloqueando
- Solução: Verificar `firestore.rules`

**4. Aparece erro de injeção de dependência:**
```
[ERROR:flutter/runtime/dart_vm_initializer.cc(41)] Unhandled Exception:
GetIt: Object/factory with type OnboardingCubit is not registered
```
- O cubit não foi registrado no GetIt
- Solução: Verificar `injection_container.dart`

## 🐛 Checklist de Debug

- [ ] App foi recompilado após as mudanças? (`flutter run` ou Hot Restart)
- [ ] Usuário está autenticado? (fez login antes do onboarding)
- [ ] Firebase está configurado? (google-services.json presente)
- [ ] Todos os campos obrigatórios foram preenchidos?
- [ ] Console do Flutter está visível e mostrando logs?
- [ ] Há algum erro vermelho no console?

## 📝 Próximos Passos

1. **Siga uma das opções de teste acima**
2. **Copie TODOS os logs** que aparecem no console
3. **Envie os logs** para análise
4. **Informe se algum SnackBar apareceu** (mensagem de validação)

## 🔧 Comandos Úteis

```bash
# Limpar build e reinstalar
flutter clean
flutter pub get
flutter run --debug

# Ver logs em tempo real (se adb estiver configurado)
flutter logs

# Reinstalar app no dispositivo
flutter install

# Verificar dispositivos conectados
flutter devices
```

## 📱 Teste Rápido

Para testar rapidamente se o botão está funcionando:

1. Preencha apenas:
   - Nome do projeto: "Teste"
   - Nome da construtora: "Teste"
   - Selecione qualquer situação

2. Clique em "Criar Projeto"

3. Se aparecer um SnackBar vermelho com mensagem de erro → validação funcionando ✅
4. Se não aparecer nada → problema no evento de clique ❌
5. Se aparecer loading → está tentando criar o projeto ✅

---

**Última atualização:** 2026-06-02