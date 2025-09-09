import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/affichage/screen_size_detector.dart';
import '../../data/experiences_data.dart';
import '../widgets/experience_card.dart';

class ExperienceJeuxScreen extends ConsumerStatefulWidget {
  const ExperienceJeuxScreen({super.key, required this.experiences});
  final List<Experience> experiences;

  @override
  ConsumerState createState() => _ExperienceJeuxScreenState();
}

class _ExperienceJeuxScreenState extends ConsumerState<ExperienceJeuxScreen> {
  Experience? activeExperience;

  @override
  Widget build(BuildContext context) {
    final size = ref.watch(screenSizeProvider);
    final isPortrait = ref.watch(isPortraitProvider);

    if (widget.experiences.isEmpty) {
      return const Center(child: Text('Aucune expérience pour ce filtre.'));
    }

    return Stack(
      children: [
        // 📌 Pile de gauche
        Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: size.width * 0.35,
            child: Stack(
              children: widget.experiences.asMap().entries.map((entry) {
                final index = entry.key;
                final exp = entry.value;

                final angle =
                    (index % 2 == 0 ? 1 : -1) * (5 + index).toDouble();

                return Positioned(
                  top: 20.0 * index,
                  left: 0,
                  child: Transform.rotate(
                    angle: angle * pi / 180,
                    child: Draggable<Experience>(
                      data: exp,
                      feedback: Transform.scale(
                        scale: 0.8,
                        child: _buildMiniCard(exp),
                      ),
                      childWhenDragging: const SizedBox.shrink(),
                      child: _buildMiniCard(exp),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // 🎯 Zone centrale
        Align(
          alignment: Alignment.center,
          child: DragTarget<Experience>(
            onAcceptWithDetails: (exp) {
              setState(() => activeExperience = exp.data);
            },
            builder: (_, _, _) {
              if (activeExperience == null) {
                return Container(
                  width: size.width * 0.5,
                  height: size.height * 0.6,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.withAlpha((255 * 0.5).toInt()),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: const Text("👉 Glisse une carte ici"),
                );
              }
              return _buildFullCard(activeExperience!);
            },
          ),
        ),
      ],
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
}
