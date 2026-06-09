import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/reform_risk_entity.dart';

/// Página que exibe os riscos identificados da reforma
/// Mostrada após completar o onboarding de 18 steps
class ReformRisksPage extends StatefulWidget {
  final List<ReformRiskEntity> risks;
  final VoidCallback onContinue;

  const ReformRisksPage({
    super.key,
    required this.risks,
    required this.onContinue,
  });

  @override
  State<ReformRisksPage> createState() => _ReformRisksPageState();
}

class _ReformRisksPageState extends State<ReformRisksPage> {
  late List<ReformRiskEntity> _risks;
  String _selectedFilter = 'all'; // all, high, medium, low

  @override
  void initState() {
    super.initState();
    _risks = widget.risks;
  }

  List<ReformRiskEntity> get _filteredRisks {
    if (_selectedFilter == 'all') return _risks;
    final severity = RiskSeverity.values.firstWhere(
      (s) => s.name == _selectedFilter,
      orElse: () => RiskSeverity.medium,
    );
    return _risks.where((r) => r.severity == severity).toList();
  }

  int get _highRiskCount =>
      _risks.where((r) => r.severity == RiskSeverity.high).length;
  int get _mediumRiskCount =>
      _risks.where((r) => r.severity == RiskSeverity.medium).length;
  int get _lowRiskCount =>
      _risks.where((r) => r.severity == RiskSeverity.low).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Riscos Identificados'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildFilterChips(),
          Expanded(
            child:
                _filteredRisks.isEmpty ? _buildEmptyState() : _buildRisksList(),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.warning,
                  size: 32,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_risks.length} ${_risks.length == 1 ? 'Risco Identificado' : 'Riscos Identificados'}',
                      style: AppTextStyles.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Baseado nas suas respostas',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildRiskSummary(),
        ],
      ),
    );
  }

  Widget _buildRiskSummary() {
    return Row(
      children: [
        _buildRiskBadge(
          'Alta',
          _highRiskCount,
          AppColors.error,
          AppColors.errorLight,
        ),
        const SizedBox(width: AppSpacing.sm),
        _buildRiskBadge(
          'Média',
          _mediumRiskCount,
          AppColors.warning,
          AppColors.warningLight,
        ),
        const SizedBox(width: AppSpacing.sm),
        _buildRiskBadge(
          'Baixa',
          _lowRiskCount,
          AppColors.info,
          AppColors.infoLight,
        ),
      ],
    );
  }

  Widget _buildRiskBadge(String label, int count, Color color, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: AppTextStyles.headlineSmall.copyWith(color: color),
            ),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('Todos', 'all', _risks.length),
            const SizedBox(width: AppSpacing.sm),
            _buildFilterChip('Alta', 'high', _highRiskCount),
            const SizedBox(width: AppSpacing.sm),
            _buildFilterChip('Média', 'medium', _mediumRiskCount),
            const SizedBox(width: AppSpacing.sm),
            _buildFilterChip('Baixa', 'low', _lowRiskCount),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary.withOpacity(0.1),
      checkmarkColor: AppColors.primary,
      labelStyle: AppTextStyles.bodyMedium.copyWith(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: AppColors.success.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Nenhum risco nesta categoria',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRisksList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: _filteredRisks.length,
      itemBuilder: (context, index) {
        final risk = _filteredRisks[index];
        return _buildRiskCard(risk);
      },
    );
  }

  Widget _buildRiskCard(ReformRiskEntity risk) {
    final severityColor = _getSeverityColor(risk.severity);
    final severityBgColor = _getSeverityBgColor(risk.severity);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: BorderSide(color: severityColor.withOpacity(0.3)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(AppSpacing.md),
        childrenPadding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: severityBgColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Text(
            risk.severity.emoji,
            style: const TextStyle(fontSize: 24),
          ),
        ),
        title: Text(
          risk.title,
          style: AppTextStyles.titleMedium,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: severityBgColor,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  risk.severity.displayName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: severityColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        children: [
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Descrição',
              style: AppTextStyles.titleSmall,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            risk.description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (risk.preventionActions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Ações Preventivas',
                style: AppTextStyles.titleSmall,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            ...risk.preventionActions.map((action) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 20,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          action,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Color _getSeverityColor(RiskSeverity severity) {
    switch (severity) {
      case RiskSeverity.high:
        return AppColors.error;
      case RiskSeverity.medium:
        return AppColors.warning;
      case RiskSeverity.low:
        return AppColors.info;
    }
  }

  Color _getSeverityBgColor(RiskSeverity severity) {
    switch (severity) {
      case RiskSeverity.high:
        return AppColors.errorLight;
      case RiskSeverity.medium:
        return AppColors.warningLight;
      case RiskSeverity.low:
        return AppColors.infoLight;
    }
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.infoLight,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.info.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.info,
                    size: 24,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Esses riscos foram salvos e você pode consultá-los a qualquer momento',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onContinue,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 52),
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Continuar para o App'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Made with Bob
