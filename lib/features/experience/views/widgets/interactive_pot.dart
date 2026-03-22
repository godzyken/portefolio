import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/experience/views/widgets/competences_chip.dart';

import '../../../../core/affichage/screen_size_detector.dart';
import '../../../../core/ui/widgets/responsive_text.dart';
import '../../controllers/providers/card_flight_provider.dart';
import '../../data/competences_data.dart';
import '../../data/experiences_data.dart';
import 'animated_card_overlay.dart';
import 'falling_tag.dart';

class InteractivePot extends ConsumerStatefulWidget {
  final List<Experience> experiences;
  final Map<String, GlobalKey> cardKeys;
  final Function(Experience exp, Offset target, BuildContext cardContext,
      {bool flyUp}) flyCard;
  final Function(List<Experience> cards)? onCardsArrivedInPot;
  final VoidCallback? onPotCleared;

  const InteractivePot({
    super.key,
    required this.experiences,
    required this.cardKeys,
    required this.flyCard,
    this.onCardsArrivedInPot,
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
  final Map<String, Offset> _chipPositions = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.15).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
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
    Future.delayed(const Duration(milliseconds: 900), () {
      if (entry.mounted) {
        entry.remove();
      }
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
        onEnd: () {
          if (entry.mounted) entry.remove();
        },
      ),
    );
    overlay.insert(entry);
  }

  /// ✅ FIX 3 : correspondance insensible à la casse entre tag de compétence
  /// et tags de l'expérience.
  void _onCoinDrop(String competenceTag) {
    // Cherche la compétence par nom (insensible à la casse)
    Competence? comp;
    try {
      comp = competences.firstWhere(
        (c) => c.nom.toLowerCase() == competenceTag.toLowerCase(),
      );
    } catch (_) {
      // Compétence non trouvée → rien à faire
      return;
    }

    // Récupère les expériences dont l'entreprise est listée dans la compétence
    // OU dont un tag correspond au nom de la compétence (comparaison souple)
    final cardsToFly = widget.experiences.where((e) {
      // Correspondance par entreprise (référence directe dans la compétence)
      if (comp!.entreprises.any(
        (ent) => ent.toLowerCase() == e.entreprise.toLowerCase(),
      )) {
        return true;
      }
      // Correspondance par tags de l'expérience (insensible à la casse)
      return e.tags.any(
        (t) => t.toLowerCase() == competenceTag.toLowerCase(),
      );
    }).toList();

    widget.onCardsArrivedInPot?.call(cardsToFly);
  }

  Widget _buildTagChip(String tag, {double opacity = 1.0}) {
    return Builder(builder: (context) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final rb = context.findRenderObject() as RenderBox?;
        if (rb != null && mounted) {
          _chipPositions[tag] = rb.localToGlobal(Offset.zero);
        }
      });
      return CompetenceChip(competenceName: tag, opacity: opacity);
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeTags = ref.watch(activeTagsProvider);
    final tagsNotifier = ref.read(activeTagsProvider.notifier);
    final cardNotifier = ref.read(cardFlightProvider.notifier);
    final info = ref.read(responsiveInfoProvider);

    final potSize = info.isMobile
        ? 120.0
        : info.isTablet
            ? 140.0
            : 160.0;

    return DragTarget<String>(
      onAcceptWithDetails: (details) {
        final tag = details.data;
        _triggerFeedback();

        if (activeTags.contains(tag)) return; // Jeton déjà dans le pot

        tagsNotifier.setTags([...activeTags, tag]);

        // ✅ FIX 3 : déclenche la récupération des cartes liées
        _onCoinDrop(tag);

        // Calcule la cible (centre de l'écran)
        final cardWidth = info.cardWidth;
        final cardHeight = cardWidth * info.cardHeightRatio;
        final target = Offset(
          info.size.width / 2 - cardWidth / 2,
          info.size.height / 2 - cardHeight / 2,
        );

        // Anime les cartes correspondantes vers le centre
        final relatedCards = widget.experiences.where((e) {
          Competence? comp;
          try {
            comp = competences.firstWhere(
              (c) => c.nom.toLowerCase() == tag.toLowerCase(),
            );
          } catch (_) {
            return false;
          }
          return comp.entreprises.any(
                (ent) => ent.toLowerCase() == e.entreprise.toLowerCase(),
              ) ||
              e.tags.any((t) => t.toLowerCase() == tag.toLowerCase());
        }).toList();

        for (final exp in relatedCards) {
          widget.flyCard(exp, target, context, flyUp: true);
        }

        if (relatedCards.isNotEmpty) {
          cardNotifier.flyCardsUp(relatedCards.map((e) => e.id).toList());
        }

        // Animation du jeton
        _flyChip(tag, target);
        final startPos = details.offset;
        final endPos = Offset(
          info.size.width - potSize / 2 - 20,
          info.size.height - potSize / 2 - 20,
        );
        _fallTag(tag, startPos, endPos);
      },
      builder: (context, candidateData, rejectedData) {
        final glow = candidateData.isNotEmpty;

        return ScaleTransition(
          scale: _scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: potSize,
            height: potSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.75),
              border: glow
                  ? Border.all(color: Colors.yellowAccent, width: 4)
                  : Border.all(
                      color: Colors.white.withValues(alpha: 0.2), width: 1),
              boxShadow: [
                if (glow)
                  BoxShadow(
                    color: Colors.yellowAccent.withValues(alpha: 0.6),
                    blurRadius: 25,
                  ),
              ],
            ),
            child: activeTags.isEmpty
                ? _buildEmptyPot()
                : _buildFilledPot(activeTags, potSize, info),
          ),
        );
      },
    );
  }

  Widget _buildEmptyPot() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.casino_outlined, color: Colors.white54, size: 28),
        SizedBox(height: 4),
        ResponsiveText.bodySmall(
          "Dépose\nun jeton",
          style: TextStyle(color: Colors.white70, fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFilledPot(
    List<String> activeTags,
    double potSize,
    ResponsiveInfo info,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Jetons empilés
        SizedBox(
          width: potSize * 0.8,
          height: potSize * 0.5,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: activeTags.take(4).toList().asMap().entries.map((e) {
              return Positioned(
                left: e.key * 6.0,
                top: e.key * 4.0,
                child: _buildTagChip(e.value, opacity: 0.9 - e.key * 0.15),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 4),
        // Bouton "Vider"
        GestureDetector(
          onTap: () {
            ref.read(activeTagsProvider.notifier).clearTags();
            widget.onPotCleared?.call();

            for (final entry in List.from(_fallingTags)) {
              if (entry.mounted) entry.remove();
            }
            _fallingTags.clear();

            // Remet les cartes dans la pile
            final cardWidth = info.cardWidth;
            final cardHeight = cardWidth * info.cardHeightRatio;

            for (final exp in widget.experiences) {
              final ctx = widget.cardKeys[exp.id]?.currentContext;
              if (ctx != null && ctx.findRenderObject() is RenderBox) {
                final rb = ctx.findRenderObject() as RenderBox;
                final target = rb.localToGlobal(Offset(
                  info.size.width * 0.15 - cardWidth / 2,
                  info.size.height / 2 - cardHeight / 2,
                ));
                widget.flyCard(exp, target, context, flyUp: false);
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const ResponsiveText.bodySmall(
              "Vider",
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    for (final entry in _fallingTags) {
      if (entry.mounted) entry.remove();
    }
    super.dispose();
  }
}
