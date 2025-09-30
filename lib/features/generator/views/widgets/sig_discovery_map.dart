import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:portefolio/features/generator/data/location_data.dart';

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
    if (kIsWeb) {
      return _buildStaticMap();
    }
    final userPosAsync = ref.watch(userLocationProvider);

    return userPosAsync.when(
      data: (pos) => Stack(
        children: [
          _buildMap(pos),
          _buildDemoBadge(),
          _buildRecenterButton(pos),
        ],
      ),
      loading: () => _buildLoading(),
      error: (e, st) => _buildError(e),
    );
  }

  /// Carte statique pour le Web (position fixe : Paris)
  Widget _buildStaticMap() {
    const parisPos = LatLng(48.8566, 2.3522);
    final mapController = MapController();

    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: parisPos,
            initialZoom: 13.0,
            minZoom: 3.0,
            maxZoom: 18.0,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.godzyken.portfolio',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: parisPos,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.location_city,
                    color: Colors.blue,
                    size: 40,
                  ),
                ),
              ],
            ),
            RichAttributionWidget(
              popupInitialDisplayDuration: const Duration(seconds: 3),
              showFlutterMapAttribution: false,
              attributions: [
                TextSourceAttribution('© OpenStreetMap'),
                const TextSourceAttribution('Mode démo Web'),
              ],
            ),
          ],
        ),
        // Badge "Mode Démo"
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.withAlpha((255 * 0.9).toInt()),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'Mode Démo (Web)',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDemoBadge() {
    return Positioned(
      top: 16,
      left: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.withAlpha((255 * 0.9).toInt()),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((255 * 0.2).toInt()),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.gps_fixed, size: 16, color: Colors.white),
            SizedBox(width: 6),
            Text(
              'Géolocalisation active',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap(LocationData pos) {
    final userPos = LatLng(pos.latitude, pos.longitude);
    final sigPoints = ref.watch(positionProvider).value ?? [];
    final followUser = ref.watch(followUserProvider);
    final mapController = ref.read(mapControllerProvider);
    final mapOptionsFactory = ref.watch(mapConfigProvider);

    final markers = <Marker>[
      Marker(
        point: userPos,
        width: 40,
        height: 40,
        child: ScaleTransition(
          scale: Tween(begin: 0.8, end: 1.2).animate(
            CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
          ),
          child: const Icon(
            Icons.person_pin_circle,
            color: Colors.blue,
            size: 40,
          ),
        ),
      ),
      ...sigPoints.map((p) => Marker(
            point: p,
            width: 40,
            height: 40,
            child: const Icon(Icons.location_on, color: Colors.red, size: 40),
          )),
    ];

    if (followUser) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        mapController.move(userPos, 16.0);
      });
    }

    return FlutterMap(
      mapController: mapController,
      options: mapOptionsFactory(userPos),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.godzyken.portfolio',
        ),
        TileLayer(
          urlTemplate:
              'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
          userAgentPackageName: 'com.godzyken.portfolio',
        ),
        MarkerLayer(markers: markers),
        RichAttributionWidget(
          popupInitialDisplayDuration: const Duration(seconds: 5),
          showFlutterMapAttribution: false,
          attributions: [
            TextSourceAttribution('© OpenStreetMap contributors'),
            const TextSourceAttribution('SIG Discovery Map'),
          ],
        ),
      ],
    );
  }

  /// Bouton flottant pour recadrer sur la position utilisateur
  Widget _buildRecenterButton(LocationData pos) {
    final mapController = ref.read(mapControllerProvider);
    final userPos = LatLng(pos.latitude, pos.longitude);

    return Positioned(
      bottom: 20,
      right: 20,
      child: FloatingActionButton(
        heroTag: "recenter_btn",
        onPressed: () {
          mapController.move(userPos, 16.0);
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.my_location, color: Colors.blue),
      ),
    );
  }

  Widget _buildLoading() => Container(
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
      );

  Widget _buildError(Object e) => Container(
        color: Colors.red.shade50,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text(
                "Erreur de géolocalisation",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700),
              ),
              const SizedBox(height: 8),
              Text("$e",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red.shade600)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(userLocationProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
}
