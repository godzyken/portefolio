import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/project_data.dart';

class ProjectPositionsNotifier extends Notifier<Map<String, Offset>> {
  @override
  Map<String, Offset> build() {
    return {};
  }

  void updatePosition(String id, Offset offset) {
    state = {...state, id: offset};
  }
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
