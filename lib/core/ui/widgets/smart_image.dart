import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

import '../../affichage/colors_spec.dart';
import '../../provider/unified_image_provider.dart';
import '../../service/unified_image_manager.dart';
import '../responsive_constants.dart';

// ---------------------------------------------------------------------------
// Types partagés
// ---------------------------------------------------------------------------

enum ResponsiveImageSize { small, medium, large, xlarge }

/// Placeholder transparent 1×1 px — évite un flash blanc lors des transitions.
const List<int> kTransparentImage = [
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0xF8,
  0xCF,
  0x00,
  0x00,
  0x02,
  0x0C,
  0x01,
  0x01,
  0xA2,
  0xA5,
  0x3D,
  0x1D,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
];

final Uint8List transparentImage = Uint8List.fromList(kTransparentImage);

// ---------------------------------------------------------------------------
// SvgPainter — source canonique unique dans tout le projet
// ---------------------------------------------------------------------------

/// [CustomPainter] pour les SVG avec support complet de [BoxFit].
///
/// Utilisé par [SmartImage] et [CachedImage] ; ne pas dupliquer ailleurs.
class SvgPainter extends CustomPainter {
  final PictureInfo pictureInfo;
  final BoxFit fit;

  const SvgPainter(this.pictureInfo, this.fit);

  @override
  void paint(Canvas canvas, Size size) {
    final ps = pictureInfo.size;
    if (ps.width == 0 || ps.height == 0) return;

    final scaleX = size.width / ps.width;
    final scaleY = size.height / ps.height;

    canvas.save();
    switch (fit) {
      case BoxFit.fill:
        canvas.scale(scaleX, scaleY);
      case BoxFit.cover:
        _applyScale(canvas, size, ps, scaleX > scaleY ? scaleX : scaleY);
      case BoxFit.fitWidth:
        _applyScale(canvas, size, ps, scaleX);
      case BoxFit.fitHeight:
        _applyScale(canvas, size, ps, scaleY);
      case BoxFit.none:
        _applyScale(canvas, size, ps, 1.0);
      case BoxFit.scaleDown:
        _applyScale(
            canvas, size, ps, (scaleX < scaleY ? scaleX : scaleY).clamp(0, 1));
      case BoxFit.contain:
      default:
        _applyScale(canvas, size, ps, scaleX < scaleY ? scaleX : scaleY);
    }
    canvas.drawPicture(pictureInfo.picture);
    canvas.restore();
  }

  void _applyScale(Canvas c, Size box, Size pic, double scale) {
    c.translate(
      (box.width - pic.width * scale) / 2,
      (box.height - pic.height * scale) / 2,
    );
    c.scale(scale);
  }

  @override
  bool shouldRepaint(SvgPainter old) =>
      old.pictureInfo != pictureInfo || old.fit != fit;
}

/// Widget image universel : PNG / JPG / WEBP / SVG, local ou réseau.
///
/// - Préchargement transparent via [UnifiedImageManager]
/// - Shimmer pendant le chargement
/// - Fallback gradient + icône en cas d'erreur
/// - Tailles responsives via [ResponsiveImageSize]
/// - BorderRadius, border, boxShadow, BoxFit complets
class SmartImage extends ConsumerStatefulWidget {
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

  const SmartImage({
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
  ConsumerState<SmartImage> createState() => _SmartImageState();
}

class _SmartImageState extends ConsumerState<SmartImage> {
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(covariant SmartImage old) {
    super.didUpdateWidget(old);
    if (widget.path != old.path) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (!widget.autoPreload) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    final manager = ref.read(unifiedImageManagerProvider);
    try {
      final success = await manager.preloadImage(widget.path, context: context);
      if (mounted)
        setState(() {
          _isLoading = false;
          _hasError = !success;
        });
    } catch (_) {
      if (mounted)
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    double? w = widget.width;
    double? h = widget.height;

    if (widget.responsiveSize != null) {
      final c = ref.watch(responsiveConstantsProvider);
      final s = _resolveSize(c, widget.responsiveSize!);
      w ??= s;
      h ??= s;
    }

    final radius = widget.borderRadius ?? BorderRadius.circular(12);

    final child = _hasError
        ? _buildFallback(w, h)
        : (_isLoading && widget.enableShimmer)
            ? _buildShimmer(w, h)
            : _buildImage(w, h);

    return ClipRRect(
      borderRadius: radius,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          border: widget.border,
          boxShadow: widget.boxShadow,
        ),
        child: AnimatedSwitcher(duration: widget.fadeDuration, child: child),
      ),
    );
  }

  Widget _buildImage(double? w, double? h) {
    final manager = ref.watch(unifiedImageManagerProvider);
    final isSvg = widget.path.toLowerCase().endsWith('.svg');

    if (isSvg) {
      final cached = manager.getCachedSvg(widget.path);
      if (cached != null) {
        return SizedBox(
          width: w,
          height: h,
          child: CustomPaint(painter: SvgPainter(cached, widget.fit)),
        );
      }
      // SVG pas encore en cache (chargement en cours) → direct Flutter SVG
      return SvgPicture.asset(
        widget.path,
        width: w,
        height: h,
        fit: widget.fit,
        colorFilter: _colorFilter,
        placeholderBuilder: (_) => _buildShimmer(w, h),
      );
    }

    final cached = manager.getCachedImage(widget.path);
    final provider = cached ??
        (widget.path.startsWith('http')
            ? NetworkImage(widget.path)
            : AssetImage(widget.path) as ImageProvider);

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
    final base = Colors.grey.withValues(alpha: 0.2);
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: Colors.grey.withValues(alpha: 0.4),
      child: Container(width: w ?? 100, height: h ?? 100, color: base),
    );
  }

  Widget _buildFallback(double? w, double? h) {
    final palette = ColorHelpers.createHarmoniousPalette(
      widget.fallbackColor ?? Theme.of(context).colorScheme.primary,
    );
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.first, palette.last],
        ),
      ),
      child: Icon(
        widget.fallbackIcon ?? Icons.broken_image_outlined,
        color: Colors.white.withValues(alpha: 0.7),
        size: (w ?? 100) * 0.4,
      ),
    );
  }

  ColorFilter? get _colorFilter =>
      (widget.color != null && widget.colorBlendMode != null)
          ? ColorFilter.mode(widget.color!, widget.colorBlendMode!)
          : null;

  double _resolveSize(ResponsiveConstants c, ResponsiveImageSize s) =>
      switch (s) {
        ResponsiveImageSize.small => c.avatarS,
        ResponsiveImageSize.medium => c.avatarM,
        ResponsiveImageSize.large => c.avatarL,
        ResponsiveImageSize.xlarge => c.avatarXL,
      };
}
