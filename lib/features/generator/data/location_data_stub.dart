// Stub pour éviter les imports geolocator sur Web

// Classes fictives pour satisfaire les références
class Position {
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime? timestamp;

  Position({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.timestamp,
  });
}

enum LocationPermission {
  denied,
  deniedForever,
  whileInUse,
  always,
  unableToDetermine,
}

enum LocationAccuracy {
  lowest,
  low,
  medium,
  high,
  best,
  bestForNavigation,
}

class LocationSettings {
  final LocationAccuracy accuracy;
  final int distanceFilter;

  const LocationSettings({
    required this.accuracy,
    required this.distanceFilter,
  });
}

// Classe statique stub
class Geolocator {
  static Future<LocationPermission> checkPermission() async {
    return LocationPermission.denied;
  }

  static Future<LocationPermission> requestPermission() async {
    return LocationPermission.denied;
  }

  static Future<Position> getCurrentPosition() async {
    throw UnimplementedError('Geolocator non disponible sur Web');
  }

  static Stream<Position> getPositionStream({
    LocationSettings? locationSettings,
  }) {
    return Stream.empty();
  }

  static Future<bool> isLocationServiceEnabled() async {
    return false;
  }
}
