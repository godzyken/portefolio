import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // Background gradient animé
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.0 + (_controller.value * 0.2),
                    colors: [
                      const Color(0xFF00D9FF).withAlpha((255 * 0.15).toInt()),
                      const Color(0xFF0A0A0A),
                    ],
                  ),
                ),
              );
            },
          ),

          // Contenu central
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo avec animation
                AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00D9FF)
                                    .withAlpha((255 * 0.4).toInt()),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/logo_godzyken.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: const Color(0xFF00D9FF),
                                  child: const Icon(
                                    Icons.flutter_dash,
                                    size: 60,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // Titre
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text(
                    'Godzyken',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Sous-titre
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Portfolio',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withAlpha((255 * 0.6).toInt()),
                      letterSpacing: 1,
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // Indicateur de chargement custom
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(60, 60),
                      painter: _LoadingPainter(
                        progress: _controller.value,
                        color: const Color(0xFF00D9FF),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Texte de chargement
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Chargement des ressources...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withAlpha((255 * 0.5).toInt()),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Version en bas
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'v1.0.0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withAlpha((255 * 0.3).toInt()),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter pour l'indicateur de chargement
class _LoadingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _LoadingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withAlpha((255 * 0.3).toInt())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Cercle de fond
    canvas.drawCircle(center, radius, paint);

    // Arc de progression
    paint.color = color;
    paint.strokeWidth = 4;
    paint.strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      paint,
    );

    // Point lumineux
    final angle = -math.pi / 2 + sweepAngle;
    final pointX = center.dx + radius * math.cos(angle);
    final pointY = center.dy + radius * math.sin(angle);

    paint.style = PaintingStyle.fill;
    paint.color = color;
    canvas.drawCircle(Offset(pointX, pointY), 6, paint);

    // Glow du point
    paint.color = color.withAlpha((255 * 0.3).toInt());
    canvas.drawCircle(Offset(pointX, pointY), 10, paint);
  }

  @override
  bool shouldRepaint(_LoadingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
