import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../animations/page_transitions.dart';
import '../provider/providers.dart';

class IsGeneratingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void start() => state = true;
  void stop() => state = false;
}

class IsPageViewNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() => state = !state;
}

class PlayingVideoNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void play(String id) => state = id;
  void stop() => state = null;
}

class FollowUserNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() => state = !state;
}

/// -------------------------
/// Streams avec StreamNotifierProvider
/// -------------------------

class RouteLocationStreamNotifier extends StreamNotifier<String> {
  @override
  Stream<String> build() async* {
    final controller = StreamController<String>.broadcast();

    controller.add(ref.read(currentLocationProvider));

    ref.listen<String>(currentLocationProvider, (p, n) {
      controller.add(n);
    });

    ref.onDispose(controller.close);

    yield* controller.stream;
  }
}

/// RouterNotifier gère la route précédente et la direction pour les transitions cube
class RouterNotifier extends Notifier<String> {
  late String _previousRoute;
  late CubeDirection _direction;

  final _listeners = <VoidCallback>[];

  @override
  String build() {
    _previousRoute = '/';
    _direction = CubeDirection.right;
    return _previousRoute;
  }

  CubeDirection get direction => _direction;

  /// Appelle à chaque navigation pour mettre à jour la direction
  void update(String newRoute) {
    final pages = ['/', '/experiences', '/projects', '/contact'];
    final oldIndex = pages.indexOf(_previousRoute);
    final newIndex = pages.indexOf(newRoute);

    if (newIndex > oldIndex) {
      _direction = CubeDirection.right;
    } else if (newIndex < oldIndex) {
      _direction = CubeDirection.left;
    }

    _previousRoute = newRoute;
    state = _previousRoute; // notifie les listeners

    // Notifie les listeners pour GoRouter
    for (final listener in _listeners) {
      listener();
    }
  }

  /// API pour GoRouter
  void addListener(VoidCallback listener) => _listeners.add(listener);
  void removeListener(VoidCallback listener) => _listeners.remove(listener);
}

class CurrentLocationNotifier extends Notifier<String> {
  @override
  String build() => '/';

  void setLocation(String location) => state = location;
}
