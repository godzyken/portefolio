import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:web/web.dart' as web;

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

  // Clé injectée avec --dart-define
  static const mapsApiKey = String.fromEnvironment('MAPS_API_KEY');

  void loadGoogleMaps(String apiKey) {
    // Injection dynamique du script Google Maps
    final script = web.HTMLScriptElement();
    script.src =
        'https://maps.googleapis.com/maps/api/js?key=$apiKey&libraries=places';
    script.async = true;

    web.document.head!.append(script);
  }

  @override
  void initState() {
    super.initState();

    loadGoogleMaps(mapsApiKey);

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

        final markers = <Marker>{
          Marker(
            markerId: const MarkerId("user"),
            position: userPos,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
          ),
          ...sigPoints.map((p) {
            return Marker(
              markerId: MarkerId(p.toString()),
              position: p,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed,
              ),
            );
          }),
        };

        if (followUser) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (mapControllerCompleter.isCompleted) {
              final controller = await mapControllerCompleter.future;
              controller.animateCamera(CameraUpdate.newLatLng(userPos));
            }
          });
        }

        return GoogleMap(
          initialCameraPosition: CameraPosition(
            target: userPos,
            zoom: 16,
            tilt: 60, // angle pour voir en 3D
          ),
          mapType: MapType.hybrid,
          markers: markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          compassEnabled: true,
          buildingsEnabled: true, // active les bâtiments 3D
          onMapCreated: (controller) {
            if (!mapControllerCompleter.isCompleted) {
              mapControllerCompleter.complete(controller);
            }
          },
          webCameraControlEnabled: true,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Text("Erreur: $e"),
    );
  }
}
