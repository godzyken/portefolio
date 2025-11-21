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
    required ServiceExpertise expertise,
    required ResponsiveInfo info,
    required Service service,
    required int currentSkillIndex,
    required Function(int) onSkillTap,
    required VoidCallback onClose,
  }) {
    final RenderBox? renderBox =
        buttonKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null || !renderBox.attached) {
      return OverlayEntry(builder: (_) => const SizedBox.shrink());
    }

    final buttonPosition = renderBox.localToGlobal(Offset.zero);
    final topSkills = expertise.topSkills.take(5).toList();

    const double bubbleSize = 70.0;
    const double spacing = 8.0;
    final double overlayWidth = (topSkills.length * (bubbleSize + spacing));
    final double overlayHeight = bubbleSize + 16.0;

    final double top = buttonPosition.dy - overlayHeight;
    final double left =
        buttonPosition.dx - (overlayWidth / 2) + (renderBox.size.width / 2);

    return OverlayEntry(
      builder: (context) {
        return Positioned(
          left: left,
          top: top,
          width: overlayWidth,
          height: overlayHeight,
          child: Material(
            color: Colors.transparent,
            child: Container(
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: topSkills.asMap().entries.map((entry) {
                  final index = entry.key;
                  final skill = entry.value;
                  final bool isActive = index == currentSkillIndex;

                  return GestureDetector(
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
                        ScaleEffect(delay: (index * 100).ms, duration: 300.ms),
                      ],
                      child: ServiceSkillBubble(
                        skill: skill,
                        index: index,
                        isActive: isActive,
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
    final screenWidth = MediaQuery.of(context).size.width;
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
