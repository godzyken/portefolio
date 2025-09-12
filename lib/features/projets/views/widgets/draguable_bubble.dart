import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/features/projets/views/widgets/project_bubble.dart';

import '../../data/project_data.dart';

class DraggableBubble extends ConsumerStatefulWidget {
  final ProjectInfo project;
  final bool isSelected;
  final Offset initialOffset;
  final ValueChanged<Offset> onPositionChanged;
  final double rotationAngle; // optionnel pour effet pile

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

class _DraggableBubbleState extends ConsumerState<DraggableBubble> {
  late Offset offset;
  bool isDragging = false;

  @override
  void initState() {
    super.initState();
    offset = widget.initialOffset;
  }

  /// 🔹 Détermine la plateforme prioritaire pour calculer la taille
  String _getPrimaryPlatform() {
    final platforms = widget.project.platform!
        .map((e) => e.toLowerCase())
        .toList();
    if (platforms.contains('largedesktop')) return 'largedesktop';
    if (platforms.contains('desktop')) return 'desktop';
    if (platforms.contains('tablet')) return 'tablet';
    if (platforms.contains('smartphone')) return 'smartphone';
    if (platforms.contains('watch')) return 'watch';
    return 'default';
  }

  /// 🔹 Retourne la taille de la bulle selon la plateforme
  Size _getBubbleSize() {
    switch (_getPrimaryPlatform()) {
      case 'watch':
        return const Size(60, 60);
      case 'smartphone':
        return const Size(80, 160);
      case 'tablet':
        return const Size(120, 180);
      case 'desktop':
        return const Size(160, 140);
      case 'largedesktop':
        return const Size(200, 160);
      default:
        return const Size(140, 140);
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(responsiveInfoProvider);
    final bubbleSize = _getBubbleSize();

    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: GestureDetector(
        onPanStart: (_) => setState(() => isDragging = true),
        onPanEnd: (_) => setState(() => isDragging = false),
        onPanUpdate: (details) {
          final newOffset = offset + details.delta;

          // ⛔ Empêche de sortir de l’écran en fonction de la vraie taille
          final clamped = Offset(
            newOffset.dx.clamp(0, info.size.width - bubbleSize.width),
            newOffset.dy.clamp(0, info.size.height - bubbleSize.height),
          );

          setState(() => offset = clamped);
          widget.onPositionChanged(clamped);
        },
        child: Transform.rotate(
          angle: widget.rotationAngle,
          child: AnimatedScale(
            scale: isDragging ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            child: SizedBox(
              width: bubbleSize.width,
              height: bubbleSize.height,
              child: ProjectBubble(
                project: widget.project,
                isSelected: widget.isSelected,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
