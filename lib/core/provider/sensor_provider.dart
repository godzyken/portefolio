import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifier/sensor_notifier.dart';

final sensorProvider =
    NotifierProvider<SensorNotifier, Map<String, double>>(() {
  return SensorNotifier();
});
