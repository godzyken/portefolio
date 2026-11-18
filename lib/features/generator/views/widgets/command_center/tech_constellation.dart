import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:portefolio/core/affichage/colors_spec.dart';

/// Constellation interactive des technologies avec zoom/pan et connexions animées
class TechConstellationGraph extends StatefulWidget {
  final List<String> technologies;

  const TechConstellationGraph({
    super.key,
    required this.technologies,
  });

  @override
  State<TechConstellationGraph> createState() => _TechConstellationGraphState();
}

class _TechConstellationGraphState extends State<TechConstellationGraph>
    with SingleTickerProviderStateMixin {
  String? _selectedTech;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final techs = widget.technologies.isNotEmpty
        ? widget.technologies
        : ['Flutter', 'Riverpod', 'Dart', 'Supabase', 'REST API', 'Git'];

    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: ColorHelpers.cyan.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: ColorHelpers.cyan.withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // En-tête HUD
            Positioned(
              top: 16,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.hub_outlined,
                          color: ColorHelpers.cyan, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'CONSTELLATION TECHNOLOGIQUE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _selectedTech != null
                        ? 'SÉLECTION: $_selectedTech'
                        : 'ZOOMABLE',
                    style: const TextStyle(
                      color: ColorHelpers.cyan,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // InteractiveViewer pour zoomer/déplacer la constellation
            Positioned.fill(
              child: InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(100),
                minScale: 0.5,
                maxScale: 2.5,
                child: Center(
                  child: SizedBox(
                    width: 400,
                    height: 250,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: _ConstellationPainter(
                            techCount: techs.length,
                            pulseValue: _pulseController.value,
                          ),
                          child: Stack(
                            children: List.generate(techs.length, (i) {
                              final angle = (i * 2 * math.pi) / techs.length;
                              const radius = 90.0;
                              final x = 200.0 + radius * math.cos(angle) - 35;
                              final y = 125.0 + radius * math.sin(angle) - 20;
                              final tech = techs[i];
                              final isSelected = _selectedTech == tech;

                              return Positioned(
                                left: x,
                                top: y,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedTech = isSelected ? null : tech;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? ColorHelpers.cyan
                                          : Colors.black87,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.white
                                            : ColorHelpers.cyan
                                                .withValues(alpha: 0.5),
                                        width: isSelected ? 2 : 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: ColorHelpers.cyan.withValues(
                                              alpha: isSelected ? 0.6 : 0.2),
                                          blurRadius: isSelected ? 12 : 6,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      tech,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.black
                                            : Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConstellationPainter extends CustomPainter {
  final int techCount;
  final double pulseValue;

  _ConstellationPainter({required this.techCount, required this.pulseValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final linePaint = Paint()
      ..color = ColorHelpers.cyan.withValues(alpha: 0.2 + (0.1 * pulseValue))
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = ColorHelpers.magenta.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    // Cercle central lumineux
    canvas.drawCircle(center, 25 + (5 * pulseValue), glowPaint);

    // Dessiner les connexions entre le centre et chaque nœud, et entre nœuds voisins
    for (int i = 0; i < techCount; i++) {
      final angle = (i * 2 * math.pi) / techCount;
      const radius = 90.0;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * sin(angle);
      final nodePos = Offset(x, y);

      canvas.drawLine(center, nodePos, linePaint);

      final nextAngle = ((i + 1) * 2 * math.pi) / techCount;
      final nextX = center.dx + radius * math.cos(nextAngle);
      final nextY = center.dy + radius * math.sin(nextAngle);
      canvas.drawLine(nodePos, Offset(nextX, nextY), linePaint);
    }
  }

  double cos(double radians) => math.cos(radians);
  double sin(double radians) => math.sin(radians);

  @override
  bool shouldRepaint(covariant _ConstellationPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue;
  }
}
