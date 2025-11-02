import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/ui/widgets/responsive_text.dart';

import '../../controllers/providers/card_flight_provider.dart';
import '../../data/competences_data.dart';

class CompetenceChip extends ConsumerStatefulWidget {
  final String competenceName;
  final double opacity;
  final double size;

  const CompetenceChip({
    super.key,
    required this.competenceName,
    this.opacity = 1.0,
    this.size = 80.0,
  });

  @override
  ConsumerState<CompetenceChip> createState() => _CompetenceChipState();
}

class _CompetenceChipState extends ConsumerState<CompetenceChip> {
  bool _hovering = false;

  // 🔧 Trouver la compétence de manière safe
  Competence? _getCompetence() {
    try {
      return competences.firstWhere(
        (comp) => comp.nom.toLowerCase() == widget.competenceName.toLowerCase(),
      );
    } catch (e) {
      // ✅ Si pas trouvé, créer une compétence par défaut
      developer.log('⚠️ Compétence non trouvée: ${widget.competenceName}');
      return Competence(
        nom: widget.competenceName,
        niveau: NiveauCompetence.fonctionnel,
        couleur: Colors.grey,
        valeur: 5,
        entreprises: [],
        description: 'Compétence custom',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final comp = _getCompetence();
    if (comp == null) {
      return _buildFallback();
    }

    final activeTags = ref.watch(activeTagsProvider);
    final isActive = activeTags.contains(widget.competenceName);

    return Tooltip(
      message: _buildTooltipMessage(comp),
      preferBelow: false,
      verticalOffset: 20,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(color: Colors.white, fontSize: 12),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: Draggable<String>(
          data: widget.competenceName,
          feedback: Material(
            color: Colors.transparent,
            child: _buildChipContent(comp, isActive, dragging: true),
          ),
          childWhenDragging: Opacity(
            opacity: 0.4,
            child: Transform.scale(
              scale: 0.9,
              child: _buildChipContent(comp, isActive),
            ),
          ),
          child: GestureDetector(
            onTap: () {
              final notifier = ref.read(activeTagsProvider.notifier);
              if (isActive) {
                notifier.setTags(activeTags
                    .where((t) => t != widget.competenceName)
                    .toList());
              } else {
                notifier.setTags([...activeTags, widget.competenceName]);
              }
            },
            child: AnimatedScale(
              alignment: Alignment.center,
              scale: _hovering ? 1.05 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: _buildChipContent(comp, isActive),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChipContent(Competence comp, bool isActive,
      {bool dragging = false}) {
    return ResponsiveBox(
      width: widget.size,
      height: widget.size,
      // 🔧 Utiliser ValueKey au lieu de GlobalKey
      key: ValueKey('competence_${widget.competenceName}_${comp.nom}'),
      child: ResponsiveBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.3, -0.3),
            radius: 1.2,
            colors: [
              comp.couleur.withValues(
                alpha: (255 * widget.opacity * 1.3).clamp(0, 255) / 255,
              ),
              comp.couleur.withValues(alpha: widget.opacity),
              comp.couleur.withValues(
                alpha: (255 * widget.opacity * 0.7).clamp(0, 255) / 255,
              ),
            ],
          ),
          border: Border.all(
            color: isActive
                ? Colors.yellowAccent
                : (_hovering ? Colors.white : Colors.grey[600]!),
            width: isActive ? (widget.size * 0.05) : (widget.size * 0.0375),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius:
                  dragging ? (widget.size * 0.1) : (widget.size * 0.075),
              offset: Offset(
                  0, dragging ? (widget.size * 0.05) : (widget.size * 0.0375)),
            ),
            if (isActive && !dragging)
              BoxShadow(
                color: comp.couleur.withValues(alpha: 0.6),
                blurRadius: widget.size * 0.1875,
                spreadRadius: widget.size * 0.0375,
              ),
            if (!dragging)
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.2),
                blurRadius: widget.size * 0.025,
                offset: const Offset(-1, -1),
                spreadRadius: widget.size * -0.025,
              ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            _buildConcentricCircles(comp.niveau),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ResponsiveText.bodyMedium(
                    '${comp.valeur}',
                    style: TextStyle(
                      color: isActive ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: widget.size * 0.175,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          offset: const Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  ResponsiveText.bodyMedium(
                    comp.nom,
                    style: TextStyle(
                      color: isActive ? Colors.black87 : Colors.white70,
                      fontWeight: FontWeight.w600,
                      fontSize: widget.size * 0.1,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          offset: const Offset(0.5, 0.5),
                          blurRadius: 1,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (!dragging)
              Positioned(
                top: widget.size * 0.1,
                left: widget.size * 0.1,
                child: ResponsiveBox(
                  width: widget.size * 0.25,
                  height: widget.size * 0.25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.4),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: widget.size * 0.0625,
              right: widget.size * 0.0625,
              child: ResponsiveBox(
                width: widget.size * 0.2,
                height: widget.size * 0.2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getNiveauBadgeColor(comp.niveau),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Center(
                  child: ResponsiveText.bodySmall(
                    _getNiveauIcon(comp.niveau),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: widget.size * 0.1,
                      fontWeight: FontWeight.bold,
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

  Widget _buildFallback() {
    return ResponsiveBox(
      width: widget.size,
      height: widget.size,
      key: ValueKey('fallback_${widget.competenceName}'),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey,
      ),
      child: Center(
        child: ResponsiveText.bodySmall(
          widget.competenceName,
          style: const TextStyle(color: Colors.white, fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildConcentricCircles(NiveauCompetence niveau) {
    final circles = <Widget>[];
    final nbCircles = switch (niveau) {
      NiveauCompetence.expert => 4,
      NiveauCompetence.confirme => 3,
      NiveauCompetence.intermediaire => 2,
      NiveauCompetence.fonctionnel => 1,
    };

    for (int i = 0; i < nbCircles; i++) {
      final size = (widget.size * 0.8125) - (i * (widget.size * 0.125));
      circles.add(
        Center(
          child: ResponsiveBox(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: (0.4 - i * 0.1)),
                width: 1,
              ),
            ),
          ),
        ),
      );
    }

    return Stack(children: circles);
  }

  String _buildTooltipMessage(Competence comp) {
    final niveau = switch (comp.niveau) {
      NiveauCompetence.expert => 'Expert',
      NiveauCompetence.confirme => 'Confirmé',
      NiveauCompetence.intermediaire => 'Intermédiaire',
      NiveauCompetence.fonctionnel => 'Fonctionnel',
    };

    return '${comp.nom} (${comp.valeur} pts)\n'
        'Niveau: $niveau\n'
        '${comp.description}\n'
        'Expériences: ${comp.entreprises.join(', ')}';
  }

  Color _getNiveauBadgeColor(NiveauCompetence niveau) {
    return switch (niveau) {
      NiveauCompetence.expert => Colors.amber,
      NiveauCompetence.confirme => Colors.grey,
      NiveauCompetence.intermediaire => Colors.orange,
      NiveauCompetence.fonctionnel => Colors.brown,
    };
  }

  String _getNiveauIcon(NiveauCompetence niveau) {
    return switch (niveau) {
      NiveauCompetence.expert => '★',
      NiveauCompetence.confirme => '◆',
      NiveauCompetence.intermediaire => '●',
      NiveauCompetence.fonctionnel => '▲',
    };
  }
}
