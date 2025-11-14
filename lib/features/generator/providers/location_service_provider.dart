import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/location_service.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  final service = LocationService.instance;

  ref.onDispose(() => service.dispose());
  return service;
});
