import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:portefolio/core/affichage/colors_spec.dart';
import 'package:portefolio/core/provider/smart_image_cache_provider.dart';
import 'package:shimmer/shimmer.dart';

import '../responsive_constants.dart';

enum ResponsiveImageSize { small, medium, large, xlarge }

// Transparent pixel placeholder
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

class SmartImage extends ConsumerStatefulWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final IconData? fallbackIcon;
  final Color? fallbackColor;
  final ResponsiveImageSize? responsiveSize;
  final bool useCache;
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
    this.useCache = true,
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
  ImageProvider? _imageProvider;
  bool _hasError = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isSvg = widget.path.toLowerCase().endsWith('.svg');

    if (widget.useCache && !isSvg) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        try {
          final cacheNotifier =
              ref.read(smartImageCacheNotifierProvider.notifier);
          cacheNotifier.setContext(context);
          cacheNotifier.preloadImage(widget.path, context);
        } catch (e) {
          debugPrint('❌ SmartImage precache suppressed: ${widget.path}');
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant SmartImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final isSvg = widget.path.toLowerCase().endsWith('.svg');
    if (widget.path != oldWidget.path && widget.useCache && !isSvg) {
      final cacheNotifier = ref.read(smartImageCacheNotifierProvider.notifier);
      cacheNotifier.preloadImage(widget.path, context);
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

    // Détecte le type d'image
    final isSvg = widget.path.toLowerCase().endsWith('.svg');
    final isNetwork = widget.path.startsWith('http');
    final useShimmer = widget.enableShimmer;

    Widget child;

    if (_hasError) {
      child = _buildFallback(finalWidth, finalHeight);
    } else if (isSvg) {
      child = _buildSvg(finalWidth, finalHeight, isNetwork);
    } else if (isNetwork) {
      child = _buildNetworkImage(finalWidth, finalHeight, useShimmer);
    } else {
      child = _buildAssetImage(finalWidth, finalHeight);
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        decoration: boxDecoration.copyWith(boxShadow: null),
        child: child,
      ),
    );
  }

  double _getResponsiveSize(
      ResponsiveConstants constants, ResponsiveImageSize size) {
    return switch (size) {
      ResponsiveImageSize.small => constants.avatarS,
      ResponsiveImageSize.medium => constants.avatarM,
      ResponsiveImageSize.large => constants.avatarL,
      ResponsiveImageSize.xlarge => constants.avatarXL,
    };
  }

  Widget _buildFallback(double? w, double? h) {
    final color = ColorHelpers.createHarmoniousPalette(
        widget.fallbackColor ?? Theme.of(context).colorScheme.primary);
    return Shimmer.fromColors(
        baseColor: color.first,
        highlightColor: color.last,
        direction: ShimmerDirection.ttb,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.8, end: 1.2),
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOut,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Container(
                width: w,
                height: h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  borderRadius:
                      widget.borderRadius ?? BorderRadius.circular(12),
                  gradient: ColorHelpers.bgGradient,
                ),
                child: Icon(
                  widget.fallbackIcon ?? Icons.broken_image_outlined,
                  color: ColorHelpers.errorColor,
                  size: (w ?? 100) * 0.4,
                ),
              ),
            );
          },
          onEnd: () => setState(() {}),
        ));
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

  Widget _buildAssetImage(double? w, double? h) {
    _imageProvider ??= AssetImage(widget.path);
    return FadeInImage(
      placeholder: MemoryImage(transparentImage),
      image: _imageProvider!,
      width: w,
      height: h,
      fit: widget.fit,
      fadeInDuration: widget.fadeDuration,
      imageErrorBuilder: (_, __, ___) => _buildFallback(w, h),
    );
  }

  Widget _buildNetworkImage(double? w, double? h, bool shimmer) {
    _imageProvider ??= NetworkImage(widget.path);
    return Image(
      image: _imageProvider!,
      width: w,
      height: h,
      fit: widget.fit,
      color: widget.color,
      colorBlendMode: widget.colorBlendMode,
      frameBuilder: (context, child, frame, _) {
        if (frame == null && shimmer) return _buildShimmer(w, h);
        return AnimatedOpacity(
            opacity: 1, duration: widget.fadeDuration, child: child);
      },
      errorBuilder: (_, __, ___) => _buildFallback(w, h),
    );
  }

  Widget _buildSvg(double? w, double? h, bool isNetwork) {
    final builder = isNetwork ? SvgPicture.network : SvgPicture.asset;
    return builder(
      widget.path,
      width: w,
      height: h,
      fit: widget.fit,
      colorFilter: (widget.color != null && widget.colorBlendMode != null)
          ? ColorFilter.mode(widget.color!, widget.colorBlendMode!)
          : null,
      placeholderBuilder: (_) => widget.enableShimmer
          ? _buildShimmer(w, h)
          : SizedBox(width: w, height: h),
      errorBuilder: (_, __, ___) => _buildFallback(w, h),
    );
  }
}
