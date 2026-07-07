import 'package:flutter/material.dart';

import '../../../../core/affichage/colors_spec.dart';

class CornerAccent extends StatelessWidget {
  final bool isActive;
  const CornerAccent({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: CustomPaint(
        painter: CornerPainter(
          color: isActive ? ColorHelpers.cyan : ColorHelpers.border,
        ),
      ),
    );
  }
}

class CornerPainter extends CustomPainter {
  final Color color;
  CornerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(size.width - 16, 0), Offset(size.width, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, 16), paint);
  }

  @override
  bool shouldRepaint(CornerPainter old) => old.color != color;
}
