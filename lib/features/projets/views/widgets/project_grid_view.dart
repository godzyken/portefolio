// lib/features/projets/views/widgets/project_grid_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/affichage/screen_size_detector.dart';
import '../../../../core/provider/providers.dart';
import '../../data/project_data.dart';
import 'project_card.dart';

class ProjectGridView extends ConsumerWidget {
  final List<ProjectInfo> projects;
  final List<ProjectInfo> selected;

  const ProjectGridView({
    super.key,
    required this.projects,
    required this.selected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPortrait = ref.watch(isPortraitProvider);
    final width = ref.watch(screenSizeProvider).width;
    final columns = width ~/ 300; // approx 300px/card

    final isGrid = columns > 1;
    final cardAspectRatio = isPortrait ? 0.85 : 1.4;

    return isGrid
        ? GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              mainAxisExtent: cardAspectRatio * 300,
              childAspectRatio: cardAspectRatio,
            ),
            itemCount: projects.length,
            itemBuilder: (_, i) => _buildCard(ref, projects[i]),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: projects.length,
            itemBuilder: (_, i) => _buildCard(ref, projects[i]),
          );
  }

  Widget _buildCard(WidgetRef ref, ProjectInfo project) {
    final isSelected = selected.any((p) => p.id == project.id);
    return GestureDetector(
      onLongPress: () {
        final notifier = ref.read(selectedProjectsProvider.notifier);
        final current = notifier.state;
        notifier.state = current.any((p) => p.id == project.id)
            ? current.where((p) => p.id != project.id).toList()
            : [...current, project];
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          ProjectCard(project: project),
          if (isSelected)
            const Positioned(
              top: 8,
              right: 8,
              child: Icon(Icons.check_circle, color: Colors.green),
            ),
        ],
      ),
    );
  }
}
