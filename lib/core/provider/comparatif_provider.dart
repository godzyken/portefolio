import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/provider/json_data_provider.dart';

import '../../features/home/data/comparatifs_data.dart';

final comparatifByIdProvider = Provider.family<Comparatif?, String>((ref, id) {
  final comparatif = ref.watch(comparaisonsJsonProvider).asData?.value ?? [];
  try {
    return comparatif.firstWhere((s) => s.id == id);
  } catch (_) {
    return null;
  }
});

final comparisonBubbleVisibilityProvider = Provider.family<bool, String>(
  (ref, currentPath) {
    // Chemins où la bulle ne doit PAS apparaître
    const excludedPaths = [
      '/experiences',
      '/experience',
      '/projects',
      '/project',
      '/pdf',
      '/legal',
      '/theme_settings',
      '/wakatime_settings',
    ];

    // Vérifier si le chemin actuel est exclu
    return !excludedPaths.any((path) => currentPath.contains(path));
  },
);
