import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/features/projets/views/widgets/project_card.dart';

import '../../../../core/provider/providers.dart';
import '../../data/project_data.dart';
import '../../providers/project_positions_provider.dart';
import 'draguable_bubble.dart';

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
    final info = ref.watch(responsiveInfoProvider);

    // ⚡ seuil d’activation du mode bulle
    final isBubbleMode = info.grid.columns >= 3;

    if (!isBubbleMode) {
      // 📱 Mode liste/grille classique
      return LayoutBuilder(
        builder: (_, constraints) {
          if (info.grid.columns <= 1) {
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: projects.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _buildCard(ref, projects[i]),
            );
          } else {
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: projects.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: info.grid.columns,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                mainAxisExtent: info.grid.aspectRatio * 300,
                childAspectRatio: info.grid.aspectRatio,
              ),
              itemBuilder: (_, i) => _buildCard(ref, projects[i]),
            );
          }
        },
      );
    }

    // 💻 Mode bulles flottantes
    final positions = ref.watch(projectPositionsProvider);

    return LayoutBuilder(
      builder: (_, constraints) {
        return Stack(
          children: [
            for (final project in projects)
              DraggableBubble(
                key: ValueKey(project.id),
                project: project,
                isSelected: selected.any((p) => p.id == project.id),
                initialOffset:
                    positions[project.id] ??
                    Offset(
                      100 + projects.indexOf(project) * 40,
                      100 + projects.indexOf(project) * 40,
                    ),
                onPositionChanged: (offset) {
                  ref
                      .read(projectPositionsProvider.notifier)
                      .updatePosition(project.id, offset);
                },
              ),
          ],
        );
      },
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
      child: ProjectCard(project: project),
    );
  }
}
