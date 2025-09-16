import 'package:flutter/material.dart';

class AnimatedCardOverlay extends StatefulWidget {
  final Offset start;
  final Offset end;
  final Size size;
  final Widget child;
  final Duration duration;
  final VoidCallback? onEnd;

  const AnimatedCardOverlay({
    super.key,
    required this.start,
    required this.end,
    required this.size,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.onEnd,
  });

  @override
  State<AnimatedCardOverlay> createState() => _AnimatedCardOverlayState();
}

class _AnimatedCardOverlayState extends State<AnimatedCardOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _position;
  late Animation<double> _scale;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);

    // Position
    _position = Tween<Offset>(begin: widget.start, end: widget.end).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    // Zoom léger
    _scale = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Petite rotation aléatoire pour donner du naturel
    _rotation = Tween<double>(
      begin: -0.1,
      end: 0.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward().whenComplete(() {
      widget.onEnd?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) {
        return Positioned(
          left: _position.value.dx,
          top: _position.value.dy,
          child: Transform.scale(
            scale: _scale.value,
            child: Transform.rotate(
              angle: _rotation.value,
              child: SizedBox(
                width: widget.size.width,
                height: widget.size.height,
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
