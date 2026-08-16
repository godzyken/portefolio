import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:portefolio/core/affichage/colors_spec.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/affichage/tech_maturity_framework.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
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
            duration: 600.ms,
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
    return Row(
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
    final storyline = (project as dynamic).storyline ?? project.points[0];
    
    return Column(
      key: const ValueKey('vision'),
      children: [
        if (images.isNotEmpty)
          Expanded(
            flex: 4,
            child: _SceneHeroImage(image: images[0]),
          ),
        const SizedBox(height: 16),
        _SceneDescription(
          title: "LA VISION",
          text: storyline,
          icon: Icons.auto_awesome,
        ),
      ],
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
    
    // On récupère l'image LinkedIn du pilier le plus fort
    String? techImageUrl;
    if (maturity.isNotEmpty) {
      final topPillar = maturity.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      techImageUrl = topPillar.skillImage;
    }

    return Column(
      key: const ValueKey('forge'),
      children: [
        if (techImageUrl != null)
          Expanded(
            flex: 4,
            child: _SceneHeroImage(image: techImageUrl, isTech: true),
          ),
        const SizedBox(height: 16),
        _SceneDescription(
          title: "LA TECHNIQUE",
          text: "Chaque choix technique est une brique vers la Production Readiness. Sécurité, Performance et Scalabilité.",
          icon: Icons.terminal_rounded,
          extra: TechMaturityRadar(scores: maturity, compact: true),
        ),
      ],
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
    
    return Column(
      key: const ValueKey('impact'),
      children: [
        Expanded(
          flex: 4,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // FOND DE MISE EN SCÈNE
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: ColorHelpers.cyan.withValues(alpha: 0.2)),
                ),
              ),
              
              // MOCKUP MOBILE (MISE EN VIE)
              if (mainImage != null)
                Positioned(
                  top: 20,
                  bottom: 20,
                  child: Container(
                    width: info.isMobile ? 180 : 220,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white24, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: ColorHelpers.cyan.withValues(alpha: 0.3),
                          blurRadius: 30,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: SmartImage(
                        path: mainImage,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ).animate().slideY(begin: 0.5, end: 0, duration: 800.ms, curve: Curves.elasticOut),

              // BOUTON ACTION
              if (project.lienProjet != null)
                Positioned(
                  bottom: 40,
                  child: FilledButton.icon(
                    onPressed: _openLiveSite,
                    icon: const Icon(Icons.rocket_launch_rounded),
                    label: const Text("VOIR LE RÉSULTAT LIVE", 
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.2)),
                    style: FilledButton.styleFrom(
                      backgroundColor: ColorHelpers.cyan,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ).animate().scale(delay: 600.ms),
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
      ],
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
    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.95, 0.95));
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
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
              fontStyle: FontStyle.italic,
            ),
          ),
          if (extra != null) ...[
            const SizedBox(height: 16),
            extra!,
          ],
        ],
      ),
    ).animate().slideY(begin: 0.2, end: 0, duration: 400.ms);
  }
}
