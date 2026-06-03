#!/bin/bash

# Script de configuração do Firebase App Distribution
# Made with Bob

set -e

echo "🚀 Costruttore - Setup Firebase App Distribution"
echo "================================================"
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

# Verificar se está no diretório correto
if [ ! -f "pubspec.yaml" ]; then
    print_error "Execute este script na raiz do projeto Flutter"
    exit 1
fi

print_success "Diretório correto detectado"
echo ""

# 1. Verificar dependências
echo "📦 Verificando dependências..."
echo ""

# Verificar Flutter
if ! command -v flutter &> /dev/null; then
    print_error "Flutter não encontrado. Instale o Flutter primeiro."
    exit 1
fi
print_success "Flutter instalado: $(flutter --version | head -n 1)"

# Verificar Java
if ! command -v java &> /dev/null; then
    print_warning "Java não encontrado. Necessário para build Android."
else
    print_success "Java instalado: $(java -version 2>&1 | head -n 1)"
fi

# Verificar keytool
if ! command -v keytool &> /dev/null; then
    print_warning "keytool não encontrado. Necessário para criar keystore."
else
    print_success "keytool disponível"
fi

# Verificar Firebase CLI
if ! command -v firebase &> /dev/null; then
    print_warning "Firebase CLI não encontrado."
    echo "  Instale com: npm install -g firebase-tools"
else
    print_success "Firebase CLI instalado"
fi

echo ""

# 2. Verificar arquivos sensíveis
echo "🔒 Verificando segurança..."
echo ""

SENSITIVE_FILES=(
    "android/key.properties"
    "android/app/keystore.jks"
    "service-account.json"
    ".env"
)

for file in "${SENSITIVE_FILES[@]}"; do
    if [ -f "$file" ]; then
        # Verificar se está no .gitignore
        if grep -q "$file" .gitignore 2>/dev/null; then
            print_success "$file está protegido no .gitignore"
        else
            print_error "$file existe mas NÃO está no .gitignore!"
            echo "  Adicione ao .gitignore imediatamente!"
        fi
    fi
done

echo ""

# 3. Verificar configuração do Android
echo "🤖 Verificando configuração Android..."
echo ""

if [ -f "android/app/build.gradle.kts" ]; then
    if grep -q "productFlavors" android/app/build.gradle.kts; then
        print_success "Flavors configurados no build.gradle.kts"
    else
        print_warning "Flavors não encontrados no build.gradle.kts"
        echo "  Configure os flavors: development, staging, production"
    fi
else
    print_error "android/app/build.gradle.kts não encontrado"
fi

if [ -f "android/app/google-services.json" ]; then
    print_success "google-services.json encontrado"
else
    print_warning "google-services.json não encontrado"
    echo "  Baixe do Firebase Console"
fi

echo ""

# 4. Criar keystore (opcional)
echo "🔑 Configuração de Keystore"
echo ""

if [ -f "android/app/keystore.jks" ]; then
    print_success "Keystore já existe"
else
    read -p "Deseja criar um novo keystore? (s/N): " create_keystore
    if [[ $create_keystore =~ ^[Ss]$ ]]; then
        echo ""
        echo "Criando keystore..."
        read -p "Key alias (padrão: costruttore): " key_alias
        key_alias=${key_alias:-costruttore}
        
        keytool -genkey -v -keystore android/app/keystore.jks \
            -keyalg RSA -keysize 2048 -validity 10000 \
            -alias "$key_alias"
        
        if [ $? -eq 0 ]; then
            print_success "Keystore criado com sucesso!"
            echo ""
            print_warning "IMPORTANTE: Anote as senhas em local seguro!"
            echo ""
            
            # Converter para Base64
            if command -v base64 &> /dev/null; then
                echo "Convertendo para Base64..."
                base64 -i android/app/keystore.jks > keystore.base64.txt
                print_success "Base64 salvo em: keystore.base64.txt"
                print_warning "Adicione o conteúdo deste arquivo ao GitHub Secret: KEYSTORE_BASE64"
                print_warning "Depois delete o arquivo: rm keystore.base64.txt"
            fi
        else
            print_error "Erro ao criar keystore"
        fi
    fi
fi

echo ""

# 5. Verificar GitHub Secrets
echo "🔐 GitHub Secrets Necessários"
echo ""

REQUIRED_SECRETS=(
    "KEYSTORE_BASE64"
    "KEY_ALIAS"
    "KEY_PASSWORD"
    "STORE_PASSWORD"
    "FIREBASE_SERVICE_ACCOUNT"
    "FIREBASE_APP_ID_ANDROID_STAGING"
    "FIREBASE_APP_ID_ANDROID_PRODUCTION"
)

echo "Configure os seguintes secrets no GitHub:"
echo "https://github.com/SEU_USUARIO/SEU_REPO/settings/secrets/actions"
echo ""

for secret in "${REQUIRED_SECRETS[@]}"; do
    echo "  • $secret"
done

echo ""

# 6. Testar build local
echo "🏗️  Teste de Build"
echo ""

read -p "Deseja testar o build local? (s/N): " test_build
if [[ $test_build =~ ^[Ss]$ ]]; then
    echo ""
    echo "Executando flutter pub get..."
    flutter pub get
    
    echo ""
    echo "Executando build_runner..."
    flutter pub run build_runner build --delete-conflicting-outputs
    
    echo ""
    echo "Testando build debug..."
    flutter build apk --debug --flavor development
    
    if [ $? -eq 0 ]; then
        print_success "Build debug executado com sucesso!"
        echo "APK gerado em: build/app/outputs/flutter-apk/"
    else
        print_error "Erro no build"
    fi
fi

echo ""

# 7. Resumo e próximos passos
echo "📋 Próximos Passos"
echo "=================="
echo ""
echo "1. Configure todos os secrets no GitHub"
echo "2. Crie os grupos de testadores no Firebase Console:"
echo "   • testers-staging"
echo "   • testers-production"
echo ""
echo "3. Obtenha os App IDs do Firebase Console:"
echo "   Project Settings > General > Your apps"
echo ""
echo "4. Crie um Service Account no Google Cloud:"
echo "   https://console.cloud.google.com"
echo "   Role: Firebase App Distribution Admin"
echo ""
echo "5. Teste o workflow:"
echo "   git checkout -b test/ci-cd"
echo "   git push origin test/ci-cd"
echo "   Crie um Pull Request"
echo ""
echo "6. Leia a documentação completa:"
echo "   FIREBASE_APP_DISTRIBUTION_SETUP.md"
echo ""

print_success "Setup concluído!"
echo ""
echo "Made with Bob 🤖"