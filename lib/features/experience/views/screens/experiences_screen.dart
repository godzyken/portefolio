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

class ExperiencesScreen extends ConsumerWidget {
  const ExperiencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final experiencesAsync = ref.watch(experiencesProvider);
    final isPageView = ref.watch(isPageViewProvider);
    final info = ref.watch(responsiveInfoProvider);

    return experiencesAsync.when(
      data: (allExperiences) {
        final filteredExperiences = ref.watch(filterExperiencesProvider);

        if (filteredExperiences.isEmpty) {
          return const Center(child: Text('Aucune expérience pour ce filtre.'));
        }

        final canPlayGame = info.size.width >= 800 && info.size.height >= 700;

        // ✅ Gestion orientation uniquement sur mobile natif
        if (!kIsWeb) {
          if (canPlayGame) {
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]);
          } else {
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ]);
          }
        }

        // ✅ Logique d'affichage 100% déclarative
        if (isPageView || info.isMobile) {
          return ExperienceSlideScreen(experiences: filteredExperiences);
        }

        if (canPlayGame && !isPageView) {
          return ExperienceJeuxScreen(experiences: filteredExperiences);
        }

        // 🟢 Toujours disponible : Timeline
        return ExperienceTimelineWrapper(experiences: filteredExperiences);
      },
      error: (e, st) {
        ref.read(loggerProvider("ExperienceScreen")).log(
              "Erreur lors du chargement des services",
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
