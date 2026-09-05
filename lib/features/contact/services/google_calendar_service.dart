import 'dart:developer' as developer;

import 'package:googleapis/calendar/v3.dart' as calendar;

import '../model/state/time_slot_state.dart';

class GoogleCalendarService {
  final calendar.CalendarApi _api;

  GoogleCalendarService(this._api);

  Future<calendar.CalendarList> listCalendars() async {
    final result = await _api.calendarList.list();
    if (result.items == null) {
      throw Exception('Aucun calendrier trouvé');
    }
    developer.log('✅ Calendriers trouvés : ${result.items?.length ?? 0}');
    return result;
  }

  Future<calendar.Event> createEvent({
    required String summary,
    required DateTime start,
    required DateTime end,
    String? location,
    String description = 'Rendez-vous créé via le Portfolio',
    String calendarId = 'primary',
  }) async {
    developer.log('Tentative de création d\'événement : $summary');

    final locationString =
        (location != null && location.isNotEmpty) ? location : null;

    final newEvent = calendar.Event(
      summary: summary,
      start: calendar.EventDateTime(dateTime: start, timeZone: 'Europe/Paris'),
      end: calendar.EventDateTime(dateTime: end, timeZone: 'Europe/Paris'),
      description: description,
      location: locationString,
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

  Future<calendar.Event> getEvent(
    String eventId, {
    String calendarId = 'primary',
  }) async {
    developer.log('Tentative de récupération de l\'événement : $eventId');
    return _api.events.get(calendarId, eventId);
  }

  Future<void> deleteEvent(
    String eventId, {
    String calendarId = 'primary',
  }) async {
    developer.log('Tentative de suppression de l\'événement : $eventId');
    return _api.events.delete(calendarId, eventId);
  }

  Future<calendar.Event> updateEvent({
    required String eventId,
    required String summary,
    required DateTime start,
    required DateTime end,
    String description = 'Rendez-vous mis à jour via le Portfolio',
    String calendarId = 'primary',
  }) async {
    developer.log('Tentative de mise à jour de l\'événement : $eventId');

    final updatedEvent = calendar.Event(
      summary: summary,
      start: calendar.EventDateTime(dateTime: start, timeZone: 'Europe/Paris'),
      end: calendar.EventDateTime(dateTime: end, timeZone: 'Europe/Paris'),
      description: description,
      reminders: calendar.EventReminders(useDefault: true),
    );

    return _api.events.update(updatedEvent, calendarId, eventId);
  }
}

class CalendarAvailabilityService {
  final GoogleCalendarService _calendarService;

  CalendarAvailabilityService(this._calendarService);

  /// Récupère les événements existants pour une date donnée
  Future<List<calendar.Event>> getEventsForDay(DateTime day) async {
    try {
      final startOfDay = DateTime(day.year, day.month, day.day, 0, 0, 0);
      final endOfDay = DateTime(day.year, day.month, day.day, 23, 59, 59);

      final events = await _calendarService.listEvents(
        'primary',
        maxResults: 50,
        timeMin: startOfDay,
      );

      // Filtrer les événements du jour
      final dayEvents = events.items?.where((event) {
            final start = event.start;
            if (start == null) return false;

            if (start.dateTime != null) {
              // Événement avec heure précise
              final eventStart = start.dateTime!;
              // On vérifie que le début de l'événement est dans la journée proposée
              return eventStart.isAfter(startOfDay) &&
                  eventStart.isBefore(endOfDay);
            } else if (start.date != null) {
              // Événement sur toute la journée (All-Day Event)
              final eventDate = DateTime.parse(start.date!.toString());
              // On vérifie si la date de l'événement est le jour recherché
              return eventDate.year == day.year &&
                  eventDate.month == day.month &&
                  eventDate.day == day.day;
            }
            return false;
          }).toList() ??
          [];

      developer.log(
          '📅 Événements trouvés pour ${day.day}/${day.month}: ${dayEvents.length}');
      return dayEvents;
    } catch (e) {
      developer.log('❌ Erreur récupération événements: $e');
      return [];
    }
  }

  /// Vérifie si un créneau horaire est disponible
  Future<bool> isTimeSlotAvailable(
      DateTime proposedStart, DateTime proposedEnd) async {
    try {
      final events = await getEventsForDay(proposedStart);

      for (final event in events) {
        if (event.start?.dateTime == null || event.end?.dateTime == null) {
          continue;
        }

        final eventStart = event.start!.dateTime!;
        final eventEnd = event.end!.dateTime!;

        // Vérifier le chevauchement
        final hasOverlap = _checkOverlap(
          proposedStart,
          proposedEnd,
          eventStart,
          eventEnd,
        );

        if (hasOverlap) {
          developer.log('⚠️ Chevauchement détecté avec: ${event.summary}');
          return false;
        }
      }

      return true;
    } catch (e) {
      developer.log('❌ Erreur vérification disponibilité: $e');
      return false;
    }
  }

  /// Récupère les créneaux disponibles pour une journée
  Future<List<TimeSlot>> getAvailableTimeSlots(
    DateTime day,
    List<TimeSlot> proposedSlots,
  ) async {
    developer.log('🔍 Recherche de créneaux pour le ${day.toIso8601String()}');
    final availableSlots = <TimeSlot>[];

    try {
      for (final slot in proposedSlots) {
        final slotStart = DateTime(
          day.year,
          day.month,
          day.day,
          slot.hour,
          slot.minute,
        );
        final slotEnd = slotStart.add(const Duration(hours: 1));

        final isAvailable = await isTimeSlotAvailable(slotStart, slotEnd);

        if (isAvailable) {
          availableSlots.add(slot);
        } else {
          developer.log(
              '❌ Créneau ${slot.hour}:${slot.minute} non disponible (occupé)');
        }
      }
    } catch (e) {
      developer.log('❌ Erreur lors du calcul des créneaux: $e');
      // En cas d'erreur de l'API, on peut décider de retourner les slots par défaut
      // ou de laisser remonter l'erreur. Ici on laisse remonter pour que availableTimeSlotsProvider le gère.
      rethrow;
    }

    developer.log(
        '✅ ${availableSlots.length} créneaux disponibles sur ${proposedSlots.length}');
    return availableSlots;
  }

  /// Vérifie si deux plages horaires se chevauchent
  bool _checkOverlap(
    DateTime start1,
    DateTime end1,
    DateTime start2,
    DateTime end2,
  ) {
    // Cas 1: start1 est pendant l'événement existant
    if (start1.isAfter(start2) && start1.isBefore(end2)) {
      return true;
    }

    // Cas 2: end1 est pendant l'événement existant
    if (end1.isAfter(start2) && end1.isBefore(end2)) {
      return true;
    }

    // Cas 3: l'événement proposé englobe l'événement existant
    if (start1.isBefore(start2) && end1.isAfter(end2)) {
      return true;
    }

    // Cas 4: l'événement proposé est identique
    if (start1.isAtSameMomentAs(start2) && end1.isAtSameMomentAs(end2)) {
      return true;
    }

    return false;
  }

  /// Créer un événement avec vérification de disponibilité
  Future<calendar.Event?> createEventIfAvailable({
    required String summary,
    required DateTime start,
    required DateTime end,
    required String description,
    String? location,
    String calendarId = 'primary',
  }) async {
    // Vérifier la disponibilité
    final isAvailable = await isTimeSlotAvailable(start, end);

    if (!isAvailable) {
      throw Exception('Ce créneau n\'est plus disponible');
    }

    try {
      // Créer l'événement
      final event = await _calendarService.createEvent(
        summary: summary,
        start: start,
        end: end,
        description: description,
        calendarId: calendarId,
        location: location,
      );
      developer.log('✅ Événement créé avec succès : ${event.summary}');
      developer.log('📅 Début : ${event.start?.dateTime}');
      developer.log('📅 Fin : ${event.end?.dateTime}');
      developer.log('📍 Lieu : ${event.location}');
      developer.log('💬 Description : ${event.description}');

      return event;
    } on calendar.ApiRequestError catch (e, st) {
      developer.log(
          '❌ Erreur critique lors de l\'insertion de l\'événement Google : $e',
          stackTrace: st,
          name: 'GoogleCalendarService');

      rethrow;
    }
  }
}
