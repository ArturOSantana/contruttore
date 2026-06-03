# 🧪 Guia de Teste - Onboarding Retroativo

## 📋 Pré-requisitos
- App compilado e rodando
- Firebase configurado
- Usuário autenticado

## 🎯 Objetivo do Teste
Verificar se o fluxo de onboarding retroativo funciona corretamente para usuários que já têm obra em andamento.

## 🔗 Como Acessar
1. Abrir o app
2. Fazer login
3. Navegar manualmente para `/retroactive-onboarding` (adicionar botão temporário ou usar deep link)

## ✅ Checklist de Teste

### Step 1: Seleção da Fase Atual
- [ ] Tela exibe título "Em qual fase sua obra está?"
- [ ] Lista mostra as 12 fases
- [ ] Consegue selecionar uma fase (ex: Fase 8 - Demolição)
- [ ] Botão "Próximo" fica habilitado após seleção
- [ ] Consegue avançar para Step 2

### Step 2: Total Gasto (Opcional)
- [ ] Tela exibe campo para informar total gasto
- [ ] Campo aceita valores monetários
- [ ] Consegue deixar em branco (opcional)
- [ ] Consegue avançar para Step 3

### Step 3: Fornecedores Ativos (Opcional)
- [ ] Tela exibe lista vazia inicialmente
- [ ] Botão "Adicionar Fornecedor" funciona
- [ ] Dialog abre com campos: Nome, Tipo, Telefone
- [ ] Consegue adicionar fornecedor
- [ ] Fornecedor aparece na lista
- [ ] Consegue remover fornecedor
- [ ] Consegue avançar para Step 4

### Step 4: Confirmação
- [ ] Tela exibe resumo dos dados informados
- [ ] Mostra fase selecionada
- [ ] Mostra total gasto (se informado)
- [ ] Mostra fornecedores (se informados)
- [ ] Botão "Confirmar" funciona

### Após Confirmação
- [ ] Loading aparece
- [ ] Navega para Home após sucesso
- [ ] Não exibe erro

## 🔍 Verificação no Firebase

### Projeto Criado
```
/projects/{projectId}
  - name: "Meu Projeto"
  - address: "Endereço não informado"
  - constructorName: "Construtora não informada"
  - currentSituation: "retroactive_phase_8" (exemplo)
  - totalBudget: {valor informado ou 0}
```

### Fases Geradas
```
/projects/{projectId}/phases
  - 12 documentos criados
  - Fases 1-7: status = "doneNoRecord"
  - Fase 8: status = "active"
  - Fases 9-12: status = "locked"
```

### Despesa Estimada (se informada)
```
/projects/{projectId}/expenses/{expenseId}
  - categoryId: "geral"
  - amount: {valor informado}
  - description: "Total gasto até o momento (estimativa)"
  - status: "estimated"
```

### Fornecedores (se informados)
```
/projects/{projectId}/suppliers/{supplierId}
  - name: {nome informado}
  - type: {tipo informado}
  - phone: {telefone informado}
  - status: "active"
  - notes: "Cadastrado via onboarding retroativo"
```

## ⚠️ Casos de Erro a Testar

1. **Tentar avançar sem selecionar fase**
   - Esperado: Mensagem de erro "Selecione a fase atual"

2. **Valor gasto inválido**
   - Esperado: Campo aceita apenas números e vírgula/ponto

3. **Fornecedor sem nome**
   - Esperado: Não permite adicionar

4. **Erro de conexão Firebase**
   - Esperado: Mensagem de erro amigável

## 📝 Observações

### Limitações Conhecidas
- Nome do projeto fixo: "Meu Projeto"
- Endereço fixo: "Endereço não informado"
- Construtora fixa: "Construtora não informada"
- Área: 0.0 m²
- Datas calculadas automaticamente

### Melhorias Futuras
- Adicionar Step 0 para coletar dados básicos do projeto
- Permitir editar dados do projeto após criação
- Adicionar validação de telefone
- Adicionar foto do fornecedor

## ✅ Critérios de Sucesso

O teste é considerado bem-sucedido se:
1. ✅ Consegue completar todos os 4 steps
2. ✅ Projeto é criado no Firebase
3. ✅ Fases anteriores marcadas como `doneNoRecord`
4. ✅ Despesa estimada criada (se informada)
5. ✅ Fornecedores cadastrados (se informados)
6. ✅ Navega para Home sem erros
7. ✅ Dados aparecem corretamente na Home

---

**Data do Teste**: _____/_____/_____
**Testador**: _____________________
**Resultado**: ⬜ Aprovado  ⬜ Reprovado
**Observações**: ___________________