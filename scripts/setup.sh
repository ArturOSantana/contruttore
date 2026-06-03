#!/bin/bash

# 🚀 Script de Setup Automatizado - Costruttore
# Este script configura o ambiente de desenvolvimento automaticamente

set -e  # Para na primeira falha

echo "🏗️  Costruttore - Setup Automatizado"
echo "===================================="
echo ""

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função para printar com cor
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "ℹ $1"
}

# 1. Verificar Flutter instalado
echo "1️⃣  Verificando Flutter..."
if ! command -v flutter &> /dev/null; then
    print_error "Flutter não encontrado. Instale o Flutter primeiro:"
    echo "   https://docs.flutter.dev/get-started/install"
    exit 1
fi
print_success "Flutter encontrado: $(flutter --version | head -n 1)"
echo ""

# 2. Verificar versão do Flutter
echo "2️⃣  Verificando versão do Flutter..."
FLUTTER_VERSION=$(flutter --version | head -n 1 | awk '{print $2}')
print_info "Versão atual: $FLUTTER_VERSION"
print_warning "Versão recomendada: 3.x ou superior"
echo ""

# 3. Verificar Dart instalado
echo "3️⃣  Verificando Dart..."
if ! command -v dart &> /dev/null; then
    print_error "Dart não encontrado"
    exit 1
fi
print_success "Dart encontrado: $(dart --version 2>&1 | head -n 1)"
echo ""

# 4. Limpar cache anterior
echo "4️⃣  Limpando cache anterior..."
flutter clean
print_success "Cache limpo"
echo ""

# 5. Obter dependências
echo "5️⃣  Obtendo dependências..."
flutter pub get
print_success "Dependências obtidas"
echo ""

# 6. Verificar Firebase CLI
echo "6️⃣  Verificando Firebase CLI..."
if ! command -v firebase &> /dev/null; then
    print_warning "Firebase CLI não encontrado"
    print_info "Instale com: npm install -g firebase-tools"
else
    print_success "Firebase CLI encontrado"
fi
echo ""

# 7. Gerar código (build_runner)
echo "7️⃣  Gerando código com build_runner..."
flutter pub run build_runner build --delete-conflicting-outputs
print_success "Código gerado"
echo ""

# 8. Verificar configuração do Android
echo "8️⃣  Verificando configuração Android..."
if [ -f "android/local.properties" ]; then
    print_success "android/local.properties encontrado"
else
    print_warning "android/local.properties não encontrado"
    print_info "Será criado automaticamente no primeiro build"
fi
echo ""

# 9. Verificar google-services.json
echo "9️⃣  Verificando google-services.json..."
if [ -f "android/app/google-services.json" ]; then
    print_success "google-services.json encontrado (Android)"
else
    print_error "google-services.json NÃO encontrado (Android)"
    print_info "Baixe do Firebase Console e coloque em android/app/"
fi
echo ""

# 10. Verificar GoogleService-Info.plist
echo "🔟 Verificando GoogleService-Info.plist..."
if [ -f "ios/Runner/GoogleService-Info.plist" ]; then
    print_success "GoogleService-Info.plist encontrado (iOS)"
else
    print_warning "GoogleService-Info.plist NÃO encontrado (iOS)"
    print_info "Baixe do Firebase Console e coloque em ios/Runner/"
fi
echo ""

# 11. Verificar dispositivos conectados
echo "1️⃣1️⃣  Verificando dispositivos..."
DEVICES=$(flutter devices | grep -c "•" || true)
if [ "$DEVICES" -gt 0 ]; then
    print_success "$DEVICES dispositivo(s) conectado(s)"
    flutter devices
else
    print_warning "Nenhum dispositivo conectado"
    print_info "Conecte um dispositivo ou inicie um emulador"
fi
echo ""

# 12. Análise estática
echo "1️⃣2️⃣  Executando análise estática..."
flutter analyze --no-fatal-infos --no-fatal-warnings > /dev/null 2>&1
if [ $? -eq 0 ]; then
    print_success "Análise estática passou (ignorando warnings de build/)"
else
    print_warning "Análise encontrou alguns problemas (verifique manualmente)"
fi
echo ""

# 13. Verificar estrutura de pastas
echo "1️⃣3️⃣  Verificando estrutura de pastas..."
REQUIRED_DIRS=(
    "lib/features"
    "lib/core"
    "lib/app"
    "android/app"
    "ios/Runner"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        print_success "$dir existe"
    else
        print_error "$dir NÃO existe"
    fi
done
echo ""

# 14. Resumo final
echo "📊 Resumo do Setup"
echo "=================="
echo ""

# Verificar se tudo está OK
ALL_OK=true

if [ ! -f "android/app/google-services.json" ]; then
    ALL_OK=false
fi

if [ "$DEVICES" -eq 0 ]; then
    ALL_OK=false
fi

if [ "$ALL_OK" = true ]; then
    print_success "✅ Setup completo! Tudo pronto para desenvolvimento."
    echo ""
    echo "🚀 Próximos passos:"
    echo "   1. flutter run (para executar no dispositivo)"
    echo "   2. flutter build apk (para gerar APK)"
    echo "   3. flutter test (para executar testes)"
else
    print_warning "⚠️  Setup completo com avisos. Verifique os itens acima."
    echo ""
    echo "📝 Ações necessárias:"
    if [ ! -f "android/app/google-services.json" ]; then
        echo "   - Adicionar google-services.json do Firebase"
    fi
    if [ "$DEVICES" -eq 0 ]; then
        echo "   - Conectar um dispositivo ou iniciar emulador"
    fi
fi

echo ""
echo "📚 Documentação disponível:"
echo "   - README.md"
echo "   - GUIA_TESTE_RAPIDO.md"
echo "   - ARQUITETURA.md"
echo "   - FIREBASE_SETUP.md"
echo ""
echo "✨ Costruttore está pronto!"

# Made with Bob
