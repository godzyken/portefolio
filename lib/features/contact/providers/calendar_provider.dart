import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifiers/calendar_notifier.dart';
import '../services/google_calendar_service.dart';

/// Fournit l'API Calendar après authentification
final googleCalendarNotifierProvider =
    AsyncNotifierProvider<GoogleCalendarNotifier, GoogleCalendarService?>(
  GoogleCalendarNotifier.new,
);

final googleCalendarServiceProvider = Provider<GoogleCalendarService?>((ref) {
  return ref.watch(googleCalendarNotifierProvider).value;
});
