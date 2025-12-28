import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:portefolio/core/provider/provider_extentions.dart';
import 'package:portefolio/core/ui/widgets/responsive_text.dart';

import '../../../experience/data/experiences_data.dart';

class SigDiscoveryMap extends ConsumerStatefulWidget {
  const SigDiscoveryMap({super.key});

  @override
  ConsumerState<SigDiscoveryMap> createState() => _SigDiscoveryMapState();
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

  void _showExperienceDetails(WorkExperience exp) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(exp.entreprise,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(exp.poste,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
            const Divider(),
            Text(exp.periode,
                style: const TextStyle(fontStyle: FontStyle.italic)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => /* Naviguer vers la page détail */ {},
              child: const Text("Voir les détails de l'expérience"),
            )
          ],
        ),
      ),
      context: context,
    );
  }

  /// 🔹 Logique de la visite guidée
  Future<void> _runGuidedTour(List<WorkExperience> experiences) async {
    final controller = ref.read(mapControllerProvider);
    final notifier = ref.read(tourIndexProvider.notifier);

    for (int i = 0; i < experiences.length; i++) {
      if (!ref.read(tourIndexProvider.notifier).isTourActive && i > 0) break;

      notifier.setIndex(i);

      // Animation de déplacement vers le job suivant
      controller.move(experiences[i].location, 15.5);

      await Future.delayed(const Duration(seconds: 4));
      if (!mounted) return;
    }
    notifier.stopTour();
  }

  @override
  Widget build(BuildContext context) {
    final fmtcInit = ref.watch(fmtcInitializationProvider);
    final tourIndex = ref.watch(tourIndexProvider);

    // Écoute de l'init du cache
    ref.listen(fmtcInitializationProvider, (_, next) {
      if (next is AsyncData && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Cache optimisé'),
              behavior: SnackBarBehavior.floating),
        );
      }
    });

    return fmtcInit.when(
      loading: _buildLoading,
      error: (e, _) => _buildError(e),
      data: (_) => ref.watch(userLocationProvider).when(
            loading: _buildLoading,
            error: (e, _) => _buildError(e),
            data: (pos) {
              final latLng = LatLng(pos.latitude, pos.longitude);
              return Stack(
                children: [
                  _buildMapCore(latLng),
                  _buildTopOverlay(tourIndex),
                  _buildBottomControls(latLng),
                  if (tourIndex != -1) _buildTourCard(tourIndex),
                ],
              );
            },
          ),
    );
  }

  Widget _buildMapCore(LatLng center) {
    final options = ref.watch(mapConfigProvider(center));
    final sigPoints = ref.watch(nearbySigPointsProvider).value ?? [];
    final isSatellite = ref.watch(satelliteModeProvider);
    final tileProvider =
        kIsWeb ? NetworkTileProvider() : ref.watch(mapTileProvider);

    final experiences = ref.watch(workExperiencesProvider).value ?? [];
    final path = ref.watch(careerPathProvider);

    return FlutterMap(
      mapController: ref.read(mapControllerProvider),
      options: options,
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.godzyken.portfolio',
          tileProvider: tileProvider,
        ),
        // On superpose la couche Satellite avec une opacité animée
        AnimatedOpacity(
          duration: const Duration(milliseconds: 500),
          opacity: isSatellite ? 1.0 : 0.0,
          child: TileLayer(
            urlTemplate:
                'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
            userAgentPackageName: 'com.godzyken.portfolio',
            tileProvider: tileProvider,
          ),
        ),
        if (!kIsWeb)
          PolylineLayer(
            polylines: [
              Polyline(
                points: path,
                color: Colors.blue.withValues(alpha: 0.6),
                strokeWidth: 4.0,
                useStrokeWidthInMeter: true,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            Marker(
              point: center,
              width: 40,
              height: 40,
              child: ScaleTransition(
                scale: Tween(begin: 0.8, end: 1.2).animate(CurvedAnimation(
                    parent: _pulseController, curve: Curves.easeInOut)),
                child: const Icon(Icons.person_pin_circle,
                    color: Colors.blue, size: 40),
              ),
            ),
            if (kIsWeb)
              ...sigPoints.map((p) => Marker(
                    point: p,
                    width: 35,
                    height: 35,
                    child: const Icon(Icons.location_on,
                        color: Colors.red, size: 35),
                  )),
            if (!kIsWeb)
              ...experiences.map((exp) => Marker(
                    point: exp.location,
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => _showExperienceDetails(exp),
                      child: const Icon(Icons.location_on,
                          color: Colors.red, size: 40),
                    ),
                  )),
          ],
        ),
      ],
    );
  }

  Widget _buildTopOverlay(int tourIndex) {
    final isTourActive = tourIndex != -1;

    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildBadge(
            isTourActive
                ? 'Visite guidée'
                : (kIsWeb ? 'Mode Démo (Web)' : 'GPS Actif'),
            isTourActive
                ? Colors.blue
                : (kIsWeb ? Colors.orange : Colors.green),
            isTourActive ? Icons.map : (kIsWeb ? Icons.web : Icons.gps_fixed),
          ),
          Row(
            children: [
              // Bouton Lancer/Arrêter la visite
              FloatingActionButton.small(
                heroTag: 'tour_btn',
                onPressed: () {
                  if (!isTourActive) {
                    final exps = ref.read(workExperiencesProvider).value ?? [];
                    _runGuidedTour(exps);
                  } else {
                    ref.read(tourIndexProvider.notifier).stopTour();
                  }
                },
                backgroundColor: Colors.white,
                child: Icon(isTourActive ? Icons.stop : Icons.play_arrow,
                    color: Colors.blue),
              ),
              const SizedBox(width: 8),
              _buildLayerToggle(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTourCard(int index) {
    final experiences = ref.watch(workExperiencesProvider).value ?? [];
    if (index >= experiences.length) return const SizedBox.shrink();
    final exp = experiences[index];

    return Positioned(
      bottom: 110,
      left: 20,
      right: 20,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Logo ou Icône entreprise
              CircleAvatar(
                backgroundColor: Colors.blue.shade50,
                child: const Icon(Icons.business, color: Colors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(exp.entreprise,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(exp.poste,
                        style:
                            const TextStyle(fontSize: 13, color: Colors.grey)),
                  ],
                ),
              ),
              Text('${index + 1}/${experiences.length}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blue)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLayerToggle() => FloatingActionButton.small(
        heroTag: 'layer_btn',
        onPressed: () => ref.read(satelliteModeProvider.notifier).toggle(),
        backgroundColor: Colors.white,
        child: Icon(ref.watch(satelliteModeProvider) ? Icons.map : Icons.layers,
            color: Colors.blue),
      );

  Widget _buildBottomControls(LatLng pos) {
    return Positioned(
      bottom: 24,
      right: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!kIsWeb) _buildCacheStatusMini(),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'recenter_btn',
            onPressed: () => ref.read(mapControllerProvider).move(pos, 16.0),
            backgroundColor: Colors.white,
            child: const Icon(Icons.my_location, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS DE SUPPORT ---

  Widget _buildBadge(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)]),
      child: Row(children: [
        Icon(icon, size: 16, color: Colors.white),
        const SizedBox(width: 8),
        ResponsiveText(text,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))
      ]),
    );
  }

  Widget _buildCacheStatusMini() {
    return ref.watch(cacheSizeProvider).maybeWhen(
          data: (size) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4)
                ]),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.storage, size: 12, color: Colors.grey),
                const SizedBox(width: 6),
                ResponsiveText.displaySmall('${size.toStringAsFixed(1)} Mo',
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          orElse: () => const SizedBox.shrink(),
        );
  }

  Widget _buildLoading() =>
      const Center(child: CircularProgressIndicator.adaptive());

  Widget _buildError(Object e) => Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ResponsiveText.displaySmall('Erreur : $e',
              textAlign: TextAlign.center),
        ),
      );
}
