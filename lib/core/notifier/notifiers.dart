import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/experience/data/experiences_data.dart';
import '../../features/generator/data/location_data.dart';
import '../../features/generator/services/location_service.dart';
import '../../features/projets/data/project_data.dart';
import '../exeptions/state/global_error_state.dart';
import '../provider/providers.dart';

class AppBarTitleNotifier extends Notifier<String> {
  @override
  String build() => "Portfolio";

  void setTitle(String title) => state = title;
}

class AppBarActionsNotifier extends Notifier<List<Widget>> {
  @override
  List<Widget> build() => [];

  void setActions(List<Widget> actions) => state = actions;
  void clearActions() => state = [];
}

class AppBarDrawerNotifier extends Notifier<Widget?> {
  @override
  Widget? build() => null;

  void setDrawer(Widget drawer) => state = drawer;
  void clearDrawer() => state = null;
}

class CurrentLocationNotifier extends Notifier<String> {
  @override
  String build() => '/';

  void setLocation(String location) => state = location;
}

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

class SelectedProjectsNotifier extends Notifier<List<ProjectInfo>> {
  @override
  List<ProjectInfo> build() => [];

  void toggle(ProjectInfo project) {
    final newState = [...state];
    if (newState.contains(project)) {
      newState.remove(project);
    } else {
      newState.add(project);
    }
    state = newState;
  }

  void toggleAll(List<ProjectInfo> projects) {
    final newState = [...state];
    bool allSelected = projects.every((p) => newState.contains(p));

    if (allSelected) {
      // Retirer tous
      newState.removeWhere((p) => projects.contains(p));
    } else {
      // Ajouter tous
      for (var p in projects) {
        if (!newState.contains(p)) newState.add(p);
      }
    }
    state = newState;
  }

  void clear() => state = [];
}

class ExperiencesNotifier extends Notifier<List<Experience>> {
  @override
  List<Experience> build() => [];

  void setExperience(List<Experience> exp) => state = exp;
  void clearExperience() => state = [];
}

class ExperienceFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setFilter(String? f) => state = f;
}

class FollowUserNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() => state = !state;
}

class GlobalErrorNotifier extends Notifier<GlobalErrorState?> {
  @override
  GlobalErrorState? build() => null;

  void setError(GlobalErrorState error) => state = error;
  void clear() => state = null;
}

class ScreenSizeNotifier extends Notifier<Size> {
  @override
  Size build() {
    // Taille initiale (avant qu'on ne mesure l'écran)
    return Size.zero;
  }

  /// Mettre à jour la taille
  void setSize(Size newSize) {
    state = newSize;
  }
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

class UserLocationNotifier extends StreamNotifier<LocationData> {
  @override
  Stream<LocationData> build() async* {
    final locationService = LocationService.instance;

    if (!await locationService.isLocationEnabled()) {
      throw Exception('Services de localisation désactivés');
    }

    final permission = await locationService.checkPermission();
    if (permission != LocationPermissionStatus.always &&
        permission != LocationPermissionStatus.whileInUse) {
      final requested = await locationService.requestPermission();
      if (requested != LocationPermissionStatus.always &&
          requested != LocationPermissionStatus.whileInUse) {
        throw Exception('Permission de localisation refusée');
      }
    }

    yield* locationService.getLocationStream();
  }
}
