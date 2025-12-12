import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:portefolio/features/generator/data/extention_models.dart';
import 'package:portefolio/features/home/views/widgets/extentions_widgets.dart';

import '../../../../../core/affichage/screen_size_detector.dart';

class ServiceExpertiseOverlay {
  /// Crée un overlay avec les bulles de compétences
  static OverlayEntry? createOverlay({
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
    if (!context.mounted) {
      debugPrint('[OVERLAY] ❌ Context non monté');
      return null;
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;

      final RenderBox? cardRenderBox =
          cardKey.currentContext?.findRenderObject() as RenderBox?;
      final RenderBox? buttonRenderBox =
          buttonKey.currentContext?.findRenderObject() as RenderBox?;

      if (cardRenderBox == null || !cardRenderBox.hasSize) {
        debugPrint('[OVERLAY] ❌ Card RenderBox invalide');
        return;
      }

      if (buttonRenderBox == null || !buttonRenderBox.hasSize) {
        debugPrint('[OVERLAY] ❌ Button RenderBox invalide');
        return;
      }

      final cardPosition = cardRenderBox.localToGlobal(Offset.zero);
      final cardSize = cardRenderBox.size;

      debugPrint('[OVERLAY] ✅ Card position: $cardPosition, size: $cardSize');
    });

    return _createOverlayEntry(
      context: context,
      cardKey: cardKey,
      expertise: expertise,
      info: info,
      service: service,
      currentSkillIndex: currentSkillIndex,
      onSkillTap: onSkillTap,
      onClose: onClose,
    );
  }

  static OverlayEntry _createOverlayEntry({
    required BuildContext context,
    required GlobalKey cardKey,
    required ServiceExpertise expertise,
    required ResponsiveInfo info,
    required Service service,
    required int currentSkillIndex,
    required Function(int) onSkillTap,
    required VoidCallback onClose,
  }) {
    return OverlayEntry(
      opaque: false,
      builder: (overlayContext) {
        return _OverlayContent(
          cardKey: cardKey,
          expertise: expertise,
          info: info,
          service: service,
          currentSkillIndex: currentSkillIndex,
          onSkillTap: onSkillTap,
          onClose: onClose,
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

class _OverlayContent extends StatefulWidget {
  final GlobalKey cardKey;
  final ServiceExpertise expertise;
  final ResponsiveInfo info;
  final Service service;
  final int currentSkillIndex;
  final Function(int) onSkillTap;
  final VoidCallback onClose;

  const _OverlayContent({
    required this.cardKey,
    required this.expertise,
    required this.info,
    required this.service,
    required this.currentSkillIndex,
    required this.onSkillTap,
    required this.onClose,
  });

  @override
  State<_OverlayContent> createState() => _OverlayContentState();
}

class _OverlayContentState extends State<_OverlayContent> {
  Offset? _position;
  Size? _size;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    // ✅ Calculer la position après le premier frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculatePosition();
    });
  }

  void _calculatePosition() {
    if (!mounted) return;

    final RenderBox? cardRenderBox =
        widget.cardKey.currentContext?.findRenderObject() as RenderBox?;

    if (cardRenderBox == null || !cardRenderBox.hasSize) {
      // ✅ Réessayer après un délai
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) _calculatePosition();
      });
      return;
    }

    final cardPosition = cardRenderBox.localToGlobal(Offset.zero);
    final cardSize = cardRenderBox.size;

    // ✅ Configuration des bulles
    final topSkills = widget.expertise.topSkills.take(5).toList();
    const double bubbleSize = 70.0;
    const double spacing = 8.0;
    const double padding = 16.0;

    final double numBubbles = topSkills.length.toDouble();
    final double contentWidth =
        (numBubbles * bubbleSize) + ((numBubbles - 1) * spacing);
    final double overlayWidth = contentWidth + (padding * 2);
    const double overlayHeight = bubbleSize + (padding * 2);

    // ✅ Position centrée sous la carte
    const double verticalMargin = 8.0;
    double top = cardPosition.dy + cardSize.height + verticalMargin;

    // ✅ Ajustement pour le scroll
    final scrollable = Scrollable.maybeOf(context);
    if (scrollable != null) {
      final RenderBox? viewport =
          scrollable.context.findRenderObject() as RenderBox?;
      if (viewport != null) {
        final viewportOffset = viewport.localToGlobal(Offset.zero);
        top -= viewportOffset.dy;
      }
    }

    // ✅ Centrage horizontal
    final screenWidth = MediaQuery.of(context).size.width;
    final double leftCenter =
        cardPosition.dx + (cardSize.width / 2) - (overlayWidth / 2);
    const double screenPadding = 16.0;

    final safeLeft = leftCenter.clamp(
      screenPadding,
      screenWidth - overlayWidth - screenPadding,
    );

    setState(() {
      _position = Offset(safeLeft, top);
      _size = Size(overlayWidth, overlayHeight);
      _isReady = true;
    });

    debugPrint('[OVERLAY] ✅ Position calculée: $_position, Size: $_size');
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Afficher un loader pendant le calcul
    if (!_isReady || _position == null || _size == null) {
      return const SizedBox.shrink();
    }

    final topSkills = widget.expertise.topSkills.take(5).toList();

    return Positioned(
      left: _position!.dx,
      top: _position!.dy,
      width: _size!.width,
      height: _size!.height,
      child: Material(
        color: Colors.transparent,
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: topSkills.asMap().entries.map((entry) {
              final index = entry.key;
              final skill = entry.value;
              final bool isActive = index == widget.currentSkillIndex;

              return GestureDetector(
                onTap: () => widget.onSkillTap(index),
                onLongPress: () {
                  widget.onClose();
                  ServiceExpertiseOverlay._showExpandedDialog(
                    context,
                    widget.expertise,
                    skill,
                    widget.service,
                    widget.info,
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
  }
}
