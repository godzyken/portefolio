import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:portefolio/core/affichage/colors_spec.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/affichage/tech_maturity_framework.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/ui/widgets/narrative_bubble.dart';
import 'package:portefolio/features/experience/views/widgets/activity_metrics_chart.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/provider/tracking_provider.dart';
import '../../../../../core/service/tracking_service.dart';
import '../../../../projets/data/project_data.dart';
import '../../../services/section_manager.dart';

/// Une section qui met en scène le projet comme un théâtre narratif.
class ProjectTheatreSection extends ConsumerStatefulWidget {
  final ProjectInfo project;
  final ResponsiveInfo info;

  const ProjectTheatreSection({
    super.key,
    required this.project,
    required this.info,
  });

  @override
  ConsumerState<ProjectTheatreSection> createState() => _ProjectTheatreSectionState();
}

class _ProjectTheatreSectionState extends ConsumerState<ProjectTheatreSection> {
  int _currentScene = 0;

  final List<String> _scenes = [
    'VISION',
    'FORGE',
    'IMPACT',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // INDICATEUR DE SCÈNE (STEPS)
        _SceneIndicator(
          currentScene: _currentScene,
          scenes: _scenes,
          onSceneTap: (index) => setState(() => _currentScene = index),
        ),
        
        const SizedBox(height: 20),

        // THÉÂTRE (CONTENU DYNAMIQUE)
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.98, end: 1.0).animate(animation),
                  child: child,
                ),
              );
            },
            child: _buildCurrentScene(),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentScene() {
    switch (_currentScene) {
      case 0:
        return _VisionScene(project: widget.project, info: widget.info);
      case 1:
        return _ForgeScene(project: widget.project, info: widget.info);
      case 2:
        return _ImpactScene(project: widget.project, info: widget.info, ref: ref);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _SceneIndicator extends StatelessWidget {
  final int currentScene;
  final List<String> scenes;
  final Function(int) onSceneTap;

  const _SceneIndicator({
    required this.currentScene,
    required this.scenes,
    required this.onSceneTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(scenes.length, (index) {
          final isActive = index == currentScene;
          return GestureDetector(
            onTap: () => onSceneTap(index),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: isActive ? 30 : 8,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isActive ? ColorHelpers.cyan : Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    scenes[index],
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.white38,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _VisionScene extends StatelessWidget {
  final ProjectInfo project;
  final ResponsiveInfo info;

  const _VisionScene({required this.project, required this.info});

  @override
  Widget build(BuildContext context) {
    final images = project.cleanedImages ?? project.image ?? [];
    final manager = SectionManager(project);
    final storylineText = manager.storyline;
    
    final isCompact = info.size.height < 600;

    return SingleChildScrollView(
      key: const ValueKey('vision'),
      child: Column(
        children: [
          // BULLE IA (MOBILE)
          if (info.isMobile)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: NarrativeBubble(
                text: "Découvrez la genèse de ce projet. C'est ici que l'idée a pris vie.",
              ),
            ),

          if (images.isNotEmpty)
            Container(
              height: isCompact ? 180 : 250,
              margin: const EdgeInsets.only(bottom: 16),
              child: _SceneHeroImage(image: images[0]),
            ),
          _SceneDescription(
            title: "LA VISION",
            text: storylineText,
            icon: Icons.auto_awesome,
          ),
          const SizedBox(height: 60), // Plus d'espace en bas pour le scroll
        ],
      ),
    );
  }
}

class _ForgeScene extends StatelessWidget {
  final ProjectInfo project;
  final ResponsiveInfo info;

  const _ForgeScene({required this.project, required this.info});

  @override
  Widget build(BuildContext context) {
    final manager = SectionManager(project);
    final maturity = manager.analyzeMaturity();
    final isCompact = info.size.height < 600;
    
    String? techImageUrl;
    if (maturity.isNotEmpty) {
      final topPillar = maturity.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      techImageUrl = topPillar.skillImage;
    }

    return SingleChildScrollView(
      key: const ValueKey('forge'),
      child: Column(
        children: [
          // BULLE IA (MOBILE)
          if (info.isMobile)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: NarrativeBubble(
                text: "La forge technique. C'est ici que la magie opère avec une stack moderne et robuste.",
              ),
            ),

          if (techImageUrl != null)
            Container(
              height: isCompact ? 180 : 250,
              margin: const EdgeInsets.only(bottom: 16),
              child: _SceneHeroImage(image: techImageUrl, isTech: true),
            ),
          _SceneDescription(
            title: "LA TECHNIQUE",
            text: "Chaque choix technique est une brique vers la Production Readiness. Sécurité, Performance et Scalabilité.",
            icon: Icons.terminal_rounded,
            extra: TechMaturityRadar(scores: maturity, compact: true),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}

class _ImpactScene extends StatelessWidget {
  final ProjectInfo project;
  final ResponsiveInfo info;
  final WidgetRef ref;

  const _ImpactScene({required this.project, required this.info, required this.ref});

  Future<void> _openLiveSite() async {
    if (project.lienProjet == null) return;
    final uri = Uri.parse(project.lienProjet!);
    
    ref.read(trackingServiceProvider).trackInteraction(
      projectId: project.id,
      projectName: project.title,
      action: TrackingAction.linkClick,
      details: {'url': project.lienProjet, 'source': 'theatre_impact_scene'},
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final results = project.results ?? ["Succès opérationnel."];
    final images = project.cleanedImages ?? project.image ?? [];
    final mainImage = images.isNotEmpty ? images[0] : null;
    final isCompact = info.size.height < 600;
    
    return SingleChildScrollView(
      key: const ValueKey('impact'),
      child: Column(
        children: [
          // BULLE IA (MOBILE)
          if (info.isMobile)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: NarrativeBubble(
                text: "L'impact final. Une solution prête pour la production avec des résultats concrets.",
              ),
            ),

          // NOUVEAU : MÉTRIQUES DYNAMIQUES
          SizedBox(
            height: 350,
            child: ActivityMetricsChart(
              project: project,
              info: info,
            ),
          ),
          
          const SizedBox(height: 24),

          Container(
            height: isCompact ? 200 : 280,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: ColorHelpers.cyan.withValues(alpha: 0.2)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (mainImage != null)
                  Positioned(
                    top: 15,
                    bottom: 15,
                    child: Container(
                      width: info.isMobile ? 140 : 180,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: ColorHelpers.cyan.withValues(alpha: 0.3),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: SmartImage(
                          path: mainImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ).animate().slideY(begin: 0.5, end: 0, duration: const Duration(milliseconds: 800), curve: Curves.elasticOut),

                if (project.lienProjet != null)
                  Positioned(
                    bottom: 20,
                    child: FilledButton.icon(
                      onPressed: _openLiveSite,
                      icon: const Icon(Icons.rocket_launch_rounded, size: 14),
                      label: const Text("VOIR LE RÉSULTAT LIVE", 
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.1)),
                      style: FilledButton.styleFrom(
                        backgroundColor: ColorHelpers.cyan,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ).animate().scale(delay: const Duration(milliseconds: 600)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SceneDescription(
            title: "L'IMPACT",
            text: results[0],
            icon: Icons.check_circle_outline,
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}

class _SceneHeroImage extends StatelessWidget {
  final String image;
  final bool isTech;

  const _SceneHeroImage({required this.image, this.isTech = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isTech ? ColorHelpers.magenta.withValues(alpha: 0.4) : ColorHelpers.cyan.withValues(alpha: 0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SmartImage(
          path: image,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 500)).scale(begin: const Offset(0.95, 0.95));
  }
}

class _SceneDescription extends StatelessWidget {
  final String title;
  final String text;
  final IconData icon;
  final Widget? extra;

  const _SceneDescription({
    required this.title,
    required this.text,
    required this.icon,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: ColorHelpers.cyan, size: 18),
              const SizedBox(width: 10),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
          if (extra != null) ...[
            const SizedBox(height: 16),
            extra!,
          ],
        ],
      ),
    ).animate().slideY(begin: 0.2, end: 0, duration: const Duration(milliseconds: 400));
  }
}
