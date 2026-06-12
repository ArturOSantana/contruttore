# 📅 Sistema de Calendário Offline

Sistema completo de calendário local com eventos salvos no Firestore e notificações.

## 🎯 Funcionalidades

- ✅ Criar, editar e deletar eventos
- ✅ Tipos de eventos: Reunião, Vistoria, Entrega, Pagamento, Prazo, Lembrete
- ✅ Prioridades: Baixa, Média, Alta
- ✅ Status: Pendente, Concluído, Cancelado
- ✅ Eventos de dia inteiro
- ✅ Notificações configuráveis
- ✅ Sincronização em tempo real (Firestore)
- ✅ Funciona offline (cache do Firestore)
- ✅ Geração de links do Google Calendar

## 📁 Estrutura

```
lib/features/calendar/
├── domain/
│   ├── entities/
│   │   └── event_entity.dart          # Entidade de evento
│   └── repositories/
│       └── event_repository.dart      # Interface do repositório
├── data/
│   ├── models/
│   │   └── event_model.dart           # Model para Firestore
│   └── repositories/
│       └── event_repository_impl.dart # Implementação do repositório
└── README.md                          # Este arquivo
```

## 🚀 Como Usar

### 1. Criar um Evento

```dart
final event = EventEntity(
  id: uuid.v4(),
  projectId: 'project-id',
  title: 'Reunião com Pedreiro',
  description: 'Discutir cronograma da obra',
  startDate: DateTime(2024, 6, 15, 10, 0),
  endDate: DateTime(2024, 6, 15, 11, 0),
  location: 'Canteiro de obras',
  type: EventType.meeting,
  priority: EventPriority.high,
  status: EventStatus.pending,
  hasNotification: true,
  notificationMinutesBefore: 60, // 1 hora antes
  createdAt: DateTime.now(),
);

await repository.createEvent(event);
```

### 2. Buscar Eventos

```dart
// Todos os eventos do projeto
final events = await repository.getEvents(projectId);

// Eventos de hoje
final todayEvents = await repository.getTodayEvents(projectId);

// Eventos próximos (próximas 24h)
final upcomingEvents = await repository.getUpcomingEvents(projectId);

// Eventos pendentes
final pendingEvents = await repository.getPendingEvents(projectId);

// Eventos por período
final events = await repository.getEventsByDateRange(
  projectId: projectId,
  startDate: DateTime(2024, 6, 1),
  endDate: DateTime(2024, 6, 30),
);
```

### 3. Atualizar Evento

```dart
final updatedEvent = event.copyWith(
  title: 'Novo título',
  status: EventStatus.completed,
  completedAt: DateTime.now(),
);

await repository.updateEvent(updatedEvent);
```

### 4. Marcar como Concluído

```dart
await repository.completeEvent(eventId);
```

### 5. Cancelar Evento

```dart
await repository.cancelEvent(eventId);
```

### 6. Deletar Evento

```dart
await repository.deleteEvent(eventId);
```

### 7. Observar Mudanças em Tempo Real

```dart
// Observar todos os eventos
repository.watchEvents(projectId).listen((events) {
  print('Eventos atualizados: ${events.length}');
});

// Observar apenas eventos pendentes
repository.watchPendingEvents(projectId).listen((events) {
  print('Eventos pendentes: ${events.length}');
});
```

## 🔔 Notificações

Para implementar notificações, use o `flutter_local_notifications` (já instalado):

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Agendar notificação para um evento
Future<void> scheduleEventNotification(EventEntity event) async {
  if (!event.hasNotification || event.notificationMinutesBefore == null) {
    return;
  }

  final notificationTime = event.startDate.subtract(
    Duration(minutes: event.notificationMinutesBefore!),
  );

  await flutterLocalNotificationsPlugin.zonedSchedule(
    event.id.hashCode,
    '${event.typeIcon} ${event.title}',
    event.description ?? 'Evento em ${event.notificationMinutesBefore} minutos',
    tz.TZDateTime.from(notificationTime, tz.local),
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'events_channel',
        'Eventos',
        channelDescription: 'Notificações de eventos do calendário',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );
}
```

## 🔗 Integração com Google Calendar

Use o `CalendarLinkService` para gerar links:

```dart
import 'package:contruttore/core/services/calendar_link_service.dart';

// Gerar link
final link = CalendarLinkService.generateGoogleCalendarLink(
  title: event.title,
  startDate: event.startDate,
  endDate: event.endDate,
  description: event.description,
  location: event.location,
  isAllDay: event.isAllDay,
);

// Ou abrir diretamente
await CalendarLinkService.openGoogleCalendarLink(
  title: event.title,
  startDate: event.startDate,
  endDate: event.endDate,
  description: event.description,
  location: event.location,
  isAllDay: event.isAllDay,
);
```

## 📱 Widgets Prontos

Use os widgets em `lib/core/widgets/add_to_calendar_button.dart`:

```dart
// Botão completo
AddToCalendarButton(
  title: event.title,
  startDate: event.startDate,
  endDate: event.endDate,
  description: event.description,
  location: event.location,
)

// Botão de ícone
AddToCalendarIconButton(
  title: event.title,
  startDate: event.startDate,
)

// Card de evento
EventCard(
  title: event.title,
  startDate: event.startDate,
  endDate: event.endDate,
  description: event.description,
  location: event.location,
  icon: Icons.meeting_room,
  iconColor: Colors.blue,
)
```

## 🗄️ Estrutura do Firestore

```
events/
  {eventId}/
    projectId: string
    title: string
    description: string?
    startDate: timestamp
    endDate: timestamp?
    location: string?
    type: string (meeting|inspection|delivery|payment|deadline|reminder|other)
    priority: string (low|medium|high)
    status: string (pending|completed|cancelled)
    isAllDay: boolean
    hasNotification: boolean
    notificationMinutesBefore: number?
    createdAt: timestamp
    completedAt: timestamp?
```

## 📊 Índices Necessários no Firestore

Crie estes índices compostos no Firebase Console:

1. **events** collection:
   - `projectId` (Ascending) + `startDate` (Ascending)
   - `projectId` (Ascending) + `status` (Ascending) + `startDate` (Ascending)

## 🎨 Tipos de Eventos e Ícones

| Tipo | Enum | Ícone | Nome |
|------|------|-------|------|
| Reunião | `EventType.meeting` | 👥 | Reunião |
| Vistoria | `EventType.inspection` | 🔍 | Vistoria |
| Entrega | `EventType.delivery` | 📦 | Entrega |
| Pagamento | `EventType.payment` | 💰 | Pagamento |
| Prazo | `EventType.deadline` | ⏰ | Prazo |
| Lembrete | `EventType.reminder` | 🔔 | Lembrete |
| Outro | `EventType.other` | 📅 | Outro |

## 🔄 Próximos Passos

Para completar o sistema, você precisa:

1. **Criar Use Cases** (opcional, mas recomendado):
   - `CreateEventUseCase`
   - `GetEventsUseCase`
   - `UpdateEventUseCase`
   - `DeleteEventUseCase`
   - `CompleteEventUseCase`

2. **Criar Cubit/Bloc** para gerenciar estado:
   - `EventsCubit` com estados: `EventsInitial`, `EventsLoading`, `EventsLoaded`, `EventsError`

3. **Criar UI**:
   - Tela de lista de eventos
   - Tela de adicionar/editar evento
   - Calendário visual (use `table_calendar` package)

4. **Implementar Notificações**:
   - Agendar notificações ao criar eventos
   - Cancelar notificações ao deletar eventos
   - Atualizar notificações ao editar eventos

5. **Integrar com Projetos**:
   - Adicionar botão "Eventos" na tela do projeto
   - Mostrar eventos próximos no dashboard

## 📚 Recursos Úteis

- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
- [table_calendar](https://pub.dev/packages/table_calendar)
- [timezone](https://pub.dev/packages/timezone)
- [Firestore Documentation](https://firebase.google.com/docs/firestore)

---

**Feito com ❤️ por Bob**