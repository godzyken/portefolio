import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/generator/views/widgets/hover_card.dart';
import 'package:portefolio/features/parametres/themes/provider/theme_repository_provider.dart';

import '../../../../core/affichage/screen_size_detector.dart';
import '../../../../core/provider/providers.dart';

class AdaptiveCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = ref.watch(isDesktopProvider);
    final theme = ref.watch(themeLoaderProvider);
    final hoverMap = ref.watch(hoverMapProvider);
    final isHovered = hoverMap[title] ?? false;

    // écoute du hover → démarre ou arrête la vidéo
    ref.listen(hoverMapProvider, (previous, next) {
      final wasHovered = previous?[title] ?? false;
      final nowHovered = next[title] ?? false;

      if (wasHovered != nowHovered && isDesktop) {
        ref.read(playingVideoProvider.notifier).state = nowHovered
            ? title
            : null;
      }
    });

    return HoverCard(
      id: title,
      child: InkWell(
        onTap: !isDesktop
            ? () {
                final current = ref.read(playingVideoProvider);
                ref.read(playingVideoProvider.notifier).state = current == title
                    ? null
                    : title;
              }
            : onTap,
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
            builder: (_, constraints) => _responsiveLayout(
              context,
              ref,
              constraints,
              isDesktop,
              isHovered,
            ),
          ),
        ),
      ),
    );
  }

  Widget _responsiveLayout(
    BuildContext ctx,
    WidgetRef ref,
    BoxConstraints constraints,
    bool isDesktop,
    bool isHovered,
  ) {
    final hasImage = imagePath != null || imageBuilder != null;
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
                  _animatedImage(ctx, ref, Size(maxWidth, maxWidth / 1.2)),
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
                  _animatedImage(ctx, ref, Size(imageWidth, imageWidth / 1.2)),
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

  Widget _animatedImage(BuildContext ctx, WidgetRef ref, Size size) {
    final playingId = ref.watch(playingVideoProvider);
    final isActiveVideo = (playingId == title && videoBuilder != null);

    return AnimatedScale(
      scale: (ref.watch(hoverMapProvider)[title] ?? false) ? 1.05 : 1.0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        child: isActiveVideo
            ? SizedBox(
                key: ValueKey('video_$title'),
                width: size.width,
                height: size.height,
                child: videoBuilder!(ctx, size),
              )
            : imageBuilder != null
            ? SizedBox(
                key: ValueKey('image_$title'),
                width: size.width,
                height: size.height,
                child: imageBuilder!(ctx, size),
              )
            : imagePath != null
            ? Image.asset(
                imagePath!,
                key: ValueKey('imageAsset_$title'),
                fit: BoxFit.cover,
                width: size.width,
                height: size.height,
                filterQuality: FilterQuality.high,
              )
            : SizedBox(
                key: ValueKey('empty_$title'),
                width: size.width,
                height: size.height,
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
    final bulletsToShow = bulletPoints.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
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
        if (bulletPoints.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '+ ${bulletPoints.length - 3} autres…',
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
          child: trailingActions != null
              ? Wrap(spacing: 4, children: trailingActions!)
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
