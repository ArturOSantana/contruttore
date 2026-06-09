import 'package:equatable/equatable.dart';

/// Representa um marco importante da reforma
///
/// Marcos são conquistas significativas que merecem ser comemoradas.
/// Exemplos:
/// - Primeira fase concluída
/// - 50% da reforma completa
/// - Infraestrutura finalizada
/// - Mudança realizada
///
/// Cada marco possui:
/// - Título e descrição
/// - Ícone e cor
/// - Status (alcançado ou não)
/// - Data de conquista
/// - Mensagem de celebração
class MilestoneEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final MilestoneType type;
  final bool isAchieved;
  final DateTime? achievedAt;
  final String celebrationMessage;
  final int progressPercentage; // Progresso necessário para alcançar
  final String icon;

  const MilestoneEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.isAchieved,
    this.achievedAt,
    required this.celebrationMessage,
    required this.progressPercentage,
    required this.icon,
  });

  /// Verifica se o marco está próximo (faltam menos de 10%)
  bool get isNear {
    return !isAchieved && progressPercentage >= 90;
  }

  /// Verifica se foi alcançado recentemente (últimos 7 dias)
  bool get isRecent {
    if (!isAchieved || achievedAt == null) return false;
    final daysSince = DateTime.now().difference(achievedAt!).inDays;
    return daysSince <= 7;
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        isAchieved,
        achievedAt,
        celebrationMessage,
        progressPercentage,
        icon,
      ];
}

/// Tipos de marcos da reforma
enum MilestoneType {
  /// Marcos de progresso geral
  progress,

  /// Marcos de fases específicas
  phase,

  /// Marcos financeiros
  financial,

  /// Marcos de tempo
  timeline,

  /// Marcos especiais
  special,
}

/// Extensão para obter informações sobre o tipo de marco
extension MilestoneTypeExtension on MilestoneType {
  /// Retorna o nome do tipo
  String get name {
    switch (this) {
      case MilestoneType.progress:
        return 'Progresso';
      case MilestoneType.phase:
        return 'Fase';
      case MilestoneType.financial:
        return 'Financeiro';
      case MilestoneType.timeline:
        return 'Prazo';
      case MilestoneType.special:
        return 'Especial';
    }
  }

  /// Retorna a cor associada ao tipo
  String get colorHex {
    switch (this) {
      case MilestoneType.progress:
        return '#4CAF50'; // Verde
      case MilestoneType.phase:
        return '#2196F3'; // Azul
      case MilestoneType.financial:
        return '#FF9800'; // Laranja
      case MilestoneType.timeline:
        return '#9C27B0'; // Roxo
      case MilestoneType.special:
        return '#F44336'; // Vermelho
    }
  }
}

/// Marcos pré-definidos da reforma
class PredefinedMilestones {
  /// Lista de todos os marcos possíveis
  static List<MilestoneEntity> getAll() {
    return [
      // Marcos de Progresso
      const MilestoneEntity(
        id: 'progress_10',
        title: 'Primeiros Passos',
        description: '10% da reforma concluída',
        type: MilestoneType.progress,
        isAchieved: false,
        celebrationMessage:
            ' Você começou! Os primeiros 10% são sempre os mais difíceis.',
        progressPercentage: 10,
        icon: '',
      ),
      const MilestoneEntity(
        id: 'progress_25',
        title: 'Um Quarto do Caminho',
        description: '25% da reforma concluída',
        type: MilestoneType.progress,
        isAchieved: false,
        celebrationMessage:
            ' Você já está em 1/4 da jornada! Continue assim!',
        progressPercentage: 25,
        icon: '',
      ),
      const MilestoneEntity(
        id: 'progress_50',
        title: 'Metade da Jornada',
        description: '50% da reforma concluída',
        type: MilestoneType.progress,
        isAchieved: false,
        celebrationMessage:
            ' Metade do caminho percorrido! Você está indo muito bem!',
        progressPercentage: 50,
        icon: '',
      ),
      const MilestoneEntity(
        id: 'progress_75',
        title: 'Reta Final',
        description: '75% da reforma concluída',
        type: MilestoneType.progress,
        isAchieved: false,
        celebrationMessage: ' Falta pouco! Você está na reta final!',
        progressPercentage: 75,
        icon: '',
      ),
      const MilestoneEntity(
        id: 'progress_90',
        title: 'Quase Lá',
        description: '90% da reforma concluída',
        type: MilestoneType.progress,
        isAchieved: false,
        celebrationMessage: ' Só mais um empurrãozinho! Você está quase lá!',
        progressPercentage: 90,
        icon: '',
      ),
      const MilestoneEntity(
        id: 'progress_100',
        title: 'Reforma Concluída',
        description: '100% da reforma finalizada',
        type: MilestoneType.progress,
        isAchieved: false,
        celebrationMessage:
            ' PARABÉNS! Você concluiu sua reforma! Hora de aproveitar!',
        progressPercentage: 100,
        icon: '',
      ),

      // Marcos de Fases
      const MilestoneEntity(
        id: 'phase_infrastructure',
        title: 'Infraestrutura Completa',
        description: 'Elétrica e hidráulica finalizadas',
        type: MilestoneType.phase,
        isAchieved: false,
        celebrationMessage:
            ' A parte mais crítica está pronta! Agora é só embelezar!',
        progressPercentage: 0,
        icon: '',
      ),
      const MilestoneEntity(
        id: 'phase_flooring',
        title: 'Pisos Instalados',
        description: 'Todos os pisos foram colocados',
        type: MilestoneType.phase,
        isAchieved: false,
        celebrationMessage:
            ' Seus pisos estão lindos! A casa já tem cara de nova!',
        progressPercentage: 0,
        icon: '',
      ),
      const MilestoneEntity(
        id: 'phase_painting',
        title: 'Pintura Finalizada',
        description: 'Todas as paredes foram pintadas',
        type: MilestoneType.phase,
        isAchieved: false,
        celebrationMessage:
            ' As cores deram vida ao ambiente! Ficou incrível!',
        progressPercentage: 0,
        icon: '',
      ),
      const MilestoneEntity(
        id: 'phase_finishing',
        title: 'Acabamentos Prontos',
        description: 'Metais, louças e interruptores instalados',
        type: MilestoneType.phase,
        isAchieved: false,
        celebrationMessage:
            ' Os detalhes fazem toda a diferença! Está ficando perfeito!',
        progressPercentage: 0,
        icon: '',
      ),
      const MilestoneEntity(
        id: 'phase_carpentry',
        title: 'Marcenaria Instalada',
        description: 'Todos os móveis planejados foram colocados',
        type: MilestoneType.phase,
        isAchieved: false,
        celebrationMessage:
            ' Seus móveis estão prontos! A casa ganhou funcionalidade!',
        progressPercentage: 0,
        icon: '',
      ),

      // Marcos Financeiros
      const MilestoneEntity(
        id: 'financial_50',
        title: 'Metade do Orçamento',
        description: '50% do orçamento utilizado',
        type: MilestoneType.financial,
        isAchieved: false,
        celebrationMessage:
            ' Você está controlando bem os gastos! Continue assim!',
        progressPercentage: 0,
        icon: '',
      ),
      const MilestoneEntity(
        id: 'financial_on_budget',
        title: 'Dentro do Orçamento',
        description: 'Reforma concluída sem estourar o orçamento',
        type: MilestoneType.financial,
        isAchieved: false,
        celebrationMessage:
            ' Você conseguiu! Reforma completa dentro do orçamento!',
        progressPercentage: 0,
        icon: '',
      ),

      // Marcos de Tempo
      const MilestoneEntity(
        id: 'timeline_first_month',
        title: 'Primeiro Mês',
        description: 'Um mês de reforma',
        type: MilestoneType.timeline,
        isAchieved: false,
        celebrationMessage: ' Um mês se passou! Você está firme na jornada!',
        progressPercentage: 0,
        icon: '',
      ),
      const MilestoneEntity(
        id: 'timeline_on_schedule',
        title: 'No Prazo',
        description: 'Reforma concluída dentro do prazo',
        type: MilestoneType.timeline,
        isAchieved: false,
        celebrationMessage: '⏰ Pontualidade é tudo! Você cumpriu o prazo!',
        progressPercentage: 0,
        icon: '',
      ),

      // Marcos Especiais
      const MilestoneEntity(
        id: 'special_first_night',
        title: 'Primeira Noite',
        description: 'Primeira noite na casa reformada',
        type: MilestoneType.special,
        isAchieved: false,
        celebrationMessage:
            ' Que momento especial! Aproveite sua primeira noite no lar renovado!',
        progressPercentage: 0,
        icon: '',
      ),
      const MilestoneEntity(
        id: 'special_housewarming',
        title: 'Festa de Inauguração',
        description: 'Primeira festa na casa reformada',
        type: MilestoneType.special,
        isAchieved: false,
        celebrationMessage:
            ' Hora de comemorar com quem você ama! Aproveite!',
        progressPercentage: 0,
        icon: '',
      ),
    ];
  }

  /// Retorna marcos de progresso
  static List<MilestoneEntity> getProgressMilestones() {
    return getAll().where((m) => m.type == MilestoneType.progress).toList();
  }

  /// Retorna marcos de fases
  static List<MilestoneEntity> getPhaseMilestones() {
    return getAll().where((m) => m.type == MilestoneType.phase).toList();
  }

  /// Retorna marcos financeiros
  static List<MilestoneEntity> getFinancialMilestones() {
    return getAll().where((m) => m.type == MilestoneType.financial).toList();
  }

  /// Retorna marcos de tempo
  static List<MilestoneEntity> getTimelineMilestones() {
    return getAll().where((m) => m.type == MilestoneType.timeline).toList();
  }

  /// Retorna marcos especiais
  static List<MilestoneEntity> getSpecialMilestones() {
    return getAll().where((m) => m.type == MilestoneType.special).toList();
  }
}

// Made with Bob
