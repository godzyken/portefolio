import 'dart:math' as math;

import 'package:flutter/material.dart';

class ParticleBackground extends StatefulWidget {
  final int particleCount;
  final Color particleColor;
  final double minSize;
  final double maxSize;

  const ParticleBackground({
    super.key,
    this.particleCount = 50,
    this.particleColor = Colors.white,
    this.minSize = 2.0,
    this.maxSize = 6.0,
  });

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    )..repeat();

    _particles = List.generate(
      widget.particleCount,
      (index) => Particle.random(
        minSize: widget.minSize,
        maxSize: widget.maxSize,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(
            particles: _particles,
            animation: _controller.value,
            color: widget.particleColor,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class Particle {
  final double x;
  final double y;
  final double size;
  final double speedX;
  final double speedY;
  final double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speedX,
    required this.speedY,
    required this.opacity,
  });

  factory Particle.random({
    double minSize = 2.0,
    double maxSize = 6.0,
  }) {
    final random = math.Random();
    return Particle(
      x: random.nextDouble(),
      y: random.nextDouble(),
      size: minSize + random.nextDouble() * (maxSize - minSize),
      speedX: (random.nextDouble() - 0.5) * 0.02,
      speedY: (random.nextDouble() - 0.5) * 0.02,
      opacity: 0.2 + random.nextDouble() * 0.6,
    );
  }

  Particle move(double animation) {
    return Particle(
      x: (x + speedX * animation) % 1.0,
      y: (y + speedY * animation) % 1.0,
      size: size,
      speedX: speedX,
      speedY: speedY,
      opacity: opacity,
    );
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animation;
  final Color color;

  ParticlePainter({
    required this.particles,
    required this.animation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final movedParticle = particle.move(animation);
      final position = Offset(
        movedParticle.x * size.width,
        movedParticle.y * size.height,
      );

      // Particule principale
      final paint = Paint()
        ..color = color.withValues(alpha: movedParticle.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(position, movedParticle.size, paint);

      // Effet de glow
      final glowPaint = Paint()
        ..color = color.withValues(alpha: movedParticle.opacity * 0.3)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, movedParticle.size);

      canvas.drawCircle(position, movedParticle.size * 2, glowPaint);
    }

    // Lignes de connexion entre particules proches
    _drawConnections(canvas, size);
  }

  void _drawConnections(Canvas canvas, Size size) {
    const maxDistance = 100.0;

    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final p1 = particles[i].move(animation);
        final p2 = particles[j].move(animation);

        final pos1 = Offset(p1.x * size.width, p1.y * size.height);
        final pos2 = Offset(p2.x * size.width, p2.y * size.height);

        final distance = (pos1 - pos2).distance;

        if (distance < maxDistance) {
          final opacity = (1 - distance / maxDistance) * 0.1;
          final paint = Paint()
            ..color = color.withValues(alpha: opacity)
            ..strokeWidth = 1.0;

          canvas.drawLine(pos1, pos2, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}
