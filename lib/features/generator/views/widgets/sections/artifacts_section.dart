import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/colors_spec.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';

import '../../../../projets/data/github_artifacts_service.dart';
import '../../../../projets/providers/projet_providers.dart';

/// Section Artefacts - Affiche les fichiers .md (présentation, vision,
/// workthrough, valuation, implementation...) trouvés dans le repo GitHub
/// du projet, sous `.artefacts/{id}/`.
///
/// S'auto-masque si aucun artefact n'est trouvé (repo pas encore équipé,
/// ou pas de githubRepoUrl renseigné).
class ArtifactsSection extends ConsumerStatefulWidget {
  final String projectId;
  final String repoUrl;
  final ResponsiveInfo info;

  const ArtifactsSection({
    super.key,
    required this.projectId,
    required this.repoUrl,
    required this.info,
  });

  @override
  ConsumerState<ArtifactsSection> createState() => _ArtifactsSectionState();
}

class _ArtifactsSectionState extends ConsumerState<ArtifactsSection>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<String> _lastKeys = const [];

  void _syncTabController(List<String> keys) {
    if (_listEquals(_lastKeys, keys)) return;
    _lastKeys = keys;
    _tabController?.dispose();
    _tabController = TabController(length: keys.length, vsync: this);
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncArtifacts = ref.watch(
      projectArtifactsProvider(
        (repoUrl: widget.repoUrl, projectId: widget.projectId),
      ),
    );

    return asyncArtifacts.when(
      // Pas de flash de loader intrusif : la section n'apparaît que
      // lorsqu'on sait qu'il y a du contenu à montrer.
      loading: () => const SizedBox.shrink(),
      error: (err, _) => const SizedBox.shrink(),
      data: (artifacts) {
        if (artifacts.isEmpty) return const SizedBox.shrink();

        final keys = GithubArtifactsService.sortedKeys(artifacts);
        _syncTabController(keys);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ResponsiveText.titleMedium(
              '📖 En savoir plus',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: ColorHelpers.cyan,
              unselectedLabelColor: ColorHelpers.textSecondary,
              indicatorColor: ColorHelpers.cyan,
              tabs: keys
                  .map((k) => Tab(text: GithubArtifactsService.labelFor(k)))
                  .toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: widget.info.isMobile ? 320 : 420,
              child: TabBarView(
                controller: _tabController,
                children: keys.map((k) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ColorHelpers.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ColorHelpers.border),
                    ),
                    child: Markdown(
                      data: artifacts[k]!,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet.fromTheme(
                        Theme.of(context),
                      ).copyWith(
                        p: const TextStyle(
                          color: ColorHelpers.textSecondary,
                          height: 1.5,
                        ),
                        h1: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        h2: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        code: const TextStyle(
                          backgroundColor: Colors.black26,
                          color: ColorHelpers.cyan,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
