# 📅 Guia de Links do Google Calendar

## 🎯 Visão Geral

Este guia explica como usar o serviço de geração de links do Google Calendar no app Contruttore. **Não requer autenticação OAuth ou configuração complexa!**

## ✨ Como Funciona

O serviço gera URLs especiais do Google Calendar que, quando clicadas, abrem o Google Calendar com o evento já pré-preenchido. O usuário só precisa clicar em "Salvar".

### Vantagens
- ✅ **Sem autenticação**: Não precisa fazer login ou configurar OAuth
- ✅ **Simples**: Apenas gera um link e abre no navegador
- ✅ **Universal**: Funciona em qualquer dispositivo com Google Calendar
- ✅ **Rápido**: O usuário só clica e salva

## 📖 Como Usar

### 1. Importar o Serviço

```dart
import 'package:contruttore/core/services/calendar_link_service.dart';
```

### 2. Gerar um Link Básico

```dart
// Gera o link
final link = CalendarLinkService.generateGoogleCalendarLink(
  title: 'Reunião com Pedreiro',
  startDate: DateTime(2024, 6, 15, 10, 0),
  endDate: DateTime(2024, 6, 15, 11, 0),
  description: 'Discutir cronograma da obra',
  location: 'Canteiro de obras',
);

print(link);
// Resultado: https://calendar.google.com/calendar/render?action=TEMPLATE&text=...
```

### 3. Abrir o Link Automaticamente

```dart
// Gera e abre o link no navegador
final success = await CalendarLinkService.openGoogleCalendarLink(
  title: 'Reunião com Pedreiro',
  startDate: DateTime(2024, 6, 15, 10, 0),
  endDate: DateTime(2024, 6, 15, 11, 0),
  description: 'Discutir cronograma da obra',
  location: 'Canteiro de obras',
);

if (success) {
  print('✅ Google Calendar aberto com sucesso!');
} else {
  print('❌ Erro ao abrir Google Calendar');
}
```

## 🎨 Exemplos Práticos

### Vistoria Técnica

```dart
final link = CalendarLinkService.generateInspectionLink(
  date: DateTime(2024, 6, 20, 14, 0),
  location: 'Rua das Flores, 123',
  notes: 'Verificar instalações elétricas e hidráulicas',
);

// Abre o link
await CalendarLinkService.openGoogleCalendarLink(
  title: '🔍 Vistoria Técnica',
  startDate: DateTime(2024, 6, 20, 14, 0),
  endDate: DateTime(2024, 6, 20, 16, 0),
  description: 'Verificar instalações elétricas e hidráulicas',
  location: 'Rua das Flores, 123',
);
```

### Entrega de Material

```dart
final link = CalendarLinkService.generateDeliveryLink(
  date: DateTime(2024, 6, 25, 9, 0),
  material: 'Cimento e Areia',
  supplier: 'Construmais Ltda',
  location: 'Canteiro de obras',
);
```

### Pagamento

```dart
final link = CalendarLinkService.generatePaymentLink(
  date: DateTime(2024, 6, 30),
  description: 'Pagamento ao Eletricista',
  amount: 2500.00,
);
```

### Reunião

```dart
final link = CalendarLinkService.generateMeetingLink(
  date: DateTime(2024, 7, 5, 15, 0),
  title: 'Reunião com Arquiteto',
  location: 'Escritório',
  notes: 'Revisar projeto de reforma',
  duration: Duration(hours: 2),
);
```

### Prazo/Deadline

```dart
final link = CalendarLinkService.generateDeadlineLink(
  date: DateTime(2024, 7, 10),
  task: 'Finalizar Pintura',
  notes: 'Prazo final para conclusão da pintura externa',
);
```

## 🎯 Integração com UI

### Exemplo de Botão

```dart
ElevatedButton.icon(
  onPressed: () async {
    final success = await CalendarLinkService.openGoogleCalendarLink(
      title: 'Vistoria Técnica',
      startDate: DateTime.now().add(Duration(days: 7)),
      endDate: DateTime.now().add(Duration(days: 7, hours: 2)),
      description: 'Vistoria da obra',
      location: 'Canteiro de obras',
    );
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Evento adicionado ao Google Calendar!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Erro ao abrir Google Calendar')),
      );
    }
  },
  icon: Icon(Icons.calendar_today),
  label: Text('Adicionar ao Calendário'),
)
```

### Exemplo de Card com Link

```dart
Card(
  child: ListTile(
    leading: Icon(Icons.event, color: Colors.blue),
    title: Text('Reunião com Pedreiro'),
    subtitle: Text('15/06/2024 às 10:00'),
    trailing: IconButton(
      icon: Icon(Icons.add_to_calendar),
      onPressed: () async {
        await CalendarLinkService.openGoogleCalendarLink(
          title: 'Reunião com Pedreiro',
          startDate: DateTime(2024, 6, 15, 10, 0),
          endDate: DateTime(2024, 6, 15, 11, 0),
        );
      },
    ),
  ),
)
```

### Exemplo de Menu de Compartilhamento

```dart
PopupMenuButton<String>(
  onSelected: (value) async {
    if (value == 'calendar') {
      final link = CalendarLinkService.generateGoogleCalendarLink(
        title: 'Vistoria Técnica',
        startDate: DateTime.now().add(Duration(days: 7)),
      );
      
      // Opção 1: Abrir diretamente
      await CalendarLinkService.openGoogleCalendarLink(
        title: 'Vistoria Técnica',
        startDate: DateTime.now().add(Duration(days: 7)),
      );
      
      // Opção 2: Compartilhar o link
      await Share.share(link);
    }
  },
  itemBuilder: (context) => [
    PopupMenuItem(
      value: 'calendar',
      child: Row(
        children: [
          Icon(Icons.calendar_today),
          SizedBox(width: 8),
          Text('Adicionar ao Calendário'),
        ],
      ),
    ),
  ],
)
```

## 🔧 Parâmetros Disponíveis

### generateGoogleCalendarLink()

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| `title` | String | ✅ Sim | Título do evento |
| `startDate` | DateTime | ✅ Sim | Data/hora de início |
| `endDate` | DateTime | ❌ Não | Data/hora de término (padrão: +1 hora) |
| `description` | String | ❌ Não | Descrição detalhada do evento |
| `location` | String | ❌ Não | Local do evento |
| `isAllDay` | bool | ❌ Não | Se é evento de dia inteiro (padrão: false) |

### openGoogleCalendarLink()

Mesmos parâmetros de `generateGoogleCalendarLink()`, mas abre o link automaticamente.

## 📱 Comportamento em Diferentes Plataformas

### Android
- Abre o app Google Calendar se instalado
- Caso contrário, abre no navegador

### iOS
- Abre o app Google Calendar se instalado
- Caso contrário, abre no Safari

### Web
- Abre em nova aba do navegador

## 🎨 Ícones Sugeridos

Use estes ícones do Material Design para melhor UX:

```dart
// Adicionar ao calendário
Icon(Icons.calendar_today)
Icon(Icons.add_to_calendar)
Icon(Icons.event)

// Tipos de eventos
Icon(Icons.meeting_room)        // Reunião
Icon(Icons.construction)        // Vistoria
Icon(Icons.local_shipping)      // Entrega
Icon(Icons.payment)             // Pagamento
Icon(Icons.alarm)               // Lembrete
Icon(Icons.flag)                // Prazo
```

## ⚠️ Observações Importantes

1. **Fuso Horário**: As datas são enviadas no fuso horário local do dispositivo
2. **Formato de Data**: O Google Calendar aceita formato ISO 8601
3. **Caracteres Especiais**: São automaticamente codificados na URL
4. **Limite de Caracteres**: Evite descrições muito longas (máx. ~1000 caracteres)

## 🚀 Próximos Passos

Agora você pode:

1. ✅ Adicionar botões "Adicionar ao Calendário" em qualquer tela
2. ✅ Gerar links para compartilhar eventos
3. ✅ Criar lembretes automáticos para prazos importantes
4. ✅ Integrar com notificações do app

## 📚 Recursos Adicionais

- [Google Calendar URL Scheme](https://github.com/InteractionDesignFoundation/add-event-to-calendar-docs/blob/main/services/google.md)
- [url_launcher Package](https://pub.dev/packages/url_launcher)
- [Intl Package](https://pub.dev/packages/intl)

---

**Feito com ❤️ por Bob**