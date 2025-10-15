import 'dart:math' as math;

import 'package:flutter/material.dart';

class SpaceBackground extends StatefulWidget {
  final Widget child;
  final Color primaryColor;
  final Color secondaryColor;
  final int starCount;

  const SpaceBackground({
    super.key,
    required this.child,
    required this.primaryColor,
    this.secondaryColor = const Color(0xFF9C27FF),
    this.starCount = 100,
  });

  @override
  State<SpaceBackground> createState() => _SpaceBackgroundState();
}

class _SpaceBackgroundState extends State<SpaceBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Star> _stars = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    _generateStars();
  }

  void _generateStars() {
    final random = math.Random();
    for (int i = 0; i < widget.starCount; i++) {
      _stars.add(Star(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 2 + 0.5,
        opacity: random.nextDouble() * 0.5 + 0.3,
        twinkleSpeed: random.nextDouble() * 2 + 1,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fond noir pur
        Container(color: const Color(0xFF000000)),

        // Étoiles scintillantes
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: SpacePainter(
                stars: _stars,
                animation: _controller.value,
                primaryColor: widget.primaryColor,
                secondaryColor: widget.secondaryColor,
              ),
              size: Size.infinite,
            );
          },
        ),

        // Contenu par-dessus
        widget.child,
      ],
    );
  }
}

class Star {
  final double x;
  final double y;
  final double size;
  final double opacity;
  final double twinkleSpeed;

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.twinkleSpeed,
  });
}

class SpacePainter extends CustomPainter {
  final List<Star> stars;
  final double animation;
  final Color primaryColor;
  final Color secondaryColor;

  SpacePainter({
    required this.stars,
    required this.animation,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Dessiner chaque étoile
    for (var star in stars) {
      final x = star.x * size.width;
      final y = star.y * size.height;

      // Effet de scintillement
      final twinkle =
          (math.sin(animation * math.pi * 2 * star.twinkleSpeed) + 1) / 2;
      final currentOpacity = star.opacity * twinkle;

      // Couleur aléatoire entre primary et secondary
      final colorMix = (star.x + star.y) % 1;
      final starColor = Color.lerp(
        primaryColor,
        secondaryColor,
        colorMix,
      )!
          .withValues(alpha: currentOpacity);

      // Dessiner l'étoile avec glow
      final paint = Paint()
        ..color = starColor
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, star.size * 2);

      canvas.drawCircle(Offset(x, y), star.size, paint);

      // Point central plus brillant
      final centerPaint = Paint()
        ..color = Colors.white.withValues(alpha: (currentOpacity * 0.8));
      canvas.drawCircle(Offset(x, y), star.size * 0.3, centerPaint);
    }

    // Ajouter quelques nébuleuses
    _drawNebulae(canvas, size);
  }

  void _drawNebulae(Canvas canvas, Size size) {
    // Nébuleuse 1 (coin supérieur gauche)
    final nebula1 = Paint()
      ..shader = RadialGradient(
        colors: [
          primaryColor.withValues(alpha: 0.05),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.2, size.height * 0.2),
        radius: size.width * 0.3,
      ))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);

    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.2),
      size.width * 0.3,
      nebula1,
    );

    // Nébuleuse 2 (coin inférieur droit)
    final nebula2 = Paint()
      ..shader = RadialGradient(
        colors: [
          secondaryColor.withValues(alpha: 0.05),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.8, size.height * 0.8),
        radius: size.width * 0.25,
      ))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);

    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.8),
      size.width * 0.25,
      nebula2,
    );
  }

  @override
  bool shouldRepaint(SpacePainter oldDelegate) => true;
}
