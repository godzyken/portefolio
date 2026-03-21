import 'dart:async';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/app_tab.dart';
import '../../constants/tech_logos.dart';
import '../../features/generator/services/pdf_export_service.dart';
import '../logging/app_logger.dart';
import '../notifier/generic_notifier.dart';
import '../notifier/notifiers.dart';
import '../service/assets_service.dart';
import '../service/bootstrap_service.dart';

/// 🔹 Asset service
final assetServiceProvider =
    Provider((ref) => AssetService(), name: 'AssetService');

/// 🔹 Bootstrap service
final bootstrapProvider = Provider<BootstrapService>((ref) {
  // Ce provider sera initialisé par un "override" dans le main.dart
  throw UnimplementedError(
      'Le bootstrapProvider doit être initialisé dans le main');
}, name: 'BootstrapService');

final bootstrapFutureProvider = FutureProvider((ref) async {
  return await BootstrapService.initialize();
}, name: 'BootstrapFuture');

/// 🔹 Location route actuelle
final currentLocationProvider =
    NotifierProvider<CurrentLocationNotifier, String>(
        CurrentLocationNotifier.new,
        name: 'CurrentLocation');

/// 🔹 Notifie quand on veut forcer un refresh
final routerNotifierProvider = NotifierProvider<RouterNotifier, String>(
    RouterNotifier.new,
    name: 'RouterNotifier');

/// 🔹 Stream qui émet la location courante
final routeLocationStreamProvider = StreamProvider<String>((ref) {
  final controller = StreamController<String>.broadcast();

  controller.add(ref.read(currentLocationProvider));

  ref.listen(currentLocationProvider, (p, n) {
    controller.add(n);
  });

  ref.onDispose(() {
    controller.close();
  });

  return controller.stream;
}, name: 'RouteLocationStream');

/// 🔹 Tab position actuelle
final currentTabProvider = Provider<AppTab>((ref) {
  final asyncLoc = ref.watch(routeLocationStreamProvider);
  final location = asyncLoc.asData?.value ?? '/';
  return AppTab.fromLocation(location);
}, name: 'CurrentTab');

/// 🔹 Index actuelle
final currentIndexProvider = Provider<int>((ref) {
  return ref.watch(currentTabProvider).index;
}, name: 'CurrentIndex');

/// 🔹 Exemple : état de chargement du PDF
final isGeneratingProvider = NotifierProvider<BooleanNotifier, bool>(
  () => BooleanNotifier(false),
  name: 'IsGenerating',
);

/// 🔹 Etat de la page courante
final isPageViewProvider = NotifierProvider<BooleanNotifier, bool>(
  () => BooleanNotifier(false),
  name: 'IsPageView',
);

/// 🔹 Etat de detection du survol d'un élément
final hoverMapProvider =
    NotifierProvider<MapNotifier<String, bool>, Map<String, bool>>(
  () => MapNotifier<String, bool>(),
  name: 'HoverMap',
);

/// Provider pour la visibilité globale des vidéos
final globalVideoVisibilityProvider = NotifierProvider<BooleanNotifier, bool>(
  () => BooleanNotifier(true),
  name: 'GlobalVideoVisibility',
);

/// 🔹 Etat du lecteur YoutubeVideoIframe
final playingVideoProvider = NotifierProvider<PlayingVideoNotifier, String?>(
    PlayingVideoNotifier.new,
    name: 'PlayingVideo');

/// 🔹 Génerateur de PDF
final pdfExportProvider = Provider<PdfExportService>((ref) {
  return PdfExportService();
}, name: 'PdfExportService');

/// 🔹 Etat du badge WakaTime
final wakatimeBadgeProvider = Provider.family<String?, String>((
  ref,
  projectName,
) {
  return wakatimeBadges[projectName];
}, name: 'WakaTimeBadge');

final followUserProvider = NotifierProvider<BooleanNotifier, bool>(
  () => BooleanNotifier(true),
  name: 'FollowUser',
);

final mapControllerProvider =
    Provider<MapController>((ref) => MapController(), name: 'MapController');

/// 🔹 Fournit un logger spécifique à une catégorie (ex: HomeScreen, ExperiencesScreen)
final loggerProvider = Provider.family<AppLogger, String>((ref, category) {
  return AppLogger(category);
}, name: 'Logger');
