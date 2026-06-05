import 'package:flutter/material.dart';
import '../../domain/entities/reform_health_entity.dart';

/// Widget que mostra a saúde geral da reforma
///
/// Exibe:
/// - Score de 0 a 100
/// - Status (Excelente, Boa, Atenção, Crítica)
/// - Cor indicativa
/// - Mensagem motivacional
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
                          style: Theme.of(context).textTheme.titleMedium,
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
              Text(
                _getMotivationalMessage(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
              ),
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
    if (health.score >= 80) return Colors.green;
    if (health.score >= 60) return Colors.blue;
    if (health.score >= 40) return Colors.orange;
    return Colors.red;
  }

  IconData _getIcon() {
    if (health.score >= 80) return Icons.check_circle;
    if (health.score >= 60) return Icons.info;
    if (health.score >= 40) return Icons.warning;
    return Icons.error;
  }

  String _getStatusText() {
    if (health.score >= 80) return 'Excelente';
    if (health.score >= 60) return 'Boa';
    if (health.score >= 40) return 'Atenção';
    return 'Crítica';
  }

  String _getMotivationalMessage() {
    if (health.score >= 80) {
      return 'Parabéns! Sua reforma está indo muito bem. Continue assim!';
    }
    if (health.score >= 60) {
      return 'Sua reforma está no caminho certo. Fique atento às pendências.';
    }
    if (health.score >= 40) {
      return 'Alguns pontos precisam de atenção. Veja as recomendações abaixo.';
    }
    return 'Sua reforma precisa de atenção urgente. Resolva os problemas críticos.';
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
