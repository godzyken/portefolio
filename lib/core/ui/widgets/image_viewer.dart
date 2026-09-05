import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:portefolio/core/ui/widgets/smart_image.dart';

/// A immersive full screen image viewer with zoom capabilities.
class FullScreenImageViewer extends StatelessWidget {
  final String path;
  final String? tag;

  const FullScreenImageViewer({
    super.key,
    required this.path,
    this.tag,
  });

  static Future<void> show(BuildContext context, String path, {String? tag}) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withValues(alpha: 0.9),
        pageBuilder: (context, _, __) =>
            FullScreenImageViewer(path: path, tag: tag),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black26),
            ),
          ),

          // Main Image with Interactive Viewer
          Center(
            child: Hero(
              tag: tag ?? path,
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: SmartImage(
                  path: path,
                  fit: BoxFit.contain,
                  borderRadius: BorderRadius.zero,
                  autoPreload: true,
                  enableShimmer: true,
                ),
              ),
            ),
          ),

          // Controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleButton(
                    icon: Icons.close,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  _CircleButton(
                    icon: Icons.info_outline,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              "Utilisez le pincement ou la molette pour zoomer"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Material(
          color: Colors.white.withValues(alpha: 0.1),
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
          ),
        ),
      ),
    );
  }
}
