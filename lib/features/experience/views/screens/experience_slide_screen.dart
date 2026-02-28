import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

import '../../../../core/affichage/colors_spec.dart';
import '../../../generator/views/generator_widgets_extentions.dart';
import '../../data/experiences_data.dart';
import '../widgets/ciberpunk_experience_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EXPERIENCE SLIDE SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class ExperienceSlideScreen extends ConsumerStatefulWidget {
  const ExperienceSlideScreen({super.key, required this.experiences});
  final List<Experience> experiences;

  @override
  ConsumerState<ExperienceSlideScreen> createState() =>
      _ExperienceSlideScreenState();
}

class _ExperienceSlideScreenState extends ConsumerState<ExperienceSlideScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _autoSlideController;
  late AnimationController _entryController;
  int _currentPage = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(viewportFraction: 0.82)
      ..addListener(() {
        final page = _pageController.page?.round() ?? 0;
        if (page != _currentPage) setState(() => _currentPage = page);
      });

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _autoSlideController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && !_isDragging) {
          _nextPage();
          _autoSlideController.forward(from: 0);
        }
      });

    _autoSlideController.forward();
  }

  void _nextPage() {
    if (!_pageController.hasClients) return;
    final next = (_currentPage + 1) % widget.experiences.length;
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
    _pauseAutoSlide();
  }

  void _pauseAutoSlide() {
    _autoSlideController.stop();
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) _autoSlideController.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoSlideController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(responsiveInfoProvider);

    if (widget.experiences.isEmpty) {
      return const Center(
        child: ResponsiveText('Aucune expérience.',
            style: TextStyle(color: ColorHelpers.textSecondary)),
      );
    }

    return FadeTransition(
      opacity: CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (n is ScrollStartNotification) {
                  _isDragging = true;
                  _pauseAutoSlide();
                } else if (n is ScrollEndNotification) {
                  _isDragging = false;
                }
                return false;
              },
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.experiences.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double offset = 0;
                      if (_pageController.position.haveDimensions) {
                        offset = ((_pageController.page ?? 0) - index);
                      }
                      final absOffset = offset.abs();
                      final scale = (1 - absOffset * 0.12).clamp(0.88, 1.0);
                      final opacity = (1 - absOffset * 0.5).clamp(0.4, 1.0);
                      final rotateY = offset * -0.05;

                      return Opacity(
                        opacity: opacity,
                        child: Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(rotateY)
                            ..scaleByVector3(vm.Vector3(scale, scale, scale)),
                          alignment: Alignment.center,
                          child: child,
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: info.isMobile ? 8 : 16,
                        vertical: 8,
                      ),
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (_, a, __) => FadeTransition(
                              opacity: a,
                              child: ImmersiveExperienceDetail(
                                experience: widget.experiences[index],
                              ),
                            ),
                            transitionDuration:
                                const Duration(milliseconds: 400),
                            fullscreenDialog: true,
                          ),
                        ),
                        child: CyberpunkExperienceCard(
                          experience: widget.experiences[index],
                          isActive: index == _currentPage,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildPagination(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 18,
                decoration: BoxDecoration(
                  color: ColorHelpers.cyan,
                  boxShadow: [
                    BoxShadow(
                      color: ColorHelpers.cyan.withValues(alpha: 0.6),
                      blurRadius: 8,
                    )
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const ResponsiveText.titleMedium(
                'EXPÉRIENCES',
                style: TextStyle(
                  color: ColorHelpers.textSecondary,
                  fontSize: 11,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          ResponsiveText(
            '${(_currentPage + 1).toString().padLeft(2, '0')} / ${widget.experiences.length.toString().padLeft(2, '0')}',
            style: const TextStyle(
              color: ColorHelpers.cyan,
              fontSize: 13,
              fontFamily: 'monospace',
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.experiences.length, (index) {
            final isActive = index == _currentPage;
            return GestureDetector(
              onTap: () => _goToPage(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 24 : 6,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: isActive ? ColorHelpers.cyan : ColorHelpers.border,
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: ColorHelpers.cyan.withValues(alpha: 0.6),
                            blurRadius: 8,
                          )
                        ]
                      : null,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: AnimatedBuilder(
            animation: _autoSlideController,
            builder: (_, __) => ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: _autoSlideController.value,
                minHeight: 2,
                backgroundColor: ColorHelpers.border,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(ColorHelpers.cyan),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
