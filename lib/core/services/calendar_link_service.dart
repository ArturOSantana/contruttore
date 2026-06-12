import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

/// Serviço para gerar links do Google Calendar
///
/// Gera URLs que abrem o Google Calendar com o evento pré-preenchido.
/// O usuário só precisa clicar em "Salvar" no Google Calendar.
///
/// Não requer autenticação ou configuração OAuth!
class CalendarLinkService {
  /// Formato de data para Google Calendar (yyyyMMddTHHmmss)
  static final DateFormat _dateFormat = DateFormat("yyyyMMdd'T'HHmmss");

  /// Formato de data para eventos de dia inteiro (yyyyMMdd)
  static final DateFormat _dateOnlyFormat = DateFormat('yyyyMMdd');

  /// Gera um link do Google Calendar para adicionar um evento
  ///
  /// Parâmetros:
  /// - [title]: Título do evento (obrigatório)
  /// - [startDate]: Data/hora de início (obrigatório)
  /// - [endDate]: Data/hora de término (opcional, padrão: 1 hora após início)
  /// - [description]: Descrição do evento (opcional)
  /// - [location]: Local do evento (opcional)
  /// - [isAllDay]: Se é um evento de dia inteiro (padrão: false)
  ///
  /// Retorna a URL do Google Calendar
  ///
  /// Exemplo de uso:
  /// ```dart
  /// final link = CalendarLinkService.generateGoogleCalendarLink(
  ///   title: 'Reunião com Pedreiro',
  ///   startDate: DateTime(2024, 6, 15, 10, 0),
  ///   endDate: DateTime(2024, 6, 15, 11, 0),
  ///   description: 'Discutir cronograma da obra',
  ///   location: 'Canteiro de obras',
  /// );
  /// ```
  static String generateGoogleCalendarLink({
    required String title,
    required DateTime startDate,
    DateTime? endDate,
    String? description,
    String? location,
    bool isAllDay = false,
  }) {
    // Se não forneceu data de término, usa 1 hora após o início
    final end = endDate ?? startDate.add(const Duration(hours: 1));

    // Formata as datas
    String dates;
    if (isAllDay) {
      // Para eventos de dia inteiro, usa formato YYYYMMDD
      final startStr = _dateOnlyFormat.format(startDate);
      final endStr = _dateOnlyFormat.format(end.add(const Duration(days: 1)));
      dates = '$startStr/$endStr';
    } else {
      // Para eventos com horário, usa formato YYYYMMDDTHHMMSS
      final startStr = _dateFormat.format(startDate);
      final endStr = _dateFormat.format(end);
      dates = '$startStr/$endStr';
    }

    // Monta os parâmetros da URL
    final params = <String, String>{
      'action': 'TEMPLATE',
      'text': title,
      'dates': dates,
    };

    if (description != null && description.isNotEmpty) {
      params['details'] = description;
    }

    if (location != null && location.isNotEmpty) {
      params['location'] = location;
    }

    // Constrói a URL
    final uri = Uri.https(
      'calendar.google.com',
      '/calendar/render',
      params,
    );

    return uri.toString();
  }

  /// Abre o link do Google Calendar no navegador
  ///
  /// Retorna true se conseguiu abrir, false caso contrário
  static Future<bool> openGoogleCalendarLink({
    required String title,
    required DateTime startDate,
    DateTime? endDate,
    String? description,
    String? location,
    bool isAllDay = false,
  }) async {
    final link = generateGoogleCalendarLink(
      title: title,
      startDate: startDate,
      endDate: endDate,
      description: description,
      location: location,
      isAllDay: isAllDay,
    );

    final uri = Uri.parse(link);

    if (await canLaunchUrl(uri)) {
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }

    return false;
  }

  /// Gera link para evento de vistoria técnica
  static String generateInspectionLink({
    required DateTime date,
    required String location,
    String? notes,
  }) {
    return generateGoogleCalendarLink(
      title: '🔍 Vistoria Técnica',
      startDate: date,
      endDate: date.add(const Duration(hours: 2)),
      description: notes ?? 'Vistoria técnica da obra',
      location: location,
    );
  }

  /// Gera link para evento de entrega de material
  static String generateDeliveryLink({
    required DateTime date,
    required String material,
    String? supplier,
    String? location,
  }) {
    final description = StringBuffer('Entrega de: $material');
    if (supplier != null) {
      description.write('\nFornecedor: $supplier');
    }

    return generateGoogleCalendarLink(
      title: '📦 Entrega de Material',
      startDate: date,
      endDate: date.add(const Duration(hours: 1)),
      description: description.toString(),
      location: location ?? 'Canteiro de obras',
    );
  }

  /// Gera link para evento de pagamento
  static String generatePaymentLink({
    required DateTime date,
    required String description,
    required double amount,
  }) {
    return generateGoogleCalendarLink(
      title: '💰 Pagamento',
      startDate: date,
      description: '$description\nValor: R\$ ${amount.toStringAsFixed(2)}',
      isAllDay: true,
    );
  }

  /// Gera link para reunião
  static String generateMeetingLink({
    required DateTime date,
    required String title,
    String? location,
    String? notes,
    Duration duration = const Duration(hours: 1),
  }) {
    return generateGoogleCalendarLink(
      title: '👥 $title',
      startDate: date,
      endDate: date.add(duration),
      description: notes,
      location: location,
    );
  }

  /// Gera link para lembrete de prazo
  static String generateDeadlineLink({
    required DateTime date,
    required String task,
    String? notes,
  }) {
    return generateGoogleCalendarLink(
      title: '⏰ Prazo: $task',
      startDate: date,
      description: notes ?? 'Prazo para conclusão',
      isAllDay: true,
    );
  }
}

// Made with Bob
