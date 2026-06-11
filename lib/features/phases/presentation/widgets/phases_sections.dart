import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../projects/domain/entities/phase_entity.dart';

/// Seção colapsável de Fases Concluídas
///
/// Mostra todas as fases que já foram completadas.
/// Inicialmente colapsada se houver mais de 2 fases.
class CompletedPhasesSection extends StatefulWidget {
  final List<PhaseEntity> phases;
  final Function(PhaseEntity) onPhaseTap;

  const CompletedPhasesSection({
    super.key,
    required this.phases,
    required this.onPhaseTap,
  });

  @override
  State<CompletedPhasesSection> createState() => _CompletedPhasesSectionState();
}

class _CompletedPhasesSectionState extends State<CompletedPhasesSection> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    // Expandir automaticamente se houver 2 ou menos fases
    _isExpanded = widget.phases.length <= 2;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.phases.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppSpacing.radiusMd),
                bottom: _isExpanded
                    ? Radius.zero
                    : Radius.circular(AppSpacing.radiusMd),
              ),
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'FASES CONCLUÍDAS',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                          SizedBox(height: AppSpacing.xxs),
                          Text(
                            '${widget.phases.length} ${widget.phases.length == 1 ? 'fase completa' : 'fases completas'}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Lista de fases (colapsável)
          if (_isExpanded) ...[
            Divider(height: 1, color: AppColors.border),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.all(AppSpacing.md),
              itemCount: widget.phases.length,
              separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final phase = widget.phases[index];
                return _CompletedPhaseItem(
                  phase: phase,
                  onTap: () => widget.onPhaseTap(phase),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// Item individual de fase concluída
class _CompletedPhaseItem extends StatelessWidget {
  final PhaseEntity phase;
  final VoidCallback onTap;

  const _CompletedPhaseItem({
    required this.phase,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.successSubtle,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              // Número da fase
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Center(
                  child: Text(
                    '${phase.number}',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              // Nome da fase
              Expanded(
                child: Text(
                  phase.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Ícone de check
              Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Seção colapsável de Próximas Fases
///
/// Mostra todas as fases que ainda não foram iniciadas.
/// Inicialmente colapsada se houver mais de 3 fases.
class UpcomingPhasesSection extends StatefulWidget {
  final List<PhaseEntity> phases;
  final Function(PhaseEntity) onPhaseTap;

  const UpcomingPhasesSection({
    super.key,
    required this.phases,
    required this.onPhaseTap,
  });

  @override
  State<UpcomingPhasesSection> createState() => _UpcomingPhasesSectionState();
}

class _UpcomingPhasesSectionState extends State<UpcomingPhasesSection> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    // Expandir automaticamente se houver 3 ou menos fases
    _isExpanded = widget.phases.length <= 3;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.phases.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppSpacing.radiusMd),
                bottom: _isExpanded
                    ? Radius.zero
                    : Radius.circular(AppSpacing.radiusMd),
              ),
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Icon(
                        Icons.lock_outline,
                        color: AppColors.textSecondary,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PRÓXIMAS FASES',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                          SizedBox(height: AppSpacing.xxs),
                          Text(
                            '${widget.phases.length} ${widget.phases.length == 1 ? 'fase futura' : 'fases futuras'}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Lista de fases (colapsável)
          if (_isExpanded) ...[
            Divider(height: 1, color: AppColors.border),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.all(AppSpacing.md),
              itemCount: widget.phases.length,
              separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final phase = widget.phases[index];
                return _UpcomingPhaseItem(
                  phase: phase,
                  onTap: () => widget.onPhaseTap(phase),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// Item individual de fase futura
class _UpcomingPhaseItem extends StatelessWidget {
  final PhaseEntity phase;
  final VoidCallback onTap;

  const _UpcomingPhaseItem({
    required this.phase,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              // Número da fase
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Center(
                  child: Text(
                    '${phase.number}',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              // Nome da fase
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      phase.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (phase.estimatedDurationDays > 0) ...[
                      SizedBox(height: AppSpacing.xxs),
                      Text(
                        '${phase.estimatedDurationDays} dias estimados',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Ícone de cadeado
              Icon(
                Icons.lock_outline,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Made with Bob
