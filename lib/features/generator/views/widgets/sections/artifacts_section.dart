import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mermaid/flutter_mermaid.dart';
import 'package:portefolio/core/affichage/colors_spec.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/affichage/tech_maturity_framework.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';
import 'package:markdown/markdown.dart' as md;

import '../../../../projets/data/github_artifacts_service.dart';
import '../../../../projets/data/project_data.dart';
import '../../../../projets/providers/projet_providers.dart';
import '../../../services/section_manager.dart';

/// Builder pour le support Mermaid dans le Markdown
class MermaidMarkdownBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final String text = element.textContent;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: MermaidDiagram(code: text),
    );
  }
}

/// Section Artefacts - Affiche les fichiers .md (présentation, vision,
/// workthrough, valuation, implementation...) trouvés dans le repo GitHub
/// du projet, sous `.artefacts/{id}/`.
///
/// Refondue pour être immersive (Glassmorphism), inclure l'analyse de maturité
/// et des diagrammes Mermaid pour remplacer les images LinkedIn floues.
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
        (
          repoUrl: widget.project.githubRepoUrl!,
          projectId: widget.project.id,
          alternativeId: widget.project.analyticsId,
        ),
      ),
    );

    final isLandscape = widget.info.orientation == Orientation.landscape;
    final manager = SectionManager(widget.project);
    final maturityScores = manager.analyzeMaturity();

    return asyncArtifacts.when(
      loading: () => _buildLayout(
        context,
        maturityScores,
        const Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: CircularProgressIndicator(color: ColorHelpers.cyan),
          ),
        ),
      ),
      error: (err, _) => _buildLayout(
        context,
        maturityScores,
        _buildEmptyState(
            "Impossible de charger la documentation. Vérifiez votre connexion."),
      ),
      data: (artifacts) {
        final keys = GithubArtifactsService.sortedKeys(artifacts);
        final pillars = maturityScores.entries
            .where((e) => e.value > 0.5)
            .map((e) => e.key)
            .toSet()
            .toList();

        final allTabs = [...keys];
        if (pillars.isNotEmpty) {
          allTabs.add('proofs');
        }

        if (allTabs.isEmpty) {
          return _buildLayout(
            context,
            maturityScores,
            _buildEmptyState(
                "Aucun artefact trouvé pour ce projet. La documentation est peut-être en cours de rédaction."),
          );
        }

        _syncTabController(allTabs);

        return _buildLayout(
          context,
          maturityScores,
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: ColorHelpers.border.withValues(alpha: 0.5))),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  dividerColor: Colors.transparent,
                  labelColor: ColorHelpers.cyan,
                  unselectedLabelColor: ColorHelpers.textSecondary,
                  indicatorColor: ColorHelpers.cyan,
                  indicatorWeight: 3,
                  tabs: allTabs
                      .map((k) => Tab(
                            icon: k == 'readme'
                                ? const Icon(Icons.description_outlined,
                                    size: 16)
                                : null,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 150),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  (k == 'proofs'
                                          ? '💡 Architecture & Concepts'
                                          : GithubArtifactsService.labelFor(k))
                                      .toUpperCase(),
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.1),
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: isLandscape ? 300 : (widget.info.isMobile ? 450 : 550),
                child: TabBarView(
                  controller: _tabController,
                  children: allTabs.map((k) {
                    if (k == 'proofs') {
                      return _TechnicalDiagramGallery(pillars: pillars);
                    }
                    return _MarkdownContentCard(content: artifacts[k]!);
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLayout(BuildContext context,
      Map<TechPillar, double> maturityScores, Widget content) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: ResponsiveText.titleMedium(
              '📖 Immersion Projet (IA Solution)',
              style: TextStyle(
                color: ColorHelpers.cyan,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 20),
          IAMaturityAnalysisCard(scores: maturityScores),
          const SizedBox(height: 24),
          content,
          const SizedBox(height: 20),
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
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ColorHelpers.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.info_outline, color: ColorHelpers.textMuted, size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: ColorHelpers.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _MarkdownContentCard extends StatelessWidget {
  final String content;
  const _MarkdownContentCard({required this.content});

  @override
  Widget build(BuildContext context) {
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
            data: content,
            selectable: true,
            shrinkWrap: false,
            builders: {
              'mermaid': MermaidMarkdownBuilder(),
            },
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
                border: const Border(
                    left: BorderSide(color: ColorHelpers.cyan, width: 4)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Galerie de diagrammes techniques (remplace les images LinkedIn floues)
class _TechnicalDiagramGallery extends StatefulWidget {
  final List<TechPillar> pillars;

  const _TechnicalDiagramGallery({required this.pillars});

  @override
  State<_TechnicalDiagramGallery> createState() =>
      _TechnicalDiagramGalleryState();
}

class _TechnicalDiagramGalleryState extends State<_TechnicalDiagramGallery> {
  bool _showOriginalImage = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorHelpers.border),
      ),
      child: PageView.builder(
        itemCount: widget.pillars.length,
        itemBuilder: (context, index) {
          final pillar = widget.pillars[index];
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      pillar.label,
                      style: const TextStyle(
                        color: ColorHelpers.cyan,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () =>
                          setState(() => _showOriginalImage = !_showOriginalImage),
                      icon: Icon(
                        _showOriginalImage ? Icons.auto_awesome : Icons.image,
                        size: 16,
                        color: ColorHelpers.textMuted,
                      ),
                      label: Text(
                        _showOriginalImage ? "Voir Schéma" : "Voir Original",
                        style: const TextStyle(
                            color: ColorHelpers.textMuted, fontSize: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _showOriginalImage
                        ? SmartImage(
                            path: pillar.skillImage,
                            fit: BoxFit.contain,
                            enableFullScreenOnTap: true,
                          )
                        : Container(
                            color: Colors.black12,
                            padding: const EdgeInsets.all(8),
                            child: MermaidDiagram(
                              code: pillar.mermaidDefinition,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _showOriginalImage
                      ? "Capture originale LinkedIn (Source: FlutterSkills)"
                      : pillar.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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
