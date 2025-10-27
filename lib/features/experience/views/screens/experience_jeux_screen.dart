import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/generator/views/widgets/immersive_experience_detail.dart';
import 'package:portefolio/features/parametres/views/widgets/smart_image.dart';

import '../../../../constants/enum_global.dart';
import '../../../../core/affichage/screen_size_detector.dart';
import '../../controllers/providers/card_flight_provider.dart';
import '../../data/experiences_data.dart';
import '../widgets/experience_widgets_extentions.dart';

class ExperienceJeuxScreen extends ConsumerStatefulWidget {
  const ExperienceJeuxScreen({super.key, required this.experiences});
  final List<Experience> experiences;

  @override
  ConsumerState createState() => _ExperienceJeuxScreenState();
}

class _ExperienceJeuxScreenState extends ConsumerState<ExperienceJeuxScreen> {
  // ✅ FIX 1: Utiliser l'ID unique au lieu de l'entreprise
  late final Map<String, GlobalKey> _cardKeys = {};
  Experience? activeExperience;
  final List<Experience> _potCards = [];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // ✅ FIX 2: S'assurer que chaque key est unique avec l'ID
    _initializeCardKeys();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _initializeCardKeys() {
    _cardKeys.clear();
    for (var exp in widget.experiences) {
      _cardKeys[exp.id] = GlobalKey(debugLabel: 'card_${exp.id}');
    }
  }

  @override
  void didUpdateWidget(ExperienceJeuxScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Si la liste des expériences change, réinitialiser les keys
    if (oldWidget.experiences.length != widget.experiences.length ||
        !_isSameExperienceList(oldWidget.experiences, widget.experiences)) {
      _initializeCardKeys();
    }
  }

  /// Vérifier si deux listes d'expériences sont identiques
  bool _isSameExperienceList(List<Experience> list1, List<Experience> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].id != list2[i].id) return false;
    }
    return true;
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  /// Fonction pour animer une carte vers un target
  void _flyCard(
    Experience exp,
    Offset target,
    BuildContext cardContext, {
    bool flyUp = true,
  }) {
    // ✅ FIX 3: Utiliser l'ID pour récupérer la key
    final key = _cardKeys[exp.id];
    if (key == null || key.currentContext == null) return;

    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final start = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final overlay = Overlay.of(context);

    ref.read(cardFlightProvider.notifier).setStateForCard(
          exp.id, // ✅ Utiliser l'ID au lieu de l'entreprise
          flyUp ? CardFlightState.flyingUp : CardFlightState.inPile,
        );

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => AnimatedCardOverlay(
        key: ValueKey(
            'overlay_${exp.id}_${DateTime.now().millisecondsSinceEpoch}'),
        start: start,
        end: target,
        size: size,
        child: _cardClone(exp),
        onEnd: () {
          entry.remove();
          ref.read(cardFlightProvider.notifier).setStateForCard(
                exp.id,
                flyUp ? CardFlightState.inTop : CardFlightState.inPile,
              );

          if (mounted) {
            setState(() {
              if (flyUp) {
                if (!_potCards.contains(exp) && _potCards.length < 4) {
                  _potCards.add(exp);
                }
                activeExperience = null;
              } else {
                activeExperience = exp;
                _potCards.clear();
              }
            });
          }
        },
      ),
    );

    overlay.insert(entry);
  }

  void _onCardsArrivedInPot(List<Experience> cards) {
    if (!mounted) return;
    setState(() {
      activeExperience = null;
      _potCards.clear();
      _potCards.addAll(cards.take(4));
    });
  }

  void _onPotCleared() {
    if (!mounted) return;
    setState(() {
      _potCards.clear();
      activeExperience = null;
    });
  }

  // ✅ FIX 4: Éviter le warning Impeller avec RepaintBoundary
  Widget _cardClone(Experience exp) {
    return RepaintBoundary(
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            if (exp.image.isNotEmpty)
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: SmartImage(path: exp.image, fit: BoxFit.cover),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                exp.entreprise,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPile(ResponsiveInfo info) {
    final pile = widget.experiences
        .where(
          (e) =>
              (ref.watch(cardFlightProvider)[e.id] ?? CardFlightState.inPile) ==
              CardFlightState.inPile,
        )
        .toList();

    // ✅ LOGIQUE DE TAILLE MAXIMALE
    // 1. Définir une taille maximale souhaitée pour la largeur des cartes.
    const double maxCardWidth = 80;

    // ✅ ÉTAPE 2: RENDRE LES CARTES PROPORTIONNELLES
    final proportionalCardWidth = info.size.width * 0.11;

    // 3. Utiliser la plus petite des deux valeurs.
    //    - Sur un grand écran, proportionalCardWidth > 140, donc cardWidth = 140.
    //    - Sur un petit écran, proportionalCardWidth < 140, donc cardWidth = proportionalCardWidth.
    final cardWidth = min(proportionalCardWidth, maxCardWidth);
    final cardHeight = cardWidth * 1.33; // Le ratio est conservé

    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: info.size.width * 0.2,
        child: Stack(
          children: pile.asMap().entries.map((entry) {
            final exp = entry.value;
            final angle =
                (entry.key % 2 == 0 ? 1 : -1) * (5 + entry.key).toDouble();

            return Positioned(
              top: (cardHeight * 0.15) * entry.key,
              left: 1,
              child: Transform.rotate(
                angle: angle * pi / 180,
                child: Draggable<Experience>(
                  data: exp,
                  feedback: Material(
                    color: Colors.transparent,
                    child: SizedBox(
                      width: cardWidth,
                      height: cardHeight,
                      child: _cardClone(exp),
                    ),
                  ),
                  childWhenDragging: SizedBox(
                    width: cardWidth,
                    height: cardHeight,
                    // ✅ FIX 5: Utiliser Opacity correctement
                    child: Opacity(
                      opacity: 0.3,
                      child: RepaintBoundary(child: _cardClone(exp)),
                    ),
                  ),
                  child: SizedBox(
                    width: cardWidth,
                    height: cardHeight,
                    child: Card(
                      key: ValueKey('card_${exp.id}'), // ✅ Utiliser l'ID
                      child: _cardClone(exp),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCardTarget(ResponsiveInfo info) {
    final width =
        info.isLandscape ? info.size.width * 0.4 : info.size.width * 0.5;
    final height =
        info.isLandscape ? info.size.height * 0.7 : info.size.height * 0.6;

    // ✅ LOGIQUE DE TAILLE MAXIMALE APPLIQUÉE ICI AUSSI
    const double maxCardWidth = 120.0; // Un peu plus petit pour le pot
    final proportionalCardWidth = info.size.width * 0.10;
    final cardWidth = min(proportionalCardWidth, maxCardWidth);
    final cardHeight = cardWidth * 1.33;

    return DragTarget<Experience>(
      onAcceptWithDetails: (details) {
        if (!mounted) return;
        setState(() {
          activeExperience = details.data;
          _potCards.clear();
        });
      },
      builder: (context, candidateData, rejectedData) {
        if (activeExperience != null && _potCards.isEmpty) {
          return Align(
            alignment: Alignment.center,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: width,
              height: height,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(blurRadius: 12, color: Colors.black26),
                ],
              ),
              child: RepaintBoundary(
                child: PokerExperienceCard(
                  experience: activeExperience!,
                  isCenter: true,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => ImmersiveExperienceDetail(
                            experience: activeExperience!)),
                  ),
                ),
              ),
            ),
          );
        }

        if (_potCards.isNotEmpty) {
          return Align(
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.yellow, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellow.withValues(alpha: 0.5),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "🎰 Main de Poker 🎰",
                    style: TextStyle(
                      color: Colors.yellow,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: _potCards.take(4).map((exp) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: SizedBox(
                          width: cardWidth,
                          height: cardHeight,
                          child: _cardClone(exp),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "${_potCards.length} carte(s) sélectionnée(s)",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }

        return Align(
          alignment: Alignment.center,
          child: Container(
            width: width,
            height: height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "👉 Glisse une carte ici\n🎰 ou utilise les jetons",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildScatteredChips(ResponsiveInfo info) {
    // ✅ LOGIQUE DE TAILLE MAXIMALE
    // 1. Définir une taille maximale souhaitée pour les jetons.
    const double maxChipSize = 80.0;

    // 2. Calculer la taille proportionnelle comme avant.
    final proportionalChipSize = info.size.height * 0.15;

    // 3. Utiliser la plus petite des deux valeurs.
    final chipSize = min(proportionalChipSize, maxChipSize);

    // Définir les positions en pourcentage de la largeur/hauteur pour qu'elles s'adaptent.
    // Format: [top%, right%, competenceName]
    final positions = [
      [0.15, 0.10, 'Flutter'], // 15% du haut, 10% de la droite
      [0.16, 0.15, 'Qualite'],
      [0.60, 0.12, 'Relation Client'],
      [0.75, 0.20, 'Logistique'],
    ];

    return positions.map((pos) {
      final competenceName = pos[2] as String;

      return Positioned(
        top: info.size.height * (pos[0] as double),
        right: info.size.width * (pos[1] as double),
        key: ValueKey('scattered_chip_${competenceName}_${pos[0]}_${pos[1]}'),
        child: CompetenceChip(
          competenceName: competenceName,
          size: chipSize,
        ),
      );
    }).toList();
  }

  Widget _buildLayout(ResponsiveInfo info) {
    return Stack(
      children: [
        Positioned.fill(
          child: SmartImage(
            path: 'assets/images/tapis-poker.png',
            fit: BoxFit.cover,
          ),
        ),
        Column(
          children: [
            Expanded(
              flex: 8,
              child: Row(
                children: [
                  Expanded(flex: 2, child: _buildCardPile(info)),
                  Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          Expanded(flex: 7, child: _buildCardTarget(info)),
                          const SizedBox(height: 10),
                          Expanded(
                            flex: 3,
                            child: SizedBox(
                              height: info.size.height * 0.2,
                              child: const CompetencesPilesByNiveau(),
                            ),
                          ),
                        ],
                      )),
                  Expanded(
                    flex: 2,
                    child: Stack(
                      children: [
                        InteractivePot(
                          experiences: widget.experiences,
                          cardKeys: _cardKeys,
                          flyCard: _flyCard,
                          onCardsArrivedInPot: _onCardsArrivedInPot,
                          onPotCleared: _onPotCleared,
                        ),
                        ..._buildScatteredChips(info),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(responsiveInfoProvider);
    final bool isSmartphone = info.size.shortestSide < 600;
    final bool isLandscape = info.isLandscape;

    if (isSmartphone && !isLandscape) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.screen_rotation,
                    size: 80, color: Colors.yellow),
                const SizedBox(height: 24),
                Text(
                  isSmartphone
                      ? "🔄 Tourne ton appareil en mode paysage\npour accéder au jeu !"
                      : "📺 L'écran est trop petit pour le mode jeu.\nEssaie sur un appareil plus grand.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: _buildLayout(info),
    );
  }
}
