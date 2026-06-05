#!/bin/bash

# Script para corrigir erros do Mapa da Reforma
# Execute: chmod +x scripts/fix_reform_map.sh && ./scripts/fix_reform_map.sh

echo "🔧 Aplicando correções no Mapa da Reforma..."

# 1. Corrigir PhaseStatus nos widgets
echo "📝 Corrigindo enums PhaseStatus..."
sed -i '' 's/PhaseStatus\.inProgress/PhaseStatus.active/g' lib/features/reform_map/presentation/widgets/current_phase_widget.dart
sed -i '' 's/PhaseStatus\.completed/PhaseStatus.done/g' lib/features/reform_map/presentation/widgets/phase_overview_widget.dart
sed -i '' 's/PhaseStatus\.inProgress/PhaseStatus.active/g' lib/features/reform_map/presentation/widgets/phase_overview_widget.dart
sed -i '' 's/PhaseStatus\.pending/PhaseStatus.locked/g' lib/features/reform_map/presentation/widgets/phase_overview_widget.dart
sed -i '' 's/PhaseStatus\.delayed/PhaseStatus.active/g' lib/features/reform_map/presentation/widgets/phase_overview_widget.dart

# 2. Corrigir timeImpactDays para delayDays
echo "📝 Corrigindo timeImpactDays → delayDays..."
sed -i '' 's/timeImpactDays/delayDays/g' lib/features/reform_map/presentation/widgets/problems_list_widget.dart

# 3. Adicionar null checks
echo "📝 Adicionando null checks..."
sed -i '' 's/problem\.financialImpact > 0/problem.financialImpact != null \&\& problem.financialImpact! > 0/g' lib/features/reform_map/presentation/widgets/problems_list_widget.dart
sed -i '' 's/problem\.delayDays > 0/problem.delayDays != null \&\& problem.delayDays! > 0/g' lib/features/reform_map/presentation/widgets/problems_list_widget.dart
sed -i '' 's/problem\.financialImpact\.toStringAsFixed/problem.financialImpact!.toStringAsFixed/g' lib/features/reform_map/presentation/widgets/problems_list_widget.dart

echo "✅ Correções aplicadas!"
echo ""
echo "📊 Verificando erros restantes..."
flutter analyze lib/features/reform_map 2>&1 | grep -E "error|warning" | wc -l
echo ""
echo "🚀 Próximo passo: Implementar métodos faltantes no repository"
echo "   Ver: CORRECOES_PENDENTES_MAPA_REFORMA.md"

# Made with Bob
