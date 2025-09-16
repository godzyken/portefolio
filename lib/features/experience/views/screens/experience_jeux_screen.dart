import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/experience/views/widgets/tap_chip.dart';

import '../../../../constants/enum_global.dart';
import '../../../../core/affichage/screen_size_detector.dart';
import '../../controllers/providers/card_flight_provider.dart';
import '../../data/experiences_data.dart';
import '../widgets/animated_card_overlay.dart';
import '../widgets/experience_card.dart';
import '../widgets/interactive_pot.dart';

class ExperienceJeuxScreen extends ConsumerStatefulWidget {
  const ExperienceJeuxScreen({super.key, required this.experiences});
  final List<Experience> experiences;

  @override
  ConsumerState createState() => _ExperienceJeuxScreenState();
}

class _ExperienceJeuxScreenState extends ConsumerState<ExperienceJeuxScreen> {
  final Map<String, GlobalKey> _cardKeys = {};
  Experience? activeExperience;
  final List<Experience> _potCards = [];

  @override
  void initState() {
    super.initState();
    for (var exp in widget.experiences) {
      _cardKeys[exp.entreprise] = GlobalKey();
    }
  }

  /// Fonction pour animer une carte vers un target
  void _flyCard(Experience exp, Offset target, {bool flyUp = true}) {
    final key = _cardKeys[exp.entreprise];
    if (key == null) return;
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final start = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final overlay = Overlay.of(context);

    ref
        .read(cardFlightProvider.notifier)
        .setStateForCard(
          exp.entreprise,
          flyUp ? CardFlightState.flyingUp : CardFlightState.inPile,
        );

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => AnimatedCardOverlay(
        start: start,
        end: target,
        size: size,
        child: _cardClone(exp),
        onEnd: () {
          entry.remove();
          ref
              .read(cardFlightProvider.notifier)
              .setStateForCard(
                exp.entreprise,
                flyUp ? CardFlightState.inTop : CardFlightState.inPile,
              );

          setState(() {
            if (flyUp) {
              // Mode pot (main de poker, max 4 cartes)
              if (!_potCards.contains(exp) && _potCards.length < 4) {
                _potCards.add(exp);
              }
              activeExperience =
                  null; // 👉 pas de détail quand on ajoute au pot
            } else {
              // Mode drag & drop (détail unique)
              activeExperience = exp;
              _potCards.clear(); // 👉 on vide la main pour ne pas mélanger
            }
          });
        },
      ),
    );

    overlay.insert(entry);
  }

  // Fonction callback pour le pot quand des cartes arrivent
  void _onCardsArrivedInPot(List<Experience> cards) {
    setState(() {
      activeExperience = null; // Très important !
      _potCards.clear();
      _potCards.addAll(cards.take(4)); // Max 4 cartes dans la main
    });
  }

  // Fonction callback pour vider le pot
  void _onPotCleared() {
    setState(() {
      _potCards.clear();
      activeExperience = null;
    });
  }

  // clone sans key
  Widget _cardClone(Experience exp) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          if (exp.image.isNotEmpty)
            Expanded(child: Image.asset(exp.image, fit: BoxFit.cover)),
          Padding(
            padding: const EdgeInsets.all(4),
            child: Text(
              exp.entreprise,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // Le Widget de la Carte (utilisé dans la pile)
  Widget _cardWidget(Experience exp) => Card(
    key: _cardKeys[exp.entreprise],
    elevation: 6,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Column(
      children: [
        if (exp.image.isNotEmpty)
          Expanded(child: Image.asset(exp.image, fit: BoxFit.cover)),
        Padding(
          padding: const EdgeInsets.all(4),
          child: Text(
            exp.entreprise,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ),
  );

  /// Carte dans la pile
  Widget _pileCard(Experience exp) =>
      SizedBox(width: 120, height: 160, child: _cardWidget(exp));

  // La construction de la Pile
  Widget _buildCardPile(ResponsiveInfo info) {
    final pile = widget.experiences
        .where(
          (e) =>
              (ref.watch(cardFlightProvider)[e.entreprise] ??
                  CardFlightState.inPile) ==
              CardFlightState.inPile,
        )
        .toList();

    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: info.size.width * 0.35,
        child: Stack(
          children: pile.asMap().entries.map((entry) {
            final exp = entry.value;
            final angle =
                (entry.key % 2 == 0 ? 1 : -1) * (5 + entry.key).toDouble();

            return Positioned(
              top: 20.0 * entry.key,
              left: 0,
              child: Transform.rotate(
                angle: angle * pi / 180,
                child: Draggable<Experience>(
                  data: exp,
                  feedback: Material(
                    color: Colors.transparent,
                    child: SizedBox(
                      width: 120,
                      height: 160,
                      child: _cardClone(exp),
                    ),
                  ),
                  childWhenDragging: SizedBox(
                    width: 120,
                    height: 160,
                    child: Opacity(opacity: 0.3, child: _cardClone(exp)),
                  ),
                  child: SizedBox(
                    width: 120,
                    height: 160,
                    child: _cardClone(exp),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Zone centrale pour déposer la carte
  Widget _buildCardTarget(ResponsiveInfo info) {
    return DragTarget<Experience>(
      onAcceptWithDetails: (details) {
        setState(() {
          activeExperience = details.data;
          _potCards.clear(); // Vider le pot si on fait du drag & drop direct
        });
      },
      builder: (context, candidateData, rejectedData) {
        // Priorité 1: Mode drag & drop (1 carte au centre)
        if (activeExperience != null && _potCards.isEmpty) {
          return Align(
            alignment: Alignment.center,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: 400,
              height: 500,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(blurRadius: 12, color: Colors.black26),
                ],
              ),
              child: ExperienceCard(
                experience: activeExperience!,
                pageOffset: 0,
              ),
            ),
          );
        }

        // Priorité 2: Mode "main de poker" (cartes du pot)
        if (_potCards.isNotEmpty) {
          return Align(
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha((255 * 0.7).toInt()),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.yellow, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellow.withAlpha((255 * 0.5).toInt()),
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
                          width: 120,
                          height: 160,
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

        // Priorité 3: Zone vide par défaut
        return Align(
          alignment: Alignment.center,
          child: Container(
            width: info.size.width * 0.5,
            height: info.size.height * 0.6,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withAlpha(128)),
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

  List<Widget> _buildScatteredChips() {
    return [
      Positioned(
        top: 120,
        right: 80,
        child: TagChip(
          tag: 'flutter',
          color: tagColors['flutter'] ?? Colors.grey,
        ),
      ),
      Positioned(
        top: 200,
        right: 100,
        child: TagChip(
          tag: 'angular',
          color: tagColors['angular'] ?? Colors.grey,
        ),
      ),
      Positioned(
        bottom: 250,
        right: 80,
        child: TagChip(
          tag: 'devOps',
          color: tagColors['devOps'] ?? Colors.grey,
        ),
      ),
      Positioned(
        bottom: 180,
        right: 140,
        child: TagChip(
          tag: 'firebase',
          color: tagColors['firebase'] ?? Colors.grey,
        ),
      ),
    ];
  }

  /// 🃏 Carte réduite
  Widget _buildMiniCard(Experience exp) {
    return SizedBox(
      width: 120,
      height: 160,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            if (exp.image.isNotEmpty)
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.asset(exp.image, fit: BoxFit.cover),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                exp.entreprise,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
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

  Widget _buildChipPile(Color color, String tag) => SizedBox(
    height: 120,
    width: 80,
    child: Stack(
      alignment: Alignment.bottomCenter,
      children: List.generate(
        5,
        (i) => Positioned(
          bottom: i * 10.0,
          child: TagChip(color: color, tag: tag),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(responsiveInfoProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Tapis de fond
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/tapis-poker.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          _buildCardPile(info),
          _buildCardTarget(info),
          InteractivePot(
            experiences: widget.experiences,
            cardKeys: _cardKeys,
            flyCard: _flyCard,
            onCardsArrivedInPot: _onCardsArrivedInPot,
            onPotCleared: _onPotCleared,
          ),
          ..._buildScatteredChips(),
          Positioned(
            bottom: 20,
            left: 20,
            child: Wrap(
              spacing: 8,
              children: tagColors.keys
                  .map((t) => _buildChipPile(tagColors[t]!, t))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
