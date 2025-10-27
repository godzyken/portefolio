import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/features/experience/data/experiences_data.dart';
import 'package:portefolio/features/generator/views/widgets/generator_widgets_extentions.dart';
import 'package:portefolio/features/parametres/views/widgets/smart_image.dart';

/// Carte minimaliste pour le jeu de poker
/// Affiche uniquement le média (image/vidéo/map) et le poste
class PokerExperienceCard extends ConsumerStatefulWidget {
  final Experience experience;
  final bool isCenter;
  final VoidCallback? onTap;

  const PokerExperienceCard({
    super.key,
    required this.experience,
    this.isCenter = false,
    this.onTap,
  });

  @override
  ConsumerState<PokerExperienceCard> createState() => _PokerExperienceCardState();
}

class _PokerExperienceCardState extends ConsumerState<PokerExperienceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(responsiveInfoProvider);
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          transform: Matrix4.identity()
            ..scale(_isHovered ? 1.03 : 1.0),
          child: AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: widget.isCenter
                      ? [
                    BoxShadow(
                      color: theme.colorScheme.primary
                          .withValues(alpha: _glowAnimation.value * 0.6),
                      blurRadius: 30 * _glowAnimation.value,
                      spreadRadius: 5 * _glowAnimation.value,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ]
                      : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: _isHovered ? 15 : 10,
                      offset: Offset(0, _isHovered ? 8 : 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Média principal
                      _buildMediaContent(info),

                      // Overlay gradient
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),

                      // Badge du poste (en haut)
                      if (widget.experience.poste.isNotEmpty)
                        Positioned(
                          top: 16,
                          left: 16,
                          right: 16,
                          child: _buildPosteBadge(theme),
                        ),

                      // Nom de l'entreprise (en bas)
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: _buildEntrepriseLabel(theme),
                      ),

                      // Indicateur "Tap to expand"
                      if (widget.isCenter)
                        Positioned(
                          bottom: 60,
                          left: 0,
                          right: 0,
                          child: _buildTapIndicator(theme),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMediaContent(ResponsiveInfo info) {
    // Détermine le type de média à afficher
    final hasSIG = widget.experience.tags.contains('SIG');
    final hasVideo = widget.experience.lienProjet.isNotEmpty;
    final hasImage = widget.experience.image.isNotEmpty;

    if (hasSIG) {
      // Afficher la carte SIG
      return const SigDiscoveryMap();
    } else if (hasVideo && widget.isCenter) {
      // Afficher la vidéo YouTube uniquement si la carte est au centre
      return YoutubeVideoPlayerIframe(
        videoUrl: widget.experience.lienProjet,
        cardId: widget.experience.id,
      );
    } else if (hasImage) {
      // Afficher l'image
      return SmartImage(
        path: widget.experience.image,
        fit: BoxFit.cover,
        fallbackIcon: Icons.business,
      );
    } else {
      // Fallback avec logo de l'entreprise
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.indigo.shade900,
              Colors.purple.shade900,
            ],
          ),
        ),
        child: Center(
          child: widget.experience.logo.isNotEmpty
              ? SmartImage(
            path: widget.experience.logo,
            width: 120,
            height: 120,
            fit: BoxFit.contain,
          )
              : Icon(
            Icons.business,
            size: 80,
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
      );
    }
  }

  Widget _buildPosteBadge(ThemeData theme) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.work_outline,
                  size: 18,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    widget.experience.poste,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEntrepriseLabel(ThemeData theme) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.experience.entreprise,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.8),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.experience.periode.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.experience.periode,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTapIndicator(ThemeData theme) {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 1500),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          final bounceValue = (1 - (value - 0.5).abs() * 2);
          return Transform.translate(
            offset: Offset(0, -10 * bounceValue),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.touch_app,
                    size: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tap pour les détails',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
