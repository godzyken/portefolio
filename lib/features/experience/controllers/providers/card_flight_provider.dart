import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/enum_global.dart';
import '../notifier/card_flight_notifier.dart';

final activeTagsProvider =
    NotifierProvider<ActiveTagsNotifier, List<String>>(ActiveTagsNotifier.new);

final cardFlightProvider =
    NotifierProvider<CardFlightNotifier, Map<String, CardFlightState>>(
  CardFlightNotifier.new,
);
