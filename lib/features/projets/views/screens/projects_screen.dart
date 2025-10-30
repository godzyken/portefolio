import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/parametres/views/widgets/smart_image.dart';
import 'package:portefolio/features/projets/providers/projects_wakatime_service_provider.dart';

import '../../../../core/logging/app_logger.dart';
import '../../../../core/provider/providers.dart';
import '../../providers/projet_providers.dart';
import '../widgets/project_grid_view.dart';

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(enrichedProjectsProvider);
    final selected = ref.watch(selectedProjectsProvider);

    return Stack(
      children: [
        // --- Image de fond ---
        Positioned.fill(
          child: SmartImage(
            path: "assets/images/flutter-mascotte.png", // ton image
            fit: BoxFit.cover,
            fallbackIcon: Icons.image,
            fallbackColor: Colors.white,
          ),
        ),

        // --- Contenu principal ---
        Positioned.fill(
          child: Container(
            color: Colors.black.withValues(
              alpha: 0.4,
            ), // voile pour lisibilité
            child: projectsAsync.when(
              data: (projects) =>
                  ProjectGridView(projects: projects, selected: selected),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) {
                ref.read(loggerProvider("ProjetsScreen")).log(
                      "Erreur lors du chargement des services",
                      level: LogLevel.error,
                      error: e,
                      stackTrace: st,
                    );
                return Center(child: Text('Erreur : $e'));
              },
            ),
          ),
        ),
      ],
    );
  }
}
