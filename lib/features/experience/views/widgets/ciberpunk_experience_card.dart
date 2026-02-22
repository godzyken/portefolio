import 'package:flutter/material.dart';

import '../../../../core/affichage/colors_spec.dart';
import '../../../../core/ui/widgets/responsive_text.dart';
import '../../../../core/ui/widgets/smart_image.dart';
import '../../data/experiences_data.dart';

class CyberpunkExperienceCard extends StatefulWidget {
  const CyberpunkExperienceCard({
    super.key,
    required this.experience,
    required this.isActive,
  });

  final Experience experience;
  final bool isActive;

  @override
  State<CyberpunkExperienceCard> createState() =>
      _CyberpunkExperienceCardState();
}

class _CyberpunkExperienceCardState extends State<CyberpunkExperienceCard>
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
    final exp = widget.experience;

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopRow(exp),
                      const SizedBox(height: 14),
                      _buildPosteAndEntreprise(exp),
                      const SizedBox(height: 12),
                      _buildPeriode(exp),
                      const SizedBox(height: 16),
                      _buildContexte(exp),
                      const SizedBox(height: 14),
                      _buildImage(exp),
                      const Spacer(),
                      _buildTags(exp),
                      const SizedBox(height: 16),
                      _buildResultats(exp),
                      const SizedBox(height: 12),
                      _buildFooterCta(),
                    ],
                  ),
                ),
              ),

              // ── Coin décoratif ───────────────────────────────────────
              Positioned(
                top: 0,
                right: 0,
                child: _CornerAccent(isActive: widget.isActive),
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
          child: CustomPaint(painter: _GridPainter(opacity: 0.035)),
        ),
      ),
    );
  }

  // ── Logo + badge id ─────────────────────────────────────────────────────
  Widget _buildTopRow(Experience exp) {
    return Row(
      children: [
        // Logo entreprise
        if (exp.logo.isNotEmpty)
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ColorHelpers.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: SmartImage(
                path: exp.logo,
                fit: BoxFit.contain,
                enableShimmer: true,
                autoPreload: true,
                colorBlendMode: BlendMode.colorBurn,
              ),
            ),
          ),

        const SizedBox(width: 12),

        // ID de l'expérience (style monospace)
        ResponsiveText(
          '#${exp.id}',
          style: TextStyle(
            color: ColorHelpers.cyan.withValues(alpha: 0.5),
            fontSize: 11,
            fontFamily: 'monospace',
            letterSpacing: 1,
          ),
        ),

        const Spacer(),

        // Badge lien projet si disponible
        if (exp.lienProjet.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: ColorHelpers.magenta.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: ColorHelpers.magenta.withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.link_outlined,
                    size: 10, color: ColorHelpers.magenta),
                SizedBox(width: 4),
                ResponsiveText(
                  'PROJET',
                  style: TextStyle(
                    color: ColorHelpers.magenta,
                    fontSize: 9,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ── Poste + entreprise ──────────────────────────────────────────────────
  Widget _buildPosteAndEntreprise(Experience exp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Poste (titre principal)
        ResponsiveText.titleSmall(
          exp.poste,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: ColorHelpers.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            height: 1.2,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        // Entreprise avec dot magenta
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: ColorHelpers.magenta,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: ColorHelpers.magenta.withValues(alpha: 0.6),
                    blurRadius: 6,
                  )
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ResponsiveText.headlineMedium(
                exp.entreprise,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: ColorHelpers.magenta,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Période ─────────────────────────────────────────────────────────────
  Widget _buildPeriode(Experience exp) {
    if (exp.periode.isEmpty) {
      return const SizedBox.shrink();
    }
    return Row(
      children: [
        const Icon(Icons.schedule_outlined,
            size: 12, color: ColorHelpers.textSecondary),
        const SizedBox(width: 6),
        ResponsiveText.bodySmall(
          exp.periode,
          style: const TextStyle(
            color: ColorHelpers.textSecondary,
            fontSize: 12,
            fontFamily: 'monospace',
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  // ── Contexte (description courte) ───────────────────────────────────────
  Widget _buildContexte(Experience exp) {
    if (exp.contexte.isEmpty) {
      return const SizedBox.shrink();
    }
    return ResponsiveText.bodySmall(
      exp.contexte,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: ColorHelpers.textSecondary.withValues(alpha: 0.85),
        fontSize: 12,
        height: 1.6,
      ),
    );
  }

  // ── Image de réalisation ────────────────────────────────────────────────
  Widget _buildImage(Experience exp) {
    if (exp.image.isEmpty) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 130,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: ColorHelpers.border),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            SmartImage(
              path: exp.image,
              responsiveSize: ResponsiveImageSize.xlarge,
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
              enableShimmer: true,
              autoPreload: true,
              color: Colors.white.withValues(alpha: 0.9),
              colorBlendMode: BlendMode.modulate,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    ColorHelpers.surface.withValues(alpha: 0.55)
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
            CustomPaint(painter: _ScanLinePainter()),
          ],
        ),
      ),
    );
  }

  // ── Tags ─────────────────────────────────────────────────────────────────
  Widget _buildTags(Experience exp) {
    final tags = exp.tags;
    if (tags.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: tags.take(6).map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: ColorHelpers.surface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: ColorHelpers.border),
          ),
          child: ResponsiveText.bodySmall(
            tag,
            style: const TextStyle(
              color: ColorHelpers.textSecondary,
              fontSize: 10,
              letterSpacing: 0.3,
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Premier résultat mis en avant ────────────────────────────────────────
  Widget _buildResultats(Experience exp) {
    final resultats = exp.resultats;
    if (resultats.isEmpty) return const SizedBox.shrink();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle_outline,
            size: 13, color: ColorHelpers.cyan.withValues(alpha: 0.7)),
        const SizedBox(width: 6),
        Expanded(
          child: ResponsiveText.displaySmall(
            resultats.first,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: ColorHelpers.cyan.withValues(alpha: 0.8),
              fontSize: 11,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  // ── CTA footer ───────────────────────────────────────────────────────────
  Widget _buildFooterCta() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ResponsiveText.headlineSmall(
          'Voir détails',
          style: TextStyle(
            color: ColorHelpers.cyan.withValues(alpha: 0.7),
            fontSize: 11,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.arrow_forward_ios, size: 10, color: ColorHelpers.cyan),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DÉCORATIFS
// ─────────────────────────────────────────────────────────────────────────────
class _CornerAccent extends StatelessWidget {
  final bool isActive;
  const _CornerAccent({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: CustomPaint(
        painter: _CornerPainter(
          color: isActive ? ColorHelpers.cyan : ColorHelpers.border,
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  _CornerPainter({required this.color});

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
  bool shouldRepaint(_CornerPainter old) => old.color != color;
}

class _GridPainter extends CustomPainter {
  final double opacity;
  _GridPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ColorHelpers.cyan.withValues(alpha: opacity)
      ..strokeWidth = 0.5;
    const spacing = 32.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.opacity != opacity;
}

class _ScanLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ColorHelpers.cyan.withValues(alpha: 0.03)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_ScanLinePainter _) => false;
}
