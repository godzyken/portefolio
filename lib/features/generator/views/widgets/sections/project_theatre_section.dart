import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:portefolio/core/affichage/colors_spec.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';
import '../../data/extention_models.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/provider/tracking_provider.dart';
import '../../../../../core/service/tracking_service.dart';

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
        
        const SizedBox(height: 24),

        // THÉÂTRE (CONTENU DYNAMIQUE)
        Expanded(
          child: AnimatedSwitcher(
            duration: 600.ms,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
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
      mainAxisAlignment: WrapAlignment.center,
      children: List.generate(scenes.length, (index) {
        final isActive = index == currentScene;
        return GestureDetector(
          onTap: () => onSceneTap(index),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: 300.ms,
                  width: isActive ? 40 : 12,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isActive ? ColorHelpers.cyan : Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      if (isActive)
                        BoxShadow(
                          color: ColorHelpers.cyan.withValues(alpha: 0.5),
                          blurRadius: 8,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  scenes[index],
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
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
    
    return Column(
      key: const ValueKey('vision'),
      children: [
        if (images.isNotEmpty)
          Expanded(
            flex: 3,
            child: _SceneHeroImage(image: images[0]),
          ),
        const SizedBox(height: 24),
        Expanded(
          flex: 2,
          child: _SceneDescription(
            title: "LA GENÈSE",
            text: project.points.isNotEmpty ? project.points[0] : "Conception d'une solution innovante.",
            icon: Icons.lightbulb_outline,
          ),
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
    // On essaye de trouver une image technique
    final images = project.cleanedImages ?? project.image ?? [];
    final techImage = images.length > 1 ? images[1] : (images.isNotEmpty ? images[0] : null);

    return Column(
      key: const ValueKey('forge'),
      children: [
        if (techImage != null)
          Expanded(
            flex: 3,
            child: _SceneHeroImage(image: techImage, isTech: true),
          ),
        const SizedBox(height: 24),
        const Expanded(
          flex: 2,
          child: _SceneDescription(
            title: "L'ARCHITECTURE",
            text: "Alignement sur les standards 'Flutter Production Readiness'. Modularité et performance au coeur du développement.",
            icon: Icons.settings_input_component_outlined,
          ),
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
    
    // Tracking
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
    final results = project.results ?? ["Succès opérationnel et utilisateur."];
    
    return Column(
      key: const ValueKey('impact'),
      children: [
        Expanded(
          flex: 3,
          child: Center(
            child: Icon(Icons.auto_graph_rounded, 
              size: 80, 
              color: ColorHelpers.cyan.withValues(alpha: 0.8)
            ).animate(onPlay: (c) => c.repeat())
             .shimmer(duration: 2.s)
             .scale(duration: 1.s, curve: Curves.easeInOut),
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          flex: 2,
          child: _SceneDescription(
            title: "RÉSULTATS",
            text: results[0],
            icon: Icons.verified_outlined,
          ),
        ),
        if (project.lienProjet != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: FilledButton.icon(
              onPressed: _openLiveSite,
              icon: const Icon(Icons.rocket_launch_outlined),
              label: const Text("VISITER LE SITE LIVE"),
              style: FilledButton.styleFrom(
                backgroundColor: ColorHelpers.cyan,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ).animate().scale(delay: 500.ms),
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isTech ? ColorHelpers.magenta.withValues(alpha: 0.3) : ColorHelpers.cyan.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: SmartImage(
          path: image,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }
}

class _SceneDescription extends StatelessWidget {
  final String title;
  final String text;
  final IconData icon;

  const _SceneDescription({
    required this.title,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: ColorHelpers.cyan, size: 20),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
