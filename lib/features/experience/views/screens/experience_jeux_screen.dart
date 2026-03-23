import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';
import 'package:portefolio/features/generator/views/widgets/immersive_experience_detail.dart';

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
  late final Map<String, GlobalKey> _cardKeys = {};

  /// La carte affichée en vue détail centrale (mode card unique).
  Experience? _activeExperience;

  /// Les cartes dans le "pot" (mode main de poker, ≤4 cartes).
  final List<Experience> _potCards = [];

  // ─── Initialisation ────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _initializeCardKeys();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _initializeCardKeys() {
    // On ne vide plus brutalement la map avec .clear()
    // pour éviter de perdre les références stables.
    for (final exp in widget.experiences) {
      // ✅ On utilise putIfAbsent : on crée la clé uniquement si l'ID est nouveau
      _cardKeys.putIfAbsent(
          exp.id, () => GlobalKey(debugLabel: 'card_${exp.id}'));
    }

    // Optionnel : Nettoyer les clés des expériences qui ne sont plus dans la liste
    final currentIds = widget.experiences.map((e) => e.id).toSet();
    _cardKeys.removeWhere((id, _) => !currentIds.contains(id));
  }

  @override
  void didUpdateWidget(ExperienceJeuxScreen old) {
    super.didUpdateWidget(old);
    if (old.experiences.length != widget.experiences.length ||
        !_areSameLists(old.experiences, widget.experiences)) {
      _initializeCardKeys();
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  bool _areSameLists(List<Experience> a, List<Experience> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  // ─── Navigation vers le détail ─────────────────────────────────────────────

  void _openDetail(Experience exp) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ImmersiveExperienceDetail(experience: exp),
      ),
    );
  }

  // ─── Gestion de l'état central (drop) ──────────────────────────────────────

  /// Appelé quand une carte est droppée dans la zone centrale.
  void _onCardDroppedCenter(Experience exp) {
    if (!mounted) return;
    setState(() {
      _activeExperience = exp;
      _potCards.clear();
    });
  }

  /// Appelé quand les cartes arrivent dans le pot (via drag de jeton).
  void _onCardsArrivedInPot(List<Experience> cards) {
    if (!mounted) return;
    setState(() {
      _activeExperience = null;
      _potCards
        ..clear()
        ..addAll(cards.take(4));
    });
  }

  /// Vide le pot et remet à zéro.
  void _onPotCleared() {
    if (!mounted) return;
    setState(() {
      _potCards.clear();
      _activeExperience = null;
    });
  }

  // ─── Animation de vol de carte (overlay) ───────────────────────────────────

  void _flyCard(
    Experience exp,
    Offset target,
    BuildContext cardContext, {
    bool flyUp = true,
  }) {
    final key = _cardKeys[exp.id];
    if (key == null || key.currentContext == null) return;

    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final start = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final overlay = Overlay.of(context);

    ref.read(cardFlightProvider.notifier).setStateForCard(
          exp.id,
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
        child: _CardClone(exp: exp),
        onEnd: () {
          entry.remove();
          ref.read(cardFlightProvider.notifier).setStateForCard(
                exp.id,
                flyUp ? CardFlightState.inTop : CardFlightState.inPile,
              );
        },
      ),
    );
    overlay.insert(entry);
  }

  // ─── Clone léger d'une carte (stateless) ───────────────────────────────────

  // ─── Pile de cartes (colonne gauche) ───────────────────────────────────────

  Widget _buildCardPile(ResponsiveInfo info) {
    final flightStates = ref.watch(cardFlightProvider);
    final pile = widget.experiences.where((e) {
      final state = flightStates[e.id] ?? CardFlightState.inPile;
      return state == CardFlightState.inPile;
    }).toList();

    const double maxCardWidth = 80;
    final cardWidth =
        min(info.size.width * 0.11, maxCardWidth).clamp(50.0, 80.0);
    final cardHeight = cardWidth * 1.33;

    // ✅ FIX layout : ListView avec items de hauteur fixe — pas de Stack
    // dans un ScrollView à hauteur infinie, ce qui causait RenderTransform
    // "infinite size" (unbounded height constraint).
    return SizedBox(
      width: info.size.width * 0.22,
      child: ListView.builder(
        padding: EdgeInsets.only(
          top: info.size.height * 0.12,
          left: 8,
          right: 8,
          bottom: 16,
        ),
        itemCount: pile.length,
        itemExtent: cardHeight + 10, // hauteur fixe par item → pas d'infini
        itemBuilder: (context, index) {
          final exp = pile[index];
          final angle = (index % 2 == 0 ? 1 : -1) * ((index % 5) + 3.0);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Transform.rotate(
              angle: angle * pi / 180,
              // ✅ alignment centre pour éviter le débordement lors de la rotation
              alignment: Alignment.center,
              child: SizedBox(
                key: _cardKeys[exp.id],
                width: cardWidth,
                height: cardHeight,
                child: Draggable<Experience>(
                  data: exp,
                  feedback: Material(
                    color: Colors.transparent,
                    child: SizedBox(
                      width: cardWidth,
                      height: cardHeight,
                      child: _CardClone(exp: exp),
                    ),
                  ),
                  childWhenDragging: SizedBox(
                    width: cardWidth,
                    height: cardHeight,
                    child: Opacity(
                      opacity: 0.3,
                      child: _CardClone(exp: exp),
                    ),
                  ),
                  child: SizedBox(
                    key: _cardKeys[exp.id],
                    width: cardWidth,
                    height: cardHeight,
                    child: _CardClone(exp: exp),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  // ─── Zone cible centrale ───────────────────────────────────────────────────

  Widget _buildCardTarget(ResponsiveInfo info) {
    final width =
        info.isLandscape ? info.size.width * 0.4 : info.size.width * 0.5;
    final height =
        info.isLandscape ? info.size.height * 0.7 : info.size.height * 0.6;

    const double maxCardWidth = 120.0;
    final cardWidth = min(info.size.width * 0.10, maxCardWidth);
    final cardHeight = cardWidth * 1.33;

    return DragTarget<Experience>(
      onAcceptWithDetails: (details) => _onCardDroppedCenter(details.data),
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;

        // ── Vue "main de poker" (plusieurs cartes dans le pot) ──────────────
        if (_potCards.isNotEmpty && _activeExperience == null) {
          return _PokerHandView(
            potCards: _potCards,
            cardWidth: cardWidth,
            cardHeight: cardHeight,
            isHovering: isHovering,
          );
        }

        // ── Vue "carte unique" (drop d'une carte) ───────────────────────────
        if (_activeExperience != null && _potCards.isEmpty) {
          return AnimatedContainer(
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
            child: PokerExperienceCard(
              experience: _activeExperience!,
              isCenter: true,
              onTap: () => _openDetail(_activeExperience!),
            ),
          );
        }

        // ── Zone vide (état initial ou après reset) ─────────────────────────
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              color: isHovering
                  ? Colors.yellowAccent
                  : Colors.grey.withValues(alpha: 0.5),
              width: isHovering ? 3 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color:
                isHovering ? Colors.yellowAccent.withValues(alpha: 0.08) : null,
          ),
          child: const ResponsiveText.headlineMedium(
            "👉 Glisse une carte ici\n🎰 ou dépose un jeton",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        );
      },
    );
  }

  // ─── Jetons éparpillés (colonne droite) ────────────────────────────────────

  List<Widget> _buildScatteredChips(ResponsiveInfo info) {
    const double maxChipSize = 80.0;
    final chipSize = min(info.size.height * 0.15, maxChipSize);

    final positions = [
      (0.10, 0.08, 'Flutter'),
      (0.18, 0.14, 'Full-Stack'),
      (0.28, 0.09, 'CI/CD'),
      (0.06, 0.06, 'Riverpod'),
    ];

    return positions.map((pos) {
      return Positioned(
        top: info.size.height * pos.$1,
        right: info.size.width * pos.$2,
        key: ValueKey('chip_${pos.$3}'),
        child: CompetenceChip(
          competenceName: pos.$3,
          size: chipSize,
        ),
      );
    }).toList();
  }

  // ─── Layout principal ──────────────────────────────────────────────────────

  Widget _buildLayout(ResponsiveInfo info) {
    return Stack(
      children: [
        // Fond
        Positioned.fill(
          child: SmartImage(
            path: 'assets/images/backgrounds/tapis_poker.png',
            responsiveSize: ResponsiveImageSize.xlarge,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            enableShimmer: true,
          ),
        ),

        Column(
          children: [
            // ── Ligne principale ────────────────────────────────────────────
            Expanded(
              flex: 85,
              child: Row(
                children: [
                  // Colonne gauche : pile de cartes
                  Expanded(
                    flex: 25,
                    child: _buildCardPile(info),
                  ),
                  // Colonne centrale : zone de drop
                  Expanded(
                    flex: 50,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: info.size.width * 0.01,
                        vertical: info.size.height * 0.02,
                      ),
                      child: Center(child: _buildCardTarget(info)),
                    ),
                  ),
                  // Colonne droite : jetons
                  Expanded(
                    flex: 25,
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: info.size.width * 0.01,
                        left: info.size.width * 0.02,
                        top: info.size.height * 0.05,
                      ),
                      child: Stack(
                          fit: StackFit.expand,
                          children: _buildScatteredChips(info)),
                    ),
                  ),
                ],
              ),
            ),

            // ── Ligne inférieure : compétences + pot ────────────────────────
            Expanded(
              flex: 40,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Compétences par niveau
                  Expanded(
                    flex: 60,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: const CompetencesPilesByNiveau(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Pot interactif
                  Expanded(
                    flex: 40,
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: info.size.width * 0.02,
                        left: info.size.width * 0.02,
                        bottom: info.size.height * 0.02,
                        top: info.size.height * 0.02,
                      ),
                      child: InteractivePot(
                        experiences: widget.experiences,
                        cardKeys: _cardKeys,
                        flyCard: _flyCard,
                        onCardsArrivedInPot: _onCardsArrivedInPot,
                        onPotCleared: _onPotCleared,
                      ),
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

  // ─── Build ─────────────────────────────────────────────────────────────────

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
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.screen_rotation, size: 80, color: Colors.yellow),
                SizedBox(height: 24),
                ResponsiveText.headlineMedium(
                  "🔄 Tourne ton appareil en mode paysage\npour accéder au jeu !",
                  textAlign: TextAlign.center,
                  style: TextStyle(
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

    return Scaffold(body: _buildLayout(info));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Clone léger d'une carte (widget stateless, pas de loading)
// ─────────────────────────────────────────────────────────────────────────────

class _CardClone extends StatelessWidget {
  final Experience exp;
  const _CardClone({required this.exp});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.hasBoundedWidth ? constraints.maxWidth : 80.0;
        final h = constraints.hasBoundedHeight ? constraints.maxHeight : 106.0;
        return SizedBox(
          width: w,
          height: h,
          child: Card(
            elevation: 6,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                if (exp.image.isNotEmpty)
                  SizedBox(
                    height: h * 0.70,
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12)),
                      child: SmartImage(
                        path: exp.image,
                        fit: BoxFit.cover,
                        // ✅ FIX 2 : pas de shimmer dans les clones pour éviter
                        // le chargement circulaire infini
                        enableShimmer: false,
                        autoPreload: false,
                        fallbackIcon: Icons.business,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: ResponsiveText.bodySmall(
                    exp.entreprise,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vue "main de poker" (plusieurs cartes dans le pot)
// ─────────────────────────────────────────────────────────────────────────────

class _PokerHandView extends StatelessWidget {
  final List<Experience> potCards;
  final double cardWidth;
  final double cardHeight;
  final bool isHovering;

  const _PokerHandView({
    required this.potCards,
    required this.cardWidth,
    required this.cardHeight,
    required this.isHovering,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: isHovering ? 0.8 : 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHovering ? Colors.white : Colors.yellow,
          width: 3,
        ),
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
          const ResponsiveText.titleLarge(
            "🎰 Main de Poker 🎰",
            style: TextStyle(
              color: Colors.yellow,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: potCards.take(4).map((exp) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: SizedBox(
                  width: cardWidth,
                  height: cardHeight,
                  child: _CardClone(exp: exp),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          ResponsiveText.headlineSmall(
            "${potCards.length} carte(s) sélectionnée(s)",
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
