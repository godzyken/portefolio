import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/device_spec.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/provider/unified_image_provider.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';
import 'package:portefolio/features/generator/views/generator_widgets_extentions.dart';
import 'package:portefolio/features/projets/providers/projects_extentions_providers.dart';

import '../../data/project_data.dart';

class DraggableBubble extends ConsumerStatefulWidget {
  final ProjectInfo project;
  final bool isSelected;
  final Offset initialOffset;
  final ValueChanged<Offset> onPositionChanged;
  final double rotationAngle;
  final VoidCallback? onToggleExpand;

  const DraggableBubble({
    super.key,
    required this.project,
    required this.isSelected,
    required this.initialOffset,
    required this.onPositionChanged,
    this.rotationAngle = 0.0,
    this.onToggleExpand,
  });

  @override
  ConsumerState<DraggableBubble> createState() => _DraggableBubbleState();
}

class _DraggableBubbleState extends ConsumerState<DraggableBubble>
    with TickerProviderStateMixin {
  late Offset offset;
  late AnimationController _expandCtrl;
  late Animation<double> _expandAnim;
  late AnimationController _centerCtrl;
  late Animation<double> _centerAnim;

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

    _centerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _centerAnim = CurvedAnimation(
      parent: _centerCtrl,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _expandCtrl.dispose();
    _centerCtrl.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      isExpanded = !isExpanded;
      if (isExpanded) {
        _expandCtrl.forward();
        _centerCtrl.forward();
      } else {
        _expandCtrl.reverse();
        _centerCtrl.reverse();
      }
    });
    widget.onToggleExpand?.call();
  }

  void _toggleSelection() {
    ref.read(selectedProjectsProvider.notifier).toggle(widget.project);
  }

  void _openImmersiveDetail() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ImmersiveDetailScreen(project: widget.project),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(responsiveInfoProvider);
    final deviceSpec = _getDeviceSpec();
    final screenSize = info.size;
    final selectedProjects = ref.watch(selectedProjectsProvider);
    final isSelected = selectedProjects.any((p) => p.id == widget.project.id);

    return AnimatedBuilder(
      animation: Listenable.merge([_expandAnim, _centerAnim]),
      builder: (context, child) {
        final expandValue = _expandAnim.value;
        final centerValue = _centerAnim.value;
        final scale = 1.0 + (expandValue * 0.8);
        final rotation = lerpDouble(widget.rotationAngle, 0.0, centerValue)!;

        final targetOffset = Offset(
          (screenSize.width - deviceSpec.size.width) / 2,
          (screenSize.height - deviceSpec.size.height) / 2,
        );

        final currentOffset = centerValue == 0
            ? offset
            : Offset.lerp(offset, targetOffset, centerValue)!;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: currentOffset.dx,
              top: currentOffset.dy,
              child: Transform.rotate(
                angle: rotation,
                alignment: Alignment.center,
                child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.center,
                  child: MouseRegion(
                    onEnter: (_) => setState(() => isHovered = true),
                    onExit: (_) => setState(() => isHovered = false),
                    child: GestureDetector(
                      onTap: _toggleExpand,
                      onLongPress: _toggleSelection,
                      onPanStart: (_) => setState(() => isDragging = true),
                      onPanEnd: (_) => setState(() => isDragging = false),
                      onPanUpdate: (details) {
                        if (isExpanded) return;
                        setState(() {
                          Offset delta = details.delta;
                          final double angle = widget.rotationAngle;
                          final double cosAn = math.cos(angle);
                          final double sinAn = math.sin(angle);
                          Offset correctedDelta = Offset(
                            delta.dx * cosAn - delta.dy * sinAn,
                            delta.dx * sinAn + delta.dy * cosAn,
                          );
                          Offset newOffset = offset + correctedDelta;
                          final bubbleSize = _getDeviceSpec().size;
                          double clampedX = newOffset.dx
                              .clamp(0.0, screenSize.width - bubbleSize.width);
                          double clampedY = newOffset.dy.clamp(
                              0.0, screenSize.height - bubbleSize.height);
                          offset = Offset(clampedX, clampedY);
                        });
                        widget.onPositionChanged(offset);
                      },
                      child: SizedBox(
                        child: Stack(
                          children: [
                            _buildDevice(deviceSpec, isSelected),
                            if (isExpanded) _buildDetailsOverlay(deviceSpec),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDevice(DeviceSpec spec, bool isSelected) {
    final images = widget.project.cleanedImages ?? [];
    final hasImages = images.isNotEmpty;

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
          if (isSelected)
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.4),
              blurRadius: 20,
              spreadRadius: 4,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Stack(
        children: [
          // Corps du device
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
              ),
            ),
          ),

          // Image ou fond vide
          if (hasImages)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: spec.screenRadius,
                child: images.length > 1
                    ? PageView(
                        children: images
                            .map((img) =>
                                CachedImage(path: img, fit: BoxFit.cover))
                            .toList(),
                      )
                    : CachedImage(path: images.first, fit: BoxFit.cover),
              ),
            )
          else
            Positioned.fill(
              child: Container(
                color: Colors.black87,
                child: Center(
                  child: Icon(
                    spec.icon,
                    size: spec.size.width * 0.25,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
              ),
            ),

          // Détails du device (caméra, boutons, etc.)
          ...spec.buildDeviceDetails(widget.project),

          // ── Badge titre minimaliste (bas du device) ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _TitleBadge(title: widget.project.title),
          ),

          // Badge sélection
          if (isSelected)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailsOverlay(DeviceSpec spec) {
    return Positioned(
      bottom: 2,
      left: 3,
      right: 3,
      child: FadeTransition(
        opacity: _expandAnim,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 1),
            child: ResponsiveBox(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.project.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: _openImmersiveDetail,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.open_in_new,
                            color: Colors.blueAccent,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (widget.project.tags != null) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 20,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: widget.project.tags!.take(4).length,
                        separatorBuilder: (_, __) => const SizedBox(width: 6),
                        itemBuilder: (context, index) {
                          return ThreeDTechIcon(
                            logoPath: widget.project.tags![index],
                            color: Colors.blueAccent,
                            size: 18,
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
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

// ─────────────────────────────────────────────────────────────
// Badge titre minimaliste en bas du device
// ─────────────────────────────────────────────────────────────
class _TitleBadge extends StatelessWidget {
  final String title;

  const _TitleBadge({required this.title});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.75),
              ],
            ),
          ),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
