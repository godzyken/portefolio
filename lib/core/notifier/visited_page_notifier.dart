import 'package:flutter_riverpod/flutter_riverpod.dart';

class VisitedPagesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    return {};
  }

  void markVisited(String route) {
    state = {...state, route};
  }

  bool get isCompleteVisit {
    const requiredPages = {'/', '/experiences', '/projects', '/contact'};
    return requiredPages.every(state.contains);
  }
}

final visitedPagesProvider =
    NotifierProvider<VisitedPagesNotifier, Set<String>>(
  VisitedPagesNotifier.new,
);
