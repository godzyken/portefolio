import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/colors_spec.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/affichage/tech_maturity_framework.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';

import '../../../../projets/data/github_artifacts_service.dart';
import '../../../../projets/data/project_data.dart';
import '../../../../projets/providers/projet_providers.dart';
import '../../../services/section_manager.dart';

/// Section Artefacts - Affiche les fichiers .md (présentation, vision,
/// workthrough, valuation, implementation...) trouvés dans le repo GitHub
/// du projet, sous `.artefacts/{id}/`.
///
/// Refondue pour être immersive (Glassmorphism) et inclure l'analyse de maturité.
class ArtifactsSection extends ConsumerStatefulWidget {
  final ProjectInfo project;
  final ResponsiveInfo info;

  const ArtifactsSection({
    super.key,
    required this.project,
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
        (repoUrl: widget.project.githubRepoUrl!, projectId: widget.project.id),
      ),
    );

    return asyncArtifacts.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(color: ColorHelpers.cyan),
        ),
      ),
      error: (err, _) => const SizedBox.shrink(),
      data: (artifacts) {
        if (artifacts.isEmpty) return const SizedBox.shrink();

        final keys = GithubArtifactsService.sortedKeys(artifacts);
        _syncTabController(keys);

        final manager = SectionManager(widget.project);
        final maturityScores = manager.analyzeMaturity();

        // Ajout dynamique d'un onglet "Preuves Techniques" basé sur les images LinkedIn
        final technicalImages = maturityScores.entries
            .where((e) => e.value > 0.5) // Seulement les points forts
            .map((e) => e.key.skillImage)
            .toSet()
            .toList();

        final allTabs = [...keys];
        if (technicalImages.isNotEmpty) {
          allTabs.add('proofs');
        }

        _syncTabController(allTabs);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ResponsiveText.titleMedium(
              '📖 Immersion Projet (IA Solution)',
              style: TextStyle(
                color: ColorHelpers.cyan,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 20),
            
            // ANALYSE DE MATURITÉ (IA)
            IAMaturityAnalysisCard(scores: maturityScores),
            
            const SizedBox(height: 24),
            
            // TABS NAVIGATION IMMERSIVE
            Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: ColorHelpers.border.withValues(alpha: 0.5))),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                dividerColor: Colors.transparent,
                labelColor: ColorHelpers.cyan,
                unselectedLabelColor: ColorHelpers.textSecondary,
                indicatorColor: ColorHelpers.cyan,
                indicatorWeight: 3,
                tabs: allTabs
                    .map((k) => Tab(
                          icon: k == 'readme' ? const Icon(Icons.description_outlined, size: 16) : null,
                          child: Text(
                            (k == 'proofs' ? '💡 Preuves Techniques' : GithubArtifactsService.labelFor(k)).toUpperCase(),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.1),
                          ),
                        ))
                    .toList(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // CONTENU MD AVEC EFFET GLASS
            SizedBox(
              height: widget.info.isMobile ? 400 : 500,
              child: TabBarView(
                controller: _tabController,
                children: allTabs.map((k) {
                  if (k == 'proofs') {
                    return _TechnicalProofsGallery(images: technicalImages);
                  }

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              ColorHelpers.cyan.withValues(alpha: 0.1),
                              Colors.black.withValues(alpha: 0.4),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: ColorHelpers.cyan.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Markdown(
                          data: artifacts[k]!,
                          selectable: true,
                          styleSheet: MarkdownStyleSheet.fromTheme(
                            Theme.of(context),
                          ).copyWith(
                            p: const TextStyle(
                              color: ColorHelpers.textSecondary,
                              height: 1.6,
                              fontSize: 14,
                            ),
                            h1: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                            h2: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            code: const TextStyle(
                              backgroundColor: Colors.black45,
                              color: ColorHelpers.cyan,
                              fontFamily: 'monospace',
                            ),
                            blockquoteDecoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(8),
                              border: const Border(left: BorderSide(color: ColorHelpers.cyan, width: 4)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 12),
            Center(
              child: Text(
                "Framework d'expertise basé sur Flutter Production Readiness & LinkedIn Insights",
                style: TextStyle(
                  color: ColorHelpers.textMuted.withValues(alpha: 0.5),
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Galerie de preuves techniques basées sur les screenshots LinkedIn
class _TechnicalProofsGallery extends StatelessWidget {
  final List<String> images;

  const _TechnicalProofsGallery({required this.images});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorHelpers.border),
      ),
      child: PageView.builder(
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      images[index],
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Concept technique appliqué dans ce projet (Source: FlutterSkills)",
                  style: TextStyle(
                    color: ColorHelpers.textSecondary,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}