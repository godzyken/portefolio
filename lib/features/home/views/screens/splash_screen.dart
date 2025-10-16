import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/provider/precache_providers.dart';
import '../../../../core/routes/router.dart';

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
    );

    _fadeAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // On attend que la première frame soit construite avant de lancer l'animation en boucle.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // On vérifie que le widget est toujours là
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final precacheAsync = ref.watch(precacheAllAssetsProvider(context));

    // 🔹 Une fois terminé, on redirige vers la Home
    precacheAsync.whenData((_) async {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        final router = ref.read(goRouterProvider);
        router.go('/home'); // 🔁 adapte selon ton route name
      }
    });

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
                      const Color(0xFF00D9FF).withValues(alpha: 0.15),
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
                                    .withValues(alpha: 0.4),
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
                // 3. REFACTO: Remplacement de FadeTransition
                AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) =>
                      Opacity(opacity: _fadeAnimation.value, child: child),
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
                AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) =>
                      Opacity(opacity: _fadeAnimation.value, child: child),
                  child: Text(
                    'Portfolio',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.6),
                      letterSpacing: 1,
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // Indicateur de chargement custom
                // 4. OPTIMISATION: Isoler le CustomPainter, qui se redessine constamment.
                RepaintBoundary(
                  child: AnimatedBuilder(
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
                ),

                const SizedBox(height: 24),

                // Texte de chargement
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Chargement des ressources...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.5),
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
            child: const _AppVersionText(), // Widget séparé pour la clarté
          ),
        ],
      ),
    );
  }
}

/// Widget pour afficher la version de l'app de manière dynamique
class _AppVersionText extends StatelessWidget {
  const _AppVersionText();

  Future<String> _getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return 'v${packageInfo.version}';
    } catch (e) {
      return 'v1.0.0'; // Fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getAppVersion(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        return Text(
          snapshot.data!,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.3),
          ),
        );
      },
    );
  }
}

/// Custom painter pour l'indicateur de chargement (légèrement optimisé)
class _LoadingPainter extends CustomPainter {
  final double progress;
  final Color color;

  // Pré-calculer les objets Paint pour éviter de les recréer dans la méthode paint()
  final Paint _backgroundPaint;
  final Paint _progressPaint;
  final Paint _pointPaint;
  final Paint _glowPaint;

  _LoadingPainter({required this.progress, required this.color})
      : _backgroundPaint = Paint()
          ..color = color.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
        _progressPaint = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
        _pointPaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill,
        _glowPaint = Paint()
          ..color = color.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Cercle de fond
    canvas.drawCircle(center, radius, _backgroundPaint);

    // Arc de progression
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Démarrer en haut
      sweepAngle,
      false,
      _progressPaint,
    );

    // Point lumineux
    final angle = -math.pi / 2 + sweepAngle;
    final pointOffset = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );

    // Glow du point
    canvas.drawCircle(pointOffset, 10, _glowPaint);
    // Point lui-même
    canvas.drawCircle(pointOffset, 6, _pointPaint);
  }

  @override
  bool shouldRepaint(_LoadingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
