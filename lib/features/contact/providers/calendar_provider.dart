import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;

import '../notifiers/calendar_notifier.dart';

/// Fournit l'API Calendar après authentification
final googleCalendarNotifierProvider =
    AsyncNotifierProvider<GoogleCalendarNotifier, calendar.CalendarApi?>(
  () => GoogleCalendarNotifier(),
);
