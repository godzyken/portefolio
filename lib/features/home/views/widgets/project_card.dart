import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/provider/providers.dart';
import '../../data/project_data.dart';

class ProjectCard extends ConsumerWidget {
  final ProjectInfo project;

  const ProjectCard({super.key, required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pdfService = ref.read(pdfExportProvider);
    final imagePath =
        project.image?.isNotEmpty == true ? project.image![0] : null;

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: Text(
                  project.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children:
                        project.points.map((point) => Text(point)).toList(),
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
        );
      },
      child: Card(
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            if (imagePath != null)
              Positioned.fill(
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.indigoAccent.withAlpha((255 * 0.2).toInt()),
                    BlendMode.colorBurn,
                  ),
                  child: Image.asset(imagePath, fit: BoxFit.cover),
                ),
              ),
            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.brown, Colors.black12, Colors.black87],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.cyanAccent,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...project.points.map(
                    (point) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              point,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.touch_app, color: Colors.white),
                      const SizedBox(width: 4),
                      const Text(
                        "Cliquer pour voir plus",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
