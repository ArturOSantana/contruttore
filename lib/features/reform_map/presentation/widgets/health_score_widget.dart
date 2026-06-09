import 'package:flutter/material.dart';
import '../../domain/entities/reform_health_entity.dart';

/// Widget que mostra a saúde geral da reforma
///
/// Exibe:
/// - Score de 0 a 100
/// - Nível (Saudável, Atenção, Crítico)
/// - Cor indicativa baseada no HealthLevel
/// - Mensagem personalizada da entidade
/// - Issues e pontos positivos
class HealthScoreWidget extends StatelessWidget {
  final ReformHealthEntity health;
  final VoidCallback? onTap;

  const HealthScoreWidget({
    super.key,
    required this.health,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getIcon(),
                    color: _getColor(),
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saúde da Reforma',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getStatusText(),
                          style: TextStyle(
                            color: _getColor(),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildScoreCircle(context),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: health.score / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(_getColor()),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 12),

              // Mensagem personalizada da entidade
              Text(
                health.message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
              ),

              // Issues (problemas identificados)
              if (health.issues.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 20,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Pontos de Atenção',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...health.issues.map((issue) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: Colors.orange.shade700,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              issue,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],

              // Positives (pontos positivos)
              if (health.positives.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 20,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Pontos Positivos',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...health.positives.map((positive) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              positive,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],

              // Fatores (mantido para retrocompatibilidade)
              if (health.factors.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  'Principais fatores:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                ...health.factors.take(3).map((factor) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            _getFactorIcon(factor.score),
                            size: 16,
                            color: _getFactorColor(factor.score),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              factor.name,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          Text(
                            '${factor.score.toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: _getFactorColor(factor.score),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCircle(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getColor().withOpacity(0.1),
        border: Border.all(
          color: _getColor(),
          width: 3,
        ),
      ),
      child: Center(
        child: Text(
          '${health.score.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _getColor(),
          ),
        ),
      ),
    );
  }

  Color _getColor() {
    switch (health.level) {
      case HealthLevel.healthy:
        return Colors.green;
      case HealthLevel.attention:
        return Colors.orange;
      case HealthLevel.critical:
        return Colors.red;
    }
  }

  IconData _getIcon() {
    switch (health.level) {
      case HealthLevel.healthy:
        return Icons.check_circle_rounded;
      case HealthLevel.attention:
        return Icons.warning_amber_rounded;
      case HealthLevel.critical:
        return Icons.error_rounded;
    }
  }

  String _getStatusText() {
    switch (health.level) {
      case HealthLevel.healthy:
        return 'Saudável';
      case HealthLevel.attention:
        return 'Atenção';
      case HealthLevel.critical:
        return 'Crítico';
    }
  }

  Color _getFactorColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  IconData _getFactorIcon(double score) {
    if (score >= 80) return Icons.check_circle_outline;
    if (score >= 60) return Icons.info_outline;
    if (score >= 40) return Icons.warning_amber;
    return Icons.error_outline;
  }
}

// Made with Bob
