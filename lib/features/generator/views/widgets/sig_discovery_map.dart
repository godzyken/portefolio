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

  @override
  void initState() {
    super.initState();

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
    final mapController = ref.read(mapControllerProvider);

    return userPosAsync.when(
      data: (pos) {
        final userPos = LatLng(pos.latitude, pos.longitude);
        final sigPoints = position.value ?? [];

        if (followUser) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            mapController.move(userPos, mapController.camera.zoom);
          });
        }

        return FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: userPos,
            initialZoom: 16,
            interactionOptions: InteractionOptions(flags: InteractiveFlag.all),
          ),
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            ),

            // Marqueur utilisateur
            MarkerLayer(
              markers: [
                Marker(
                  point: userPos,
                  width: 40,
                  height: 40,
                  alignment: Alignment(0, -1),
                  rotate: true,
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.blue,
                    size: 40,
                  ),
                ),
                // Marquer des Données Sig
                ...sigPoints.map(
                  (p) => Marker(
                    point: p,
                    width: 35,
                    height: 35,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final scale = 1.0 + 0.3 * _pulseController.value;
                        return Transform.scale(
                          scale: scale,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 35,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Text("Erreur: $e"),
    );
  }
}
