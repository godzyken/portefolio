import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Fournit la bonne configuration selon la plateforme
final locationSettingsProvider = Provider<Map<String, dynamic>>((ref) {
  if (defaultTargetPlatform == TargetPlatform.android) {
    return {
      'accuracy': 'high',
      'distanceFilter': 100,
      'intervalDuration': 10000, // millisecondes
    };
  } else if (defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    return {
      'accuracy': 'high',
      'activityType': 'fitness',
      'distanceFilter': 100,
    };
  } else if (kIsWeb) {
    return {
      'accuracy': 'high',
      'distanceFilter': 100,
      'maximumAge': 300000, // 5 minutes en millisecondes
    };
  } else {
    return {'accuracy': 'high', 'distanceFilter': 100};
  }
});
