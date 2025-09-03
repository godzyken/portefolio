import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/grid_config_provider.dart';
import 'package:portefolio/features/projets/views/widgets/project_card.dart';

import '../../../../core/affichage/screen_size_detector.dart';
import '../../../../core/provider/providers.dart';
import '../../data/project_data.dart';

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
    final config = ref.watch(gridConfigProvider);
    final cardWidth = ref.watch(cardWidthProvider);

    return LayoutBuilder(
      builder: (_, constraints) {
        if (config.columns <= 1) {
          // Mode liste mobile
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: projects.length,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SizedBox(
                width: cardWidth,
                child: _buildCard(ref, projects[i]),
              ),
            ),
          );
        } else {
          // Mode grille desktop/tablette
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: projects.length,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: config.columns,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              mainAxisExtent: config.aspectRatio * 300,
              childAspectRatio: config.aspectRatio,
            ),
            itemBuilder: (_, i) => _buildCard(ref, projects[i]),
          );
        }
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
      child: Stack(
        fit: StackFit.loose,
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
