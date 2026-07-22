import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;

import '../model/state/appointment_state.dart';
import '../model/state/time_slot_state.dart';
import '../notifiers/appointment_notifier.dart';
import '../notifiers/calendar_notifier.dart';
import '../services/google_calendar_service.dart';

final googleCalendarNotifierProvider =
    AsyncNotifierProvider<GoogleCalendarNotifier, GoogleCalendarService?>(
  GoogleCalendarNotifier.new,
);

final googleCalendarServiceProvider = Provider<GoogleCalendarService?>((ref) {
  return ref.watch(googleCalendarNotifierProvider).value;
});

final calendarAvailabilityServiceProvider =
    Provider<CalendarAvailabilityService?>((ref) {
  final calendarService = ref.watch(googleCalendarServiceProvider);

  if (calendarService == null) {
    return null;
  }

  return CalendarAvailabilityService(calendarService);
});

final availableTimeSlotsProvider =
    FutureProvider.family<List<TimeSlot>, DateTime>(
  (ref, day) async {
    final availabilityService = ref.watch(calendarAvailabilityServiceProvider);

    if (availabilityService == null) {
      // Retourner tous les créneaux par défaut
      return _defaultTimeSlots;
    }

    // Récupérer les créneaux disponibles
    return await availabilityService.getAvailableTimeSlots(
      day,
      _defaultTimeSlots,
    );
  },
);

const List<TimeSlot> _defaultTimeSlots = [
  TimeSlot(hour: 9, minute: 0),
  TimeSlot(hour: 10, minute: 0),
  TimeSlot(hour: 11, minute: 0),
  TimeSlot(hour: 14, minute: 0),
  TimeSlot(hour: 15, minute: 0),
  TimeSlot(hour: 16, minute: 0),
];

final calendarEventsProvider =
    FutureProvider.autoDispose<calendar.Events>((ref) async {
  final calendarService = ref.watch(googleCalendarNotifierProvider).value;

  if (calendarService == null) {
    return calendar.Events();
  }

  return calendarService.listEvents('primary');
});

final appointmentProvider =
    NotifierProvider<AppointmentNotifier, AppointmentState>(
  AppointmentNotifier.new,
);
