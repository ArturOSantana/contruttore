# ✅ Checklist de Deploy - Costruttore

## 🔒 Segurança

- [ ] Firestore Rules implementadas e testadas
- [ ] Todo dado tem `projectId` vinculado
- [ ] Toda query filtra por `projectId` do projeto ativo
- [ ] FCM token salvo no Firestore por usuário
- [ ] Validação de entrada em todos os formulários
- [ ] Senhas nunca armazenadas em plain text
- [ ] Tokens de autenticação gerenciados pelo Firebase Auth
- [ ] Storage Rules configuradas para isolamento por usuário

## 💻 Qualidade de Código

- [ ] Nenhuma tela exibe tela em branco (empty states implementados)
- [ ] Shimmer em todos os loadings (substituiu CircularProgressIndicator)
- [ ] Loading state em toda operação assíncrona
- [ ] Erro tratado em toda operação (try-catch)
- [ ] Confirmação antes de deletar (ConfirmationDialog)
- [ ] `await` + reload em navegação que cria/edita dados
- [ ] Nenhum warning do Dart Analyzer
- [ ] Código formatado (`flutter format .`)
- [ ] Imports organizados

## 🎨 UX/UI

- [ ] Tap target mínimo 48px em elementos interativos
- [ ] Fonte mínima 16px em inputs (evita zoom iOS)
- [ ] Botão de voltar sempre disponível
- [ ] Nenhum overflow de layout em telas pequenas (375px)
- [ ] Feedback visual em todas as ações (loading, sucesso, erro)
- [ ] Empty states com ilustração e CTA
- [ ] Mensagens de erro claras e acionáveis
- [ ] Navegação intuitiva e consistente
- [ ] Cores acessíveis (contraste adequado)
- [ ] Animações suaves e não invasivas

## ⚙️ Funcionalidades Críticas

### Autenticação
- [ ] Login com email/senha funciona
- [ ] Registro de novo usuário funciona
- [ ] Recuperação de senha funciona
- [ ] Logout funciona e limpa dados locais
- [ ] Sessão persiste após fechar app

### Projetos
- [ ] Criar projeto → dados salvos corretamente
- [ ] Editar projeto → alterações persistem
- [ ] Deletar projeto → confirmação e remoção completa
- [ ] Trocar projeto → todos módulos recarregam
- [ ] Projeto ativo persiste após fechar app

### Financeiro
- [ ] Criar despesa → vinculada ao projeto correto
- [ ] Editar despesa → alterações refletem no total
- [ ] Deletar despesa → confirmação e atualização do total
- [ ] Filtros funcionam corretamente
- [ ] Gráficos exibem dados corretos
- [ ] Exportar PDF funciona

### Fornecedores
- [ ] Criar fornecedor → vinculação correta
- [ ] Validação CNPJ funciona (BrasilAPI)
- [ ] Adicionar orçamento funciona
- [ ] Aceitar orçamento → cria compromisso no financeiro
- [ ] Comparador de orçamentos funciona

### Parcelas
- [ ] Criar parcela → vinculada ao fornecedor
- [ ] Pagar parcela → lançamento no financeiro
- [ ] Alertas de vencimento funcionam
- [ ] Histórico de pagamentos correto

### Diário
- [ ] Adicionar entrada com foto funciona
- [ ] Timeline ordenada corretamente
- [ ] Filtros por tipo funcionam
- [ ] Exportar PDF funciona
- [ ] Compartilhar funciona

### Listas (Compras e Desejos)
- [ ] Adicionar item funciona
- [ ] Marcar como comprado funciona
- [ ] Mover entre listas funciona
- [ ] Deletar item funciona

### Documentos
- [ ] Upload de arquivo funciona
- [ ] Visualização de documento funciona
- [ ] Alertas de vencimento funcionam
- [ ] Download funciona

### Alertas
- [ ] Notificações push funcionam (foreground)
- [ ] Notificações push funcionam (background)
- [ ] Notificações push funcionam (app killed)
- [ ] Tap em notificação navega para tela correta
- [ ] Sistema anti-fadiga funciona

### Glossário
- [ ] Busca funciona
- [ ] Favoritos funcionam
- [ ] Termos carregam corretamente

## 🚀 Performance

- [ ] Imagens otimizadas (cached_network_image)
- [ ] Listas com lazy loading
- [ ] Cache local funcionando (Hive)
- [ ] Queries Firestore otimizadas (índices criados)
- [ ] App inicia em menos de 2 segundos
- [ ] Navegação fluida (60fps)
- [ ] Sem memory leaks (dispose correto)
- [ ] Bundle size < 20MB

## 📱 Compatibilidade

### Android
- [ ] Testado em Android 8.0+ (API 26+)
- [ ] Testado em diferentes tamanhos de tela
- [ ] Permissões solicitadas corretamente
- [ ] Deep links funcionam
- [ ] Notificações funcionam

### iOS
- [ ] Testado em iOS 12.0+
- [ ] Testado em diferentes tamanhos de tela (iPhone SE ao Pro Max)
- [ ] Permissões solicitadas corretamente
- [ ] Deep links funcionam
- [ ] Notificações funcionam

## 🌐 Offline

- [ ] App funciona sem internet (cache)
- [ ] Sincronização automática ao voltar online
- [ ] Mensagem clara quando offline
- [ ] Operações críticas bloqueadas quando offline

## 🧪 Testes

### Testes Manuais
- [ ] Fluxo completo de onboarding
- [ ] Criar projeto e todas as entidades
- [ ] Trocar entre projetos
- [ ] Receber notificações
- [ ] Exportar PDFs
- [ ] Funcionar offline (cache)
- [ ] Testar em dispositivos reais (Android e iOS)
- [ ] Testar em diferentes tamanhos de tela
- [ ] Testar com dados reais (não apenas mock)

### Testes Automatizados
- [ ] Testes unitários passam (`flutter test`)
- [ ] Cobertura de código > 70%
- [ ] Testes de widget críticos implementados

## 📦 Build

### Android
- [ ] Build release funciona (`flutter build apk --release`)
- [ ] APK assinado corretamente
- [ ] Ícone do app configurado
- [ ] Splash screen configurada
- [ ] Versão e build number atualizados
- [ ] ProGuard configurado (se necessário)

### iOS
- [ ] Build release funciona (`flutter build ios --release`)
- [ ] Certificados e provisioning profiles configurados
- [ ] Ícone do app configurado
- [ ] Splash screen configurada
- [ ] Versão e build number atualizados
- [ ] Info.plist configurado (permissões)

## 🔥 Firebase

- [ ] Projeto Firebase em modo produção
- [ ] Firestore Rules em produção
- [ ] Storage Rules em produção
- [ ] Authentication configurado
- [ ] Cloud Messaging configurado
- [ ] Índices Firestore criados
- [ ] Quotas e limites verificados
- [ ] Billing configurado (se necessário)

## 📄 Documentação

- [ ] README.md completo e atualizado
- [ ] CHANGELOG.md atualizado
- [ ] Comentários em código crítico
- [ ] Documentação de APIs externas
- [ ] Guia de contribuição (se open source)

## 🚀 Deploy

### Google Play Store
- [ ] Conta de desenvolvedor ativa
- [ ] Listing completo (título, descrição, screenshots)
- [ ] Política de privacidade publicada
- [ ] Termos de uso publicados
- [ ] Classificação etária definida
- [ ] Categorias selecionadas
- [ ] APK/AAB enviado

### Apple App Store
- [ ] Conta de desenvolvedor ativa
- [ ] App Store Connect configurado
- [ ] Listing completo (título, descrição, screenshots)
- [ ] Política de privacidade publicada
- [ ] Termos de uso publicados
- [ ] Classificação etária definida
- [ ] Categorias selecionadas
- [ ] Build enviado para revisão

## 📊 Monitoramento

- [ ] Firebase Analytics configurado
- [ ] Crashlytics configurado
- [ ] Performance Monitoring configurado
- [ ] Alertas de erro configurados
- [ ] Dashboard de métricas criado

## 🎯 Pós-Deploy

- [ ] Testar app da loja (não sideload)
- [ ] Monitorar crashes nas primeiras 24h
- [ ] Monitorar reviews e responder
- [ ] Preparar hotfix se necessário
- [ ] Comunicar lançamento (redes sociais, email, etc)

---

## 📝 Notas Importantes

### Prioridades
1. **Segurança** - Nunca comprometer
2. **Qualidade** - Bugs críticos devem ser corrigidos
3. **Performance** - App deve ser fluido

### Antes de Cada Deploy
1. Testar em dispositivos reais
2. Verificar Firestore Rules
3. Atualizar versão no pubspec.yaml
4. Criar tag no Git
5. Gerar changelog

### Em Caso de Problema Crítico
1. Reverter para versão anterior
2. Investigar e corrigir
3. Testar extensivamente
4. Deploy de hotfix

---

**Made with Bob** 🤖