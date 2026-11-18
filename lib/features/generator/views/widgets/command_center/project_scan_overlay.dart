import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:portefolio/core/affichage/colors_spec.dart';

class ProjectScanOverlay extends StatefulWidget {
  final Widget child;
  final VoidCallback? onScanComplete;

  const ProjectScanOverlay({
    super.key,
    required this.child,
    this.onScanComplete,
  });

  @override
  State<ProjectScanOverlay> createState() => _ProjectScanOverlayState();
}

class _ProjectScanOverlayState extends State<ProjectScanOverlay>
    with TickerProviderStateMixin {
  bool _isScanning = false;
  bool _isScanned = false;
  late final AnimationController _scanController;
  late final Animation<double> _laserAnimation;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    );

    _laserAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOutSine),
    );

    _scanController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isScanning = false;
          _isScanned = true;
        });
        widget.onScanComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  void _startScan() {
    if (_isScanning) return;
    setState(() {
      _isScanning = true;
      _isScanned = false;
    });
    _scanController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Contenu principal avec effet de révélation post-scan
        AnimatedOpacity(
          opacity: _isScanning ? 0.6 : 1.0,
          duration: const Duration(milliseconds: 400),
          child: widget.child,
        ),

        // Grille HUD pendant ou après le scan
        if (_isScanning || _isScanned)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _HudGridPainter(
                  progress: _isScanning ? _laserAnimation.value : 1.0,
                  isScanned: _isScanned,
                ),
              ),
            ),
          ),

        // Ligne Laser verticale qui balaie l'écran
        if (_isScanning)
          AnimatedBuilder(
            animation: _laserAnimation,
            builder: (context, child) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final laserY = constraints.maxHeight * _laserAnimation.value;
                  return Stack(
                    children: [
                      Positioned(
                        top: laserY - 2,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                ColorHelpers.cyan,
                                Colors.white,
                                ColorHelpers.magenta,
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: ColorHelpers.cyan.withValues(alpha: 0.8),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: laserY - 50,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                ColorHelpers.cyan.withValues(alpha: 0.25),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),

        // Bouton HUD Scan flottant en bas à droite ou en haut
        Positioned(
          bottom: 24,
          right: 24,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _startScan,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ColorHelpers.cyan.withValues(alpha: 0.2),
                          ColorHelpers.magenta.withValues(alpha: 0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: _isScanned
                            ? ColorHelpers.cyan
                            : ColorHelpers.cyan.withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ColorHelpers.cyan.withValues(alpha: 0.3),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isScanned
                              ? Icons.verified_outlined
                              : Icons.radar_outlined,
                          color: ColorHelpers.cyan,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _isScanning
                              ? 'ANALYSE EN COURS...'
                              : _isScanned
                                  ? 'SYSTÈME INITIALISÉ'
                                  : 'SCANNER LE PROJET',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HudGridPainter extends CustomPainter {
  final double progress;
  final bool isScanned;

  _HudGridPainter({required this.progress, required this.isScanned});

  @override
  void paint(Canvas canvas, Size size) {
    // Lignes de coins HUD cyberpunk
    final cornerSize = 25.0;
    final borderPaint = Paint()
      ..color = ColorHelpers.cyan.withValues(alpha: 0.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Top-Left
    canvas.drawPath(
      Path()
        ..moveTo(0, cornerSize)
        ..lineTo(0, 0)
        ..lineTo(cornerSize, 0),
      borderPaint,
    );
    // Top-Right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerSize, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, cornerSize),
      borderPaint,
    );
    // Bottom-Left
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - cornerSize)
        ..lineTo(0, size.height)
        ..lineTo(cornerSize, size.height),
      borderPaint,
    );
    // Bottom-Right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerSize, size.height)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width, size.height - cornerSize),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _HudGridPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isScanned != isScanned;
  }
}
