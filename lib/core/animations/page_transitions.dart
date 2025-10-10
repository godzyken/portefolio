import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum TransitionType { fade, slide, cube }

enum CubeDirection { left, right }

/// Page avec animation personnalisée (fade, slide ou cube)
class CustomTransitionPageBuilder extends CustomTransitionPage<void> {
  CustomTransitionPageBuilder({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
    TransitionType type = TransitionType.fade,
    CubeDirection direction = CubeDirection.right,
    required super.child,
  }) : super(
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            switch (type) {
              case TransitionType.cube:
                final rotate = Tween<double>(
                  begin: direction == CubeDirection.right ? 1.0 : -1.0,
                  end: 0.0,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOutCubic,
                ));

                final opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                );

                return AnimatedBuilder(
                  animation: rotate,
                  builder: (context, childWidget) {
                    final angle = rotate.value * (math.pi / 2);
                    final transform = Matrix4.identity()
                      ..setEntry(3, 2, 0.0015)
                      ..rotateY(angle);

                    return Opacity(
                      opacity: opacity.value,
                      child: Transform(
                        transform: transform,
                        alignment: direction == CubeDirection.right
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: childWidget,
                      ),
                    );
                  },
                  child: child,
                );

              case TransitionType.slide:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.05, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: animation, curve: curve)),
                  child: child,
                );

              case TransitionType.fade:
                return FadeTransition(
                  opacity: CurvedAnimation(parent: animation, curve: curve),
                  child: child,
                );
            }
          },
        );
}
