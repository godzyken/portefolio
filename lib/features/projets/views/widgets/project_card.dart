import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portefolio/features/generator/services/pdf_export_service.dart';

import '../../../../core/provider/providers.dart';
import '../../../generator/views/widgets/adaptive_card.dart';
import '../../data/project_data.dart';

class ProjectCard extends ConsumerWidget {
  final ProjectInfo project;
  const ProjectCard({super.key, required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pdfService = ref.watch(pdfExportProvider);

    return MouseRegion(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => showDialog(
          context: context,
          builder: (_) => _buildAlertDialog(context, pdfService),
        ),
        child: AdaptiveCard(
          title: project.title,
          bulletPoints: project.points,
          imagePath: (project.image?.isNotEmpty ?? false)
              ? project.image!.first
              : null,
          //onTap: () => context.push('/project/${project.id}'), // or showDialog
          onTap: () => showDialog(
            context: context,
            builder: (_) => _buildAlertDialog(context, pdfService),
          ),
        ),
      ),
    );
  }

  AlertDialog _buildAlertDialog(
    BuildContext context,
    PdfExportService pdfService,
  ) {
    return AlertDialog(
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
          children: [
            if (project.image != null && project.image!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(project.image!.first),
                ),
              ),
            ...project.points.map(
              (point) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: Text(
                        point,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
    );
  }
}
