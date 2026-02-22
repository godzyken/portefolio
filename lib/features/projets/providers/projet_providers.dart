import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/github_project_ai_analyzer.dart';
import '../data/project_data.dart';
import '../notifiers/projet_notifiers.dart';

/// Provider pour stocker les positions des bulles
final projectPositionsProvider =
    NotifierProvider<ProjectPositionsNotifier, Map<String, Offset>>(
        ProjectPositionsNotifier.new);

/// Liste des projets sélectionnés
final selectedProjectsProvider =
    NotifierProvider<SelectedProjectsNotifier, List<ProjectInfo>>(
        SelectedProjectsNotifier.new);

/// SECTION ACTIVE
final activeSectionProvider =
    NotifierProvider<ActiveSectionNotifier, String>(ActiveSectionNotifier.new);

final githubProjectAIProvider = FutureProvider.family
    .autoDispose<GithubProjectAIInfo, String>((ref, repoUrl) async {
  return await GithubProjectAIAnalyzer.analyzeRepoWithAI(repoUrl);
});
