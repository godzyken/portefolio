import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/device_spec.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/provider/unified_image_provider.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';

import '../../../generator/views/widgets/immersive_detail_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(responsiveInfoProvider);
    final deviceSpec = _getDeviceSpec();
    final screenSize = info.size;

    return AnimatedBuilder(
      animation: Listenable.merge([_expandAnim, _centerAnim]),
      builder: (context, child) {
        final expandValue = _expandAnim.value;
        final centerValue = _centerAnim.value;

        // Échelle élastique (rebond)
        final scale = 1.0 + (expandValue * 0.8);

        // Redressement progressif (rotation 0)
        final rotation = lerpDouble(widget.rotationAngle, 0.0, centerValue)!;

        // Déplacement vers le centre progressif
        final targetOffset = Offset(
          (screenSize.width - deviceSpec.size.width) / 2,
          (screenSize.height - deviceSpec.size.height) / 2,
        );

        final currentOffset = Offset.lerp(offset, targetOffset, centerValue)!;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // === DEVICE ANIMÉ ===
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
                      onPanStart: (_) => setState(() => isDragging = true),
                      onPanEnd: (_) => setState(() => isDragging = false),
                      onPanUpdate: (details) {
                        if (isExpanded)
                          return; // Désactive drag pendant expansion
                        final newOffset = offset + details.delta;
                        setState(() => offset = newOffset);
                        widget.onPositionChanged(newOffset);
                      },
                      child: _buildDevice(deviceSpec),
                    ),
                  ),
                ),
              ),
            ),
            // === BOUTON "VOIR LES DÉTAILS" ===
            if (isExpanded)
              Positioned(
                left: screenSize.width / 2 - 60, // centré horizontalement
                top: screenSize.height / 2 +
                    deviceSpec.size.height / 2 * scale +
                    20, // juste sous le device
                child: AnimatedOpacity(
                  opacity: _expandAnim.value.clamp(0.0, 1.0),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  child: ResponsiveButton.icon(
                    style: ElevatedButton.styleFrom(
                      elevation: 6,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ImmersiveDetailScreen(project: widget.project),
                        ),
                      );
                    },
                    icon: const Icon(Icons.open_in_full_rounded),
                    label: "Voir en détail",
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDevice(DeviceSpec spec) {
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
              ),
            ),
          ),
          if (hasImages)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: spec.screenRadius,
                child: images.length > 1
                    ? PageView(
                        children: images
                            .map((img) => CachedImage(
                                  path: img,
                                  fit: BoxFit.cover,
                                ))
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
          ...spec.buildDeviceDetails(widget.project),
        ],
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
