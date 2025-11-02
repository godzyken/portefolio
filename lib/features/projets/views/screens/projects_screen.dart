import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/ui/widgets/ui_widgets_extentions.dart';
import 'package:portefolio/features/projets/providers/projects_wakatime_service_provider.dart';

import '../../../../core/logging/app_logger.dart';
import '../../../../core/provider/provider_extentions.dart';
import '../../providers/projet_providers.dart';
import '../widgets/project_widgets_extentions.dart';

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // On s’assure de ne lancer le provider qu’après la première frame
    if (!_initialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(enrichedProjectsProvider.future);
      });
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(enrichedProjectsProvider);
    final selected = ref.watch(selectedProjectsProvider);

    return Stack(
      children: [
        // --- Image de fond ---
        Positioned.fill(
          child: SmartImage(
            key: UniqueKey(),
            path: "assets/images/line.svg", // ton image
            fit: BoxFit.contain,
            responsiveSize: ResponsiveImageSize.xlarge,
            fallbackIcon: Icons.image,
            fallbackColor: Colors.white,
          ),
        ),

        // --- Contenu principal ---
        Positioned.fill(
          child: Container(
            color: Colors.black.withValues(alpha: 0.4),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              child: projectsAsync.when(
                data: (projects) => ProjectGridView(
                  projects: projects,
                  selected: selected,
                ),
                loading: () => const Center(
                  key: ValueKey('loading'),
                  child: CircularProgressIndicator(),
                ),
                error: (e, st) {
                  ref.read(loggerProvider("ProjectsScreen")).log(
                        "Erreur lors du chargement des projets",
                        level: LogLevel.error,
                        error: e,
                        stackTrace: st,
                      );
                  return Center(
                    key: const ValueKey('error'),
                    child: Text(
                      'Erreur : $e',
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
