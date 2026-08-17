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
    state = {
      ...state,
      pillar: state[pillar]! + 1,
    };
  }

  bool get isQualified {
    // Qualification : score cumulé > 8 sur au moins 2 piliers différents
    int totalScore = 0;
    int pillarsWithQuestions = 0;
    
    state.forEach((pillar, count) {
      totalScore += count;
      if (count > 0) pillarsWithQuestions++;
    });

    return totalScore >= 8 && pillarsWithQuestions >= 2;
  }

  int get maxDepth => state.values.fold(0, (max, val) => val > max ? val : max);

  List<String> get exploredPillars => state.entries
      .where((e) => e.value > 0)
      .map((e) => e.key.label)
      .toList();

  TechPillar? classifyMessage(String text) {
    final lowerText = text.toLowerCase();
    
    // On utilise la logique existante dans TechPillar si possible, 
    // ou on l'étend ici pour le chat.
    for (final pillar in TechPillar.values) {
      if (_matchesPillar(pillar, lowerText)) {
        return pillar;
      }
    }
    return null;
  }

  bool _matchesPillar(TechPillar pillar, String text) {
    switch (pillar) {
      case TechPillar.architecture:
        return text.contains('arch') || text.contains('structure') || text.contains('dossier') || text.contains('clean');
      case TechPillar.stateManagement:
        return text.contains('state') || text.contains('riverpod') || text.contains('bloc') || text.contains('provider') || text.contains('donnée');
      case TechPillar.testing:
        return text.contains('test') || text.contains('qualité') || text.contains('mock') || text.contains('coverage');
      case TechPillar.security:
        return text.contains('secu') || text.contains('auth') || text.contains('crypt') || text.contains('rgpd') || text.contains('token');
      case TechPillar.performance:
        return text.contains('perf') || text.contains('optim') || text.contains('fps') || text.contains('vitesse') || text.contains('charge');
      case TechPillar.cicd:
        return text.contains('ci') || text.contains('cd') || text.contains('deploy') || text.contains('git') || text.contains('action') || text.contains('codemagic');
      case TechPillar.monitoring:
        return text.contains('monitor') || text.contains('analytic') || text.contains('log') || text.contains('sentry') || text.contains('crash');
      case TechPillar.aiSmart:
        return text.contains('ia') || text.contains('ai') || text.contains('intel') || text.contains('openai') || text.contains('llm') || text.contains('gpt');
    }
  }
}

final engagementProvider = NotifierProvider<EngagementNotifier, Map<TechPillar, int>>(
  EngagementNotifier.new,
);
