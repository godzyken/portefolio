import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/parametres/themes/provider/theme_repository_provider.dart';

import '../../../../core/affichage/screen_size_detector.dart';

class AdaptiveCard extends ConsumerStatefulWidget {
  final String title;
  final List<String> bulletPoints;
  final String? imagePath;
  final VoidCallback? onTap;
  final List<Widget>? trailingActions;
  final Widget Function(BuildContext context, Size size)? imageBuilder;

  const AdaptiveCard({
    super.key,
    required this.title,
    required this.bulletPoints,
    this.imagePath,
    this.onTap,
    this.trailingActions,
    this.imageBuilder,
  });

  @override
  ConsumerState<AdaptiveCard> createState() => _AdaptiveCardState();
}

class _AdaptiveCardState extends ConsumerState<AdaptiveCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final isDesktop = ref.watch(isDesktopProvider);
    final theme = ref.watch(themeLoaderProvider);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: InkWell(
        onTap: widget.onTap,
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
                _responsiveLayout(context, constraints, isDesktop),
          ),
        ),
      ),
    );
  }

  Widget _responsiveLayout(
    BuildContext ctx,
    BoxConstraints constraints,
    bool isDesktop,
  ) {
    final hasImage = widget.imagePath != null || widget.imageBuilder != null;
    final maxWidth = constraints.maxWidth;

    if (!isDesktop || maxWidth < 600) {
      // ----- Mobile / vertical -----
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImage)
            AspectRatio(
              aspectRatio: 1.2,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _animatedImage(
                    ctx,
                    Size(maxWidth, maxWidth / 1.2),
                    isDesktop,
                  ),
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
      // ----- Desktop / horizontal -----
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
                  _animatedImage(
                    ctx,
                    Size(imageWidth, imageWidth / 1.2),
                    isDesktop,
                  ),
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

  Widget _animatedImage(BuildContext ctx, Size size, bool isDesktop) {
    final scale = _hovering && isDesktop ? 1.05 : 1.0;
    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: widget.imageBuilder != null
          ? widget.imageBuilder!(ctx, size)
          : widget.imagePath != null
          ? Image.asset(
              widget.imagePath!,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            )
          : const SizedBox.expand(),
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
    final bulletsToShow = widget.bulletPoints.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
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
