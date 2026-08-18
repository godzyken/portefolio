import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/tech_maturity_framework.dart';

class EngagementNotifier extends Notifier<Map<TechPillar, int>> {
  @override
  Map<TechPillar, int> build() {
    return {
      for (var pillar in TechPillar.values) pillar: 0,
    };
  }

  void incrementPillar(TechPillar pillar) {
    final currentCount = state[pillar] ?? 0; // ✅ Plus de '!'
    state = {
      ...state,
      pillar: currentCount + 1,
    };
  }

  bool get isQualified {
    int totalScore = 0;
    int pillarsWithQuestions = 0;
    
    state.forEach((pillar, count) {
      totalScore += count;
      if (count > 0) pillarsWithQuestions++;
    });

    return totalScore >= 8 && pillarsWithQuestions >= 2;
  }

  int get maxDepth {
    if (state.isEmpty) return 0;
    return state.values.fold(0, (max, val) => val > max ? val : max);
  }

  List<String> get exploredPillars => state.entries
      .where((e) => e.value > 0)
      .map((e) => e.key.label)
      .toList();

  TechPillar? classifyMessage(String text) {
    final lowerText = text.toLowerCase();
    for (final pillar in TechPillar.values) {
      if (_matchesPillar(pillar, lowerText)) return pillar;
    }
    return null;
  }

  bool _matchesPillar(TechPillar pillar, String text) {
    switch (pillar) {
      case TechPillar.architecture: return text.contains('arch') || text.contains('clean');
      case TechPillar.stateManagement: return text.contains('state') || text.contains('riverpod');
      case TechPillar.testing: return text.contains('test') || text.contains('qualité');
      case TechPillar.security: return text.contains('secu') || text.contains('auth');
      case TechPillar.performance: return text.contains('perf') || text.contains('optim');
      case TechPillar.cicd: return text.contains('ci') || text.contains('cd');
      case TechPillar.monitoring: return text.contains('monitor') || text.contains('log');
      case TechPillar.aiSmart: return text.contains('ia') || text.contains('ai');
    }
  }
}

final engagementProvider = NotifierProvider<EngagementNotifier, Map<TechPillar, int>>(
  EngagementNotifier.new,
);
