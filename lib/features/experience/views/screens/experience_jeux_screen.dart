import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/enum_global.dart';
import '../../../../core/affichage/screen_size_detector.dart';
import '../../controllers/providers/card_flight_provider.dart';
import '../../data/experiences_data.dart';
import '../widgets/animated_card_flight.dart';
import '../widgets/experience_card.dart';

const Map<String, Color> tagColors = {
  'flutter': Colors.blue,
  'devOps': Colors.red,
  'react': Colors.white,
  'firebase': Colors.grey,
};

class ExperienceJeuxScreen extends ConsumerStatefulWidget {
  const ExperienceJeuxScreen({super.key, required this.experiences});
  final List<Experience> experiences;

  @override
  ConsumerState createState() => _ExperienceJeuxScreenState();
}

class _ExperienceJeuxScreenState extends ConsumerState<ExperienceJeuxScreen> {
  final Map<String, GlobalKey> _cardKeys = {};
  Experience? activeExperience;

  @override
  void initState() {
    super.initState();
    for (var exp in widget.experiences) {
      _cardKeys[exp.entreprise] = GlobalKey();
    }
  }

  /// Animation carte vers le haut
  /// remplacer par _FlyCard
  void _flyCard(BuildContext context, Experience exp, {required bool toTop}) {
    final key = _cardKeys[exp.entreprise];
    if (key == null) return;

    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final start = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    final cardNotifier = ref.read(cardFlightProvider.notifier);
    final info = ref.watch(responsiveInfoProvider);

    // marquer l'état initial
    cardNotifier.setStateForCard(
      exp.entreprise,
      toTop ? CardFlightState.flyingUp : CardFlightState.flyingDown,
    );

    OverlayEntry? entry;
    entry = OverlayEntry(
      builder: (_) => AnimatedCardFlight(
        start: start,
        end: toTop
            ? Offset(info.size.width / 2 - size.width / 2, 20)
            : start, // retour pile
        size: size,
        flyUp: toTop,
        child: _cardWidget(exp),
        onEnd: () {
          entry?.remove();
          cardNotifier.setStateForCard(
            exp.entreprise,
            toTop ? CardFlightState.inTop : CardFlightState.inPile,
          );
        },
      ),
    );

    overlay.insert(entry);
  }

  Widget _cardWidget(Experience exp, {Key? key}) => Card(
    key: key,
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

  Widget _buildCardPile(ResponsiveInfo info, List<Experience> experiences) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: info.size.width * 0.35,
        child: Stack(
          children: experiences.asMap().entries.map((entry) {
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
                      child: _cardWidget(
                        exp,
                        key: ValueKey(
                          "feedback_${exp.entreprise}_${DateTime.now().millisecondsSinceEpoch}",
                        ),
                      ),
                    ),
                  ),
                  childWhenDragging: SizedBox(
                    width: 120,
                    height: 160,
                    child: Opacity(opacity: 0.3, child: _pileCard(exp)),
                  ),
                  child: SizedBox(
                    key: _cardKeys[exp.entreprise],
                    width: 120,
                    height: 160,
                    child: _pileCard(exp),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSelectedCards(List<Experience> selected) {
    if (selected.isEmpty) {
      return Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Text(
            'Déposez des jetons dans le pot pour voir les cartes correspondantes.',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.only(top: 20, left: 100),
          child: Row(
            children: selected
                .map(
                  (e) =>
                      SizedBox(width: 120, height: 160, child: _cardWidget(e)),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTopDragTarget() {
    return Align(
      alignment: Alignment.topRight,
      child: DragTarget<Experience>(
        onWillAcceptWithDetails: (details) => true,
        onAcceptWithDetails: (details) {
          setState(() {
            // Logique pour mettre à jour l'état de la carte
            final cardNotifier = ref.read(cardFlightProvider.notifier);
            cardNotifier.setStateForCard(
              details.data.entreprise,
              CardFlightState.inTop,
            );
          });
        },
        builder: (context, candidateData, rejectedData) {
          final selected = widget.experiences
              .where(
                (e) =>
                    (ref.watch(cardFlightProvider)[e.entreprise] ??
                        CardFlightState.inPile) ==
                    CardFlightState.inTop,
              )
              .toList();

          if (selected.isEmpty) {
            return const SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'Déposez une carte ici',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 100,
              ),
              child: Row(
                children: selected
                    .map(
                      (exp) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: _buildMiniCard(exp),
                      ),
                    )
                    .toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardTarget(ResponsiveInfo info) {
    return Align(
      alignment: Alignment.center,
      child: DragTarget<Experience>(
        onAcceptWithDetails: (details) =>
            setState(() => activeExperience = details.data),
        builder: (_, _, _) {
          if (activeExperience == null) {
            return Container(
              width: info.size.width * 0.5,
              height: info.size.height * 0.6,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withAlpha(128)),
              ),
              child: const Text("👉 Glisse une carte ici"),
            );
          }
          return AnimatedContainer(
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
            child: ExperienceCard(experience: activeExperience!, pageOffset: 0),
          );
        },
      ),
    );
  }

  Widget _buildChip(Color color, String tag) => Draggable<String>(
    data: tag,
    feedback: Material(
      color: Colors.transparent,
      child: _chipVisual(color, tag, 0.8),
    ),
    childWhenDragging: SizedBox(width: 50, height: 50),
    child: _chipVisual(color, tag),
  );

  Widget _chipVisual(Color color, String tag, [double opacity = 1.0]) =>
      Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color.withAlpha((255 * opacity).toInt()),
          shape: BoxShape.circle,
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
        ),
        child: Center(
          child: Text(
            tag,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
      );

  Widget _buildChipPile(Color color, String tag) => SizedBox(
    height: 100,
    width: 50,
    child: Stack(
      alignment: Alignment.bottomCenter,
      children: List.generate(
        5,
        (i) => Positioned(bottom: i * 10.0, child: _buildChip(color, tag)),
      ),
    ),
  );

  Widget _interactivePot() {
    final activeTags = ref.watch(activeTagsProvider);
    final tagsNotifier = ref.read(activeTagsProvider.notifier);
    final cardNotifier = ref.read(cardFlightProvider.notifier);

    return Positioned(
      bottom: 30,
      right: 30,
      child: DragTarget<String>(
        onAcceptWithDetails: (details) async {
          final tag = details.data;
          if (!activeTags.contains(tag)) {
            // 1️⃣ Mettre à jour le pot
            tagsNotifier.state = [...activeTags, tag];

            // 2️⃣ Marquer les cartes correspondantes comme "flyingUp"
            final cardsToFly = widget.experiences
                .where((e) => e.tags.contains(tag))
                .toList();

            // 3️⃣ Lancer l'animation Overlay pour chaque carte
            for (var exp in cardsToFly) {
              if (mounted) {
                _flyCard(context, exp, toTop: true);
              }
            }
          }
        },
        builder: (context, candidateData, rejectedData) {
          final glow = candidateData.isNotEmpty;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 160,
            height: 160,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withAlpha(120),
              border: glow ? Border.all(color: Colors.yellow, width: 4) : null,
              boxShadow: glow
                  ? [
                      BoxShadow(
                        color: Colors.yellow.withAlpha((255 * 0.6).toInt()),
                        blurRadius: 20,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (activeTags.isEmpty)
                  const Text(
                    "Glisse un jeton ici",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                Wrap(
                  spacing: 4,
                  children: activeTags
                      .map(
                        (t) =>
                            _chipVisual(tagColors[t] ?? Colors.white, t, 0.3),
                      )
                      .toList(),
                ),
                if (activeTags.isNotEmpty)
                  ElevatedButton(
                    onPressed: () {
                      tagsNotifier.state = [];
                      for (var e in widget.experiences) {
                        _flyCard(context, e, toTop: false);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text("Vider le pot"),
                  ),
              ],
            ),
          );
        },
      ),
    );
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

  /// 🃏 Carte en grand au centre
  Widget _buildFullCard(Experience exp) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: 400,
      height: 500,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(blurRadius: 12, color: Colors.black26)],
      ),
      child: ExperienceCard(experience: exp, pageOffset: 0),
    );
  }

  /// [🃏🃏🃏🃏] NOUVEAU WIDGET pour la zone de cartes sélectionnées en haut
  Widget _buildSelectedCardsDisplay() {
    final selectedCards = widget.experiences
        .where(
          (e) =>
              (ref.watch(cardFlightProvider)[e.entreprise] ??
                  CardFlightState.inPile) ==
              CardFlightState.inTop,
        )
        .toList();

    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 100),
          child: Row(
            children: selectedCards.map((exp) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _buildMiniCard(exp),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(responsiveInfoProvider);
    final pile = widget.experiences
        .where(
          (e) =>
              (ref.watch(cardFlightProvider)[e.entreprise] ??
                  CardFlightState.inPile) ==
              CardFlightState.inPile,
        )
        .toList();

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/tapis-poker.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          _buildSelectedCardsDisplay(),
          _buildCardPile(info, pile),
          _buildCardTarget(info),
          _interactivePot(),
          _buildChip(tagColors['flutter']!, 'flutter'),
          _buildChip(tagColors['react']!, 'react'),
          _buildChip(tagColors['devOps']!, 'devOps'),
          _buildChip(tagColors['firebase']!, 'firebase'),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildChipPile(tagColors['flutter']!, 'flutter'),
                _buildChipPile(tagColors['devOps']!, 'devOps'),
                _buildChipPile(tagColors['react']!, 'react'),
                _buildChipPile(tagColors['firebase']!, 'firebase'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
