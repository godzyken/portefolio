import 'package:flutter/material.dart';

/// Collection d'helpers pour les animations réutilisables
class AnimationHelpers {
  /// Crée une animation de fade-in avec slide
  static Widget fadeSlideIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 600),
    Duration delay = Duration.zero,
    Offset offset = const Offset(0, 0.1),
    Curve curve = Curves.easeOut,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration + delay,
      curve: curve,
      builder: (context, value, child) {
        if (delay != Duration.zero &&
            value < delay.inMilliseconds / (duration + delay).inMilliseconds) {
          return Opacity(opacity: 0, child: child);
        }

        final adjustedValue = delay == Duration.zero
            ? value
            : (value -
                    delay.inMilliseconds / (duration + delay).inMilliseconds) *
                ((duration + delay).inMilliseconds / duration.inMilliseconds);

        return Transform.translate(
          offset: Offset(
            offset.dx * 20 * (1 - adjustedValue),
            offset.dy * 20 * (1 - adjustedValue),
          ),
          child: Opacity(
            opacity: adjustedValue.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Crée une animation de scale avec bounce
  static Widget scaleIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 800),
    Duration delay = Duration.zero,
    Curve curve = Curves.elasticOut,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration + delay,
      curve: curve,
      builder: (context, value, child) {
        if (delay != Duration.zero &&
            value < delay.inMilliseconds / (duration + delay).inMilliseconds) {
          return Transform.scale(scale: 0, child: child);
        }

        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Crée une animation de rotation
  static Widget rotateIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 600),
    Duration delay = Duration.zero,
    double turns = 0.25,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: turns, end: 0.0),
      duration: duration + delay,
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.rotate(
          angle: value * 2 * 3.14159,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Crée une animation de pulsation continue
  static Widget pulse({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1000),
    double minScale = 0.95,
    double maxScale = 1.05,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: minScale, end: maxScale),
      duration: duration,
      curve: Curves.easeInOut,
      onEnd: () {
        // Cette animation se répète automatiquement
      },
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Crée une animation de glow (effet de lueur)
  static Widget glowEffect({
    required Widget child,
    required Color color,
    Duration duration = const Duration(seconds: 2),
    double minAlpha = 0.3,
    double maxAlpha = 1.0,
  }) {
    return AnimatedBuilder(
      animation: AlwaysStoppedAnimation<double>(0),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: minAlpha),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: child,
        );
      },
      child: child,
    );
  }

  /// Crée un controller d'animation avec dispose automatique
  static AnimationController createController({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 300),
    double initialValue = 0.0,
  }) {
    return AnimationController(
      vsync: vsync,
      duration: duration,
      value: initialValue,
    );
  }

  /// Crée une curved animation standard
  static Animation<double> createCurvedAnimation({
    required AnimationController parent,
    Curve curve = Curves.easeInOut,
  }) {
    return CurvedAnimation(
      parent: parent,
      curve: curve,
    );
  }

  /// Animation de shake (secousse)
  static Widget shake({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    double offset = 10.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        final displacement = offset * (1 - value) * (value > 0.5 ? -1 : 1);
        return Transform.translate(
          offset: Offset(displacement, 0),
          child: child,
        );
      },
      child: child,
    );
  }

  /// Animation de flip (retournement)
  static Widget flip({
    required Widget child,
    Duration duration = const Duration(milliseconds: 600),
    Axis axis = Axis.vertical,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        final angle = value * 3.14159;
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(axis == Axis.vertical ? angle : 0)
            ..rotateX(axis == Axis.horizontal ? angle : 0),
          alignment: Alignment.center,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Animation de slide from direction
  static Widget slideFrom({
    required Widget child,
    required SlideDirection direction,
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeOut,
  }) {
    Offset getOffset() {
      switch (direction) {
        case SlideDirection.left:
          return const Offset(-1, 0);
        case SlideDirection.right:
          return const Offset(1, 0);
        case SlideDirection.top:
          return const Offset(0, -1);
        case SlideDirection.bottom:
          return const Offset(0, 1);
      }
    }

    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: getOffset(), end: Offset.zero),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return SlideTransition(
          position: AlwaysStoppedAnimation(value),
          child: child,
        );
      },
      child: child,
    );
  }
}

/// Directions de slide
enum SlideDirection {
  left,
  right,
  top,
  bottom,
}

/// Widget wrapper pour animations combinées
class AnimatedEntry extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final bool fade;
  final bool slide;
  final bool scale;
  final Offset slideOffset;

  const AnimatedEntry({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.delay = Duration.zero,
    this.fade = true,
    this.slide = true,
    this.scale = false,
    this.slideOffset = const Offset(0, 0.1),
  });

  @override
  Widget build(BuildContext context) {
    Widget result = child;

    if (scale) {
      result = AnimationHelpers.scaleIn(
        duration: duration,
        delay: delay,
        child: result,
      );
    }

    if (slide || fade) {
      result = AnimationHelpers.fadeSlideIn(
        duration: duration,
        delay: delay,
        offset: slideOffset,
        child: result,
      );
    }

    return result;
  }
}
