import 'package:flutter/material.dart';

import '../../data/competences_data.dart';
import 'competences_chip.dart';

class CompetenceNiveauPile extends StatefulWidget {
  final NiveauCompetence niveau;
  final int nombreJetons;

  const CompetenceNiveauPile({
    super.key,
    required this.niveau,
    this.nombreJetons = 5,
  });

  @override
  State<CompetenceNiveauPile> createState() => _CompetenceNiveauPileState();
}

class _CompetenceNiveauPileState extends State<CompetenceNiveauPile> {
  late List<Competence> _jetons;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    // on prend les compétences disponibles, sinon on génère des placeholders
    final competences = getCompetencesByNiveau(widget.niveau);
    _jetons = competences.isNotEmpty
        ? List.from(competences)
        : List.generate(
            widget.nombreJetons,
            (i) => Competence(
              nom: 'Jeton ${i + 1}',
              niveau: widget.niveau,
              couleur: couleursNiveau[widget.niveau]!,
              valeur: i + 1,
              entreprises: [],
              description: 'Compétence générique de niveau ${widget.niveau}',
            ),
          );
  }

  String get niveauLabel {
    return switch (widget.niveau) {
      NiveauCompetence.expert => 'Expert',
      NiveauCompetence.confirme => 'Confirmé',
      NiveauCompetence.intermediaire => 'Intermédiaire',
      NiveauCompetence.fonctionnel => 'Fonctionnel',
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_jetons.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 120,
        height: _isExpanded ? 220 : 140,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Pile réelle : chaque jeton est interactif
            ..._jetons.asMap().entries.map((entry) {
              final index = entry.key;
              final competence = entry.value;
              return Positioned(
                bottom: 20 + (index * 8.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _jetons.removeAt(index);
                    });
                  },
                  child: Draggable<Competence>(
                    data: competence,
                    feedback: Material(
                      color: Colors.transparent,
                      child: CompetenceChip(competenceName: competence.nom),
                    ),
                    childWhenDragging: const SizedBox.shrink(),
                    onDragCompleted: () {
                      setState(() {
                        _jetons.removeAt(index);
                      });
                    },
                    child: CompetenceChip(competenceName: competence.nom),
                  ),
                ),
              );
            }),

            // Label du niveau
            Positioned(
              bottom: 5,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha((255 * 0.7).toInt()),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  niveauLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Indicateur nombre
            Positioned(
              top: 5,
              right: 5,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: couleursNiveau[widget.niveau]!,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    '${_jetons.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
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
}

// Widget pour organiser toutes les piles par niveau
class CompetencesPilesByNiveau extends StatelessWidget {
  const CompetencesPilesByNiveau({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned(
          bottom: 20,
          left: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Compétences',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Expert (Or)
                  CompetenceNiveauPile(niveau: NiveauCompetence.expert),
                  SizedBox(width: 15),
                  // Confirmé (Argent)
                  CompetenceNiveauPile(niveau: NiveauCompetence.confirme),
                  SizedBox(width: 15),
                  // Intermédiaire (Bronze)
                  CompetenceNiveauPile(
                    niveau: NiveauCompetence.intermediaire,
                  ),
                  SizedBox(width: 15),
                  // Fonctionnel (Cuivre)
                  CompetenceNiveauPile(niveau: NiveauCompetence.fonctionnel),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}
