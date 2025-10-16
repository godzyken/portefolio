import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/generator/data/location_data.dart';
import '../../features/generator/services/location_service.dart';

class UserLocationNotifier extends StreamNotifier<LocationData> {
  @override
  Stream<LocationData> build() async* {
    final locationService = LocationService.instance;

    if (!await locationService.isLocationEnabled()) {
      throw Exception('Services de localisation désactivés');
    }

    final permission = await locationService.checkPermission();
    if (permission != LocationPermissionStatus.always &&
        permission != LocationPermissionStatus.whileInUse) {
      final requested = await locationService.requestPermission();
      if (requested != LocationPermissionStatus.always &&
          requested != LocationPermissionStatus.whileInUse) {
        throw Exception('Permission de localisation refusée');
      }
    }

    yield* locationService.getLocationStream();
  }
}
