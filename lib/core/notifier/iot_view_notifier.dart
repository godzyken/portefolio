import 'package:flutter_riverpod/flutter_riverpod.dart';

class IoTViewModeNotifier extends Notifier<bool> {
  @override
  bool build() => false; // false = liste, true = grille

  void toggle() => state = !state;
}

class IoTSectionExpandedNotifier extends Notifier<Map<String, bool>> {
  @override
  Map<String, bool> build() => {
        'dashboard': true,
        'historical': false,
        'statistics': false,
      };

  void toggleSection(String key) {
    state = {
      for (final entry in state.entries)
        entry.key: entry.key == key ? !entry.value : entry.value,
    };
  }
}

class IoTSensorFilterNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {
        'Température',
        'Consommation',
        'Vibrations',
        'Humidité',
      };

  void toggleSensor(String sensor) {
    final newSet = {...state};
    if (newSet.contains(sensor)) {
      newSet.remove(sensor);
    } else {
      newSet.add(sensor);
    }
    state = newSet;
  }

  bool isActive(String sensor) => state.contains(sensor);
}

class IoTDashboardThemeNotifier extends Notifier<bool> {
  @override
  bool build() => true; // true = dark, false = light

  void toggleTheme() => state = !state;
}
