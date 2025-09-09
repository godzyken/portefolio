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

  const DraggableBubble({
    super.key,
    required this.project,
    required this.isSelected,
    required this.initialOffset,
    required this.onPositionChanged,
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

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);

    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: GestureDetector(
        onPanStart: (_) {
          setState(() => isDragging = true);
        },
        onPanEnd: (_) {
          setState(() => isDragging = false);
        },
        onPanUpdate: (details) {
          final newOffset = offset + details.delta;

          // empêcher de sortir complètement
          final clamped = Offset(
            newOffset.dx.clamp(0, screenSize.width - 120),
            newOffset.dy.clamp(0, screenSize.height - 120),
          );

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => offset = clamped);
            }
          });

          widget.onPositionChanged(clamped);
        },
        child: AnimatedScale(
          scale: isDragging ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: ProjectBubble(
            project: widget.project,
            isSelected: widget.isSelected,
          ),
        ),
      ),
    );
  }
}
