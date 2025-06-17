import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/provider/providers.dart';
import '../../data/project_data.dart';
import '../widgets/project_card.dart';

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  void _toggleSelection(ProjectInfo project) {
    final selected = [...ref.read(selectedProjectsProvider)];
    if (selected.any((p) => p.id == project.id)) {
      selected.removeWhere((p) => p.id == project.id);
    } else {
      selected.add(project);
    }
    ref.read(selectedProjectsProvider.notifier).state = selected;
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsFutureProvider);
    final selectedProjects = ref.watch(selectedProjectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mes Projets',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.select_all),
            tooltip: 'Tout sélectionner',
            onPressed: () {
              final projects = ref.read(projectsFutureProvider).value;
              final isAllSelected =
                  projects != null &&
                  ref.read(selectedProjectsProvider).length == projects.length;

              ref.read(selectedProjectsProvider.notifier).state =
                  isAllSelected ? [] : [...?projects];
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Exporter PDF',
            onPressed: () {
              if (selectedProjects.isNotEmpty) {
                context.pushNamed('pdf');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Veuillez sélectionner des projets."),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: projectsAsync.when(
        data:
            (projects) => ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                final isSelected = selectedProjects.any(
                  (p) => p.id == project.id,
                );
                return GestureDetector(
                  onLongPress: () => _toggleSelection(project),
                  child: Stack(
                    children: [
                      ProjectCard(project: project),
                      if (isSelected)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Icon(Icons.check_circle, color: Colors.green),
                        ),
                    ],
                  ),
                );
              },
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
      ),
    );
  }
}
