import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:portefolio/features/generator/data/extention_models.dart';
import 'package:portefolio/features/home/views/widgets/extentions_widgets.dart';

import '../../../../../core/affichage/screen_size_detector.dart';

class ServiceExpertiseOverlay {
  /// Crée un overlay avec les bulles de compétences
  static OverlayEntry createOverlay({
    required BuildContext context,
    required GlobalKey buttonKey,
    required GlobalKey cardKey,
    required ServiceExpertise expertise,
    required ResponsiveInfo info,
    required Service service,
    required int currentSkillIndex,
    required Function(int) onSkillTap,
    required VoidCallback onClose,
  }) {
    final RenderBox? cardRenderBox =
        cardKey.currentContext?.findRenderObject() as RenderBox?;

    if (cardRenderBox == null || !cardRenderBox.attached) {
      debugPrint('[DEBUG OVERLAY] ❌ RenderBox de la carte non trouvée.');
      return OverlayEntry(builder: (_) => const SizedBox.shrink());
    }

    final cardPosition = cardRenderBox.localToGlobal(Offset.zero);
    final cardHeight = cardRenderBox.size.height;
    final cardWidth = cardRenderBox.size.width;

    final topSkills = expertise.topSkills.take(5).toList();
    if (topSkills.isEmpty) {
      debugPrint('[DEBUG OVERLAY] ❌ La liste topSkills est vide.');
      return OverlayEntry(builder: (_) => const SizedBox.shrink());
    }

    const double bubbleSize = 70.0;
    const double spacing = 8.0;

    final double numBubbles = topSkills.length.toDouble();
    // Largeur = (N * taille bulle) + ((N-1) * espacement)
    final double baseContentWidth =
        (numBubbles * bubbleSize) + ((numBubbles - 1) * spacing);

    const double overflowSafetyMargin = 50.0;
    final double overlayWidth = baseContentWidth + overflowSafetyMargin;
    const double overlayHeight = bubbleSize + 16.0;

    const double verticalMargin = 8.0;
    double top = cardPosition.dy + cardHeight + verticalMargin;

    final scrollable = Scrollable.maybeOf(context);
    if (scrollable != null) {
      final RenderBox? viewport =
          scrollable.context.findRenderObject() as RenderBox?;
      if (viewport != null) {
        final Offset viewportOffset = viewport.localToGlobal(Offset.zero);

        top = cardPosition.dy + cardHeight + verticalMargin - viewportOffset.dy;
        debugPrint(
            '[DEBUG OVERLAY] Décalage Viewport appliqué: ${viewportOffset.dy.toStringAsFixed(2)}');
      }
    }

    final double leftCenter =
        cardPosition.dx + (cardWidth / 2) - (overlayWidth / 2);

    final screenWidth = MediaQuery.of(context).size.width;
    const double screenPadding = 16.0;

    final safeLeft = leftCenter.clamp(
        screenPadding, screenWidth - overlayWidth - screenPadding);

    debugPrint('[DEBUG OVERLAY] Top corrigé final: ${top.toStringAsFixed(2)}');
    debugPrint(
        '[DEBUG OVERLAY] Left (safe) calculé: ${safeLeft.toStringAsFixed(2)}');
    debugPrint(
        '[DEBUG OVERLAY] Largeur overlay (avec marge): ${overlayWidth.toStringAsFixed(2)}');

    return OverlayEntry(
      builder: (context) {
        return Positioned(
          left: safeLeft,
          top: top,
          width: overlayWidth,
          height: overlayHeight,
          child: Material(
            color: Colors.transparent,
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: topSkills.asMap().entries.map((entry) {
                  final index = entry.key;
                  final skill = entry.value;
                  final bool isActive = index == currentSkillIndex;

                  return Padding(
                    padding: index < topSkills.length - 1
                        ? const EdgeInsets.only(right: spacing)
                        : EdgeInsets.zero,
                    child: GestureDetector(
                      onTap: () => onSkillTap(index),
                      onLongPress: () {
                        onClose();
                        _showExpandedDialog(
                          context,
                          expertise,
                          skill,
                          service,
                          info,
                        );
                      },
                      child: Animate(
                        effects: [
                          FadeEffect(delay: (index * 100).ms, duration: 300.ms),
                          ScaleEffect(
                              delay: (index * 100).ms, duration: 300.ms),
                        ],
                        child: ServiceSkillBubble(
                          skill: skill,
                          index: index,
                          isActive: isActive,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Affiche le dialogue détaillé d'expertise
  static void _showExpandedDialog(
    BuildContext context,
    ServiceExpertise expertise,
    TechSkill? selectedSkill,
    Service service,
    ResponsiveInfo info,
  ) {
    final screenWidth = info.size.width;
    final dialogWidth = screenWidth * 0.75;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: BoxConstraints(
            maxWidth: dialogWidth,
            maxHeight: 700,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDialogHeader(context, service),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (selectedSkill != null)
                        _buildSkillDetails(selectedSkill, info, context),
                      const Divider(height: 32),
                      ServiceExpertiseCard(expertise: expertise),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildDialogHeader(BuildContext context, Service service) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Détails d\'Expertise - ${service.title}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  static Widget _buildSkillDetails(
    TechSkill skill,
    ResponsiveInfo info,
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          skill.name,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Niveau d\'Expertise: ${skill.levelPercent}%',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text('Projets Utilisés: ${skill.projectCount}'),
        Text('Années d\'expérience: ${skill.yearsOfExperience}'),
      ],
    );
  }
}
