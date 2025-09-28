import 'package:flutter/material.dart';

class FallingTag extends StatefulWidget {
  final Offset start;
  final Offset end;
  final Widget child;
  final Duration duration;

  const FallingTag({
    super.key,
    required this.start,
    required this.end,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<FallingTag> createState() => _FallingTagState();
}

class _FallingTagState extends State<FallingTag>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _position;
  late Animation<double> _scale;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);

    // Trajectoire verticale + horizontale
    _position = Tween<Offset>(
      begin: widget.start,
      end: widget.end,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInQuad));

    // La pièce grossit un peu puis redevient normale
    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 70),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Petite rotation pour l’effet réaliste
    _rotation = Tween<double>(
      begin: 0.0,
      end: 2.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Positioned(
          left: _position.value.dx,
          top: _position.value.dy,
          child: Transform.scale(
            scale: _scale.value,
            child: Transform.rotate(
              angle: _rotation.value,
              child: widget.child,
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
