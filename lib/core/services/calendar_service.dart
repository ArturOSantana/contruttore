import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../features/reform_map/domain/entities/reform_calendar_entity.dart';

/// Serviço para gerenciar exportação e integração com calendários
class CalendarService {
  /// Gera arquivo .ics (iCalendar) com os eventos
  /// Formato padrão compatível com Google Calendar, Apple Calendar, Outlook
  String generateICSFile(List<CalendarEventEntity> events) {
    final buffer = StringBuffer();

    // Cabeçalho do arquivo iCalendar
    buffer.writeln('BEGIN:VCALENDAR');
    buffer.writeln('VERSION:2.0');
    buffer.writeln('PRODID:-//Costruttore//Reforma Calendar//PT');
    buffer.writeln('CALSCALE:GREGORIAN');
    buffer.writeln('METHOD:PUBLISH');
    buffer.writeln('X-WR-CALNAME:Reforma - Costruttore');
    buffer.writeln('X-WR-TIMEZONE:America/Sao_Paulo');
    buffer.writeln('X-WR-CALDESC:Calendário da sua reforma');

    // Adiciona cada evento
    for (final event in events) {
      buffer.writeln(_generateEventICS(event));
    }

    // Rodapé
    buffer.writeln('END:VCALENDAR');

    return buffer.toString();
  }

  /// Gera o ICS de um evento individual
  String _generateEventICS(CalendarEventEntity event) {
    final buffer = StringBuffer();
    final now = DateTime.now();

    // Formata datas no formato iCalendar (YYYYMMDDTHHMMSS)
    final dateFormat = DateFormat('yyyyMMdd');
    final dateTimeFormat = DateFormat('yyyyMMddTHHmmss');

    buffer.writeln('BEGIN:VEVENT');
    buffer.writeln('UID:${event.id}@costruttore.app');
    buffer.writeln('DTSTAMP:${dateTimeFormat.format(now)}Z');

    // Data do evento (dia inteiro)
    buffer.writeln('DTSTART;VALUE=DATE:${dateFormat.format(event.date)}');
    buffer.writeln(
        'DTEND;VALUE=DATE:${dateFormat.format(event.date.add(const Duration(days: 1)))}');

    // Informações do evento
    buffer.writeln('SUMMARY:${_escapeICSText(event.title)}');
    buffer.writeln('DESCRIPTION:${_escapeICSText(event.description)}');
    buffer.writeln('LOCATION:Obra - Costruttore');

    // Status
    buffer.writeln('STATUS:${event.isCompleted ? 'COMPLETED' : 'CONFIRMED'}');

    // Prioridade (1=alta, 5=média, 9=baixa)
    final priority = _getPriorityNumber(event.priority);
    buffer.writeln('PRIORITY:$priority');

    // Categoria
    buffer.writeln('CATEGORIES:${event.type.displayName}');

    // Alarme (lembrete)
    if (!event.isCompleted) {
      buffer.writeln(_generateAlarm(event.priority));
    }

    buffer.writeln('END:VEVENT');

    return buffer.toString();
  }

  /// Gera alarme baseado na prioridade
  String _generateAlarm(EventPriority priority) {
    final buffer = StringBuffer();

    // Define quando alertar baseado na prioridade
    final minutesBefore = switch (priority) {
      EventPriority.critical => 1440, // 1 dia antes
      EventPriority.high => 720, // 12 horas antes
      EventPriority.medium => 360, // 6 horas antes
      EventPriority.low => 60, // 1 hora antes
    };

    buffer.writeln('BEGIN:VALARM');
    buffer.writeln('ACTION:DISPLAY');
    buffer.writeln('DESCRIPTION:Lembrete: Evento da reforma');
    buffer.writeln('TRIGGER:-PT${minutesBefore}M');
    buffer.writeln('END:VALARM');

    return buffer.toString();
  }

  /// Converte prioridade para número iCalendar
  int _getPriorityNumber(EventPriority priority) {
    return switch (priority) {
      EventPriority.critical => 1,
      EventPriority.high => 3,
      EventPriority.medium => 5,
      EventPriority.low => 9,
    };
  }

  /// Escapa texto para formato ICS
  String _escapeICSText(String text) {
    return text
        .replaceAll('\\', '\\\\')
        .replaceAll(',', '\\,')
        .replaceAll(';', '\\;')
        .replaceAll('\n', '\\n');
  }

  /// Exporta eventos para arquivo .ics e compartilha
  Future<void> exportToCalendar(List<CalendarEventEntity> events) async {
    try {
      // Gera conteúdo ICS
      final icsContent = generateICSFile(events);

      // Salva em arquivo temporário
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/reforma_calendario.ics');
      await file.writeAsString(icsContent);

      // Compartilha arquivo
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Calendário da Reforma - Costruttore',
        text:
            'Importe este arquivo no seu calendário preferido (Google Calendar, Apple Calendar, Outlook, etc.)',
      );
    } catch (e) {
      throw Exception('Erro ao exportar calendário: $e');
    }
  }

  /// Gera link para adicionar evento no Google Calendar
  String generateGoogleCalendarLink(CalendarEventEntity event) {
    final dateFormat = DateFormat('yyyyMMdd');
    final startDate = dateFormat.format(event.date);
    final endDate = dateFormat.format(event.date.add(const Duration(days: 1)));

    final title = Uri.encodeComponent(event.title);
    final description = Uri.encodeComponent(event.description);

    return 'https://calendar.google.com/calendar/render?action=TEMPLATE'
        '&text=$title'
        '&dates=$startDate/$endDate'
        '&details=$description'
        '&location=Obra';
  }

  /// Gera link para adicionar evento no Apple Calendar
  String generateAppleCalendarLink(CalendarEventEntity event) {
    final timestamp = event.date.millisecondsSinceEpoch ~/ 1000;
    return 'calshow:$timestamp';
  }
}

// Made with Bob
