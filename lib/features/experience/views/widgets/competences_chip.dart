import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/providers/card_flight_provider.dart';
import '../../data/competences_data.dart';

class CompetenceChip extends ConsumerStatefulWidget {
  final String competenceName;
  final double opacity;

  const CompetenceChip({
    super.key,
    required this.competenceName,
    this.opacity = 1.0,
  });

  @override
  ConsumerState<CompetenceChip> createState() => _CompetenceChipState();
}

class _CompetenceChipState extends ConsumerState<CompetenceChip> {
  bool _hovering = false;

  // Récupérer la compétence depuis les données
  Competence? get competence {
    try {
      return competences.firstWhere(
        (comp) => comp.nom.toLowerCase() == widget.competenceName.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final comp = competence;
    if (comp == null) {
      // Fallback si la compétence n'est pas trouvée
      return Container(
        width: 80,
        height: 80,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey,
        ),
        child: Center(
          child: Text(
            widget.competenceName,
            style: const TextStyle(color: Colors.white, fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final activeTags = ref.watch(activeTagsProvider);
    final isActive = activeTags.contains(widget.competenceName);

    // Contenu visuel du jeton
    Widget chipContent({bool dragging = false}) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.3, -0.3),
            radius: 1.2,
            colors: [
              // Effet de brillance en haut à gauche
              comp.couleur.withAlpha(
                (255 * widget.opacity * 1.3).clamp(0, 255).toInt(),
              ),
              comp.couleur.withAlpha((255 * widget.opacity).toInt()),
              // Ombre en bas à droite
              comp.couleur.withAlpha(
                (255 * widget.opacity * 0.7).clamp(0, 255).toInt(),
              ),
            ],
          ),
          border: Border.all(
            color: isActive
                ? Colors.yellowAccent
                : (_hovering ? Colors.white : Colors.grey[600]!),
            width: isActive ? 4 : 3,
          ),
          boxShadow: [
            // Ombre principale
            BoxShadow(
              color: Colors.black.withAlpha((255 * 0.3).toInt()),
              blurRadius: dragging ? 8 : 6,
              offset: Offset(0, dragging ? 4 : 3),
            ),
            // Effet lumineux si actif
            if (isActive && !dragging)
              BoxShadow(
                color: comp.couleur.withAlpha((255 * 0.6).toInt()),
                blurRadius: 15,
                spreadRadius: 3,
              ),
            // Reflet interne
            if (!dragging)
              BoxShadow(
                color: Colors.white.withAlpha((255 * 0.2).toInt()),
                blurRadius: 2,
                offset: const Offset(-1, -1),
                spreadRadius: -2,
              ),
          ],
        ),
        child: Stack(
          children: [
            // Cercles concentriques selon le niveau
            _buildConcentricCircles(comp.niveau),

            // Valeur du jeton au centre
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${comp.valeur}',
                    style: TextStyle(
                      color: isActive ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      shadows: [
                        Shadow(
                          color: Colors.black.withAlpha((255 * 0.5).toInt()),
                          offset: const Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    comp.nom,
                    style: TextStyle(
                      color: isActive ? Colors.black87 : Colors.white70,
                      fontWeight: FontWeight.w600,
                      fontSize: 8,
                      shadows: [
                        Shadow(
                          color: Colors.black.withAlpha((255 * 0.5).toInt()),
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

            // Reflet brillant
            if (!dragging)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withAlpha((255 * 0.4).toInt()),
                        Colors.white.withAlpha((255 * 0.0).toInt()),
                      ],
                    ),
                  ),
                ),
              ),

            // Indicateur de niveau (petit badge)
            Positioned(
              bottom: 5,
              right: 5,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getNiveauBadgeColor(comp.niveau),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Center(
                  child: Text(
                    _getNiveauIcon(comp.niveau),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Widget avec tooltip
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
            child: chipContent(dragging: true),
          ),
          childWhenDragging: Opacity(
            opacity: 0.4,
            child: Transform.scale(scale: 0.9, child: chipContent()),
          ),
          child: GestureDetector(
            onTap: () {
              final notifier = ref.read(activeTagsProvider.notifier);
              if (isActive) {
                notifier.state = activeTags
                    .where((t) => t != widget.competenceName)
                    .toList();
              } else {
                notifier.state = [...activeTags, widget.competenceName];
              }
            },
            child: AnimatedScale(
              scale: _hovering ? 1.05 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: chipContent(),
            ),
          ),
        ),
      ),
    );
  }

  // Cercles concentriques selon le niveau
  Widget _buildConcentricCircles(NiveauCompetence niveau) {
    final circles = <Widget>[];

    // Nombre de cercles selon le niveau
    final nbCircles = switch (niveau) {
      NiveauCompetence.expert => 4,
      NiveauCompetence.confirme => 3,
      NiveauCompetence.intermediaire => 2,
      NiveauCompetence.fonctionnel => 1,
    };

    for (int i = 0; i < nbCircles; i++) {
      final size = 65.0 - (i * 10.0);
      circles.add(
        Center(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withAlpha((255 * (0.4 - i * 0.1)).toInt()),
                width: 1,
              ),
            ),
          ),
        ),
      );
    }

    return Stack(children: circles);
  }

  // Message du tooltip
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

  // Couleur du badge de niveau
  Color _getNiveauBadgeColor(NiveauCompetence niveau) {
    return switch (niveau) {
      NiveauCompetence.expert => Colors.amber,
      NiveauCompetence.confirme => Colors.grey,
      NiveauCompetence.intermediaire => Colors.orange,
      NiveauCompetence.fonctionnel => Colors.brown,
    };
  }

  // Icône du niveau
  String _getNiveauIcon(NiveauCompetence niveau) {
    return switch (niveau) {
      NiveauCompetence.expert => '★',
      NiveauCompetence.confirme => '◆',
      NiveauCompetence.intermediaire => '●',
      NiveauCompetence.fonctionnel => '▲',
    };
  }
}
