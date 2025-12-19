import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:portefolio/core/ui/widgets/responsive_text.dart';
import 'package:shimmer/shimmer.dart';

import '../responsive_constants.dart';

enum ResponsiveImageSize { small, medium, large, xlarge }

// 🔹 Transparent pixel
const kTransparentImage = <int>[
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

/// 🧠 Image universelle : responsive, stylée, avec cache, shimmer et fade
class SmartImage extends ConsumerStatefulWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final IconData? fallbackIcon;
  final Color? fallbackColor;
  final Duration? cacheTimeout;
  final ResponsiveImageSize? responsiveSize;
  final bool useCache;
  final bool enableShimmer;
  final Duration fadeDuration;
  final Color? color;
  final BlendMode? colorBlendMode;

  // 🎨 Nouveau : style visuel
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
    this.cacheTimeout = const Duration(days: 7),
    this.responsiveSize,
    this.useCache = false,
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
  ImageProvider? _cachedProvider;
  bool _hasError = false;
  bool _isLoading = false;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    if (widget.useCache) _loadImage();
  }

  @override
  void didUpdateWidget(SmartImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.useCache && oldWidget.path != widget.path) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    setState(() {
      _isLoading = true;
      _isLoaded = false;
    });

    try {
      final isNetwork = widget.path.startsWith('http');
      _cachedProvider = isNetwork
          ? NetworkImage(widget.path)
          : AssetImage(widget.path) as ImageProvider;

      await precacheImage(_cachedProvider!, context);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoaded = true;
          _hasError = false;
        });
      }
    } catch (e) {
      debugPrint('❌ SmartImage precache error: ${widget.path}, $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoaded = false;
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
      final size = _getImageSize(constants, widget.responsiveSize!);
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

    if (widget.useCache && _cachedProvider != null && !_hasError) {
      child = AnimatedOpacity(
        opacity: _isLoaded ? 1 : 0,
        duration: widget.fadeDuration,
        child: Image(
          image: _cachedProvider!,
          width: finalWidth,
          height: finalHeight,
          fit: widget.fit,
          color: widget.color,
          colorBlendMode: widget.colorBlendMode,
          errorBuilder: (context, _, __) =>
              _buildFallback(context, finalWidth, finalHeight),
        ),
      );
    } else if (widget.enableShimmer &&
        (widget.useCache && (_isLoading || !_isLoaded))) {
      child = _buildShimmerPlaceholder(finalWidth, finalHeight);
    } else {
      final isSvg = widget.path.toLowerCase().endsWith('.svg');
      final isNetwork = widget.path.startsWith('http');

      if (isSvg) {
        child = _buildSvgImage(context, finalWidth, finalHeight);
      } else if (isNetwork) {
        child = _buildNetworkImage(context, finalWidth, finalHeight);
      } else {
        child = _buildAssetImage(context, finalWidth, finalHeight);
      }
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        decoration: boxDecoration.copyWith(boxShadow: null),
        child: child,
      ),
    );
  }

  double _getImageSize(
      ResponsiveConstants constants, ResponsiveImageSize size) {
    return switch (size) {
      ResponsiveImageSize.small => constants.avatarS,
      ResponsiveImageSize.medium => constants.avatarM,
      ResponsiveImageSize.large => constants.avatarL,
      ResponsiveImageSize.xlarge => constants.avatarXL,
    };
  }

  Widget _buildNetworkImage(BuildContext context, double? w, double? h) {
    return Image.network(
      widget.path,
      width: w,
      height: h,
      fit: widget.fit,
      color: widget.color,
      colorBlendMode: widget.colorBlendMode,
      frameBuilder: (context, child, frame, _) {
        if (frame == null && widget.enableShimmer) {
          return _buildShimmerPlaceholder(w, h);
        }
        return AnimatedOpacity(
          opacity: 1,
          duration: widget.fadeDuration,
          child: child,
        );
      },
      errorBuilder: (_, __, ___) => _buildFallback(context, w, h),
    );
  }

  Widget _buildAssetImage(BuildContext context, double? w, double? h) {
    final cleanPath = widget.path.replaceFirst('assets/assets/', 'assets/');
    return FadeInImage(
      placeholder: MemoryImage(transparentImage),
      image: AssetImage(cleanPath),
      width: w,
      height: h,
      fit: widget.fit,
      fadeInDuration: widget.fadeDuration,
      imageErrorBuilder: (_, __, ___) => _buildFallback(context, w, h),
    );
  }

  Widget _buildShimmerPlaceholder(double? w, double? h) {
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

  Widget _buildFallback(BuildContext context, double? w, double? h) {
    final color = widget.fallbackColor ?? Theme.of(context).colorScheme.primary;
    return Container(
      width: w,
      height: h,
      color: color.withValues(alpha: 0.1),
      alignment: Alignment.center,
      child: Icon(
        widget.fallbackIcon ?? Icons.broken_image_outlined,
        color: color.withValues(alpha: 0.7),
        size: (w ?? 100) * 0.4,
      ),
    );
  }

  Widget _buildSvgImage(BuildContext context, double? w, double? h) {
    final isNetwork = widget.path.startsWith('http');
    final builder = isNetwork ? SvgPicture.network : SvgPicture.asset;
    return builder(
      widget.path,
      width: w,
      height: h,
      fit: widget.fit,
      colorFilter: widget.color != null
          ? ColorFilter.mode(widget.color!, widget.colorBlendMode!)
          : null,
      placeholderBuilder: (_) => widget.enableShimmer
          ? _buildShimmerPlaceholder(w, h)
          : ResponsiveBox(
              width: w,
              height: h,
            ),
      errorBuilder: (_, __, ___) => _buildFallback(context, w, h),
    );
  }
}
