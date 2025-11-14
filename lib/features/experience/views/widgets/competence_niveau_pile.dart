import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/ui/widgets/responsive_text.dart';

import '../../../../core/affichage/screen_size_detector.dart';
import '../../data/competences_data.dart';
import 'competences_chip.dart';

class CompetenceNiveauPile extends ConsumerStatefulWidget {
  final NiveauCompetence niveau;
  final int nombreJetons;

  const CompetenceNiveauPile({
    super.key,
    required this.niveau,
    this.nombreJetons = 5,
  });

  @override
  ConsumerState<CompetenceNiveauPile> createState() =>
      _CompetenceNiveauPileState();
}

class _CompetenceNiveauPileState extends ConsumerState<CompetenceNiveauPile> {
  late List<Competence> _jetons;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    // on prend les compétences disponibles, sinon on génère des placeholders
    _initializeJetons();
  }

  void _initializeJetons() {
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
    final info = ref.watch(responsiveInfoProvider);

    // Dimensions adaptatives
    final double width = switch (info.type) {
      DeviceType.watch => 70,
      DeviceType.mobile => 90,
      DeviceType.smallTablet => 100,
      DeviceType.tablet => 110,
      DeviceType.desktop => 130,
      DeviceType.largeDesktop => 150,
    };

    final double height = _isExpanded
        ? width * (info.isMobile ? 2.0 : 1.6)
        : width * (info.isMobile ? 1.3 : 1.1);

    final double offsetStep = info.isMobile ? 6 : 8;

    if (_jetons.isEmpty) {
      return const ResponsiveBox(paddingSize: ResponsiveSpacing.xs);
    }

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: width,
        height: height,
        child: Stack(
          alignment: Alignment.bottomCenter,
          fit: StackFit.loose,
          clipBehavior: Clip.none,
          children: [
            // Pile réelle : chaque jeton est interactif
            ..._jetons.asMap().entries.map((entry) {
              final index = entry.key;
              final competence = entry.value;
              return Positioned(
                bottom: 20 + (index * offsetStep),
                left: 0,
                key: ValueKey('pile_jeton_${competence.nom}_$index'),
                child: Center(
                  child: ResponsiveBox(
                    paddingSize: ResponsiveSpacing.s,
                    marginSize: ResponsiveSpacing.s,
                    alignment: Alignment.center,
                    width: 80,
                    height: 80,
                    child: Draggable<Competence>(
                      data: competence,
                      feedback: Material(
                        color: Colors.transparent,
                        child: CompetenceChip(competenceName: competence.nom),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: CompetenceChip(competenceName: competence.nom),
                      ),
                      onDragCompleted: () {
                        setState(() {
                          _jetons.removeAt(index);
                        });
                      },
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _jetons.removeAt(index);
                          });
                        },
                        child: CompetenceChip(competenceName: competence.nom),
                      ),
                    ),
                  ),
                ),
              );
            }),

            // Label du niveau
            Positioned(
              bottom: 5,
              left: 0,
              right: 0,
              child: Center(
                child: ResponsiveBox(
                  paddingSize: ResponsiveSpacing.s,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ResponsiveText.headlineMedium(
                    niveauLabel,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: info.isMobile ? 10 : 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // Indicateur nombre
            Positioned(
              top: 5,
              right: 5,
              child: ResponsiveBox(
                width: info.isMobile ? 18 : 20,
                height: info.isMobile ? 18 : 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: couleursNiveau[widget.niveau]!,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ResponsiveText.headlineSmall(
                  '${_jetons.length}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: info.isMobile ? 9 : 11,
                    fontWeight: FontWeight.bold,
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
class CompetencesPilesByNiveau extends ConsumerWidget {
  const CompetencesPilesByNiveau({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(responsiveInfoProvider);

    final isVerticalLayout = info.isPortrait && info.isMobile;
    final spacing = info.isMobile ? 8.0 : 16.0;

    final piles = const [
      NiveauCompetence.expert,
      NiveauCompetence.confirme,
      NiveauCompetence.intermediaire,
      NiveauCompetence.fonctionnel,
    ];

    return ResponsiveBox(
      paddingSize: ResponsiveSpacing.s,
      marginSize: ResponsiveSpacing.l,
      alignment: Alignment.bottomCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText.bodyMedium(
            'Compétences',
            style: TextStyle(
              color: Colors.white,
              fontSize: info.isMobile ? 14 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Flex(
              direction: isVerticalLayout ? Axis.vertical : Axis.horizontal,
              spacing: spacing,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              clipBehavior: Clip.hardEdge,
              children: [
                const SizedBox(
                  height: 10,
                ),
                for (final niveau in piles) ...[
                  CompetenceNiveauPile(niveau: niveau),
                  if (niveau != piles.last)
                    ResponsiveBox(
                      width: spacing,
                      height: spacing,
                    )
                ]
              ])
        ],
      ),
    );
  }
}
