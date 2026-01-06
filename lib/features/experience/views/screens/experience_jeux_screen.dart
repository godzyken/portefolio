import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/ui/widgets/smart_image.dart';
import 'package:portefolio/features/generator/views/widgets/immersive_experience_detail.dart';

import '../../../../constants/enum_global.dart';
import '../../../../core/affichage/screen_size_detector.dart';
import '../../../../core/ui/widgets/responsive_text.dart';
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
  Experience? activeExperience;
  final List<Experience> _potCards = [];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
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

    if (oldWidget.experiences.length != widget.experiences.length ||
        !_isSameExperienceList(oldWidget.experiences, widget.experiences)) {
      _initializeCardKeys();
    }
  }

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
                  child: SmartImage(
                    path: exp.image,
                    fit: BoxFit.cover,
                    enableShimmer: true,
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
  }

  Widget _buildCardPile(ResponsiveInfo info) {
    final pile = widget.experiences
        .where(
          (e) =>
              (ref.watch(cardFlightProvider)[e.id] ?? CardFlightState.inPile) ==
              CardFlightState.inPile,
        )
        .toList();

    const double maxCardWidth = 80;
    final proportionalCardWidth = info.size.width * 0.11;
    final cardWidth = min(proportionalCardWidth, maxCardWidth);
    final cardHeight = cardWidth * 1.33;

    return Align(
      alignment: Alignment.centerLeft,
      child: ResponsiveBox(
        width: info.size.width * 0.2,
        padding: EdgeInsets.only(
          top: info.size.height * 0.12, // ~12% de l'écran pour le menu
          left: 8,
        ),
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.loose,
          clipBehavior: Clip.hardEdge,
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
                    child: ResponsiveBox(
                      width: cardWidth,
                      height: cardHeight,
                      child: _cardClone(exp),
                    ),
                  ),
                  childWhenDragging: ResponsiveBox(
                    width: cardWidth,
                    height: cardHeight,
                    child: Opacity(
                      opacity: 0.3,
                      child: RepaintBoundary(child: _cardClone(exp)),
                    ),
                  ),
                  child: ResponsiveBox(
                    width: cardWidth,
                    height: cardHeight,
                    child: Card(
                      key: ValueKey('card_${exp.id}'),
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

    const double maxCardWidth = 120.0;
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
            child: ResponsiveBox(
              paddingSize: ResponsiveSpacing.m,
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
                  const ResponsiveText.titleLarge(
                    "🎰 Main de Poker 🎰",
                    style: TextStyle(
                      color: Colors.yellow,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const ResponsiveBox(
                    paddingSize: ResponsiveSpacing.m,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: _potCards.take(4).map((exp) {
                      return ResponsiveBox(
                        paddingSize: ResponsiveSpacing.s,
                        child: ResponsiveBox(
                          width: cardWidth,
                          height: cardHeight,
                          child: _cardClone(exp),
                        ),
                      );
                    }).toList(),
                  ),
                  const ResponsiveBox(paddingSize: ResponsiveSpacing.m),
                  ResponsiveText.headlineSmall(
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
          child: ResponsiveBox(
            width: width,
            height: height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const ResponsiveText.headlineMedium(
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
    const double maxChipSize = 80.0;
    final proportionalChipSize = info.size.height * 0.15;
    final chipSize = min(proportionalChipSize, maxChipSize);

    final positions = [
      [0.15, 0.10, 'Flutter'], // 15% du haut, 10% de la droite
      [0.16, 0.15, 'Qualite'],
      [0.20, 0.12, 'Relation Client'],
      [0.09, 0.07, 'Logistique'],
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
            path: 'assets/images/tapis-poker-2.png',
            responsiveSize: ResponsiveImageSize.xlarge,
            fit: BoxFit.cover,
            enableShimmer: true,
          ),
        ),
        Column(
          children: [
            // ✅ ROW 1: Pile de cartes, Cible, Jetons éparpillés
            Expanded(
              flex: 85,
              child: Row(
                children: [
                  // Colonne 1: Pile de cartes
                  Expanded(
                    flex: 30,
                    child: ResponsiveBox(
                      child: _buildCardPile(info),
                    ),
                  ),
                  // Colonne 2: Zone cible centrale
                  Expanded(
                    flex: 50,
                    child: ResponsiveBox(
                      padding: EdgeInsets.symmetric(
                        horizontal: info.size.width * 0.01,
                        vertical: info.size.height * 0.02,
                      ),
                      child: _buildCardTarget(info),
                    ),
                  ),
                  // Colonne 3: Jetons éparpillés
                  Expanded(
                    flex: 30,
                    child: ResponsiveBox(
                      padding: EdgeInsets.only(
                        right: info.size.width * 0.01,
                        left: info.size.width * 0.02,
                        top: info.size.height * 0.05,
                      ),
                      child: Stack(
                        children: _buildScatteredChips(info),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ✅ ROW 2: Compétences et Pot
            Expanded(
              flex: 40,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 33,
                children: [
                  // Colonne 1: Rangée de compétences
                  Expanded(
                      flex: 60,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ResponsiveBox(
                              alignment: Alignment.bottomCenter,
                              child: const CompetencesPilesByNiveau(),
                            ),
                          )
                        ],
                      )),
                  // Colonne 2: Pot
                  Expanded(
                      flex: 40,
                      child: ResponsiveBox(
                        padding: EdgeInsets.only(
                          right: info.size.width * 0.02,
                          left: info.size.width * 0.02,
                          bottom: info.size.height * 0.02,
                          top: info.size.height * 0.02,
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            InteractivePot(
                              experiences: widget.experiences,
                              cardKeys: _cardKeys,
                              flyCard: _flyCard,
                              onCardsArrivedInPot: _onCardsArrivedInPot,
                              onPotCleared: _onPotCleared,
                            ),
                          ],
                        ),
                      )),
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
          child: ResponsiveBox(
            paddingSize: ResponsiveSpacing.l,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.screen_rotation,
                    size: 80, color: Colors.yellow),
                const ResponsiveBox(height: 24),
                ResponsiveText.headlineMedium(
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
