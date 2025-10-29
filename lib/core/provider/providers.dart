import 'dart:async';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/generator/notifiers/hover_map_notifier.dart';

import '../../constants/app_tab.dart';
import '../../constants/tech_logos.dart';
import '../../features/generator/services/pdf_export_service.dart';
import '../logging/app_logger.dart';
import '../notifier/notifiers.dart';
import '../service/bootstrap_service.dart';

/// 🔹 Bootstrap service
final bootstrapFutureProvider = FutureProvider((ref) async {
  return await BootstrapService.initialize();
});

/// 🔹 Location route actuelle
final currentLocationProvider =
    NotifierProvider<CurrentLocationNotifier, String>(
        CurrentLocationNotifier.new);

/// 🔹 Notifie quand on veut forcer un refresh
final routerNotifierProvider =
    NotifierProvider<RouterNotifier, String>(RouterNotifier.new);

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
});

/// 🔹 Tab position actuelle
final currentTabProvider = Provider<AppTab>((ref) {
  final asyncLoc = ref.watch(routeLocationStreamProvider);
  final location = asyncLoc.asData?.value ?? '/';
  return AppTab.fromLocation(location);
});

/// 🔹 Index actuelle
final currentIndexProvider = Provider<int>((ref) {
  return ref.watch(currentTabProvider).index;
});

/// 🔹 Exemple : état de chargement du PDF
final isGeneratingProvider =
    NotifierProvider<IsGeneratingNotifier, bool>(IsGeneratingNotifier.new);

/// 🔹 Etat de la page courante
final isPageViewProvider =
    NotifierProvider<IsPageViewNotifier, bool>(IsPageViewNotifier.new);

/// 🔹 Etat de detection du survol d'un élément
final hoverMapProvider = NotifierProvider<HoverMapNotifier, Map<String, bool>>(
  HoverMapNotifier.new,
);

/// Provider pour la visibilité globale des vidéos
final globalVideoVisibilityProvider =
    NotifierProvider<GlobalVideoVisibilityNotifier, bool>(
        GlobalVideoVisibilityNotifier.new);

/// 🔹 Etat du lecteur YoutubeVideoIframe
final playingVideoProvider =
    NotifierProvider<PlayingVideoNotifier, String?>(PlayingVideoNotifier.new);

/// 🔹 Génerateur de PDF
final pdfExportProvider = Provider<PdfExportService>((ref) {
  return PdfExportService();
});

/// 🔹 Etat du badge WakaTime
final wakatimeBadgeProvider = Provider.family<String?, String>((
  ref,
  projectName,
) {
  return wakatimeBadges[projectName];
});

final followUserProvider =
    NotifierProvider<FollowUserNotifier, bool>(FollowUserNotifier.new);

final mapControllerProvider = Provider<MapController>((ref) => MapController());

/// 🔹 Fournit un logger spécifique à une catégorie (ex: HomeScreen, ExperiencesScreen)
final loggerProvider = Provider.family<AppLogger, String>((ref, category) {
  return AppLogger(category);
});
