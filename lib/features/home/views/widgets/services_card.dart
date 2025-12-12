import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/generator/data/extention_models.dart';
import 'package:portefolio/features/generator/views/generator_widgets_extentions.dart';
import 'package:portefolio/features/home/views/widgets/extentions_widgets.dart';

import '../../../../core/affichage/screen_size_detector.dart';
import '../../../../core/provider/expertise_provider.dart';

class ServicesCard extends ConsumerStatefulWidget {
  final Service service;
  final VoidCallback? onTap;

  const ServicesCard({
    super.key,
    required this.service,
    this.onTap,
  });

  @override
  ConsumerState<ServicesCard> createState() => _ServicesCardState();
}

class _ServicesCardState extends ConsumerState<ServicesCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scrollController;
  int _currentSkillIndex = 0;

  OverlayEntry? _overlayEntry;
  final GlobalKey _buttonKey = GlobalKey();
  final GlobalKey _cardKey = GlobalKey();

  bool _isTogglingOverlay = false;

  DateTime? _lastUpdate;
  static const _throttleDuration = Duration(milliseconds: 100);

  @override
  void initState() {
    super.initState();
    _initializeScrollAnimation();
  }

  void _initializeScrollAnimation() {
    _scrollController = AnimationController(
      vsync: this,
      duration: 2500.ms,
    )..repeat();

    _scrollController.addListener(_onAnimationTick);
  }

  void _onAnimationTick() {
    if (!mounted) return;

    final now = DateTime.now();
    if (_lastUpdate != null &&
        now.difference(_lastUpdate!) < _throttleDuration) {
      return;
    }

    final expertise = ref.read(serviceExpertiseProvider(widget.service.id));
    final skillCount = expertise?.topSkills.take(5).length ?? 0;

    if (skillCount > 0) {
      final newIndex =
          (_scrollController.value * skillCount).floor() % skillCount;
      if (newIndex != _currentSkillIndex && mounted) {
        _lastUpdate = now;
        setState(() => _currentSkillIndex = newIndex);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onAnimationTick);
    _scrollController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry?.dispose();
      _overlayEntry = null;
      debugPrint('[CARD] ✅ Overlay retiré');
    }
  }

  void _toggleSkillBubbles(ServiceExpertise expertise, ResponsiveInfo info) {
    // Éviter les appels multiples
    if (_isTogglingOverlay) {
      debugPrint('[CARD] ⚠️ Toggle déjà en cours...');
      return;
    }

    _isTogglingOverlay = true;

    if (_overlayEntry != null) {
      // Fermer l'overlay existant
      _removeOverlay();
      setState(() {});
      _isTogglingOverlay = false;
      return;
    }

    // ✅ Attendre que le contexte soit prêt
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!mounted) {
        _isTogglingOverlay = false;
        return;
      }

      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          _isTogglingOverlay = false;
          return;
        }

        try {
          final newOverlay = ServiceExpertiseOverlay.createOverlay(
            context: context,
            buttonKey: _buttonKey,
            cardKey: _cardKey,
            expertise: expertise,
            info: info,
            service: widget.service,
            currentSkillIndex: _currentSkillIndex,
            onSkillTap: (index) {
              if (!mounted) return;
              setState(() {
                _currentSkillIndex = index;
                // Force le rebuild de l'overlay
                _overlayEntry?.markNeedsBuild();
              });
            },
            onClose: () {
              if (!mounted) return;
              _removeOverlay();
              setState(() {});
            },
          );

          if (newOverlay != null && mounted) {
            Overlay.of(context).insert(newOverlay);
            setState(() {
              _overlayEntry = newOverlay;
            });
            debugPrint('[CARD] ✅ Overlay inséré avec succès');
          } else {
            debugPrint('[CARD] ❌ Échec de création de l\'overlay');
          }
        } catch (e, stack) {
          debugPrint('[CARD] ❌ Erreur lors de la création de l\'overlay: $e');
          debugPrint('Stack: $stack');
        } finally {
          _isTogglingOverlay = false;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final info = ref.watch(responsiveInfoProvider);

    return RepaintBoundary(
      child: GestureDetector(
        child: HoverCard(
          key: _cardKey,
          id: widget.service.id,
          shadowColor: theme.shadowColor,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_getBorderRadius(info)),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: [
                    SizedBox(
                      height: _getTopSectionHeight(info),
                      child: ServiceCardTopSection(
                        service: widget.service,
                        buttonKey: _buttonKey,
                        overlayEntry: _overlayEntry,
                        onToggleSkillBubbles: _toggleSkillBubbles,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 150.ms)
        .slideY(begin: 0.2, duration: 500.ms, curve: Curves.easeOutBack);
  }

  double _getTopSectionHeight(ResponsiveInfo info) {
    if (info.isWatch) return 120;
    if (info.isMobile) return 160;
    if (info.isSmallTablet) return 180;
    if (info.isTablet) return 200;
    return info.cardWidth * info.cardHeightRatio * 0.4;
  }

  double _getBorderRadius(ResponsiveInfo info) => info.isWatch
      ? 12
      : info.isMobile
          ? 16
          : info.isTablet
              ? 20
              : 24;
}
