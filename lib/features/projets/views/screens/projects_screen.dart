import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/provider/providers.dart';
import '../../data/project_data.dart';
import '../widgets/project_grid_view.dart';

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final projects = ref
          .read(projectsFutureProvider)
          .maybeWhen(data: (list) => list, orElse: () => <ProjectInfo>[]);

      ref.read(appBarTitleProvider.notifier).state = "Mes Projets";
      ref.read(appBarActionsProvider.notifier).state = [
        IconButton(
          icon: const Icon(Icons.select_all),
          tooltip: "Tout sélectionner",
          onPressed: () {
            ref.read(selectedProjectsProvider.notifier).state = projects;
          },
        ),
        IconButton(
          icon: const Icon(Icons.picture_as_pdf),
          tooltip: "Exporter PDF",
          onPressed: () {
            final selected = ref.read(selectedProjectsProvider);
            if (selected.isNotEmpty) {
              ref.read(pdfExportProvider).export(selected);
              context.pushNamed("pdf");
            }
          },
        ),
      ];
      ref.read(appBarDrawerProvider.notifier).state = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsFutureProvider);
    final selected = ref.watch(selectedProjectsProvider);

    return projectsAsync.when(
      data: (projects) =>
          ProjectGridView(projects: projects, selected: selected),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur : $e')),
    );
  }
}
