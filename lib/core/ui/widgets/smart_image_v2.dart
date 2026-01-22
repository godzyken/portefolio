import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:portefolio/core/ui/widgets/smart_image.dart';
import 'package:shimmer/shimmer.dart';

import '../../affichage/colors_spec.dart';
import '../../provider/unified_image_provider.dart';
import '../responsive_constants.dart';

/// SmartImage V2 - Utilise le UnifiedImageManager
class SmartImageV2 extends ConsumerStatefulWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final IconData? fallbackIcon;
  final Color? fallbackColor;
  final ResponsiveImageSize? responsiveSize;
  final bool autoPreload;
  final bool enableShimmer;
  final Duration fadeDuration;
  final Color? color;
  final BlendMode? colorBlendMode;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  const SmartImageV2({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallbackIcon,
    this.fallbackColor,
    this.responsiveSize,
    this.autoPreload = true,
    this.enableShimmer = true,
    this.fadeDuration = const Duration(milliseconds: 400),
    this.color,
    this.colorBlendMode,
    this.borderRadius,
    this.border,
    this.boxShadow,
  });

  @override
  ConsumerState<SmartImageV2> createState() => _SmartImageV2State();
}

class _SmartImageV2State extends ConsumerState<SmartImageV2> {
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(covariant SmartImageV2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.path != oldWidget.path) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (!widget.autoPreload) {
      setState(() => _isLoading = false);
      return;
    }

    final manager = ref.read(unifiedImageManagerProvider);

    try {
      final success = await manager.preloadImage(
        widget.path,
        context: context,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = !success;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double? finalWidth = widget.width;
    double? finalHeight = widget.height;

    if (widget.responsiveSize != null) {
      final constants = ref.watch(responsiveConstantsProvider);
      final size = _getResponsiveSize(constants, widget.responsiveSize!);
      finalWidth ??= size;
      finalHeight ??= size;
    }

    final borderRadius = widget.borderRadius ?? BorderRadius.circular(12);
    final boxDecoration = BoxDecoration(
      borderRadius: borderRadius,
      border: widget.border,
      boxShadow: widget.boxShadow,
    );

    Widget child;

    if (_hasError) {
      child = _buildFallback(finalWidth, finalHeight);
    } else if (_isLoading && widget.enableShimmer) {
      child = _buildShimmer(finalWidth, finalHeight);
    } else {
      child = _buildCachedImage(finalWidth, finalHeight);
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        decoration: boxDecoration.copyWith(boxShadow: null),
        child: AnimatedSwitcher(
          duration: widget.fadeDuration,
          child: child,
        ),
      ),
    );
  }

  Widget _buildCachedImage(double? w, double? h) {
    final manager = ref.watch(unifiedImageManagerProvider);
    final isSvg = widget.path.toLowerCase().endsWith('.svg');

    if (isSvg) {
      final cachedSvg = manager.getCachedSvg(widget.path);
      if (cachedSvg != null) {
        return SizedBox(
          width: w,
          height: h,
          child: CustomPaint(
            painter: _SvgPainter(cachedSvg, widget.fit),
          ),
        );
      }

      // Fallback SVG si pas en cache
      return SvgPicture.asset(
        widget.path,
        width: w,
        height: h,
        fit: widget.fit,
        colorFilter: (widget.color != null && widget.colorBlendMode != null)
            ? ColorFilter.mode(widget.color!, widget.colorBlendMode!)
            : null,
        placeholderBuilder: (_) => _buildShimmer(w, h),
      );
    }

    // Image raster
    final cachedImage = manager.getCachedImage(widget.path);
    if (cachedImage != null) {
      return Image(
        image: cachedImage,
        width: w,
        height: h,
        fit: widget.fit,
        color: widget.color,
        colorBlendMode: widget.colorBlendMode,
        errorBuilder: (_, __, ___) => _buildFallback(w, h),
      );
    }

    // Fallback si pas en cache
    final isNetwork = widget.path.startsWith('http');
    final provider = isNetwork
        ? NetworkImage(widget.path)
        : AssetImage(widget.path) as ImageProvider;

    return Image(
      image: provider,
      width: w,
      height: h,
      fit: widget.fit,
      color: widget.color,
      colorBlendMode: widget.colorBlendMode,
      errorBuilder: (_, __, ___) => _buildFallback(w, h),
    );
  }

  Widget _buildShimmer(double? w, double? h) {
    final baseColor = Colors.grey.withValues(alpha: 0.2);
    final highlightColor = Colors.grey.withValues(alpha: 0.4);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: w ?? 100,
        height: h ?? 100,
        color: baseColor,
      ),
    );
  }

  Widget _buildFallback(double? w, double? h) {
    final color = ColorHelpers.createHarmoniousPalette(
      widget.fallbackColor ?? Theme.of(context).colorScheme.primary,
    );

    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.first, color.last],
        ),
      ),
      child: Icon(
        widget.fallbackIcon ?? Icons.broken_image_outlined,
        color: Colors.white.withValues(alpha: 0.7),
        size: (w ?? 100) * 0.4,
      ),
    );
  }

  double _getResponsiveSize(
    ResponsiveConstants constants,
    ResponsiveImageSize size,
  ) {
    return switch (size) {
      ResponsiveImageSize.small => constants.avatarS,
      ResponsiveImageSize.medium => constants.avatarM,
      ResponsiveImageSize.large => constants.avatarL,
      ResponsiveImageSize.xlarge => constants.avatarXL,
    };
  }
}

/// Painter pour les SVG avec BoxFit
class _SvgPainter extends CustomPainter {
  final PictureInfo pictureInfo;
  final BoxFit fit;

  _SvgPainter(this.pictureInfo, this.fit);

  @override
  void paint(Canvas canvas, Size size) {
    final pictureSize = pictureInfo.size;

    // Calculer le scaling selon BoxFit
    double scaleX = size.width / pictureSize.width;
    double scaleY = size.height / pictureSize.height;
    double scale;

    switch (fit) {
      case BoxFit.contain:
        scale = scaleX < scaleY ? scaleX : scaleY;
        break;
      case BoxFit.cover:
        scale = scaleX > scaleY ? scaleX : scaleY;
        break;
      case BoxFit.fill:
        canvas.save();
        canvas.scale(scaleX, scaleY);
        canvas.drawPicture(pictureInfo.picture);
        canvas.restore();
        return;
      case BoxFit.fitWidth:
        scale = scaleX;
        break;
      case BoxFit.fitHeight:
        scale = scaleY;
        break;
      case BoxFit.none:
        scale = 1.0;
        break;
      case BoxFit.scaleDown:
        scale = scaleX < scaleY ? scaleX : scaleY;
        scale = scale > 1.0 ? 1.0 : scale;
        break;
    }

    canvas.save();

    // Centrer l'image
    final scaledWidth = pictureSize.width * scale;
    final scaledHeight = pictureSize.height * scale;
    final dx = (size.width - scaledWidth) / 2;
    final dy = (size.height - scaledHeight) / 2;

    canvas.translate(dx, dy);
    canvas.scale(scale);
    canvas.drawPicture(pictureInfo.picture);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SvgPainter oldDelegate) {
    return oldDelegate.pictureInfo != pictureInfo || oldDelegate.fit != fit;
  }
}

// ============================================================================
// HELPERS & EXTENSIONS
// ============================================================================

/// Extension pour précharger facilement des images
extension ImagePreloadExtension on WidgetRef {
  Future<void> preloadImages(
    List<String> paths, {
    BuildContext? context,
  }) async {
    final manager = read(unifiedImageManagerProvider);
    await manager.preloadBatch(paths, context: context);
  }

  Future<void> preloadCriticalImages(BuildContext context) async {
    final notifier = read(preloadNotifierProvider.notifier);
    await notifier.preloadCriticalImages(context);
  }
}

/// Widget helper pour précharger au démarrage
class ImagePreloader extends ConsumerWidget {
  final Widget child;
  final List<String> paths;
  final bool showProgress;

  const ImagePreloader({
    super.key,
    required this.child,
    required this.paths,
    this.showProgress = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preloadState = ref.watch(preloadNotifierProvider);

    return preloadState.when(
      data: (_) => child,
      loading: () {
        if (showProgress) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Chargement des ressources...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          );
        }
        return child;
      },
      error: (_, __) => child,
    );
  }
}
