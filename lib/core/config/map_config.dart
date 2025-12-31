import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

@immutable
class MapConfig {
  final LatLng initialCenter;
  static const double defaultZoom = 16.0;
  static final parisBounds =
      LatLngBounds(LatLng(48.85, 2.34), LatLng(48.87, 2.36));

  const MapConfig(this.initialCenter);

  MapOptions get options => MapOptions(
        initialCenter: initialCenter,
        initialZoom: defaultZoom,
        cameraConstraint: CameraConstraint.contain(bounds: parisBounds),
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      );
}
