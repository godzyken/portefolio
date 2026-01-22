import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';
import 'package:portefolio/features/experience/data/experiences_data.dart';
import 'package:portefolio/features/generator/views/generator_widgets_extentions.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

import '../../../../core/provider/providers.dart';

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
  bool _isMediaLoading = true;
  bool _hasMediaError = false;
  String? _errorMessage;
  Widget? _cachedMediaContent;
  bool _mediaCacheBuilt = false;

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

    _initializeMedia();
  }

  Future<void> _initializeMedia() async {
    try {
      // Délai pour éviter que toutes les cartes se chargent en même temps
      await Future.delayed(
          Duration(milliseconds: 100 + (widget.experience.id.hashCode % 300)));

      if (!mounted) return;

      setState(() {
        _isMediaLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isMediaLoading = false;
        _hasMediaError = true;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PokerExperienceCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.experience.id != widget.experience.id ||
        oldWidget.isCenter != widget.isCenter) {
      _mediaCacheBuilt = false;
      _cachedMediaContent = null;
    }
  }

  void _navigateToDetails() async {
    developer.log('🎯 Navigation vers ImmersiveExperienceDetail');

    final playingVideo = ref.read(playingVideoProvider);
    if (playingVideo != null) {
      ref.read(playingVideoProvider.notifier).stop();

      await Future.delayed(const Duration(milliseconds: 100));
    }
    // Cache et arrête la vidéo avant la navigation
    ref.read(globalVideoVisibilityProvider.notifier).setFalse();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ImmersiveExperienceDetail(
          experience: widget.experience,
        ),
      ),
    );

    // Réaffiche la vidéo après le retour
    if (mounted) {
      ref.read(globalVideoVisibilityProvider.notifier).setTrue();
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(responsiveInfoProvider);
    final theme = Theme.of(context);

    final bool hasVideo = widget.experience.youtubeVideoId?.isNotEmpty ?? false;
    final bool shouldShowVideo = hasVideo && widget.isCenter;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          if (widget.isCenter) {
            _navigateToDetails();
          } else {
            widget.onTap?.call();
          }
        },
        onSecondaryTap: widget.isCenter ? _navigateToDetails : widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          transform: Matrix4.identity()
            ..scaledByVector3(Vector3.all(_isHovered ? 1.03 : 1.0)),
          child: AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return child!;
            },
            child: _buildCardShell(theme, info, shouldShowVideo),
          ),
        ),
      ),
    );
  }

  /// ✅ Construit la coquille de la carte (ne dépend PAS de l'animation)
  Widget _buildCardShell(
      ThemeData theme, ResponsiveInfo info, bool shouldShowVideo) {
    return ResponsiveBox(
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
            // ✅ Média avec cache
            IgnorePointer(
              ignoring: false || !widget.isCenter,
              child: _buildCachedMediaContent(info),
            ),

            // Overlay gradient (statique)
            IgnorePointer(
              child: ResponsiveBox(
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

            // Badge du poste
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
                child: buildCompanyLabel(theme),
              ),
          ],
        ),
      ),
    );
  }

  /// ✅ Construit le contenu média UNE SEULE FOIS et le met en cache
  Widget _buildCachedMediaContent(ResponsiveInfo info) {
    // Si déjà construit et en cache, retourner le cache
    if (_mediaCacheBuilt && _cachedMediaContent != null) {
      return _cachedMediaContent!;
    }

    // Construire le contenu
    final content = _buildMediaContent(info);

    // Mettre en cache
    _cachedMediaContent = content;
    _mediaCacheBuilt = true;

    return content;
  }

  Widget _buildMediaContent(ResponsiveInfo info) {
    final hasSIG = widget.experience.tags.contains('SIG');
    final hasVideo = widget.experience.youtubeVideoId?.isNotEmpty ?? false;
    final hasImage = widget.experience.image.isNotEmpty;

    // ✅ Afficher un loader pendant le chargement initial
    if (_isMediaLoading) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade900, Colors.purple.shade900],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white70,
            strokeWidth: 2,
          ),
        ),
      );
    }

    // ✅ Afficher une erreur si le chargement a échoué
    if (_hasMediaError) {
      return Container(
        color: Colors.grey.shade900,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 40,
              ),
              const SizedBox(height: 8),
              const Text(
                'Erreur de chargement',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // CAS 1 : Carte SIG
    if (hasSIG) {
      return FutureBuilder(
        future: Future.delayed(const Duration(milliseconds: 300)),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Container(
              color: Colors.teal.shade900,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.tealAccent,
                  strokeWidth: 2,
                ),
              ),
            );
          }
          return const SigDiscoveryMap();
        },
      );
    }

    // CAS 2 : Vidéo YouTube (carte centrale)
    if (widget.isCenter && hasVideo) {
      final isVideoVisible = ref.watch(globalVideoVisibilityProvider);
      final playingVideo = ref.watch(playingVideoProvider);

      if (isVideoVisible && playingVideo == widget.experience.id) {
        return YoutubeVideoPlayerIframe(
          youtubeVideoId: widget.experience.youtubeVideoId!,
          cardId: widget.experience.id,
        );
      }

      return Stack(
        fit: StackFit.expand,
        children: [
          if (hasImage)
            SmartImageV2(
              path: widget.experience.image,
              fit: BoxFit.cover,
              width: info.size.width * 0.5,
              height: info.size.height * 0.5,
              responsiveSize: ResponsiveImageSize.medium,
              fallbackIcon: Icons.business,
              enableShimmer: true,
            )
          else
            ResponsiveBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade900, Colors.purple.shade900],
                ),
              ),
            ),
          // Bouton Play au centre
          Center(
            child: AbsorbPointer(
              absorbing: false,
              child: ResponsiveBox(
                padding: const EdgeInsets.all(16),
                paddingSize: ResponsiveSpacing.m,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: ResponsiveButton.icon(
                  type: ButtonType.primary,
                  icon: Icon(Icons.play_arrow),
                  label: 'Jouer',
                  onPressed: () {
                    ref.read(globalVideoVisibilityProvider.notifier).setTrue();
                    ref
                        .read(playingVideoProvider.notifier)
                        .play(widget.experience.id);
                  },
                ),
              ),
            ),
          ),
        ],
      );
    }

    // CAS 3 : Image standard
    if (hasImage) {
      return SmartImageV2(
        path: widget.experience.image,
        responsiveSize: ResponsiveImageSize.medium,
        fit: BoxFit.cover,
        width: info.size.width,
        height: info.size.height,
        fallbackIcon: Icons.business,
        enableShimmer: true,
      );
    }

    // CAS 4 : Fallback
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

  Widget buildCompanyLabel(ThemeData theme) {
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
                  style: TextStyle(
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
                  const ResponsiveBox(paddingSize: ResponsiveSpacing.xs),
                  ResponsiveText.bodyMedium(
                    widget.experience.periode,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
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
                    onTap: _navigateToDetails,
                    borderRadius: BorderRadius.circular(30),
                    splashColor:
                        theme.colorScheme.primary.withValues(alpha: 0.3),
                    highlightColor:
                        theme.colorScheme.primary.withValues(alpha: 0.2),
                    child: ResponsiveBox(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
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
