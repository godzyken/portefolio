import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/errors/geolocation_exception.dart';

class LocationErrorNotifier extends Notifier<GeolocationException?> {
  @override
  GeolocationException? build() {
    return null; // état initial = pas d’erreur
  }

  void setError(GeolocationException? e) => state = e;

  void clear() => state = null;
}
