import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnimatedCardFlight extends ConsumerStatefulWidget {
  final Offset start; // Position de départ
  final Offset end; // Position final
  final Size size; // Taille de la carte
  final Widget child; // Carte à animer
  final VoidCallback onEnd; // Callback fin animation
  final bool flyUp; // true = vers le haut, false = retour pile

  const AnimatedCardFlight({
    super.key,
    required this.start,
    required this.end,
    required this.size,
    required this.child,
    required this.onEnd,
    this.flyUp = true,
  });

  @override
  ConsumerState<AnimatedCardFlight> createState() => _AnimatedCardFlightState();
}

class _AnimatedCardFlightState extends ConsumerState<AnimatedCardFlight>
    with SingleTickerProviderStateMixin {
  static const _animDuration = Duration(milliseconds: 700);
  static const _curve = Curves.easeInOutCubic;

  late final AnimationController _controller;
  late Animation<Offset> _position = AlwaysStoppedAnimation(Offset.zero);
  late Animation<double> _scale = AlwaysStoppedAnimation(1.0);
  late Animation<double> _rotation = AlwaysStoppedAnimation(0.0);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _animDuration);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final screenSize =
          View.of(context).physicalSize / View.of(context).devicePixelRatio;

      final end = widget.flyUp
          ? Offset(screenSize.width / 2 - widget.size.width / 2, 20)
          : widget.start;

      _position = Tween<Offset>(
        begin: widget.start,
        end: end,
      ).animate(CurvedAnimation(parent: _controller, curve: _curve));

      _scale = Tween<double>(
        begin: 1.0,
        end: widget.flyUp ? 0.9 : 1.0,
      ).animate(CurvedAnimation(parent: _controller, curve: _curve));

      _rotation = Tween<double>(
        begin: 0,
        end: widget.flyUp ? (Random().nextDouble() - 0.5) * 0.2 : 0,
      ).animate(CurvedAnimation(parent: _controller, curve: _curve));

      _controller.forward().whenComplete(() {
        if (mounted) widget.onEnd();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _position,
      builder: (_, child) {
        return Positioned(
          left: _position.value.dx,
          top: _position.value.dy,
          width: widget.size.width * _scale.value,
          height: widget.size.height * _scale.value,
          child: Transform.rotate(angle: _rotation.value, child: widget.child),
        );
      },
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
