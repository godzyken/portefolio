import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../notifiers/errors/location_error_notifier.dart';

class GeolocationException implements Exception {
  final String message;
  final String? code; // Ex: PERMISSION_DENIED, POSITION_UNAVAILABLE

  GeolocationException(this.message, {this.code});

  @override
  String toString() => 'GeolocationException: $message (code: $code)';
}

final locationErrorProvier =
    NotifierProvider<LocationErrorNotifier, GeolocationException?>(
  LocationErrorNotifier.new,
);
