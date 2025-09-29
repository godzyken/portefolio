import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/features/projets/views/widgets/project_card.dart';

import '../../../../core/provider/providers.dart';
import '../../../generator/views/widgets/sig_discovery_map.dart';
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

    final isBubbleMode = info.grid.columns >= 3;

    if (!isBubbleMode) {
      // 📱 Mode portrait / mobile : Liste ou Grid classique avec carte en haut
      return LayoutBuilder(
        builder: (_, constraints) {
          if (info.grid.columns <= 1) {
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: projects.length + 1, // +1 pour la carte
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                if (i == 0) {
                  // Carte en haut
                  return AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: const SigDiscoveryMap(),
                    ),
                  );
                }
                return _buildCard(ref, projects[i - 1]);
              },
            );
          } else {
            // Grid classique
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
        // Taille dynamique des bulles selon largeur de l'écran
        final bubbleSize = constraints.maxWidth < 600 ? 120.0 : 80.0;

        return Stack(
          children: [
            for (final project in projects)
              DraggableBubble(
                key: ValueKey(project.id),
                rotationAngle: bubbleSize,
                project: project,
                isSelected: selected.any((p) => p.id == project.id),
                initialOffset: positions[project.id] ??
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
    // final isSelected = selected.any((p) => p.id == project.id);
    return GestureDetector(
      onLongPress: () {
        ref.read(selectedProjectsProvider.notifier).toggle(project);
      },
      child: ProjectCard(project: project),
    );
  }
}
