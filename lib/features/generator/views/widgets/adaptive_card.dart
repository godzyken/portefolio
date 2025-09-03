import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/generator/views/widgets/responsive_layout.dart';
import 'package:portefolio/features/generator/views/widgets/sig_discovery_map.dart';
import 'package:portefolio/features/parametres/themes/provider/theme_repository_provider.dart';

import '../../../../core/provider/providers.dart';

class AdaptiveCard extends ConsumerWidget {
  final String title;
  final List<String> bulletPoints;
  final String? imagePath;
  final VoidCallback? onTap;
  final List<Widget>? trailingActions;
  final Widget Function(BuildContext, Size)? imageBuilder;
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
    final theme = ref.watch(themeLoaderProvider);
    final isHovered = ref.watch(hoverMapProvider).containsKey(title);

    return MouseRegion(
      onEnter: (_) => ref.read(hoverMapProvider.notifier).setHover(title, true),
      onExit: (_) => ref.read(hoverMapProvider.notifier).setHover(title, false),
      child: GestureDetector(
        onTap: () async {
          if (bulletPoints.contains('SIG')) {
            await _showSigOverlay(context);
          } else {
            final current = ref.read(playingVideoProvider);
            ref.read(playingVideoProvider.notifier).state = current == title
                ? null
                : title;
          }
          onTap?.call();
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
              builder: (context, constraints) => ResponsiveLayout(
                title: title,
                bulletPoints: bulletPoints,
                imagePath: imagePath,
                imageBuilder: imageBuilder,
                videoBuilder: videoBuilder,
                trailingActions: trailingActions,
                constraints: constraints,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showSigOverlay(BuildContext context) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Fermer",
      barrierColor: Colors.black54,
      pageBuilder: (context, _, _) {
        return SafeArea(
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                const Positioned.fill(child: SigDiscoveryMap()),
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
      transitionBuilder: (context, anim1, _, child) {
        return FadeTransition(opacity: anim1, child: child);
      },
    );
  }
}
