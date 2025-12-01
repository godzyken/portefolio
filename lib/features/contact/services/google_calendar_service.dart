import 'package:googleapis/calendar/v3.dart' as calendar;

class GoogleCalendarService {
  final calendar.CalendarApi _api;

  GoogleCalendarService(this._api);

  Future<calendar.CalendarList> listCalendars() async {
    return _api.calendarList.list();
  }

  Future<calendar.Event> createEvent({
    required String summary,
    required DateTime start,
    required DateTime end,
    String description = 'Rendez-vous créé via le Portfolio',
    String calendarId = 'primary',
  }) async {
    final newEvent = calendar.Event(
      summary: summary,
      start: calendar.EventDateTime(dateTime: start, timeZone: 'Europe/Paris'),
      end: calendar.EventDateTime(dateTime: end, timeZone: 'Europe/Paris'),
      description: description,
      reminders: calendar.EventReminders(useDefault: true),
    );

    return _api.events.insert(newEvent, calendarId);
  }

  Future<calendar.Events> listEvents(String calendarId,
      {int maxResults = 10, DateTime? timeMin}) async {
    return _api.events.list(
      calendarId,
      maxResults: maxResults,
      timeMin: timeMin?.toUtc(),
      singleEvents: true,
      orderBy: 'startTime',
    );
  }

// ... (Autres méthodes : getEvents, deleteEvent, etc.)
}
