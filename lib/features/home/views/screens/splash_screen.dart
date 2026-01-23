import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:portefolio/core/service/unified_image_manager.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';

import '../../../../core/provider/unified_image_provider.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeApp();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      final manager = ref.read(unifiedImageManagerProvider);
      await manager.initialize(config: createLocalImageConfiguration(context));

      // TEST CRITIQUE : Dis-nous combien d'images le manager voit
      final allPaths =
          manager.getStats().totalAssets > 0 ? manager.getAssetPaths() : [];
      developer
          .log("🔥 DEBUG : Nombre d'images détectées = ${allPaths.length}");

      if (allPaths.isEmpty) {
        developer.log(
            "❌ ERREUR : La liste d'images est VIDE. Le problème est dans ImagePreloadConfig !");
      } else {
        final imagesToLoad = allPaths.map((path) {
          // Exemple : les logos sont critiques, le reste est en background
          final strategy = path.contains('logos/')
              ? PreloadStrategy.critical
              : PreloadStrategy.background;
          return ImagePriority(path, strategy: strategy);
        }).toList();

        manager.setTotalToLoad(imagesToLoad.length);
        await manager.preloadWithPriorities(imagesToLoad, context: context);
      }

      await Future.delayed(const Duration(milliseconds: 800));

      developer.log("🏁 DEBUG : Chargement fini, tentative de redirection...");
      if (mounted) ref.read(goRouterProvider).go('/');
    } catch (e, stack) {
      developer.log("❌ CRASH DANS INITIALIZE : $e");
      developer.log("X DEBUG : $stack");
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(imageCacheStatsProvider);
    final bool isInitializing = stats.totalAssets == 0;

    final double progress = stats.totalAssets > 0
        ? ((stats.totalLoaded + stats.failed) / stats.totalAssets)
            .clamp(0.0, 1.0)
        : 0.0;

    final isFinished = progress >= 1.0;

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
                              'assets/images/entreprises/logo_godzyken.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) =>
                                  const Icon(Icons.person, size: 50),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // Titres
                _buildAnimatedText('Godzyken', isTitle: true),
                const SizedBox(height: 12),
                _buildAnimatedText('Portfolio', isTitle: false),

                const SizedBox(height: 60),

                // Indicateur de chargement custom
                RepaintBoundary(
                  child: Column(
                    children: [
                      AnimatedScale(
                        scale: isFinished ? 1.2 : 1.0,
                        duration: Duration(milliseconds: 500),
                        child: CustomPaint(
                          size: const Size(80, 80),
                          painter: _LoadingPainter(
                            progress: progress,
                            color: const Color(0xFF00D9FF),
                          ),
                        ),
                      ),
                      if (isFinished)
                        const ResponsiveText.bodyMedium(
                          "C'est prêt !",
                          style: TextStyle(color: Colors.greenAccent),
                        )
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Texte de chargement
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      ResponsiveText.bodySmall(
                        isInitializing
                            ? 'Initialisation...'
                            : '${(progress * 100).toInt()}%',
                        style: const TextStyle(
                          color: Color(0xFF00D9FF),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ResponsiveText.bodySmall(
                        'Chargement des ressources...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
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
            child: const _AppVersionText(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedText(String text, {required bool isTitle}) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) =>
          Opacity(opacity: _fadeAnimation.value, child: child),
      child: isTitle
          ? ResponsiveText.displaySmall(text,
              style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2))
          : ResponsiveText.titleMedium(text,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.6),
                  letterSpacing: 1)),
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
        return ResponsiveText.bodySmall(
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

  // On initialise les Paint une seule fois
  late final Paint _backgroundPaint = Paint()
    ..color = color.withValues(alpha: 0.1)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  late final Paint _progressPaint = Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4
    ..strokeCap = StrokeCap.round;

  late final Paint _glowPaint = Paint()
    ..color = color.withValues(alpha: 0.2)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

  _LoadingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 4; // On laisse un peu de marge

    // 1. Dessiner le cercle de fond (Rail)
    canvas.drawCircle(center, radius, _backgroundPaint);

    // 2. Dessiner l'arc de progression
    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      _progressPaint,
    );

    // 3. Dessiner l'effet de lueur (Glow) à l'extrémité de l'arc
    if (progress > 0) {
      final angle = -math.pi / 2 + sweepAngle;
      final tipOffset = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      // On dessine un petit cercle lumineux au bout
      canvas.drawCircle(tipOffset, 6, _glowPaint);
      canvas.drawCircle(tipOffset, 3, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_LoadingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
