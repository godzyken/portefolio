import 'package:flutter/material.dart';

class SmartImage extends StatelessWidget {
  final String? path;
  final BoxFit fit;
  final IconData fallbackIcon;
  final Color? fallbackColor;
  final double? width;
  final double? height;

  const SmartImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.image,
    this.fallbackColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (path == null || path!.isEmpty) {
      return _buildFallback(context);
    }

    if (path!.startsWith('http://') || path!.startsWith('https://')) {
      return Image.network(
        path!,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => _buildFallback(context),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoading(context, loadingProgress);
        },
      );
    } else {
      return Image.asset(
        path!,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => _buildFallback(context),
      );
    }
  }

  Widget _buildFallback(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            fallbackColor ??
                Theme.of(context)
                    .colorScheme
                    .primary
                    .withAlpha((255 * 0.3).toInt()),
            fallbackColor ??
                Theme.of(context)
                    .colorScheme
                    .secondary
                    .withAlpha((255 * 0.2).toInt()),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        fallbackIcon,
        size: 64,
        color: Colors.white.withAlpha((255 * 0.5).toInt()),
      ),
    );
  }

  Widget _buildLoading(BuildContext context, ImageChunkEvent loadingProgress) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Center(
        child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
              : null,
        ),
      ),
    );
  }
}
