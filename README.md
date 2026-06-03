# 🏗️ Costruttore

> Seu parceiro para gerenciar a obra do apartamento na planta

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 📋 Sobre o Projeto

O **Costruttore** é um aplicativo mobile desenvolvido em Flutter para ajudar pessoas que compraram apartamentos na planta a gerenciar todo o processo de acompanhamento da obra, reforma e mobília.

### 🎯 Problema que Resolve

Comprar um apartamento na planta é um processo longo e ansioso. O Costruttore organiza, explica, lembra e acalma, resolvendo três medos principais:

1. **Não saber o que está acontecendo** → Diário de obra com fotos e timeline
2. **Não saber o que fazer agora** → Próxima ação sempre sugerida
3. **Não saber quanto vai gastar** → Controle financeiro completo

---

## ✨ Features

### 🔐 Autenticação
- Login com email/senha
- Registro de novos usuários
- Recuperação de senha
- Persistência de sessão

### 🏠 Gestão de Projetos
- Múltiplos projetos por usuário
- Onboarding guiado (5 steps)
- Troca fácil entre projetos
- Dados isolados por projeto

### 📋 12 Fases do Projeto
**Jornada A - Comprador** (antes das chaves):
1. Assinatura e documentação
2. Acompanhamento da obra
3. Decisões de personalização
4. Preparação para entrega
5. Vistoria de entrega

**Jornada B - Reforma** (após as chaves):
6. Regularização pós-entrega
7. Projeto e planejamento
8. Demolição e limpeza
9. Instalações (hidráulica e elétrica)
10. Revestimentos e pisos
11. Gesso, pintura e acabamentos
12. Marcenaria e mobiliário

### 💰 Controle Financeiro
- CRUD de despesas
- 3 status: confirmado, comprometido, estimado
- Categorias pré-definidas
- Gráficos e relatórios
- Calculadora de custo total real
- Progresso por categoria

### 👷 Gestão de Fornecedores
- Cadastro completo de fornecedores
- 15+ tipos de profissionais
- Sistema de avaliação (1-5 estrelas)
- Múltiplos orçamentos por fornecedor
- Comparador de orçamentos
- Validação de CNPJ

### 💳 Controle de Parcelas
- Contratos com parcelas mensais
- Geração automática de datas
- Marcar como pago
- Integração automática com financeiro
- Alertas de vencimento
- Dashboard de pendências

### 📓 Diário de Obra
- 4 tipos de entrada (diário, visita, problema, entrega)
- Upload de fotos
- Timeline visual
- Modo vistoria com checklist
- Exportação para PDF
- Filtros por tipo e fase

### 🛒 Lista de Compras
- Itens organizados por fase
- Marcar como comprado
- Preço estimado vs real
- Sugestões automáticas
- Total estimado vs pago

### ❤️ Lista de Desejos
- Salvar links de produtos
- Grid visual com thumbnails
- Marcar como selecionado
- Mover para lista de compras
- Compartilhamento

### 🔔 Sistema de Alertas
- 4 tipos: crítico, preventivo, info, educativo
- Filtros por tipo
- Navegação contextual
- Sistema anti-fadiga
- Notificações locais

### 📖 Glossário
- 50+ termos técnicos
- Busca e filtros
- Glossário contextual
- Explicações didáticas

### 📄 Gestão de Documentos
- Upload de PDF e imagens
- 7 tipos de documento
- Alertas de vencimento
- Visualização inline

---

## 🏗️ Arquitetura

### Clean Architecture

```
┌─────────────────────────────────────────┐
│         PRESENTATION LAYER              │
│  (Pages, Widgets, Cubits, States)      │
└─────────────────────────────────────────┘
              ↓ ↑
┌─────────────────────────────────────────┐
│           DOMAIN LAYER                  │
│  (Entities, Repositories, Use Cases)   │
└─────────────────────────────────────────┘
              ↓ ↑
┌─────────────────────────────────────────┐
│            DATA LAYER                   │
│  (Models, Repository Impl, Data Sources)│
└─────────────────────────────────────────┘
              ↓ ↑
┌─────────────────────────────────────────┐
│         EXTERNAL SOURCES                │
│    (Firebase, Hive, APIs Externas)     │
└─────────────────────────────────────────┘
```

### Stack Tecnológica

**Core**:
- Flutter 3.x
- Dart 3.x (null-safety)

**State Management**:
- flutter_bloc 8.x (Cubit pattern)
- equatable 2.x

**Dependency Injection**:
- get_it 8.x
- injectable 2.x

**Navigation**:
- go_router 14.x

**Backend**:
- Firebase Auth
- Cloud Firestore
- Firebase Storage
- Firebase Messaging

**Cache Local**:
- Hive (offline-first)

**UI**:
- google_fonts (DM Sans)
- cached_network_image
- fl_chart (gráficos)
- shimmer (loading)

---

## 🚀 Como Começar

### Pré-requisitos

- Flutter 3.x ou superior
- Dart 3.x ou superior
- Android Studio / Xcode
- Firebase CLI (opcional)

### Instalação

1. **Clone o repositório**
```bash
git clone https://github.com/seu-usuario/contruttore.git
cd contruttore
```

2. **Execute o setup automatizado**
```bash
make setup
```

Ou manualmente:

```bash
# Obter dependências
flutter pub get

# Gerar código
flutter pub run build_runner build --delete-conflicting-outputs
```

3. **Configure o Firebase**

- Crie um projeto no [Firebase Console](https://console.firebase.google.com)
- Adicione os apps Android e iOS
- Baixe `google-services.json` e coloque em `android/app/`
- Baixe `GoogleService-Info.plist` e coloque em `ios/Runner/`

4. **Execute o app**
```bash
make run
```

Ou:

```bash
flutter run
```

---

## 📱 Comandos Úteis

O projeto inclui um **Makefile** com comandos úteis:

```bash
make help              # Mostra todos os comandos disponíveis
make setup             # Configura o ambiente
make run               # Executa o app
make test              # Executa testes
make analyze           # Analisa o código
make build-apk         # Gera APK de debug
make build-apk-release # Gera APK de release
make full-build        # Build completo (clean + get + build-runner + apk)
make ci                # Pipeline CI (format + analyze + test + build)
make stats             # Mostra estatísticas do projeto
```

---

## 📚 Documentação

- **[GUIA_TESTE_RAPIDO.md](GUIA_TESTE_RAPIDO.md)**: Guia completo de testes (15 cenários)
- **[ARQUITETURA.md](ARQUITETURA.md)**: Documentação técnica detalhada (1500 linhas)
- **[FIREBASE_SETUP.md](FIREBASE_SETUP.md)**: Configuração do Firebase
- **[DEPLOY_GUIDE.md](DEPLOY_GUIDE.md)**: Guia de deploy

---

## 🧪 Testes

### Executar todos os testes
```bash
make test
```

### Executar com cobertura
```bash
make test-coverage
```

### Análise estática
```bash
make analyze
```

---

## 📦 Build

### Android

**Debug APK**:
```bash
make build-apk
```

**Release APK**:
```bash
make build-apk-release
```

**App Bundle** (para Play Store):
```bash
make build-appbundle
```

### iOS

```bash
make build-ios
```

---

## 🎨 Design System

### Paleta de Cores

- **Primary**: Terracota queimado (#BF5942)
- **Background**: Areia clara (#F7F3EE)
- **Surface**: Branco (#FFFFFF)
- **Status**: Verde, Amarelo, Vermelho, Azul

### Tipografia

- **Fonte**: DM Sans (Google Fonts)
- **Tamanhos**: 12px a 28px
- **Pesos**: 400 (regular), 600 (semibold), 700 (bold)

### Espaçamento

Sistema baseado em 4pt: 4, 8, 12, 16, 24, 32, 48

---

## 🔥 Firebase

### Estrutura Firestore

```
/users/{userId}
/projects/{projectId}
  /phases/{phaseId}
  /expenses/{expenseId}
  /suppliers/{supplierId}
  /quotes/{quoteId}
  /installments/{installmentId}
  /diary/{entryId}
  /shopping/{itemId}
  /wishlist/{itemId}
  /documents/{docId}
  /alerts/{alertId}
/glossary/{termId}
```

### Firestore Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Usuários
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Projetos
    match /projects/{projectId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
      
      // Subcoleções
      match /{subcollection}/{docId} {
        allow read, write: if request.auth != null &&
          get(/databases/$(database)/documents/projects/$(projectId))
            .data.userId == request.auth.uid;
      }
    }
    
    // Glossário (público)
    match /glossary/{termId} {
      allow read: if request.auth != null;
    }
  }
}
```

---

## 🌐 APIs Externas

Todas as APIs são gratuitas e não requerem chave:

1. **ViaCEP**: Autopreenchimento de endereço
2. **BrasilAPI - Feriados**: Exclusão de feriados do cronograma
3. **BrasilAPI - CNPJ**: Validação de CNPJ
4. **Open-Meteo**: Alerta de chuva com fases sensíveis

---

## 📊 Estatísticas

- **Linhas de código**: ~15.000 linhas Dart
- **Features**: 15 módulos completos
- **Entities**: 15+ entidades de domínio
- **Use Cases**: 60+ casos de uso
- **Cubits**: 15+ gerenciadores de estado
- **Pages**: 30+ telas
- **Widgets reutilizáveis**: 8+

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Por favor:

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

### Padrões de Código

- Seguir Clean Architecture
- Usar Cubit para state management
- Sempre tratar erros com Either<Failure, Success>
- Adicionar testes para novas features
- Documentar código complexo

---

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

## 👨‍💻 Autor

**Bob (AI Assistant)**

- Desenvolvido com ❤️ usando Flutter
- Arquitetura: Clean Architecture
- Padrões: SOLID, DRY, KISS

---

## 🙏 Agradecimentos

- Flutter Team pela excelente framework
- Firebase pela infraestrutura
- Comunidade Flutter pelo suporte

---

## 📞 Suporte

Para suporte, abra uma issue no GitHub ou entre em contato:

- **Email**: suporte@costruttore.app
- **Website**: https://costruttore.app
- **GitHub**: https://github.com/seu-usuario/contruttore

---

## 🗺️ Roadmap

### v1.1.0
- [ ] Testes unitários completos
- [ ] Testes de integração
- [ ] Firebase Analytics
- [ ] Deep links

### v1.2.0
- [ ] Modo offline completo
- [ ] Sincronização em background
- [ ] Notificações push do servidor
- [ ] Compartilhamento de projetos

### v2.0.0
- [ ] Versão web
- [ ] Integração com Google Calendar
- [ ] Exportação de relatórios
- [ ] Modo escuro

---

## 📸 Screenshots

_Em breve_

---

**Costruttore** - Transformando a experiência de quem comprou na planta 🏗️✨
