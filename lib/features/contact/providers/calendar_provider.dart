import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;

import '../notifiers/calendar_notifier.dart';
import '../services/google_calendar_service.dart';

final googleCalendarNotifierProvider =
    AsyncNotifierProvider<GoogleCalendarNotifier, GoogleCalendarService?>(
  GoogleCalendarNotifier.new,
);

final googleCalendarServiceProvider = Provider<GoogleCalendarService?>((ref) {
  return ref.watch(googleCalendarNotifierProvider).value;
});

final calendarEventsProvider =
    FutureProvider.autoDispose<calendar.Events>((ref) async {
  final calendarService = ref.watch(googleCalendarNotifierProvider).value;

  if (calendarService == null) {
    return calendar.Events();
  }

  return calendarService.listEvents('primary');
});
