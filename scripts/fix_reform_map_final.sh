#!/bin/bash

# Script para corrigir os erros finais do Mapa da Reforma

echo "🔧 Aplicando correções finais no Mapa da Reforma..."

# Arquivo do repositório
REPO_FILE="lib/features/reform_map/data/repositories/reform_map_repository_impl.dart"

# Correção 1: Usar toFactorStatus() em vez de HealthStatus
sed -i '' 's/status: deadlineScore >= 80 ? HealthStatus.excellent : HealthStatus.good,/status: deadlineScore.toFactorStatus(),/g' "$REPO_FILE"
sed -i '' 's/status: budgetScore >= 80 ? HealthStatus.excellent : HealthStatus.good,/status: budgetScore.toFactorStatus(),/g' "$REPO_FILE"
sed -i '' 's/status: problemsScore >= 80 ? HealthStatus.excellent : HealthStatus.good,/status: problemsScore.toFactorStatus(),/g' "$REPO_FILE"

# Arquivo do modelo de saúde
HEALTH_MODEL="lib/features/reform_map/data/models/reform_health_model.dart"

# Correção 2: Adicionar status no HealthFactorModel (linha 82)
sed -i '' '82s/HealthFactorModel(/HealthFactorModel(\n          status: factor.status,/' "$HEALTH_MODEL"

# Arquivo do widget de visão geral
OVERVIEW_WIDGET="lib/features/reform_map/presentation/widgets/phase_overview_widget.dart"

# Correção 3: Adicionar case para PhaseStatus.doneNoRecord
sed -i '' '/case PhaseStatus.done:/a\
      case PhaseStatus.doneNoRecord:\
        return Icons.check_circle;\
' "$OVERVIEW_WIDGET"

# Correção 4: Remover case duplicado (linha 96)
sed -i '' '96,98d' "$OVERVIEW_WIDGET"

echo "✅ Correções aplicadas!"
echo ""
echo "📊 Executando flutter analyze..."
flutter analyze lib/features/reform_map 2>&1 | grep -E "(error|warning)" | head -20

# Made with Bob
