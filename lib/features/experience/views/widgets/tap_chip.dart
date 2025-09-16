import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/providers/card_flight_provider.dart';

class TagChip extends ConsumerStatefulWidget {
  final String tag;
  final Color color;
  final double opacity;

  const TagChip({
    super.key,
    required this.tag,
    required this.color,
    this.opacity = 1.0,
  });

  @override
  ConsumerState<TagChip> createState() => _TagChipState();
}

class _TagChipState extends ConsumerState<TagChip> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final activeTags = ref.watch(activeTagsProvider);
    final isActive = activeTags.contains(widget.tag);

    // contenu visuel du chip
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
              widget.color.withAlpha(
                (255 * widget.opacity * 1.3).clamp(0, 255).toInt(),
              ),
              widget.color.withAlpha((255 * widget.opacity).toInt()),
              // Ombre en bas à droite
              widget.color.withAlpha(
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
                color: widget.color.withAlpha((255 * 0.6).toInt()),
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
            // Cercles concentriques (motif typique des jetons)
            Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withAlpha((255 * 0.4).toInt()),
                    width: 1,
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withAlpha((255 * 0.3).toInt()),
                    width: 1,
                  ),
                ),
              ),
            ),
            // Texte du tag
            Center(
              child: Text(
                widget.tag,
                style: TextStyle(
                  color: isActive ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  shadows: [
                    Shadow(
                      color: Colors.black.withAlpha((255 * 0.5).toInt()),
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
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
          ],
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Draggable<String>(
        data: widget.tag,
        feedback: Material(
          color: Colors.transparent,
          child: chipContent(dragging: true),
        ),
        childWhenDragging: Opacity(
          opacity: 0.4,
          child: Transform.scale(
            scale: 0.9, // Légèrement plus petit quand on drag
            child: chipContent(),
          ),
        ),
        child: GestureDetector(
          onTap: () {
            final notifier = ref.read(activeTagsProvider.notifier);
            if (isActive) {
              notifier.state = activeTags
                  .where((t) => t != widget.tag)
                  .toList();
            } else {
              notifier.state = [...activeTags, widget.tag];
            }
          },
          child: AnimatedScale(
            scale: _hovering ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: chipContent(),
          ),
        ),
      ),
    );
  }
}
