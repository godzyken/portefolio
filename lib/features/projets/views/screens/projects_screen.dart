import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/provider/providers.dart';
import '../widgets/project_app_bar.dart';
import '../widgets/project_grid_view.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsFutureProvider);
    final selected = ref.watch(selectedProjectsProvider);

    return Scaffold(
      appBar: const ProjectAppBar(),
      body: projectsAsync.when(
        data: (projects) =>
            ProjectGridView(projects: projects, selected: selected),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
      ),
    );
  }
}
