import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/provider/providers.dart';
import '../../../generator/views/widgets/adaptive_card.dart';
import '../../data/project_data.dart';

class ProjectCard extends ConsumerWidget {
  final ProjectInfo project;
  const ProjectCard({super.key, required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pdfService = ref.watch(pdfExportProvider);

    return AdaptiveCard(
      title: project.title,
      bulletPoints: project.points,
      imagePath:
          (project.image?.isNotEmpty ?? false) ? project.image!.first : null,
      //onTap: () => context.push('/project/${project.id}'), // or showDialog
      onTap: () => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(
            project.title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: project.points.map((point) => Text(point)).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: const Text('Fermer'),
            ),
            TextButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Imprimer ce projet'),
              onPressed: () => pdfService.export([project]),
            ),
          ],
        ),
      ), // or showDialog
    );
  }
}
