import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/widgets/responsive_text.dart';
import 'package:portefolio/features/experience/data/experiences_data.dart';
import 'package:portefolio/features/generator/views/widgets/generator_widgets_extentions.dart';
import 'package:portefolio/features/parametres/views/widgets/smart_image.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

import '../../../../core/provider/providers.dart';

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
  ConsumerState<PokerExperienceCard> createState() =>
      _PokerExperienceCardState();
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

    final bool hasVideo = widget.experience.youtubeVideoId?.isNotEmpty ?? false;
    final bool shouldShowVideo = hasVideo && widget.isCenter;

    final isVideoVisible = ref.watch(globalVideoVisibilityProvider);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: shouldShowVideo ? null : widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          transform: Matrix4.identity()
            ..scaledByVector3(Vector3.all(_isHovered ? 1.03 : 1.0)),
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
                      IgnorePointer(
                        ignoring: !isVideoVisible && shouldShowVideo,
                        child: _buildMediaContent(info),
                      ),

                      // Overlay gradient
                      IgnorePointer(
                        child: Container(
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
                      ),

                      // Badge du poste (en haut)
                      if (widget.experience.poste.isNotEmpty)
                        Positioned(
                          top: 16,
                          left: 16,
                          right: 16,
                          child: _buildPosteBadge(theme),
                        ),

                      // Badge du poste (en haut)
                      if (widget.experience.poste.isNotEmpty)
                        Positioned(
                          top: 16,
                          left: 16,
                          right: 16,
                          child: _buildPosteBadge(theme),
                        ),

                      // Bouton "Tap pour détails" ou label entreprise
                      if (shouldShowVideo && widget.isCenter)
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: _buildTapIndicator(theme),
                        )
                      else
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: _buildEntrepriseLabel(theme),
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
    final hasVideo = widget.experience.youtubeVideoId!.isNotEmpty;
    final hasImage = widget.experience.image.isNotEmpty;

    final isVideoVisible = ref.watch(globalVideoVisibilityProvider);
    final isVideoPlaying = ref.watch(playingVideoProvider);

    // --- 2. Gérer les cas par ordre de priorité ---

    // CAS 1 : Carte SIG
    if (hasSIG) {
      return const SigDiscoveryMap();
    }

    // CAS 2 : La carte est au centre et a une vidéo
    if (widget.isCenter && hasVideo) {
      // Si une autre vidéo est en cours de lecture, on affiche le fallback.
      // Sinon, on affiche notre vidéo.
      final bool showFallback =
          isVideoVisible && isVideoPlaying != widget.experience.id;

      if (showFallback) {
        // Le code de fallback (image ou icône) est maintenant dans un bloc clair.
        if (hasImage) {
          return SmartImage(
            path: widget.experience.image,
            fit: BoxFit.cover,
            fallbackIcon: Icons.business,
          );
        }
        // Si pas d'image, on affiche le fallback générique.
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
            child: Icon(
              Icons.play_circle_outline,
              size: 80,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        );
      } else {
        // C'est le bon moment pour jouer notre vidéo.
        return YoutubeVideoPlayerIframe(
          youtubeVideoId: widget.experience.youtubeVideoId!,
          cardId: widget.experience.id,
        );
      }
    }

    // CAS 3 (Fallback général) : Si ce n'est ni SIG, ni une vidéo au centre,
    // on affiche l'image de l'expérience, ou une icône si pas d'image.
    if (hasImage) {
      return SmartImage(
        path: widget.experience.image,
        fit: BoxFit.cover,
        fallbackIcon: Icons.business,
      );
    }

    // CAS 4 (Dernier recours) : Si absolument aucun média n'est défini.
    return Container(
      color: Colors.grey.shade900,
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.white24,
          size: 60,
        ),
      ),
    );
  }

  Widget _buildPosteBadge(ThemeData theme) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: ResponsiveBox(
            paddingSize: ResponsiveSpacing.m,
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
                const ResponsiveBox(paddingSize: ResponsiveSpacing.s),
                Flexible(
                  child: ResponsiveText(
                    widget.experience.poste,
                    size: ResponsiveTextSize.bodyMedium,
                    style: const TextStyle(
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
                ResponsiveText.headlineSmall(
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
                  const ResponsiveBox(
                      paddingSize: ResponsiveSpacing.xs), // ✅ Remplace SizedBox
                  ResponsiveText.bodyMedium(
                    widget.experience.periode,
                    style: const TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 0.9),
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
            child: Material(
                color: Colors.transparent,
                child: InkWell(
                    onTap: () async {
                      developer.log('🎯 TAP DÉTECTÉ !'); // ✅ DEBUG
                      ref.read(globalVideoVisibilityProvider.notifier).hide();
                      ref.read(playingVideoProvider.notifier).stop();

                      await context.showDialogWithVideoHidden(
                        ref: ref,
                        dialog: AlertDialog(
                          title: Text(widget.experience.poste),
                          content: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.experience.entreprise,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text('Periode : ${widget.experience.periode}'),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Fermer'),
                            ),
                          ],
                        ),
                      );

                      ref.read(globalVideoVisibilityProvider.notifier).show();
                    },
                    borderRadius: BorderRadius.circular(30),
                    splashColor:
                        theme.colorScheme.primary.withValues(alpha: 0.3),
                    highlightColor:
                        theme.colorScheme.primary.withValues(alpha: 0.2),
                    child: ResponsiveBox(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(255, 255, 255, 0.2),
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
                          const ResponsiveBox(paddingSize: ResponsiveSpacing.s),
                          ResponsiveText.bodySmall(
                            'Tap pour les détails',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ))),
          );
        },
      ),
    );
  }
}
