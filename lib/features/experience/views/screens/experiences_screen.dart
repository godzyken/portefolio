import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/provider/providers.dart';
import 'package:portefolio/features/experience/views/screens/experience_screens_extentions.dart';

import '../../../../core/logging/app_logger.dart';
import '../../../../core/provider/experience_providers.dart';
import '../../../../core/provider/json_data_provider.dart';
import '../widgets/experience_widgets_extentions.dart';

class ExperiencesScreen extends ConsumerStatefulWidget {
  const ExperiencesScreen({super.key});

  @override
  ConsumerState<ExperiencesScreen> createState() => _ExperiencesScreenState();
}

class _ExperiencesScreenState extends ConsumerState<ExperiencesScreen> {
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
  }

  @override
  void dispose() {
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
    final experiencesAsync = ref.watch(experiencesProvider);
    final isPageView = ref.watch(isPageViewProvider);
    final info = ref.watch(responsiveInfoProvider);

    return experiencesAsync.when(
      data: (allExperiences) {
        final filteredExperiences = ref.watch(filterExperiencesProvider);

        if (filteredExperiences.isEmpty) {
          return const Center(child: Text('Aucune expérience pour ce filtre.'));
        }

        // ✅ Vérifier dynamiquement si le jeu peut être affiché
        final canPlayGame = info.size.width >= 800 &&
            info.size.height >= 700 &&
            info.isLandscape;

        // ✅ Mode Slide (toujours disponible)
        if (isPageView) {
          return ExperienceSlideScreen(experiences: filteredExperiences);
        }

        // ✅ Mode Jeu (si les conditions sont remplies)
        if (canPlayGame) {
          return ExperienceJeuxScreen(experiences: filteredExperiences);
        }

        // 🟢 Fallback : Timeline (toujours disponible)
        return ExperienceTimelineWrapper(experiences: filteredExperiences);
      },
      error: (e, st) {
        ref.read(loggerProvider("ExperienceScreen")).log(
              "Erreur lors du chargement des expériences",
              level: LogLevel.error,
              error: e,
              stackTrace: st,
            );
        return Center(child: Text('Erreur : $e'));
      },
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}
