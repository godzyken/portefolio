import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/provider/providers.dart';
import '../../../projets/providers/projet_providers.dart';

class PdfScreen extends ConsumerWidget {
  const PdfScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGenerating = ref.watch(isGeneratingProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Cliquez pour générer un PDF selon vos projets sélectionnés.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.picture_as_pdf),
            label: Text(
              isGenerating ? 'Génération en cours...' : 'Créer le PDF',
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              textStyle: const TextStyle(fontSize: 16),
            ),
            onPressed: isGenerating
                ? null
                : () async {
                    ref.read(isGeneratingProvider.notifier).start();

                    final pdfService = ref.read(pdfExportProvider);
                    final selectedProjects = ref.read(selectedProjectsProvider);
                    await pdfService.export(selectedProjects);

                    ref.read(isGeneratingProvider.notifier).stop();
                  },
          ),
        ],
      ),
    );
  }
}
