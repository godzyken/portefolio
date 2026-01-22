import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/provider/unified_image_provider.dart';
import 'package:portefolio/features/generator/views/generator_widgets_extentions.dart';

import '../../../../core/affichage/screen_size_detector.dart';
import '../../../../core/provider/providers.dart';
import '../../../../core/ui/widgets/tech_icon.dart';

class ResponsiveLayout extends ConsumerWidget {
  final String title;
  final List<String> bulletPoints;
  final String? imagePath;
  final List<Widget>? trailingActions;
  final Widget Function(BuildContext, Size)? imageBuilder;
  final Widget Function(BuildContext, Size)? videoBuilder;
  final Widget Function(BuildContext, Size)? badgeBuilder;
  final BoxConstraints constraints;

  const ResponsiveLayout({
    super.key,
    required this.title,
    required this.bulletPoints,
    required this.imagePath,
    required this.imageBuilder,
    required this.videoBuilder,
    required this.badgeBuilder,
    required this.trailingActions,
    required this.constraints,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(responsiveInfoProvider);

    final hasImage = imagePath != null || imageBuilder != null;
    final maxHeight = info.size.height * info.grid.aspectRatio;

    Widget buildImage() => _AnimatedImage(
          title: title,
          bulletPoints: bulletPoints,
          imagePath: imagePath,
          imageBuilder: imageBuilder,
          videoBuilder: videoBuilder,
          badgeBuilder: badgeBuilder,
          size: Size(info.size.width, info.size.width / 1.2),
        );

    Widget buildContent() => _TextContent(
          title: title,
          bulletPoints: bulletPoints,
          trailingActions: trailingActions,
          isDesktop: info.isDesktop,
        );

    if (!info.isDesktop || info.grid.columns == 1) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasImage)
              Flexible(
                flex: 50,
                child: AspectRatio(
                  aspectRatio: info.grid.aspectRatio,
                  child: buildImage(),
                ),
              ),
            Flexible(
              flex: 50,
              child: SizedBox(
                width: info.size.width,
                height: info.size.height,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: buildContent(),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Desktop / large screens
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasImage)
          Flexible(
            flex: 50,
            child: SizedBox(
              width: info.size.width,
              height: info.size.height,
              child: buildImage(),
            ),
          ),
        const SizedBox(width: 12),
        Flexible(
          flex: 50,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 0.5, horizontal: 0.5),
            child: buildContent(),
          ),
        ),
      ],
    );
  }
}

class _AnimatedImage extends ConsumerWidget {
  final String title;
  final List<String> bulletPoints;
  final String? imagePath;
  final Widget Function(BuildContext, Size)? imageBuilder;
  final Widget Function(BuildContext, Size)? videoBuilder;
  final Widget Function(BuildContext, Size)? badgeBuilder;
  final Size size;

  const _AnimatedImage({
    required this.title,
    required this.bulletPoints,
    required this.imagePath,
    required this.imageBuilder,
    required this.videoBuilder,
    required this.badgeBuilder,
    required this.size,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playingId = ref.watch(playingVideoProvider);
    final isActiveVideo = (playingId == title && videoBuilder != null);
    final isMapActive = bulletPoints.contains("SIG");

    Widget content;
    if (isActiveVideo && isMapActive) {
      content = const SigDiscoveryMap();
    } else if (isActiveVideo && videoBuilder != null) {
      content = videoBuilder!(context, size);
    } else if (imageBuilder != null) {
      content = imageBuilder!(context, size);
    } else if (imagePath != null) {
      content = CachedImage(
        path: imagePath!,
        fit: BoxFit.cover,
        width: size.width,
        height: size.height,
      );
    } else {
      content = const SizedBox.shrink();
    }

    return FadeSlideAnimation(
      key: ValueKey(
        isActiveVideo
            ? (isMapActive ? 'sig_$title' : 'video_$title')
            : 'image_$title',
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          content,
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
                backgroundColor: Colors.green.shade700.withValues(
                  alpha: 0.8,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ),
        ],
      ),
    );
  }
}

class _TextContent extends StatelessWidget {
  final String title;
  final List<String> bulletPoints;
  final List<Widget>? trailingActions;
  final bool isDesktop;

  const _TextContent({
    required this.title,
    required this.bulletPoints,
    required this.trailingActions,
    required this.isDesktop,
  });

  bool _hasProgrammingTag() {
    return TechIconHelper.getProgrammingTags()
        .any((tag) => bulletPoints.contains(tag));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bulletsToShow = bulletPoints.take(3).toList();

    return _hasProgrammingTag()
        ? CodeHighlightList(items: bulletsToShow, tag: '//')
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Titre
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: isDesktop ? 20 : 16,
                  fontWeight: FontWeight.w700,
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [Colors.indigoAccent, Colors.cyanAccent],
                    ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                ),
              ),
              const SizedBox(height: 8),
              ...bulletsToShow.map(
                (p) => Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDesktop
                        ? Colors.indigo.withValues(alpha: 0.05)
                        : Colors.white10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.arrow_right,
                        size: 16,
                        color: Colors.cyanAccent,
                      ),
                      const SizedBox(width: 4),
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
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '+ ${bulletPoints.length - 3} autres…',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: isDesktop ? Colors.black54 : Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: trailingActions != null
                    ? Wrap(spacing: 4, children: trailingActions!)
                    : const Wrap(
                        spacing: 4,
                        children: [
                          Icon(
                            Icons.touch_app,
                            size: 14,
                            color: Colors.white70,
                          ),
                          Text(
                            'Voir plus',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          );
  }
}
