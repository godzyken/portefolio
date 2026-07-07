import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/affichage/colors_spec.dart';
import '../../../../core/affichage/screen_size_detector.dart';
import '../../data/experiences_data.dart';
import '../layouts/desktop_layout.dart';
import '../layouts/mobile_layout.dart';
import '../layouts/tablet_layout.dart';
import '../painters/corner_painter.dart';
import '../painters/grid_painter.dart';

class CyberpunkExperienceCard extends ConsumerStatefulWidget {
  const CyberpunkExperienceCard({
    super.key,
    required this.experience,
    required this.isActive,
  });

  final Experience experience;
  final bool isActive;

  @override
  ConsumerState<CyberpunkExperienceCard> createState() =>
      _CyberpunkExperienceCardState();
}

class _CyberpunkExperienceCardState
    extends ConsumerState<CyberpunkExperienceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(responsiveInfoProvider);
    final exp = widget.experience;

    Widget layout;

    if (info.isDesktop) {
      layout = DesktopLayout(
        experience: exp,
      );
    } else if (info.isTablet) {
      layout = TabletLayout(experience: exp);
    } else {
      layout = MobileLayout(experience: exp);
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          final glowIntensity = widget.isActive
              ? 0.28 + _glowController.value * 0.18
              : (_hovered ? 0.18 : 0.04);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ColorHelpers.cyan.withValues(alpha: glowIntensity * 1.4),
                width: widget.isActive ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: ColorHelpers.cyan.withValues(alpha: glowIntensity),
                  blurRadius: 24,
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: ColorHelpers.magenta
                      .withValues(alpha: glowIntensity * 0.35),
                  blurRadius: 48,
                  spreadRadius: -8,
                ),
              ],
            ),
            child: child,
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // ── Fond animé + grille ──────────────────────────────────
              _buildBackground(),

              // ── Contenu ──────────────────────────────────────────────
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: layout,
                ),
              ),

              // ── Coin décoratif ───────────────────────────────────────
              Positioned(
                top: 0,
                right: 0,
                child: CornerAccent(isActive: widget.isActive),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Fond dégradé + grille ───────────────────────────────────────────────
  Widget _buildBackground() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (_, __) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ColorHelpers.surfaceAlt,
                ColorHelpers.surface,
                Color.lerp(
                  ColorHelpers.surface,
                  const Color(0xFF0A1628),
                  _glowController.value * 0.3,
                )!,
              ],
            ),
          ),
          child: CustomPaint(painter: GridPainter(opacity: 0.035)),
        ),
      ),
    );
  }
}
