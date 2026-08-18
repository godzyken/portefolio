import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/tech_maturity_framework.dart';

class EngagementNotifier extends Notifier<Map<TechPillar, int>> {
  @override
  Map<TechPillar, int> build() {
    // On initialise la map de manière immuable et safe
    return Map<TechPillar, int>.unmodifiable({
      for (var pillar in TechPillar.values) pillar: 0,
    });
  }

  void incrementPillar(TechPillar pillar) {
    final currentMap = Map<TechPillar, int>.from(state);
    final currentCount = currentMap[pillar] ?? 0;
    currentMap[pillar] = currentCount + 1;
    state = currentMap;
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
    int max = 0;
    for (var val in state.values) {
      if (val > max) max = val;
    }
    return max;
  }

  List<String> get exploredPillars {
    return state.entries
      .where((e) => e.value > 0)
      .map((e) => e.key.label)
      .toList();
  }

  TechPillar? classifyMessage(String text) {
    final lowerText = text.toLowerCase();
    for (final pillar in TechPillar.values) {
      if (_matchesPillar(pillar, lowerText)) return pillar;
    }
    return null;
  }

  bool _matchesPillar(TechPillar pillar, String text) {
    switch (pillar) {
      case TechPillar.architecture: return text.contains('arch') || text.contains('clean') || text.contains('dossier');
      case TechPillar.stateManagement: return text.contains('state') || text.contains('riverpod') || text.contains('donnée');
      case TechPillar.testing: return text.contains('test') || text.contains('qualité') || text.contains('mock');
      case TechPillar.security: return text.contains('secu') || text.contains('auth') || text.contains('crypt') || text.contains('token');
      case TechPillar.performance: return text.contains('perf') || text.contains('optim') || text.contains('vitesse');
      case TechPillar.cicd: return text.contains('ci') || text.contains('cd') || text.contains('deploy') || text.contains('git');
      case TechPillar.monitoring: return text.contains('monitor') || text.contains('log') || text.contains('sentry');
      case TechPillar.aiSmart: return text.contains('ia') || text.contains('ai') || text.contains('openai') || text.contains('llm');
    }
  }
}

final engagementProvider = NotifierProvider<EngagementNotifier, Map<TechPillar, int>>(
  EngagementNotifier.new,
);
