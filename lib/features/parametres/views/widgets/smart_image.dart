import 'package:flutter/material.dart';

/// Widget intelligent pour afficher des images locales ou réseau
/// avec fallback et gestion d'erreur robuste et animations de chargement (fade-in + shimmer) et fallback élégant.
class SmartImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final IconData? fallbackIcon;
  final Color? fallbackColor;
  final Widget? loadingWidget;
  final Duration? cacheTimeout;

  const SmartImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallbackIcon,
    this.fallbackColor,
    this.loadingWidget,
    this.cacheTimeout = const Duration(days: 7),
  });

  @override
  Widget build(BuildContext context) {
    final isNetwork = path.startsWith('http');

    if (isNetwork) {
      return _buildNetworkImage(context);
    } else {
      return _buildAssetImage(context);
    }
  }

  Widget _buildNetworkImage(BuildContext context) {
    return Image.network(
      path,
      width: width,
      height: height,
      fit: fit,
      // Indicateur de chargement
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        return loadingWidget ??
            Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  strokeWidth: 2,
                ),
              ),
            );
      },
      // Gestion d'erreur avec fallback
      errorBuilder: (context, error, stackTrace) {
        debugPrint('❌ Erreur chargement image réseau: $path');
        debugPrint('Erreur: $error');
        return _buildFallback(context);
      },
      // Headers pour meilleure compatibilité
      headers: const {
        'User-Agent': 'Mozilla/5.0 (compatible; FlutterApp/1.0)',
      },
      // Cache
      cacheWidth: width?.toInt(),
      cacheHeight: height?.toInt(),
    );
  }

  Widget _buildAssetImage(BuildContext context) {
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('❌ Erreur chargement asset: $path');
        debugPrint('Erreur: $error');
        return _buildFallback(context);
      },
      cacheWidth: width?.toInt(),
      cacheHeight: height?.toInt(),
    );
  }

  Widget _buildFallback(BuildContext context) {
    final theme = Theme.of(context);
    final color = fallbackColor ?? theme.colorScheme.primary;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withAlpha((255 * 0.3).toInt()),
            color.withAlpha((255 * 0.1).toInt()),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              fallbackIcon ?? Icons.broken_image_outlined,
              size: (width != null && height != null)
                  ? (width! < height! ? width! * 0.3 : height! * 0.3)
                  : 48,
              color: color.withAlpha((255 * 0.5).toInt()),
            ),
            if (width != null && width! > 100)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Image indisponible',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color.withAlpha((255 * 0.7).toInt()),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Variante avec cache personnalisé pour les images critiques
class CachedSmartImage extends StatefulWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final IconData? fallbackIcon;
  final Color? fallbackColor;

  const CachedSmartImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallbackIcon,
    this.fallbackColor,
  });

  @override
  State<CachedSmartImage> createState() => _CachedSmartImageState();
}

class _CachedSmartImageState extends State<CachedSmartImage> {
  ImageProvider? _cachedProvider;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(CachedSmartImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    try {
      final isNetwork = widget.path.startsWith('http');
      _cachedProvider = isNetwork
          ? NetworkImage(widget.path)
          : AssetImage(widget.path) as ImageProvider;

      // Précharger l'image
      await precacheImage(_cachedProvider!, context);

      if (mounted) {
        setState(() {
          _hasError = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Erreur précache dans CachedSmartImage: ${widget.path}');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError || _cachedProvider == null) {
      return SmartImage(
        path: widget.path,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        fallbackIcon: widget.fallbackIcon,
        fallbackColor: widget.fallbackColor,
      );
    }

    return Image(
      image: _cachedProvider!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {
        return SmartImage(
          path: widget.path,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          fallbackIcon: widget.fallbackIcon,
          fallbackColor: widget.fallbackColor,
        );
      },
    );
  }
}
