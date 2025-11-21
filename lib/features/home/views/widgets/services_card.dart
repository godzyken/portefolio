import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/generator/data/extention_models.dart';
import 'package:portefolio/features/generator/views/widgets/hover_card.dart';
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

    _scrollController.addListener(() {
      final expertise = ref.read(serviceExpertiseProvider(widget.service.id));
      final skillCount = expertise?.topSkills.take(5).length ?? 0;

      if (skillCount > 0) {
        final newIndex =
            (_scrollController.value * skillCount).floor() % skillCount;
        if (newIndex != _currentSkillIndex) {
          setState(() => _currentSkillIndex = newIndex);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  void _toggleSkillBubbles(ServiceExpertise expertise, ResponsiveInfo info) {
    if (_overlayEntry == null) {
      _overlayEntry = ServiceExpertiseOverlay.createOverlay(
        context: context,
        buttonKey: _buttonKey,
        expertise: expertise,
        info: info,
        service: widget.service,
        currentSkillIndex: _currentSkillIndex,
        onSkillTap: (index) {
          setState(() {
            _currentSkillIndex = index;
            _overlayEntry?.markNeedsBuild();
          });
        },
        onClose: () {
          _overlayEntry?.remove();
          _overlayEntry = null;
          setState(() {});
        },
      );
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final info = ref.watch(responsiveInfoProvider);

    return GestureDetector(
      child: HoverCard(
        id: widget.service.id,
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
                  Expanded(
                    child: ServiceCardBottomSection(
                      service: widget.service,
                      currentSkillIndex: _currentSkillIndex,
                    ),
                  ),
                ],
              );
            },
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
    if (info.isTablet) return 180;
    return info.cardWidth * info.cardHeightRatio;
  }

  double _getBorderRadius(ResponsiveInfo info) => info.isWatch
      ? 12
      : info.isMobile
          ? 16
          : info.isTablet
              ? 20
              : 24;
}
