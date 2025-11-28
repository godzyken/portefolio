import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';

import '../../../generator/views/generator_widgets_extentions.dart';
import '../../data/experiences_data.dart';
import '../widgets/experience_widgets_extentions.dart';

class ExperienceSlideScreen extends ConsumerStatefulWidget {
  const ExperienceSlideScreen({super.key, required this.experiences});
  final List<Experience> experiences;

  @override
  ConsumerState createState() => _ExperienceSlideScreenState();
}

class _ExperienceSlideScreenState extends ConsumerState<ExperienceSlideScreen>
    with SingleTickerProviderStateMixin {
  late PageController _controller;
  late AnimationController _autoSlideController;
  bool _isControllerInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.85);

    _autoSlideController =
        AnimationController(vsync: this, duration: const Duration(seconds: 5))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _nextPage();
              _autoSlideController.forward(from: 0);
            }
          });

    _autoSlideController.forward();
  }

  void _nextPage() {
    if (!_controller.hasClients) return;

    final nextPage = (_controller.page?.round() ?? 0) + 1;
    if (nextPage < widget.experiences.length) {
      _controller.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _controller.animateToPage(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _pauseAutoSlide() {
    _autoSlideController.stop();
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) _autoSlideController.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _autoSlideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(responsiveInfoProvider);

    if (!_isControllerInitialized) {
      _controller = PageController(
        viewportFraction: info.isPortrait ? 0.95 : 0.85,
      );
      _isControllerInitialized = true;
    }

    if (widget.experiences.isEmpty) {
      return const Center(child: Text('Aucune expérience pour ce filtre.'));
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollStartNotification) {
          _pauseAutoSlide();
        }
        return false;
      },
      child: PageView.builder(
        controller: _controller,
        itemCount: widget.experiences.length,
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              double value = 0.0;
              if (_controller.position.haveDimensions) {
                value = ((_controller.page ?? _controller.initialPage) - index)
                    .toDouble();
              }

              // Parallax et scale
              final scale = (1 - value.abs() * 0.2).clamp(0.85, 1.0);
              final translateX = value * -40.0;
              final parallax = value * 20;

              return Transform.translate(
                offset: Offset(translateX + parallax, 0),
                child: Transform.scale(
                  scale: scale,
                  child: Center(
                    child: SizedBox(
                      width: info.isPortrait
                          ? info.size.width * 0.95
                          : info.size.width * 0.75,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ImmersiveExperienceDetail(
                                experience: widget.experiences[index],
                              ),
                              fullscreenDialog: true,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: FadeSlideAnimation(
                              offset: const Offset(0, 0.1),
                              delay: Duration(milliseconds: index * 100),
                              child: PokerExperienceCard(
                                experience: widget.experiences[index],
                                isCenter: value == 0 ? true : false,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ImmersiveExperienceDetail(
                                        experience: widget.experiences[index]),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
