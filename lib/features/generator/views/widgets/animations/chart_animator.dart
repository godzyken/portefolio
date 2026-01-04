import 'package:flutter/material.dart';

/// Wrapper d’animation réutilisable pour tous les graphiques
class ChartAnimator extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double delay;

  const ChartAnimator({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.curve = Curves.easeOutCubic,
    this.delay = 0,
  });

  @override
  State<ChartAnimator> createState() => _ChartAnimatorState();
}

class _ChartAnimatorState extends State<ChartAnimator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _fade =
      CurvedAnimation(parent: _controller, curve: widget.curve);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: (widget.delay * 1000).round()), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.9, end: 1.0).animate(_fade),
        child: widget.child,
      ),
    );
  }
}
