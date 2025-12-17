import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class SensorNotifier extends Notifier<Map<String, double>> {
  final _random = Random();

  @override
  Map<String, double> build() {
    _simulateData();
    return {
      'Température': 23.0,
      'Consommation': 5.0,
      'Vibrations': 1.0,
      'Humidité': 45.0,
    };
  }

  void _simulateData() async {
    while (true) {
      await Future.delayed(const Duration(seconds: 2));
      state = {
        for (var e in state.entries)
          e.key: (e.value + _random.nextDouble() * 2 - 1).clamp(0, 100),
      };
    }
  }
}
