import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/provider/providers.dart';

class SigDiscoveryMap extends ConsumerStatefulWidget {
  const SigDiscoveryMap({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SigDiscoveryMapState();
}

class _SigDiscoveryMapState extends ConsumerState<SigDiscoveryMap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late bool _ready = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.endOfFrame.then((_) {
      if (mounted) setState(() => _ready = true);
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final position = ref.watch(positionProvider);
    final userPosAsync = ref.watch(userLocationProvider);
    final followUser = ref.watch(followUserProvider);
    final mapControllerCompleter = ref.read(mapControllerProvider);

    return userPosAsync.when(
      data: (pos) {
        final userPos = LatLng(pos.latitude, pos.longitude);
        final sigPoints = position.value ?? [];

        final markers = <Marker>[
          Marker(
            point: userPos,
            width: 40,
            height: 40,
            child: const Icon(
              Icons.person_pin_circle,
              color: Colors.blue,
              size: 40,
            ),
          ),
          ...sigPoints.map((p) {
            return Marker(
              point: p,
              width: 40,
              height: 40,
              child: const Icon(Icons.location_on, color: Colors.red, size: 40),
            );
          }),
        ];

        if (followUser) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            mapControllerCompleter.move(userPos, 16.0);
          });
        }

        if (!_ready) const Center(child: CircularProgressIndicator());

        return FlutterMap(
          mapController: mapControllerCompleter,
          options: MapOptions(
              initialCenter: userPos,
              initialZoom: 16.0,
              minZoom: 3.0,
              maxZoom: 18.0,
              keepAlive: true,
              backgroundColor: Colors.grey.shade100),
          children: [
            // Couche de tuiles - OpenStreetMap
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.example.app',
            ),

            // Couche satellite alternative (optionnel)
            TileLayer(
              urlTemplate:
                  'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
              userAgentPackageName: 'com.godzyken.portfolio',
            ),

            // Couche des marqueurs
            MarkerLayer(markers: markers),

            // Contrôles de la carte
            RichAttributionWidget(
              popupInitialDisplayDuration: const Duration(seconds: 5),
              animationConfig: const ScaleRAWA(),
              showFlutterMapAttribution: false,
              attributions: [
                TextSourceAttribution(
                  '© OpenStreetMap contributors',
                  onTap: () {}, // Vous pouvez ajouter un lien vers OSM
                ),
                const TextSourceAttribution('SIG Discovery Map'),
              ],
            ),
          ],
        );
      },
      loading: () => Container(
        color: Colors.grey.shade200,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Chargement de la carte SIG...'),
            ],
          ),
        ),
      ),
      error: (e, st) => Container(
        color: Colors.red.shade50,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                "Erreur de géolocalisation",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "$e",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red.shade600),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // Relancer la géolocalisation
                  ref.invalidate(userLocationProvider);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
