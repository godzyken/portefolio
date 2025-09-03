import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/grid_config_provider.dart';
import 'package:portefolio/features/generator/views/widgets/sig_discovery_map.dart';

import '../../../../core/affichage/screen_size_detector.dart';
import '../../../../core/provider/providers.dart';
import 'fade_slide_animation.dart';

class ResponsiveLayout extends ConsumerWidget {
  final String title;
  final List<String> bulletPoints;
  final String? imagePath;
  final List<Widget>? trailingActions;
  final Widget Function(BuildContext, Size)? imageBuilder;
  final Widget Function(BuildContext, Size)? videoBuilder;
  final BoxConstraints constraints;

  const ResponsiveLayout({
    super.key,
    required this.title,
    required this.bulletPoints,
    required this.imagePath,
    required this.imageBuilder,
    required this.videoBuilder,
    required this.trailingActions,
    required this.constraints,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(gridConfigProvider);
    final screenSize = ref.watch(screenSizeProvider);
    final isDesktop = ref.watch(isDesktopProvider);

    final hasImage = imagePath != null || imageBuilder != null;
    final maxHeight = screenSize.height * config.aspectRatio;

    Widget buildImage() => _AnimatedImage(
      title: title,
      bulletPoints: bulletPoints,
      imagePath: imagePath,
      imageBuilder: imageBuilder,
      videoBuilder: videoBuilder,
      size: Size(screenSize.width, screenSize.width / 1.2),
    );

    Widget buildContent() => _TextContent(
      title: title,
      bulletPoints: bulletPoints,
      trailingActions: trailingActions,
      isDesktop: isDesktop,
    );

    if (!isDesktop || config.columns == 1) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasImage)
              AspectRatio(aspectRatio: config.aspectRatio, child: buildImage()),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: buildContent(),
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
            flex: 35,
            child: SizedBox(
              width: screenSize.width,
              height: screenSize.height,
              child: buildImage(),
            ),
          ),
        const SizedBox(width: 12),
        Flexible(
          flex: 65,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
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
  final Size size;

  const _AnimatedImage({
    required this.title,
    required this.bulletPoints,
    required this.imagePath,
    required this.imageBuilder,
    required this.videoBuilder,
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
      content = Image.asset(
        imagePath!,
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
                backgroundColor: Colors.green.shade700.withAlpha(
                  (255 * 0.8).toInt(),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bulletsToShow = bulletPoints.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
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
          (p) => Row(
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
        if (bulletPoints.length > 3)
          Text(
            '+ ${bulletPoints.length - 3} autres…',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: isDesktop ? Colors.black54 : Colors.white70,
            ),
          ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: trailingActions != null
              ? Wrap(spacing: 4, children: trailingActions!)
              : Wrap(
                  spacing: 4,
                  children: const [
                    Icon(Icons.touch_app, size: 14, color: Colors.white70),
                    Text(
                      'Voir plus',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
