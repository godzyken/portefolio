import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../generator/views/widgets/fade_slide_animation.dart';
import '../../data/experiences_data.dart';
import '../widgets/experience_card.dart';

class ExperienceSlideScreen extends ConsumerStatefulWidget {
  const ExperienceSlideScreen({super.key, required this.experiences});
  final List<Experience> experiences;

  @override
  ConsumerState createState() => _ExperienceSlideScreenState();
}

class _ExperienceSlideScreenState extends ConsumerState<ExperienceSlideScreen> {
  late PageController _controller;
  bool _isControllerInitialized = false;
  Timer? _autoSlideTimer;
  Timer? _resumeTimer;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.85);
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
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
    });
  }

  void _pauseAutoSlide() {
    _autoSlideTimer?.cancel();
    _resumeTimer?.cancel();
    _resumeTimer = Timer(const Duration(seconds: 6), _startAutoSlide);
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _resumeTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    final size = MediaQuery.of(context).size;
    if (!_isControllerInitialized) {
      _controller = PageController(viewportFraction: isPortrait ? 0.95 : 0.85);
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
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              double value = 0.0;
              if (_controller.position.haveDimensions) {
                value = _controller.page! - index;
              }

              final scale = (1 - value.abs() * 0.2).clamp(0.85, 1.0);
              final translateX = value * -40.0;
              final parallax = value * 20;

              return Transform.translate(
                offset: Offset(translateX + parallax, 0),
                child: Transform.scale(
                  scale: scale,
                  child: Center(
                    child: SizedBox(
                      width: isPortrait ? size.width * 0.95 : size.width * 0.75,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: FadeSlideAnimation(
                          delay: Duration(milliseconds: index * 100),
                          child: ExperienceCard(
                            experience: widget.experiences[index],
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
