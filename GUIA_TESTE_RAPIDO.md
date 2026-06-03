# 🧪 Guia de Teste Rápido - Costruttore

## 🎯 Objetivo
Este guia ajuda a testar rapidamente todas as funcionalidades do app após o build.

---

## 📱 Pré-requisitos

1. ✅ APK instalado no dispositivo/emulador
2. ✅ Conexão com internet (para Firebase)
3. ✅ Firebase configurado corretamente

---

## 🔐 Teste 1: Autenticação (5 min)

### 1.1 Registro
```
1. Abrir app → Splash → Login
2. Clicar em "Criar conta"
3. Preencher: email, senha, confirmar senha
4. Clicar em "Registrar"
✅ Deve redirecionar para Onboarding
```

### 1.2 Login
```
1. Fazer logout (se logado)
2. Preencher email e senha
3. Clicar em "Entrar"
✅ Deve redirecionar para Home (se tem projeto) ou Onboarding (se não tem)
```

### 1.3 Recuperar Senha
```
1. Na tela de login, clicar "Esqueci minha senha"
2. Digitar email
3. Clicar em "Enviar"
✅ Deve mostrar mensagem de sucesso
✅ Verificar email recebido
```

---

## 🏗️ Teste 2: Onboarding (5 min)

### 2.1 Criar Primeiro Projeto
```
Step 1: Nome do projeto
- Digitar: "Meu Apartamento"
- Clicar "Próximo"

Step 2: Dados do imóvel
- Construtora: "Construtora XYZ"
- Endereço: "Rua ABC, 123"
- Área: "80"
- Data de entrega: selecionar data futura
- Data do contrato: selecionar data passada
- Clicar "Próximo"

Step 3: Situação atual
- Selecionar: "Acabei de assinar o contrato"
- Clicar "Próximo"

Step 4: Orçamento
- Selecionar: "Sim"
- Digitar: "50000"
- Clicar "Próximo"

Step 5: Confirmar
- Revisar dados
- Clicar "Criar meu projeto"

✅ Deve redirecionar para Home
✅ Deve mostrar nome do projeto no topo
```

---

## 🏠 Teste 3: Home (3 min)

### 3.1 Verificar Dashboard
```
1. Verificar saudação com nome do usuário
2. Verificar nome do projeto
3. Verificar card "Próxima Ação"
4. Verificar resumo financeiro
5. Verificar grid de módulos (8 cards)

✅ Todos os elementos devem estar visíveis
✅ Valores devem estar zerados (projeto novo)
```

### 3.2 Bottom Navigation
```
1. Clicar em cada item do bottom nav:
   - 🏠 Início
   - 📋 Fases
   - 💰 Financeiro
   - 👷 Fornecedores

✅ Deve navegar para cada tela
✅ Item selecionado deve estar destacado
```

---

## 📋 Teste 4: Fases (5 min)

### 4.1 Visualizar Fases
```
1. Home → Clicar em "Fases" (bottom nav ou grid)
2. Verificar lista das 12 fases
3. Verificar status de cada fase:
   - Fases 1-4: Active (amarelo)
   - Fases 5-12: Locked (cinza)

✅ Deve mostrar 12 fases
✅ Status correto baseado no onboarding
```

### 4.2 Detalhes da Fase
```
1. Clicar em "Fase 1 - Assinatura e documentação"
2. Verificar subtarefas obrigatórias
3. Marcar uma subtarefa como concluída
4. Verificar progresso atualizado

✅ Progresso deve aumentar
✅ Checkbox deve ficar marcado
```

---

## 💰 Teste 5: Financeiro (10 min)

### 5.1 Adicionar Despesa
```
1. Home → Financeiro
2. Clicar no botão "+" (FAB)
3. Preencher:
   - Categoria: "Elétrica"
   - Valor: "1500"
   - Data: hoje
   - Descrição: "Quadro de distribuição"
   - Status: "Confirmado"
4. Clicar "Salvar"

✅ Deve voltar para lista
✅ Despesa deve aparecer na lista
✅ Resumo deve atualizar
```

### 5.2 Verificar Resumo
```
1. Verificar card de resumo no topo
2. Verificar gráfico de rosca (se houver)
3. Verificar progresso por categoria

✅ Total gasto deve mostrar R$ 1.500,00
✅ Categoria "Elétrica" deve ter progresso
```

### 5.3 Editar Despesa
```
1. Clicar em uma despesa da lista
2. Alterar valor para "2000"
3. Salvar

✅ Valor deve atualizar na lista
✅ Resumo deve recalcular
```

### 5.4 Deletar Despesa
```
1. Clicar em uma despesa
2. Clicar no ícone de lixeira
3. Confirmar exclusão

✅ Deve mostrar diálogo de confirmação
✅ Despesa deve sumir da lista
✅ Resumo deve recalcular
```

---

## 👷 Teste 6: Fornecedores (10 min)

### 6.1 Adicionar Fornecedor
```
1. Home → Fornecedores
2. Clicar no botão "+"
3. Preencher:
   - Nome: "João Eletricista"
   - Tipo: "Eletricista"
   - Telefone: "11999999999"
   - Email: "joao@email.com"
   - CPF: "12345678900"
4. Clicar "Salvar"

✅ Deve voltar para lista
✅ Fornecedor deve aparecer
```

### 6.2 Adicionar Orçamento
```
1. Clicar no fornecedor criado
2. Clicar em "Adicionar Orçamento"
3. Preencher:
   - Descrição: "Instalação elétrica completa"
   - Valor total: "5000"
   - Validade: data futura
4. Adicionar itens:
   - "Mão de obra" - 1 - "serviço" - 3000
   - "Material" - 1 - "conjunto" - 2000
5. Salvar

✅ Orçamento deve aparecer no fornecedor
```

### 6.3 Avaliar Fornecedor
```
1. Marcar serviço como concluído
2. Avaliar:
   - Prazo: 5 estrelas
   - Qualidade: 5 estrelas
   - Comunicação: 4 estrelas
3. Salvar avaliação

✅ Média deve aparecer no card do fornecedor
```

---

## 💳 Teste 7: Parcelas (10 min)

### 7.1 Criar Contrato com Parcelas
```
1. Home → Parcelas
2. Clicar no botão "+"
3. Preencher:
   - Fornecedor: selecionar "João Eletricista"
   - Descrição: "Instalação elétrica"
   - Valor total: "6000"
   - Número de parcelas: "3"
   - Data do contrato: hoje
   - Primeira parcela: hoje + 30 dias
4. Salvar

✅ Deve gerar 3 parcelas automaticamente
✅ Datas devem ser mensais
```

### 7.2 Marcar Parcela como Paga
```
1. Clicar em uma parcela
2. Clicar "Marcar como paga"
3. Confirmar valor: "2000"
4. Confirmar data: hoje
5. Salvar

✅ Parcela deve ficar marcada como paga
✅ Deve criar despesa no Financeiro automaticamente
✅ Dashboard deve atualizar
```

---

## 📓 Teste 8: Diário de Obra (10 min)

### 8.1 Adicionar Entrada Diária
```
1. Home → Diário
2. Clicar no botão "+"
3. Selecionar tipo: "Registro diário"
4. Preencher:
   - Título: "Início da obra"
   - Descrição: "Primeira visita ao canteiro"
   - Fase: "Fase 1"
   - Data: hoje
5. Adicionar foto (câmera ou galeria)
6. Salvar

✅ Entrada deve aparecer na timeline
✅ Foto deve estar visível
```

### 8.2 Registrar Problema
```
1. Adicionar nova entrada
2. Tipo: "Problema"
3. Preencher:
   - Título: "Infiltração detectada"
   - Descrição: "Parede do banheiro com umidade"
   - Gravidade: "Alta"
   - Fornecedor: selecionar
4. Adicionar foto do problema
5. Salvar

✅ Deve aparecer com ícone de alerta
✅ Deve criar alerta automático
```

### 8.3 Exportar PDF
```
1. Na lista do diário, clicar no botão de menu
2. Selecionar "Exportar PDF"
3. Escolher período ou "Tudo"
4. Gerar PDF

✅ Deve gerar PDF com todas as entradas
✅ Fotos devem estar incluídas
```

---

## 🛒 Teste 9: Lista de Compras (5 min)

### 9.1 Adicionar Item
```
1. Home → Compras
2. Clicar no botão "+"
3. Preencher:
   - Nome: "Tomadas 2P+T"
   - Categoria: "Elétrica"
   - Quantidade: "20"
   - Unidade: "un"
   - Preço estimado: "15"
   - Fase: "Fase 9"
4. Salvar

✅ Item deve aparecer na lista
✅ Total estimado deve atualizar
```

### 9.2 Marcar como Comprado
```
1. Clicar no checkbox do item
2. Preencher:
   - Preço real: "12"
   - Loja: "Leroy Merlin"
3. Confirmar

✅ Item deve ficar marcado
✅ Total pago deve atualizar
✅ Economia deve ser calculada
```

---

## ❤️ Teste 10: Lista de Desejos (5 min)

### 10.1 Adicionar Item
```
1. Home → Desejos
2. Clicar no botão "+"
3. Preencher:
   - Nome: "Sofá Retrátil"
   - URL: "https://www.loja.com/sofa"
   - Categoria: "Mobiliário"
   - Preço: "2500"
   - Loja: "Tok&Stok"
4. Salvar

✅ Item deve aparecer no grid
✅ Thumbnail deve carregar (se URL válida)
```

### 10.2 Marcar como Selecionado
```
1. Clicar no item
2. Clicar em "Marcar como selecionado"

✅ Item deve ir para o topo
✅ Deve ter indicador visual
```

### 10.3 Mover para Compras
```
1. Clicar no item selecionado
2. Clicar "Mover para lista de compras"
3. Confirmar

✅ Deve criar item na lista de compras
✅ Item permanece na wishlist
```

---

## 🔔 Teste 11: Alertas (5 min)

### 11.1 Visualizar Alertas
```
1. Home → Alertas
2. Verificar lista de alertas
3. Verificar tipos:
   - 🔴 Crítico (parcela vencida)
   - ⚠️ Preventivo (parcela vencendo)
   - ℹ️ Info (lembrete)
   - 📚 Educativo (dica)

✅ Alertas devem estar ordenados por prioridade
```

### 11.2 Marcar como Lido
```
1. Clicar em um alerta
2. Clicar "Marcar como lido"

✅ Alerta deve ficar com opacidade reduzida
✅ Badge no ícone deve diminuir
```

### 11.3 Ação do Alerta
```
1. Clicar em um alerta com ação
2. Clicar no botão de ação

✅ Deve navegar para tela relacionada
✅ Contexto deve estar correto
```

---

## 📖 Teste 12: Glossário (3 min)

### 12.1 Buscar Termo
```
1. Home → Glossário
2. Digitar na busca: "ART"
3. Clicar no resultado

✅ Deve mostrar definição completa
✅ Deve mostrar "Por que importa"
✅ Deve mostrar termos relacionados
```

### 12.2 Filtrar por Categoria
```
1. Clicar no filtro
2. Selecionar "Documentação e legal"

✅ Deve mostrar apenas termos da categoria
```

---

## 📄 Teste 13: Documentos (5 min)

### 13.1 Upload de Documento
```
1. Home → Documentos
2. Clicar no botão "+"
3. Preencher:
   - Tipo: "Contrato"
   - Nome: "Contrato de Compra e Venda"
   - Data de recebimento: hoje
4. Selecionar arquivo (PDF ou foto)
5. Salvar

✅ Documento deve aparecer na lista
✅ Thumbnail deve carregar
```

### 13.2 Visualizar Documento
```
1. Clicar no documento
2. Verificar visualização

✅ PDF deve abrir corretamente
✅ Imagem deve estar legível
```

---

## ⚙️ Teste 14: Configurações (3 min)

### 14.1 Perfil
```
1. Home → Menu → Configurações
2. Clicar em "Perfil"
3. Verificar dados do usuário

✅ Nome e email devem estar corretos
```

### 14.2 Notificações
```
1. Configurações → Notificações
2. Ativar/desativar notificações
3. Configurar horário silencioso

✅ Configurações devem ser salvas
```

---

## 🔄 Teste 15: Navegação e Performance (5 min)

### 15.1 Navegação Rápida
```
1. Navegar entre todas as telas rapidamente
2. Usar bottom nav
3. Usar drawer
4. Usar botão voltar

✅ Navegação deve ser fluida
✅ Sem travamentos
✅ Sem memory leaks
```

### 15.2 Pull to Refresh
```
1. Em qualquer lista, puxar para baixo
2. Aguardar reload

✅ Indicador de loading deve aparecer
✅ Lista deve recarregar
```

### 15.3 Offline
```
1. Desativar internet
2. Navegar pelo app
3. Tentar adicionar item

✅ Dados em cache devem aparecer
✅ Deve mostrar mensagem de offline ao tentar salvar
```

---

## ✅ Checklist Final

### Funcionalidades Básicas
- [ ] Login funciona
- [ ] Registro funciona
- [ ] Onboarding completo
- [ ] Home carrega corretamente
- [ ] Navegação fluida

### CRUD Completo
- [ ] Fases: visualizar e marcar subtarefas
- [ ] Financeiro: criar, editar, deletar despesas
- [ ] Fornecedores: criar, editar, deletar, avaliar
- [ ] Parcelas: criar contrato, marcar como pago
- [ ] Diário: criar entradas, adicionar fotos
- [ ] Compras: adicionar, marcar como comprado
- [ ] Desejos: adicionar, marcar, mover para compras
- [ ] Alertas: visualizar, marcar como lido
- [ ] Documentos: upload, visualizar

### Integrações
- [ ] Firebase Auth funcionando
- [ ] Firestore salvando dados
- [ ] Storage fazendo upload de fotos
- [ ] Notificações locais agendadas

### Performance
- [ ] App inicia em < 3 segundos
- [ ] Navegação sem lag
- [ ] Listas rolam suavemente
- [ ] Imagens carregam rápido

### UX
- [ ] Loading states visíveis
- [ ] Error states com retry
- [ ] Empty states com CTA
- [ ] Confirmações antes de deletar
- [ ] Mensagens de sucesso/erro

---

## 🐛 Bugs Conhecidos

Nenhum bug conhecido no momento. Se encontrar algum, documente aqui:

```
1. [Descrição do bug]
   - Como reproduzir:
   - Comportamento esperado:
   - Comportamento atual:
   - Prioridade: Alta/Média/Baixa
```

---

## 📊 Métricas de Sucesso

### Tempo de Teste Completo
- Estimado: 90 minutos
- Real: _____ minutos

### Taxa de Sucesso
- Testes passados: _____ / 15
- Porcentagem: _____%

### Problemas Encontrados
- Críticos: _____
- Médios: _____
- Baixos: _____

---

## 🎯 Próximos Passos

Após completar todos os testes:

1. [ ] Documentar bugs encontrados
2. [ ] Priorizar correções
3. [ ] Testar em diferentes dispositivos
4. [ ] Testar em diferentes versões do Android
5. [ ] Preparar para testes com usuários reais

---

**Última atualização**: 02/06/2026
**Versão do app**: 1.0.0-debug
**Testado por**: _____________