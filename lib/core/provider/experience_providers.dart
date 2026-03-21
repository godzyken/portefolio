import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/experience/data/experiences_data.dart';
import '../notifier/experience_notifiers.dart';
import 'json_data_provider.dart';

/// 🔹 Filtre des expériences
final experienceFilterProvider =
    NotifierProvider<ExperienceFilterNotifier, String?>(
        ExperienceFilterNotifier.new,
        name: 'ExperienceFilter');

final filterExperiencesProvider = Provider<List<Experience>>((ref) {
  final List<Experience> all = ref
      .watch(experiencesProvider)
      .maybeWhen(data: (d) => d, orElse: () => <Experience>[]);
  final filter = ref.watch(experienceFilterProvider);

  if (filter == null || filter.isEmpty) return all;

  return all.where((exp) => exp.tags.contains(filter)).toList();
}, name: 'FilterExperiences');
