import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/enum_global.dart';
import '../notifier/card_flight_notifier.dart';

final activeTagsProvider = StateProvider<List<String>>((ref) => []);

final cardFlightProvider =
    StateNotifierProvider<CardFlightNotifier, Map<String, CardFlightState>>(
      (ref) => CardFlightNotifier(),
    );
