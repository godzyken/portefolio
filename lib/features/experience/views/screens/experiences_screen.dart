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
  bool _forceGameMode = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateGameModeForScreen();
  }

  void _updateGameModeForScreen() {
    final info = ref.read(responsiveInfoProvider);
    final canPlayGame = info.size.width >= 1200 && info.size.height >= 700;

    // Si écran assez grand, activer le mode jeu forcément en paysage
    if (canPlayGame && !_forceGameMode) {
      setState(() => _forceGameMode = true);
      // Forcer l'orientation paysage
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else if (!canPlayGame && _forceGameMode) {
      setState(() => _forceGameMode = false);
      // Réinitialiser toutes les orientations
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  @override
  void dispose() {
    // Réinitialiser les orientations à la sortie
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final experiencesAsync = ref.watch(experiencesProvider);
    final isPageView = ref.watch(isPageViewProvider);
    final info = ref.watch(responsiveInfoProvider);

    // Mettre à jour le mode jeu si nécessaire
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateGameModeForScreen();
    });

    return experiencesAsync.when(
      data: (allExperiences) {
        final filteredExperiences = ref.watch(filterExperiencesProvider);

        if (filteredExperiences.isEmpty) {
          return const Center(child: Text('Aucune expérience pour ce filtre.'));
        }

        // Logique d'affichage :
        // 1. Si écran grand (>= 1200x700) → toujours JEUX en paysage forcé
        // 2. Si mobile OU slide view → SLIDE
        // 3. Sinon → Timeline

        final canPlayGame = info.size.width >= 1200 && info.size.height >= 700;

        if (canPlayGame) {
          // Force le mode paysage et affiche les jeux
          return ExperienceJeuxScreen(experiences: filteredExperiences);
        } else if (info.isMobile || isPageView) {
          // Mobile ou vue slide
          return ExperienceSlideScreen(experiences: filteredExperiences);
        } else {
          // Desktop/Tablet en portrait avec timeline
          return ExperienceTimelineWrapper(experiences: filteredExperiences);
        }
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
