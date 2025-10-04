import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/provider/providers.dart';
import 'package:portefolio/features/experience/views/screens/experience_screens_extentions.dart';

import '../../../../core/logging/app_logger.dart';
import '../widgets/experience_widgets_extentions.dart';

class ExperiencesScreen extends ConsumerStatefulWidget {
  const ExperiencesScreen({super.key});

  @override
  ConsumerState<ExperiencesScreen> createState() => _ExperiencesScreenState();
}

class _ExperiencesScreenState extends ConsumerState<ExperiencesScreen> {
  @override
  Widget build(BuildContext context) {
    final experiencesAsync = ref.watch(experiencesFutureProvider);
    final isPageView = ref.watch(isPageViewProvider);
    final info = ref.watch(responsiveInfoProvider);

    return experiencesAsync.when(
      data: (allExperiences) {
        final filteredExperiences = ref.watch(filterExperiencesProvider);
        return filteredExperiences.isEmpty
            ? const Center(child: Text('Aucune expérience pour ce filtre.'))
            : isPageView
                ? info.isMobile
                    ? ExperienceSlideScreen(experiences: filteredExperiences)
                    : ExperienceJeuxScreen(experiences: filteredExperiences)
                : ExperienceTimelineWrapper(experiences: filteredExperiences);
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
