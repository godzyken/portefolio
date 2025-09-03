import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/generator/views/widgets/fade_slide_animation.dart';
import 'package:portefolio/features/generator/views/widgets/sig_discovery_map.dart';
import 'package:portefolio/features/parametres/themes/provider/theme_repository_provider.dart';

import '../../../../core/affichage/screen_size_detector.dart';
import '../../../../core/provider/providers.dart';

class AdaptiveCard extends ConsumerStatefulWidget {
  final String title;
  final List<String> bulletPoints;
  final String? imagePath;
  final VoidCallback? onTap;
  final List<Widget>? trailingActions;
  final Widget Function(BuildContext context, Size size)? imageBuilder;
  final Widget Function(BuildContext, Size)? videoBuilder;

  const AdaptiveCard({
    super.key,
    required this.title,
    required this.bulletPoints,
    this.imagePath,
    this.onTap,
    this.trailingActions,
    this.imageBuilder,
    this.videoBuilder,
  });

  @override
  ConsumerState<AdaptiveCard> createState() => _AdaptiveCardState();
}

class _AdaptiveCardState extends ConsumerState<AdaptiveCard> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> showSigOverlayIfSig(
    BuildContext context,
    List<String> tags,
  ) async {
    if (!tags.contains("SIG")) return;
    await showGeneralDialog(
      context: context,
      barrierDismissible: true, // l'utilisateur peut fermer en tapant dehors
      barrierLabel: "Fermer",
      barrierColor: Colors.black54, // fond semi-transparent
      pageBuilder: (context, anim1, anim2) {
        return SafeArea(
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                // Carte en plein écran
                const Positioned.fill(child: SigDiscoveryMap()),

                // Bouton de fermeture en haut à droite
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(opacity: anim1, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ref.watch(isDesktopProvider);
    final theme = ref.watch(themeLoaderProvider);
    final isHovered = ref.watch(hoverMapProvider).containsKey(widget.title);

    return MouseRegion(
      onEnter: (_) =>
          ref.read(hoverMapProvider.notifier).setHover(widget.title, true),
      onExit: (_) =>
          ref.read(hoverMapProvider.notifier).setHover(widget.title, false),
      child: GestureDetector(
        onTap: () async {
          // Si SIG, ouvre l’overlay et bloque le slide derrière
          if (widget.bulletPoints.contains('Sig')) {
            showSigOverlayIfSig(context, widget.bulletPoints);
          } else {
            // Si pas SIG mais vidéo/image, tu peux faire ton comportement existant
            final current = ref.read(playingVideoProvider);
            ref.read(playingVideoProvider.notifier).state =
                current == widget.title ? null : widget.title;
          }

          if (widget.onTap != null) {
            widget.onTap!();
          }
        },
        child: AnimatedScale(
          scale: isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Card(
            margin: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color:
                theme.value?.tertiaryColor ??
                theme.value?.neutralColor ??
                theme.value?.primaryColor,
            elevation: 4,
            clipBehavior: Clip.hardEdge,
            child: LayoutBuilder(
              builder: (_, constraints) =>
                  _responsiveLayout(context, constraints, isDesktop, isHovered),
            ),
          ),
        ),
      ),
    );
  }

  Widget _responsiveLayout(
    BuildContext ctx,
    BoxConstraints constraints,
    bool isDesktop,
    bool isHovered,
  ) {
    final hasImage = widget.imagePath != null || widget.imageBuilder != null;
    final maxWidth = constraints.maxWidth;

    if (!isDesktop || maxWidth < 600) {
      // Mobile / vertical
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImage)
            AspectRatio(
              aspectRatio: 1.2,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _animatedImage(ctx, Size(maxWidth, maxWidth / 1.2)),
                  _gradientOverlay(),
                ],
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: _textContent(ctx, isDesktop),
              ),
            ),
          ),
        ],
      );
    } else {
      // Desktop / horizontal
      final imageWidth = maxWidth * 0.35;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImage)
            SizedBox(
              width: imageWidth,
              height: imageWidth / 1.2,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _animatedImage(ctx, Size(imageWidth, imageWidth / 1.2)),
                  _gradientOverlay(),
                ],
              ),
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: _textContent(ctx, isDesktop),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _animatedImage(BuildContext ctx, Size size) {
    final playingId = ref.watch(playingVideoProvider);
    final isActiveVideo =
        (playingId == widget.title && widget.videoBuilder != null);

    final isMapActive = widget.bulletPoints.contains("SIG");

    Widget content;
    if (isActiveVideo && isMapActive) {
      // 🔹 Carte SIG affichée
      content = const SigDiscoveryMap();
    } else if (isActiveVideo && widget.videoBuilder != null) {
      // 🔹 Video affichée
      content = widget.videoBuilder!(ctx, size);
    } else if (widget.imageBuilder != null) {
      // 🔹 Image via builder affichée
      content = widget.imageBuilder!(ctx, size);
    } else if (widget.imagePath != null) {
      // 🔹 Image asset affichée par defaut
      content = Image.asset(
        widget.imagePath!,
        fit: BoxFit.cover,
        width: size.width,
        height: size.height,
        filterQuality: FilterQuality.high,
      );
    } else {
      content = const SizedBox.shrink();
    }

    return FadeSlideAnimation(
      key: ValueKey(
        isActiveVideo
            ? (isMapActive ? 'sig_${widget.title}' : 'video_${widget.title}')
            : 'image_${widget.title}',
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        child: Stack(
          children: [
            SizedBox(width: size.width, height: size.height, child: content),
            if (isMapActive)
              Positioned(
                child: Chip(
                  label: const Text(
                    "SIG",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: Colors.green.shade700.withAlpha(
                    (255 * 0.8).toInt(),
                  ),
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _gradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withAlpha((255 * 0.1).toInt()),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _textContent(BuildContext ctx, bool isDesktop) {
    final theme = Theme.of(ctx);
    final bulletsToShow = widget.bulletPoints.take(3).toList(); // 3 bullets max

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: isDesktop ? 18 : 16,
            fontWeight: FontWeight.bold,
            color: isDesktop ? Colors.indigoAccent : Colors.cyanAccent,
          ),
        ),
        const SizedBox(height: 8),
        ...bulletsToShow.map(
          (p) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "• ",
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
                Expanded(
                  child: Text(
                    p,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: isDesktop ? 14 : 13,
                      color: isDesktop ? Colors.black87 : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.bulletPoints.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '+ ${widget.bulletPoints.length - 3} autres…',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: isDesktop ? Colors.black54 : Colors.white70,
              ),
            ),
          ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: widget.trailingActions != null
              ? Wrap(spacing: 4, children: widget.trailingActions!)
              : Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  children: [
                    const Icon(
                      Icons.touch_app,
                      size: 14,
                      color: Colors.white70,
                    ),
                    Text(
                      'Voir plus',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: isDesktop ? Colors.black87 : Colors.white70,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
