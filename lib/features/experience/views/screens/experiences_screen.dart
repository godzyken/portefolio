import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/provider/providers.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';
import '../../../../core/ui/widgets/seo_wrapper.dart';
import 'package:portefolio/features/experience/views/screens/experience_screens_extentions.dart';

import '../../../../core/logging/app_logger.dart';
import '../../../../core/provider/experience_providers.dart';
import '../../../../core/provider/json_data_provider.dart';
import '../../data/experiences_data.dart';
import '../widgets/experience_widgets_extentions.dart';

class ExperiencesScreen extends ConsumerStatefulWidget {
  const ExperiencesScreen({super.key});

  @override
  ConsumerState<ExperiencesScreen> createState() => _ExperiencesScreenState();
}

class _ExperiencesScreenState extends ConsumerState<ExperiencesScreen> {
  final _slideKey = GlobalKey(debugLabel: 'ExperienceSlideScreen_key');
  final _gameKey = GlobalKey(debugLabel: 'ExperienceJeuxScreen_key');
  final _freezeKey = GlobalKey(debugLabel: 'ExperienceTimeline_key');

  late final ProviderSubscription _expSub;

  @override
  void initState() {
    super.initState();
    // Restaurer l'orientation normale au montage
    if (!kIsWeb) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }

    _expSub = ref.listenManual<AsyncValue<List<Experience>>>(
      experiencesProvider,
      (prev, next) {
        next.whenOrNull(error: (e, st) {
          ref.read(loggerProvider("ExperienceScreen")).log(
                "Erreur lors du chargement des expériences",
                level: LogLevel.error,
                error: e,
                stackTrace: st,
              );
        });
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(experienceFilterProvider.notifier).setFilter("");
    });
  }

  @override
  void dispose() {
    _expSub.close(); // 🧹 nettoie l'écoute manuelle
    // Nettoyer à la destruction
    if (!kIsWeb) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<List<Experience>>>(experiencesProvider, (prev, next) {
      next.whenOrNull(error: (e, st) {
        ref.read(loggerProvider("ExperienceScreen")).log(
              "Erreur lors du chargement des expériences",
              level: LogLevel.error,
              error: e,
              stackTrace: st,
            );
      });
    });

    final experiencesAsync = ref.watch(experiencesProvider);
    final isPageView = ref.watch(isPageViewProvider);
    final info = ref.watch(responsiveInfoProvider);

    return SeoWrapper(
      title: 'Expériences & Compétences | Emryck Doré',
      description:
          'Découvrez mon parcours professionnel, mes compétences techniques en Flutter et mes expériences en gestion de projet.',
      url: 'https://godzyken.github.io/portefolio/experiences',
      child: experiencesAsync.when(
        data: (allExperiences) {
          final filteredExperiences = ref.watch(filterExperiencesProvider);

          // ✅ DEBUG : Afficher le nombre d'expériences filtrées
          debugPrint(
              '🔍 Expériences après filtre : ${filteredExperiences.length}');
          debugPrint(
              '📌 Filtre actuel : ${ref.read(experienceFilterProvider)}');

          if (filteredExperiences.isEmpty) {
            // ✅ Amélioration : Afficher un message plus informatif
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.filter_alt_off,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  ResponsiveText.displaySmall(
                    'Aucune expérience pour le filtre "${ref.watch(experienceFilterProvider)}"',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ResponsiveButton.icon(
                    onPressed: () {
                      ref.read(experienceFilterProvider.notifier).setFilter("");
                    },
                    icon: const Icon(Icons.refresh),
                    label: 'Afficher toutes les expériences',
                  ),
                  const SizedBox(height: 24),
                  ResponsiveText.bodyMedium(
                    'Total disponible : ${allExperiences.length} expériences',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // ✅ Vérifier dynamiquement si le jeu peut être affiché
          final canPlayGame = info.size.width >= 800 &&
              info.size.height >= 700 &&
              info.isLandscape;

          // ✅ Mode Slide (toujours disponible)
          if (isPageView) {
            return ExperienceSlideScreen(
                key: _slideKey, experiences: filteredExperiences);
          }

          // ✅ Mode Jeu (si les conditions sont remplies)
          if (canPlayGame) {
            return ExperienceJeuxScreen(
                key: _gameKey, experiences: filteredExperiences);
          }

          // 🟢 Fallback : Timeline (toujours disponible)
          return ExperienceTimelineWrapper(
              key: _freezeKey, experiences: filteredExperiences);
        },
        error: (e, st) {
          ref.read(loggerProvider("ExperienceScreen")).log(
                "Erreur lors du chargement des expériences",
                level: LogLevel.error,
                error: e,
                stackTrace: st,
              );
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                ResponsiveText.displaySmall('Erreur : $e'),
                const SizedBox(height: 16),
                ResponsiveButton.icon(
                  onPressed: () {
                    ref.invalidate(experiencesProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: 'Réessayer',
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
