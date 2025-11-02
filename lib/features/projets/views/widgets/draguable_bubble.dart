import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/widgets/ui_widgets_extentions.dart';
import 'package:portefolio/features/generator/views/widgets/generator_widgets_extentions.dart';
import 'package:portefolio/features/projets/views/widgets/project_card.dart';

import '../../data/project_data.dart';

class DraggableBubble extends ConsumerStatefulWidget {
  final ProjectInfo project;
  final bool isSelected;
  final Offset initialOffset;
  final ValueChanged<Offset> onPositionChanged;
  final double rotationAngle;

  const DraggableBubble({
    super.key,
    required this.project,
    required this.isSelected,
    required this.initialOffset,
    required this.onPositionChanged,
    this.rotationAngle = 0.0,
  });

  @override
  ConsumerState<DraggableBubble> createState() => _DraggableBubbleState();
}

class _DraggableBubbleState extends ConsumerState<DraggableBubble>
    with TickerProviderStateMixin {
  late Offset offset;
  late AnimationController _expandCtrl;
  late Animation<double> _expandAnim;

  bool isDragging = false;
  bool isHovered = false;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    offset = widget.initialOffset;

    _expandCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _expandAnim = CurvedAnimation(
      parent: _expandCtrl,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _expandCtrl.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      isExpanded = !isExpanded;
      if (isExpanded) {
        _expandCtrl.forward();
      } else {
        _expandCtrl.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(responsiveInfoProvider);
    final deviceSpec = _getDeviceSpec();
    final canExpand = info.size.width > 900;

    final expandScale = isExpanded ? 2.2 : 1.0;
    final currentSize = Size(
      deviceSpec.size.width * expandScale,
      deviceSpec.size.height * expandScale,
    );

    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: MouseRegion(
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: GestureDetector(
          onTap: canExpand ? _toggleExpand : _showProjectDialog,
          onPanStart: (_) => setState(() => isDragging = true),
          onPanEnd: (_) => setState(() => isDragging = false),
          onPanUpdate: (details) {
            final newOffset = offset + details.delta;
            final clamped = Offset(
              newOffset.dx.clamp(0.0, info.size.width - currentSize.width),
              newOffset.dy.clamp(0.0, info.size.height - currentSize.height),
            );
            setState(() => offset = clamped);
            widget.onPositionChanged(clamped);
          },
          child: AnimatedBuilder(
            animation: _expandAnim,
            builder: (context, child) {
              // ✅ Pas d'animation flottante automatique
              // ✅ Animation uniquement au hover et drag
              final hoverScale = isHovered && !isDragging ? 1.08 : 1.0;
              final dragScale = isDragging ? 1.15 : 1.0;
              final finalScale =
                  (hoverScale * dragScale) * (1.0 + _expandAnim.value * 1.2);

              return Transform.scale(
                scale: finalScale,
                child: Transform.rotate(
                  angle: widget.rotationAngle,
                  child: _buildDevice(deviceSpec, canExpand),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ✅ Afficher le dialog au clic sur mobile
  void _showProjectDialog() {
    final info = ref.read(responsiveInfoProvider);
    final deviceSpec = _getDeviceSpec();
    final screenWidth = deviceSpec.size.width - 2 * deviceSpec.bezelSize;
    final screenHeight = deviceSpec.size.height - 2 * deviceSpec.bezelSize;

    final dialogMaxWidth = math.min(info.size.width * 0.92, screenWidth * 2.4);
    final dialogMaxHeight =
        math.min(info.size.height * 0.86, screenHeight * 2.4);

    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: dialogMaxWidth,
            maxHeight: dialogMaxHeight,
          ),
          child: ResponsiveBox(
            width: dialogMaxWidth,
            height: dialogMaxHeight,
            child: ProjectCard(
              project: widget.project,
              width: dialogMaxWidth,
              height: dialogMaxHeight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDevice(DeviceSpec spec, bool canExpand) {
    final isPortrait = spec.size.height >= spec.size.width;
    final screenWidth = isPortrait
        ? spec.size.width - 2 * spec.bezelSize
        : spec.size.height - 2 * spec.bezelSize;
    final screenHeight = isPortrait
        ? spec.size.height - 2 * spec.bezelSize
        : spec.size.width - 2 * spec.bezelSize;
    return ResponsiveBox(
      width: spec.size.width,
      height: spec.size.height,
      decoration: BoxDecoration(
        borderRadius: spec.borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDragging ? 0.6 : 0.4),
            blurRadius: isDragging ? 40 : 25,
            spreadRadius: isDragging ? 8 : 3,
            offset: Offset(0, isDragging ? 20 : 12),
          ),
          if (widget.isSelected)
            BoxShadow(
              color: spec.accentColor.withValues(alpha: 0.6),
              blurRadius: 25,
              spreadRadius: 5,
            ),
          if (isHovered && !widget.isSelected)
            BoxShadow(
              color: spec.accentColor.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 3,
            ),
        ],
      ),
      child: Stack(
        children: [
          ResponsiveBox(
            decoration: BoxDecoration(
              borderRadius: spec.borderRadius,
              border: Border.all(
                color: spec.frameColor,
                width: spec.frameWidth,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  spec.bodyColor,
                  spec.bodyColor.withValues(alpha: 0.85),
                  spec.bodyColor.withValues(alpha: 0.7),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          Positioned.fill(
            child: ResponsiveBox(
              decoration: BoxDecoration(
                borderRadius: spec.borderRadius,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.center,
                  colors: [
                    Colors.white.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          ResponsiveBox(
            padding: EdgeInsets.all(spec.bezelSize),
            paddingSize: ResponsiveSpacing.m,
            child: isExpanded
                ? SingleChildScrollView(
                    child: ResponsiveBox(
                      width: screenWidth,
                      height: screenHeight,
                      child: MinimalCard(
                        project: widget.project,
                      ),
                    ),
                  )
                : ClipRRect(
                    borderRadius: spec.screenRadius,
                    child: _buildScreen(spec),
                  ),
          ),
          ...spec.buildDeviceDetails(widget.project),
          if (widget.isSelected)
            Positioned(
              top: spec.bezelSize / 2,
              right: spec.bezelSize / 2,
              child: TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 400),
                curve: Curves.elasticOut,
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: ResponsiveBox(
                      padding: const EdgeInsets.all(6),
                      paddingSize: ResponsiveSpacing.xs,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.6),
                            blurRadius: 12,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScreen(DeviceSpec spec) {
    final screenWidth = spec.size.width - 2 * spec.bezelSize;
    final screenHeight = spec.size.height - 2 * spec.bezelSize;

    final images = widget.project.cleanedImages ?? [];
    final hasImages = images.isNotEmpty;

    if (!hasImages) {
      // Pas d’images → icône par défaut
      return Container(
        width: screenWidth,
        height: screenHeight,
        color: Colors.black87,
        child: Center(
          child: Icon(
            spec.icon,
            size: screenWidth * 0.25,
            color: Colors.white.withValues(alpha: 0.2),
          ),
        ),
      );
    }

    final screenContent = images.length > 1
        ? PageView(
            children: images
                .map((img) => SmartImage(
                      path: img,
                      fit: BoxFit.cover,
                      width: screenWidth,
                      height: screenHeight,
                    ))
                .toList(),
          )
        : SmartImage(
            path: images.first,
            fit: BoxFit.cover,
            width: screenWidth,
            height: screenHeight,
          );

    // clickable vers ProjectCard
    return InkWell(
      onTap: () {
        final mq = MediaQuery.of(context);
        // dialog size limited to viewport and related to device screen
        final dialogMaxWidth =
            math.min(mq.size.width * 0.92, screenWidth * 2.4);
        final dialogMaxHeight =
            math.min(mq.size.height * 0.86, screenHeight * 2.4);

        showDialog(
          context: context,
          builder: (_) => Dialog(
            insetPadding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: dialogMaxWidth,
                maxHeight: dialogMaxHeight,
              ),
              child: ResponsiveBox(
                width: dialogMaxWidth,
                height: dialogMaxHeight,
                key: ValueKey(
                    'project_card_${widget.project.id}_${DateTime.now().millisecondsSinceEpoch}'),
                child: MinimalCard(project: widget.project),
              ),
            ),
          ),
        );
      },
      child: SizedBox(
        width: screenWidth,
        height: screenHeight,
        child: screenContent,
      ),
    );
  }

  DeviceSpec _getDeviceSpec() {
    final platforms =
        widget.project.platform?.map((e) => e.toLowerCase()).toList() ?? [];
    if (platforms.contains('watch')) return DeviceSpec.watch();
    if (platforms.contains('smartphone')) return DeviceSpec.smartphone();
    if (platforms.contains('tablet')) return DeviceSpec.tablet();
    if (platforms.contains('desktop')) return DeviceSpec.desktop();
    if (platforms.contains('largedesktop')) return DeviceSpec.largeDesktop();
    return DeviceSpec.smartphone();
  }
}

// ============================================================================
// DEVICE SPECIFICATIONS
// ============================================================================

class DeviceSpec {
  final Size size;
  final BorderRadius borderRadius;
  final BorderRadius screenRadius;
  final Color bodyColor;
  final Color frameColor;
  final Color accentColor;
  final double frameWidth;
  final double bezelSize;
  final IconData icon;

  const DeviceSpec({
    required this.size,
    required this.borderRadius,
    required this.screenRadius,
    required this.bodyColor,
    required this.frameColor,
    required this.accentColor,
    required this.frameWidth,
    required this.bezelSize,
    required this.icon,
  });

  factory DeviceSpec.watch() => DeviceSpec(
        size: const Size(90, 90),
        borderRadius: BorderRadius.circular(22),
        screenRadius: BorderRadius.circular(18),
        bodyColor: const Color(0xFF1a1a1a),
        frameColor: const Color(0xFF0d0d0d),
        accentColor: const Color(0xFF00d4ff),
        frameWidth: 4,
        bezelSize: 8,
        icon: Icons.watch,
      );

  factory DeviceSpec.smartphone() => DeviceSpec(
        size: const Size(110, 220),
        borderRadius: BorderRadius.circular(28),
        screenRadius: BorderRadius.circular(24),
        bodyColor: const Color(0xFF0a0a0a),
        frameColor: const Color(0xFF050505),
        accentColor: const Color(0xFF00ff88),
        frameWidth: 3,
        bezelSize: 5,
        icon: Icons.phone_android,
      );

  factory DeviceSpec.tablet() => DeviceSpec(
        size: const Size(160, 220),
        borderRadius: BorderRadius.circular(24),
        screenRadius: BorderRadius.circular(20),
        bodyColor: const Color(0xFF1f1f1f),
        frameColor: const Color(0xFF0f0f0f),
        accentColor: const Color(0xFFa855f7),
        frameWidth: 4,
        bezelSize: 10,
        icon: Icons.tablet_android,
      );

  factory DeviceSpec.desktop() => DeviceSpec(
        size: const Size(240, 150),
        borderRadius: BorderRadius.circular(16),
        screenRadius: BorderRadius.circular(12),
        bodyColor: const Color(0xFF2a2a2a),
        frameColor: const Color(0xFF0a0a0a),
        accentColor: const Color(0xFFfb923c),
        frameWidth: 5,
        bezelSize: 14,
        icon: Icons.computer,
      );

  factory DeviceSpec.largeDesktop() => DeviceSpec(
        size: const Size(300, 180),
        borderRadius: BorderRadius.circular(20),
        screenRadius: BorderRadius.circular(16),
        bodyColor: const Color(0xFF1a1a1a),
        frameColor: const Color(0xFF000000),
        accentColor: const Color(0xFFef4444),
        frameWidth: 6,
        bezelSize: 16,
        icon: Icons.desktop_windows,
      );

  List<Widget> buildDeviceDetails(ProjectInfo project) {
    if (icon == Icons.watch) {
      return [
        Positioned(
          right: -4,
          top: size.height * 0.35,
          child: ResponsiveBox(
            width: 10,
            height: 24,
            decoration: BoxDecoration(
              color: frameColor,
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(6),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 4,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: bezelSize + 10,
          left: size.width / 2 - 8,
          child: ResponsiveBox(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.green.shade700.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.green.shade800, width: 2),
            ),
          ),
        ),
      ];
    } else if (icon == Icons.phone_android) {
      return [
        Positioned(
          top: 0,
          left: size.width / 2 - 25,
          child: ResponsiveBox(
            width: 50,
            height: bezelSize - 1,
            decoration: BoxDecoration(
              color: frameColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ResponsiveBox(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.only(right: 8),
                  marginSize: ResponsiveSpacing.xs,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    shape: BoxShape.circle,
                  ),
                ),
                ResponsiveBox(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ];
    } else if (icon == Icons.tablet_android) {
      return [
        Positioned(
          top: bezelSize / 2 - 3,
          left: size.width / 2 - 3,
          child: ResponsiveBox(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ];
    } else if (icon == Icons.computer || icon == Icons.desktop_windows) {
      final isLarge = icon == Icons.desktop_windows;
      return [
        Positioned(
          top: bezelSize / 2 - 2,
          left: size.width / 2 - 3,
          child: ResponsiveBox(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: -20,
          left: size.width / 2 - (isLarge ? 35 : 25),
          child: ResponsiveBox(
            width: isLarge ? 70 : 50,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: -36,
          left: size.width / 2 - (isLarge ? 20 : 14),
          child: ResponsiveBox(
            width: isLarge ? 40 : 28,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ];
    }
    return [];
  }
}
