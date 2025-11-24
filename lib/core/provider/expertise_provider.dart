import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/generator/data/extention_models.dart';

import 'json_data_provider.dart';

/// Provider pour charger toutes les expertises depuis le JSON
final expertisesProvider = FutureProvider<List<ServiceExpertise>>((ref) async {
  return loadJsonFile(
    'assets/data/expertise.json',
    ServiceExpertise.fromJson,
  );
});

/// Provider pour obtenir l'expertise d'un service spécifique
final serviceExpertiseProvider = Provider.family<ServiceExpertise?, String>(
  (ref, serviceId) {
    final expertisesAsync = ref.watch(expertisesProvider);

    return expertisesAsync.maybeWhen(
      data: (expertises) {
        try {
          return expertises.firstWhere((e) => e.serviceId == serviceId);
        } catch (_) {
          return null;
        }
      },
      orElse: () {
        final previousData = expertisesAsync.value;
        if (previousData != null) {
          try {
            return previousData.firstWhere((e) => e.serviceId == serviceId);
          } catch (_) {
            return null;
          }
        }
        return null;
      },
    );
  },
);

/// Provider pour les statistiques globales de toutes les expertises
final globalExpertiseStatsProvider = Provider<GlobalExpertiseStats>((ref) {
  final expertisesAsync = ref.watch(expertisesProvider);

  return expertisesAsync.when(
    data: (expertises) {
      final allSkills = expertises.expand((e) => e.skills).toList();

      // Calculer les statistiques globales
      final totalProjects = expertises.fold<int>(
        0,
        (sum, e) => sum + e.totalProjects,
      );

      final totalYears = expertises.fold<int>(
        0,
        (sum, e) => sum + e.totalYearsExperience,
      );

      final avgLevel = expertises.isEmpty
          ? 0.0
          : expertises.fold<double>(0, (sum, e) => sum + e.averageLevel) /
              expertises.length;

      // Trouver les compétences les plus fortes
      final topSkills = List<TechSkill>.from(allSkills)
        ..sort((a, b) => b.level.compareTo(a.level));

      return GlobalExpertiseStats(
        totalProjects: totalProjects,
        totalYearsExperience: totalYears,
        averageLevel: avgLevel,
        totalSkills: allSkills.length,
        topSkills: topSkills.take(10).toList(),
      );
    },
    loading: () => const GlobalExpertiseStats.empty(),
    error: (_, __) => const GlobalExpertiseStats.empty(),
  );
});

/// Statistiques globales d'expertise
class GlobalExpertiseStats {
  final int totalProjects;
  final int totalYearsExperience;
  final double averageLevel;
  final int totalSkills;
  final List<TechSkill> topSkills;

  const GlobalExpertiseStats({
    required this.totalProjects,
    required this.totalYearsExperience,
    required this.averageLevel,
    required this.totalSkills,
    required this.topSkills,
  });

  const GlobalExpertiseStats.empty()
      : totalProjects = 0,
        totalYearsExperience = 0,
        averageLevel = 0.0,
        totalSkills = 0,
        topSkills = const [];
}

/// Provider pour obtenir les compétences par catégorie
final skillsByCategoryProvider = Provider<Map<String, List<TechSkill>>>((ref) {
  final expertisesAsync = ref.watch(expertisesProvider);

  return expertisesAsync.when(
    data: (expertises) {
      final Map<String, List<TechSkill>> result = {};

      for (final expertise in expertises) {
        for (final skill in expertise.skills) {
          result.putIfAbsent(skill.category, () => []).add(skill);
        }
      }

      return result;
    },
    loading: () => {},
    error: (_, __) => {},
  );
});
