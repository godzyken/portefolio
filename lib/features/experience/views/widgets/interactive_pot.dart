import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/experience/views/widgets/competences_chip.dart';

import '../../../../core/affichage/screen_size_detector.dart';
import '../../controllers/providers/card_flight_provider.dart';
import '../../data/competences_data.dart';
import '../../data/experiences_data.dart';
import 'animated_card_overlay.dart';
import 'falling_tag.dart';

class InteractivePot extends ConsumerStatefulWidget {
  final List<Experience> experiences;
  final Map<String, GlobalKey> cardKeys;
  final Function(Experience exp, Offset target, {bool flyUp}) flyCard;
  final Function(List<Experience> cards)? onCardsArrivedInPot;
  final VoidCallback? onPotCleared;

  const InteractivePot({
    super.key,
    required this.experiences,
    required this.cardKeys,
    required this.flyCard,
    this.onCardsArrivedInPot, // 🔥 Nouveau
    this.onPotCleared,
  });

  @override
  ConsumerState<InteractivePot> createState() => _InteractivePotState();
}

class _InteractivePotState extends ConsumerState<InteractivePot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  final List<OverlayEntry> _fallingTags = [];

  /// 🔥 positions mémorisées pour chaque jeton
  final Map<String, Offset> _chipPositions = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
  }

  void _triggerFeedback() {
    _controller.forward(from: 0).then((_) => _controller.reverse());
  }

  void _fallTag(String tag, Offset start, Offset target) {
    final overlay = Overlay.of(context);

    final entry = OverlayEntry(
      builder: (context) => FallingTag(
        start: start,
        end: target,
        child: CompetenceChip(competenceName: tag, opacity: 1.0),
      ),
    );

    _fallingTags.add(entry);
    overlay.insert(entry);

    Future.delayed(const Duration(milliseconds: 600), () {
      entry.remove();
      _fallingTags.remove(entry);
    });
  }

  void _flyChip(String tag, Offset target) {
    const size = Size(50, 50);
    final start = _chipPositions[tag] ?? const Offset(0, 0);
    final overlay = Overlay.of(context);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => AnimatedCardOverlay(
        start: start,
        end: target,
        size: size,
        child: CompetenceChip(competenceName: tag),
        onEnd: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }

  void _onCoinDrop(String tag) {
    // Trouver la compétence
    final comp = competences.firstWhere(
      (c) => c.nom.toLowerCase() == tag.toLowerCase(),
    );

    final cardsToFly = widget.experiences
        .where((e) => comp.entreprises.contains(e.entreprise))
        .toList();

    widget.onCardsArrivedInPot?.call(cardsToFly);
  }

  /// 🔥 helper pour créer un TagChip qui mémorise sa position
  Widget _buildTagChip(String tag, {double opacity = 1.0}) {
    return Builder(
      builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final rb = context.findRenderObject() as RenderBox?;
          if (rb != null && mounted) {
            _chipPositions[tag] = rb.localToGlobal(Offset.zero);
          }
        });
        return CompetenceChip(competenceName: tag, opacity: opacity);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeTags = ref.watch(activeTagsProvider);
    final tagsNotifier = ref.read(activeTagsProvider.notifier);
    final cardNotifier = ref.read(cardFlightProvider.notifier);
    final info = ref.read(responsiveInfoProvider);

    return Positioned(
      bottom: 0,
      right: 30,
      child: DragTarget<String>(
        onAcceptWithDetails: (details) {
          final tag = details.data;

          debugPrint('[Pot] received tag: $tag');
          _triggerFeedback();

          if (!ref.read(activeTagsProvider).contains(tag)) {
            tagsNotifier.setTags([...ref.read(activeTagsProvider), tag]);

            _onCoinDrop(tag);

            final cardsToFly =
                widget.experiences.where((e) => e.tags.contains(tag)).toList();

            const cardWidth = 120.0;
            const cardHeight = 160.0;
            final target = Offset(
              info.size.width / 2 - cardWidth / 2,
              info.size.height / 2 - cardHeight / 2,
            );

            for (var exp in cardsToFly) {
              widget.flyCard(exp, target, flyUp: true);
            }

            cardNotifier.flyCardsUp(
              cardsToFly.map((e) => e.entreprise).toList(),
            );

            // 🔥 animation chip qui vole vers le centre
            _flyChip(tag, target);

            // 🔥 animation de chute dans le pot
            final startPos = details.offset;
            final endPos = Offset(info.size.width - 80, info.size.height - 80);
            _fallTag(tag, startPos, endPos);
          }
        },
        builder: (context, candidateData, rejectedData) {
          final glow = candidateData.isNotEmpty;
          return ScaleTransition(
            scale: _scale,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 160,
              height: 160,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withAlpha(120),
                border:
                    glow ? Border.all(color: Colors.yellow, width: 4) : null,
                boxShadow: [
                  if (glow)
                    BoxShadow(
                      color: Colors.yellow.withAlpha(150),
                      blurRadius: 25,
                    ),
                ],
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
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        for (int i = 0; i < activeTags.length; i++)
                          Positioned(
                            left: (i * 8).toDouble(), // décalage horizontal
                            top: (i * 6).toDouble(), // décalage vertical
                            child: _buildTagChip(
                              activeTags[i],
                              opacity: 0.9 - i * 0.1,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (activeTags.isNotEmpty)
                    ElevatedButton(
                      onPressed: () {
                        tagsNotifier.clearTags();

                        widget.onPotCleared?.call();

                        setState(() {
                          for (var e in _fallingTags) {
                            e.remove();
                          }
                          _fallingTags.clear();
                        });

                        for (var e in widget.experiences) {
                          final ctx =
                              widget.cardKeys[e.entreprise]?.currentContext;
                          if (ctx != null &&
                              ctx.findRenderObject() is RenderBox) {
                            final rb = ctx.findRenderObject() as RenderBox;
                            final target = rb.localToGlobal(Offset.zero);
                            widget.flyCard(e, target, flyUp: false);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text("Vider le pot"),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
