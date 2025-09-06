import 'package:flutter_riverpod/flutter_riverpod.dart';

class VisitedPagesNotifier extends StateNotifier<Set<String>> {
  VisitedPagesNotifier() : super({});

  void markVisited(String route) {
    state = {...state, route};
  }

  bool get isCompleteVisit {
    const requiredPages = {'/', '/experiences', '/projects', '/contact'};
    return requiredPages.every(state.contains);
  }
}

final visitedPagesProvider =
    StateNotifierProvider<VisitedPagesNotifier, Set<String>>(
      (ref) => VisitedPagesNotifier(),
    );
