import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/logging/app_logger.dart';
import '../../../../core/provider/providers.dart';
import '../widgets/project_grid_view.dart';

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsFutureProvider);
    final selected = ref.watch(selectedProjectsProvider);

    return Stack(
      children: [
        // --- Image de fond ---
        Positioned.fill(
          child: Image.asset(
            "assets/images/design-digital.png", // ton image
            fit: BoxFit.cover, // couvre tout l'écran
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
