import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

/// Widget universel pour charger des images locales, réseau (avec cache) ou SVG,
/// avec animations de chargement (fade-in + shimmer) et fallback élégant.
class SmartImage extends StatelessWidget {
  final String? path;
  final BoxFit fit;
  final IconData fallbackIcon;
  final Color? fallbackColor;
  final double? width;
  final double? height;
  final Duration fadeDuration;

  const SmartImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.image,
    this.fallbackColor,
    this.width,
    this.height,
    this.fadeDuration = const Duration(milliseconds: 500),
  });

  @override
  Widget build(BuildContext context) {
    if (path == null || path!.isEmpty) {
      return _buildFallback(context);
    }

    final cleanPath = _cleanImagePath(path!);
    if (cleanPath.isEmpty) {
      return _buildFallback(context);
    }

    final isNetwork =
        cleanPath.startsWith('http://') || cleanPath.startsWith('https://');
    final isSvg = cleanPath.toLowerCase().endsWith('.svg');

    if (isNetwork) {
      if (isSvg) {
        // ✅ Gestion SVG réseau
        return SvgPicture.network(
          cleanPath,
          width: width,
          height: height,
          fit: fit,
          placeholderBuilder: (_) => _buildShimmer(context),
        );
      } else {
        // ✅ Gestion image réseau + cache + fade + shimmer
        return CachedNetworkImage(
          imageUrl: cleanPath,
          width: width,
          height: height,
          fit: fit,
          fadeInDuration: fadeDuration,
          placeholder: (context, _) => _buildShimmer(context),
          errorWidget: (context, url, error) {
            debugPrint('❌ Erreur chargement image réseau: $cleanPath - $error');
            return _buildFallback(context);
          },
        );
      }
    } else {
      // ✅ Gestion image locale
      return Image.asset(
        cleanPath,
        width: width,
        height: height,
        fit: fit,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: fadeDuration,
            curve: Curves.easeInOut,
            child: child,
          );
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('❌ Erreur chargement asset local: $cleanPath - $error');
          return _buildFallback(context);
        },
      );
    }
  }

  /// Nettoyage du chemin d'image (URL encodée, doubles slashs, etc.)
  String _cleanImagePath(String path) {
    if (path.isEmpty) return path;

    if (path.contains('assets/http')) {
      final httpIndex = path.indexOf('http');
      if (httpIndex != -1) path = path.substring(httpIndex);
    }

    if (path.contains('%')) {
      try {
        path = Uri.decodeFull(path);
      } catch (_) {}
    }

    path = path.replaceAllMapped(RegExp(r'(?<!:)//+'), (_) => '/');
    return path;
  }

  /// Fallback visuel si l'image ne peut pas être chargée
  Widget _buildFallback(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            fallbackColor ??
                Theme.of(context)
                    .colorScheme
                    .primary
                    .withAlpha((255 * 0.25).toInt()),
            fallbackColor ??
                Theme.of(context)
                    .colorScheme
                    .secondary
                    .withAlpha((255 * 0.15).toInt()),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        fallbackIcon,
        size: 48,
        color: Colors.white.withAlpha((255 * 0.6).toInt()),
      ),
    );
  }

  /// Shimmer (effet de chargement fluide)
  Widget _buildShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      highlightColor: Theme.of(context).colorScheme.surface,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
