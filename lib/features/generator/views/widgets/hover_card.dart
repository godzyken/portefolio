import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import '../../../../core/provider/providers.dart';

class HoverCard extends ConsumerWidget {
  final String id;
  final Widget child;
  final EdgeInsets margin;
  final double translateY;
  final double scale;
  final Color shadowColor;
  final double shadowBlur;

  const HoverCard({
    super.key,
    required this.id,
    required this.child,
    this.margin = const EdgeInsets.all(16),
    this.translateY = -6.0,
    this.scale = 1.02,
    this.shadowColor = Colors.indigo,
    this.shadowBlur = 18,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHovered = ref.watch(
      hoverMapProvider.select((map) => map[id] ?? false),
    );

    return MouseRegion(
      onEnter: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setHover(ref, id, true);
        });
      },
      onExit: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setHover(ref, id, false);
        });
      },
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: margin,
        transform: isHovered
            ? (Matrix4.identity()
                ..translateByVector3(Vector3(0.0, -6.0, 0.0))
                ..scaleByVector3(Vector3.all(1.02)))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withAlpha(
                isHovered ? (255 * 0.30).toInt() : (255 * 0.10).toInt(),
              ),
              blurRadius: isHovered ? shadowBlur : 10,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}
