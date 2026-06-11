import 'package:injectable/injectable.dart';
import '../../features/projects/domain/entities/project_entity.dart';

/// Serviço de personalização baseado na prioridade principal do usuário
///
/// Este serviço usa o campo `mainPriority` coletado no onboarding para
/// personalizar a experiência do usuário em todo o app.
@lazySingleton
class PersonalizationService {
  /// Retorna recomendações personalizadas baseadas na prioridade
  List<String> getRecommendations(ProjectEntity project) {
    final priority = project.mainPriority;

    if (priority == null) {
      return _getDefaultRecommendations();
    }

    switch (priority) {
      case 'save_money':
        return _getSaveMoneyRecommendations(project);
      case 'finish_fast':
        return _getFinishFastRecommendations(project);
      case 'avoid_problems':
        return _getAvoidProblemsRecommendations(project);
      case 'best_quality':
        return _getBestQualityRecommendations(project);
      case 'control_spending':
        return _getControlSpendingRecommendations(project);
      case 'organize_everything':
        return _getOrganizeEverythingRecommendations(project);
      default:
        return _getDefaultRecommendations();
    }
  }

  /// Retorna a mensagem de motivação personalizada
  String getMotivationalMessage(String? priority) {
    if (priority == null) return 'Vamos organizar sua reforma!';

    switch (priority) {
      case 'save_money':
        return 'Economizando em cada etapa 💰';
      case 'finish_fast':
        return 'Acelerando sua mudança 🚀';
      case 'avoid_problems':
        return 'Prevenindo problemas 🛡️';
      case 'best_quality':
        return 'Qualidade em primeiro lugar ⭐';
      case 'control_spending':
        return 'Gastos sob controle 📊';
      case 'organize_everything':
        return 'Tudo organizado 📋';
      default:
        return 'Vamos organizar sua reforma!';
    }
  }

  /// Retorna alertas personalizados baseados na prioridade
  List<String> getPersonalizedAlerts(ProjectEntity project) {
    final priority = project.mainPriority;

    if (priority == null) return [];

    switch (priority) {
      case 'save_money':
        return [
          'Compare pelo menos 3 orçamentos antes de contratar',
          'Considere comprar materiais por conta própria',
          'Negocie descontos para pagamento à vista',
        ];
      case 'finish_fast':
        return [
          'Tenha todos os materiais antes de começar',
          'Contrate profissionais com disponibilidade imediata',
          'Evite mudanças no projeto durante a obra',
        ];
      case 'avoid_problems':
        return [
          'Exija nota fiscal de todos os serviços',
          'Fotografe cada etapa da obra',
          'Mantenha contratos por escrito',
        ];
      case 'best_quality':
        return [
          'Pesquise referências dos profissionais',
          'Invista em materiais de primeira linha',
          'Não aceite acabamento inferior ao combinado',
        ];
      case 'control_spending':
        return [
          'Atualize os gastos diariamente',
          'Reserve 15% para imprevistos',
          'Evite compras por impulso',
        ];
      case 'organize_everything':
        return [
          'Mantenha o diário de obra atualizado',
          'Organize todos os documentos digitalmente',
          'Crie checklists para cada etapa',
        ];
      default:
        return [];
    }
  }

  /// Retorna dicas específicas para a fase atual
  String getPhaseSpecificTip(String? priority, String phaseName) {
    if (priority == null) return '';

    // Dicas para fase de planejamento
    if (phaseName.toLowerCase().contains('planejamento')) {
      switch (priority) {
        case 'save_money':
          return 'Planeje bem agora para economizar depois. Mudanças durante a obra custam caro.';
        case 'finish_fast':
          return 'Defina tudo agora. Cada decisão adiada atrasa a obra.';
        case 'avoid_problems':
          return 'Documente tudo. Um bom planejamento evita 90% dos problemas.';
        default:
          return '';
      }
    }

    // Dicas para fase de execução
    if (phaseName.toLowerCase().contains('execução') ||
        phaseName.toLowerCase().contains('obra')) {
      switch (priority) {
        case 'save_money':
          return 'Acompanhe de perto para evitar desperdício de materiais.';
        case 'finish_fast':
          return 'Visite a obra diariamente para resolver problemas rapidamente.';
        case 'avoid_problems':
          return 'Fotografe tudo antes de fechar paredes e tetos.';
        default:
          return '';
      }
    }

    return '';
  }

  /// Retorna o nível de urgência para alertas (1-5)
  int getAlertUrgencyLevel(String? priority) {
    if (priority == null) return 3;

    switch (priority) {
      case 'finish_fast':
        return 5; // Máxima urgência
      case 'avoid_problems':
        return 4; // Alta urgência
      case 'control_spending':
        return 4; // Alta urgência
      case 'save_money':
        return 3; // Média urgência
      case 'best_quality':
        return 3; // Média urgência
      case 'organize_everything':
        return 2; // Baixa urgência
      default:
        return 3;
    }
  }

  /// Retorna se deve mostrar comparação de preços
  bool shouldShowPriceComparison(String? priority) {
    return priority == 'save_money' || priority == 'control_spending';
  }

  /// Retorna se deve mostrar timeline detalhado
  bool shouldShowDetailedTimeline(String? priority) {
    return priority == 'finish_fast' || priority == 'organize_everything';
  }

  /// Retorna se deve mostrar checklists extras
  bool shouldShowExtraChecklists(String? priority) {
    return priority == 'avoid_problems' || priority == 'organize_everything';
  }

  // Métodos privados para cada tipo de prioridade

  List<String> _getSaveMoneyRecommendations(ProjectEntity project) {
    return [
      'Compare preços de pelo menos 3 fornecedores',
      'Considere comprar materiais por conta própria',
      'Negocie descontos para pagamento à vista',
      'Evite mudanças no projeto durante a obra',
      'Compre materiais em promoção quando possível',
    ];
  }

  List<String> _getFinishFastRecommendations(ProjectEntity project) {
    return [
      'Tenha todos os materiais antes de começar',
      'Contrate profissionais com disponibilidade imediata',
      'Evite mudanças no projeto',
      'Organize etapas para trabalho paralelo',
      'Mantenha comunicação diária com a equipe',
    ];
  }

  List<String> _getAvoidProblemsRecommendations(ProjectEntity project) {
    return [
      'Exija nota fiscal de todos os serviços',
      'Fotografe cada etapa da obra',
      'Mantenha contratos por escrito',
      'Faça vistorias regulares',
      'Documente todas as decisões importantes',
    ];
  }

  List<String> _getBestQualityRecommendations(ProjectEntity project) {
    return [
      'Pesquise referências dos profissionais',
      'Invista em materiais de primeira linha',
      'Não aceite acabamento inferior',
      'Contrate profissionais especializados',
      'Exija garantia de todos os serviços',
    ];
  }

  List<String> _getControlSpendingRecommendations(ProjectEntity project) {
    return [
      'Atualize os gastos diariamente',
      'Reserve 15% para imprevistos',
      'Evite compras por impulso',
      'Mantenha planilha de custos atualizada',
      'Revise o orçamento semanalmente',
    ];
  }

  List<String> _getOrganizeEverythingRecommendations(ProjectEntity project) {
    return [
      'Mantenha o diário de obra atualizado',
      'Organize documentos digitalmente',
      'Crie checklists para cada etapa',
      'Mantenha agenda de compromissos',
      'Arquive todas as notas fiscais',
    ];
  }

  List<String> _getDefaultRecommendations() {
    return [
      'Planeje bem antes de começar',
      'Compare preços de fornecedores',
      'Mantenha documentação organizada',
      'Acompanhe o progresso regularmente',
      'Reserve verba para imprevistos',
    ];
  }
}

// Made with Bob
