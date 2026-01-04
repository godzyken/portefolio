import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';

class TrailingLightPainter extends CustomPainter {
  final FlSpot spot;
  final Color color;
  final double opacity;

  TrailingLightPainter({
    required this.spot,
    required this.color,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Adapter aux coordonnées réelles du graphique
    final x = spot.x / 10 * size.width;
    final y = size.height - (spot.y / 10 * size.height);

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.8 * opacity),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(x, y),
        radius: 20,
      ));

    canvas.drawCircle(
      Offset(x, y),
      10,
      paint,
    );
  }

  @override
  bool shouldRepaint(TrailingLightPainter oldDelegate) =>
      oldDelegate.spot != spot || oldDelegate.opacity != opacity;
}
