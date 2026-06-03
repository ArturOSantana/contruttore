# 🏗️ Makefile - Costruttore
# Comandos úteis para desenvolvimento

.PHONY: help setup clean get build-runner run test analyze format build-apk build-ios install doctor

# Comando padrão
.DEFAULT_GOAL := help

# Cores para output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m # No Color

## help: Mostra esta mensagem de ajuda
help:
	@echo "$(BLUE)Costruttore - Comandos Disponíveis$(NC)"
	@echo "===================================="
	@echo ""
	@grep -E '^## ' $(MAKEFILE_LIST) | sed 's/## //' | awk 'BEGIN {FS = ":"}; {printf "$(GREEN)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""

## setup: Configura o ambiente de desenvolvimento
setup:
	@echo "$(BLUE)🚀 Configurando ambiente...$(NC)"
	@chmod +x scripts/setup.sh
	@./scripts/setup.sh

## clean: Limpa o projeto
clean:
	@echo "$(BLUE)🧹 Limpando projeto...$(NC)"
	@flutter clean
	@rm -rf build/
	@rm -rf .dart_tool/
	@echo "$(GREEN)✓ Projeto limpo$(NC)"

## get: Obtém as dependências
get:
	@echo "$(BLUE)📦 Obtendo dependências...$(NC)"
	@flutter pub get
	@echo "$(GREEN)✓ Dependências obtidas$(NC)"

## build-runner: Gera código com build_runner
build-runner:
	@echo "$(BLUE)⚙️  Gerando código...$(NC)"
	@flutter pub run build_runner build --delete-conflicting-outputs
	@echo "$(GREEN)✓ Código gerado$(NC)"

## watch: Observa mudanças e regenera código automaticamente
watch:
	@echo "$(BLUE)👀 Observando mudanças...$(NC)"
	@flutter pub run build_runner watch --delete-conflicting-outputs

## run: Executa o app no dispositivo conectado
run:
	@echo "$(BLUE)🚀 Executando app...$(NC)"
	@flutter run

## run-release: Executa o app em modo release
run-release:
	@echo "$(BLUE)🚀 Executando app (release)...$(NC)"
	@flutter run --release

## test: Executa todos os testes
test:
	@echo "$(BLUE)🧪 Executando testes...$(NC)"
	@flutter test
	@echo "$(GREEN)✓ Testes concluídos$(NC)"

## test-coverage: Executa testes com cobertura
test-coverage:
	@echo "$(BLUE)🧪 Executando testes com cobertura...$(NC)"
	@flutter test --coverage
	@echo "$(GREEN)✓ Cobertura gerada em coverage/lcov.info$(NC)"

## analyze: Analisa o código
analyze:
	@echo "$(BLUE)🔍 Analisando código...$(NC)"
	@flutter analyze
	@echo "$(GREEN)✓ Análise concluída$(NC)"

## format: Formata o código
format:
	@echo "$(BLUE)✨ Formatando código...$(NC)"
	@dart format lib/ test/
	@echo "$(GREEN)✓ Código formatado$(NC)"

## format-check: Verifica formatação sem modificar
format-check:
	@echo "$(BLUE)🔍 Verificando formatação...$(NC)"
	@dart format --set-exit-if-changed lib/ test/

## build-apk: Gera APK de debug
build-apk:
	@echo "$(BLUE)📦 Gerando APK (debug)...$(NC)"
	@flutter build apk --debug
	@echo "$(GREEN)✓ APK gerado em build/app/outputs/flutter-apk/app-debug.apk$(NC)"

## build-apk-release: Gera APK de release
build-apk-release:
	@echo "$(BLUE)📦 Gerando APK (release)...$(NC)"
	@flutter build apk --release
	@echo "$(GREEN)✓ APK gerado em build/app/outputs/flutter-apk/app-release.apk$(NC)"

## build-appbundle: Gera App Bundle para Play Store
build-appbundle:
	@echo "$(BLUE)📦 Gerando App Bundle...$(NC)"
	@flutter build appbundle --release
	@echo "$(GREEN)✓ App Bundle gerado em build/app/outputs/bundle/release/app-release.aab$(NC)"

## build-ios: Gera build para iOS
build-ios:
	@echo "$(BLUE)📦 Gerando build iOS...$(NC)"
	@flutter build ios --release
	@echo "$(GREEN)✓ Build iOS concluído$(NC)"

## install: Instala o app no dispositivo conectado
install:
	@echo "$(BLUE)📲 Instalando app...$(NC)"
	@flutter install
	@echo "$(GREEN)✓ App instalado$(NC)"

## devices: Lista dispositivos conectados
devices:
	@echo "$(BLUE)📱 Dispositivos conectados:$(NC)"
	@flutter devices

## doctor: Verifica a instalação do Flutter
doctor:
	@echo "$(BLUE)🏥 Verificando instalação do Flutter...$(NC)"
	@flutter doctor -v

## upgrade: Atualiza dependências
upgrade:
	@echo "$(BLUE)⬆️  Atualizando dependências...$(NC)"
	@flutter pub upgrade
	@echo "$(GREEN)✓ Dependências atualizadas$(NC)"

## outdated: Verifica dependências desatualizadas
outdated:
	@echo "$(BLUE)📊 Verificando dependências desatualizadas...$(NC)"
	@flutter pub outdated

## icons: Gera ícones do app
icons:
	@echo "$(BLUE)🎨 Gerando ícones...$(NC)"
	@flutter pub run flutter_launcher_icons
	@echo "$(GREEN)✓ Ícones gerados$(NC)"

## splash: Gera splash screen
splash:
	@echo "$(BLUE)🎨 Gerando splash screen...$(NC)"
	@flutter pub run flutter_native_splash:create
	@echo "$(GREEN)✓ Splash screen gerado$(NC)"

## l10n: Gera arquivos de localização
l10n:
	@echo "$(BLUE)🌍 Gerando arquivos de localização...$(NC)"
	@flutter gen-l10n
	@echo "$(GREEN)✓ Localização gerada$(NC)"

## firebase-deploy: Deploy das Firestore Rules
firebase-deploy:
	@echo "$(BLUE)🔥 Fazendo deploy das Firestore Rules...$(NC)"
	@firebase deploy --only firestore:rules
	@echo "$(GREEN)✓ Rules deployadas$(NC)"

## firebase-emulators: Inicia emuladores do Firebase
firebase-emulators:
	@echo "$(BLUE)🔥 Iniciando emuladores do Firebase...$(NC)"
	@firebase emulators:start

## logs: Mostra logs do dispositivo
logs:
	@echo "$(BLUE)📋 Mostrando logs...$(NC)"
	@flutter logs

## screenshot: Tira screenshot do app
screenshot:
	@echo "$(BLUE)📸 Tirando screenshot...$(NC)"
	@flutter screenshot

## full-build: Limpa, obtém dependências, gera código e builda
full-build: clean get build-runner build-apk
	@echo "$(GREEN)✓ Build completo concluído!$(NC)"

## ci: Executa pipeline de CI (análise + testes + build)
ci: format-check analyze test build-apk
	@echo "$(GREEN)✓ Pipeline CI concluído!$(NC)"

## dev: Setup completo para desenvolvimento
dev: clean get build-runner
	@echo "$(GREEN)✓ Ambiente de desenvolvimento pronto!$(NC)"
	@echo "$(YELLOW)Execute 'make run' para iniciar o app$(NC)"

## release: Prepara release completa
release: clean get build-runner test analyze build-apk-release build-appbundle
	@echo "$(GREEN)✓ Release preparado!$(NC)"
	@echo "$(YELLOW)APK: build/app/outputs/flutter-apk/app-release.apk$(NC)"
	@echo "$(YELLOW)AAB: build/app/outputs/bundle/release/app-release.aab$(NC)"

## stats: Mostra estatísticas do projeto
stats:
	@echo "$(BLUE)📊 Estatísticas do Projeto$(NC)"
	@echo "=========================="
	@echo ""
	@echo "$(GREEN)Linhas de código Dart:$(NC)"
	@find lib -name "*.dart" | xargs wc -l | tail -1
	@echo ""
	@echo "$(GREEN)Número de arquivos Dart:$(NC)"
	@find lib -name "*.dart" | wc -l
	@echo ""
	@echo "$(GREEN)Features implementadas:$(NC)"
	@ls -1 lib/features | wc -l
	@echo ""
	@echo "$(GREEN)Tamanho do projeto:$(NC)"
	@du -sh .
	@echo ""

## tree: Mostra árvore de diretórios
tree:
	@echo "$(BLUE)📁 Estrutura do Projeto$(NC)"
	@echo "======================="
	@tree -L 3 -I 'build|.dart_tool|.idea|*.iml' lib/

## check: Verifica tudo antes de commit
check: format analyze test
	@echo "$(GREEN)✓ Tudo pronto para commit!$(NC)"

# Made with Bob
