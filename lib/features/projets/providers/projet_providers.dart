import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/provider/config_env_provider.dart';
import '../data/github_artifacts_service.dart';
import '../data/github_project_ai_analyzer.dart';
import '../data/project_data.dart';
import '../notifiers/projet_notifiers.dart';

/// Clé du provider d'artefacts : repo + id du projet.
typedef ProjectArtifactsKey = ({String repoUrl, String projectId});

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

/// Récupère les artefacts .md (présentation, vision, workthrough...) d'un
/// projet depuis son repo GitHub. Retourne une map vide si rien n'est
/// trouvé (le repo n'a pas encore de .artefacts/, ou l'url est absente).
final projectArtifactsProvider = FutureProvider.family
    .autoDispose<Map<String, String>, ProjectArtifactsKey>((ref, key) async {
  final token = ref.watch(githubTokenProvider);
  return await GithubArtifactsService.fetchArtifacts(
    repoUrl: key.repoUrl,
    projectId: key.projectId,
    token: token,
  );
});
