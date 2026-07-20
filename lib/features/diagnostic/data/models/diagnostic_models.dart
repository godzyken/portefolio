/// Modèles du diagnostic interactif de maturité numérique.
///
/// Tout le contenu (questions, options, niveaux de résultat) est piloté par
/// `assets/data/diagnostic.json`, dans l'esprit "content piloté par JSON"
/// déjà utilisé par le reste du portfolio (services, expériences, projets).

class DiagnosticCategory {
  final String id;
  final String title;

  const DiagnosticCategory({required this.id, required this.title});

  factory DiagnosticCategory.fromJson(Map<String, dynamic> json) {
    return DiagnosticCategory(
      id: json['id'] as String,
      title: json['title'] as String,
    );
  }
}

class DiagnosticOption {
  final String label;
  final int score;

  const DiagnosticOption({required this.label, required this.score});

  factory DiagnosticOption.fromJson(Map<String, dynamic> json) {
    return DiagnosticOption(
      label: json['label'] as String,
      score: json['score'] as int,
    );
  }
}

class DiagnosticQuestion {
  final String id;
  final String categoryId;
  final String text;
  final List<DiagnosticOption> options;

  const DiagnosticQuestion({
    required this.id,
    required this.categoryId,
    required this.text,
    required this.options,
  });

  factory DiagnosticQuestion.fromJson(Map<String, dynamic> json) {
    return DiagnosticQuestion(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      text: json['text'] as String,
      options: (json['options'] as List)
          .map((o) => DiagnosticOption.fromJson(o as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Score maximum atteignable pour cette question (la meilleure réponse).
  int get maxScore =>
      options.map((o) => o.score).fold(0, (a, b) => a > b ? a : b);
}

class DiagnosticLevel {
  final int min;
  final int max;
  final String title;
  final String description;
  final List<String> recommendedActions;

  const DiagnosticLevel({
    required this.min,
    required this.max,
    required this.title,
    required this.description,
    required this.recommendedActions,
  });

  factory DiagnosticLevel.fromJson(Map<String, dynamic> json) {
    return DiagnosticLevel(
      min: json['min'] as int,
      max: json['max'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      recommendedActions:
          (json['recommendedActions'] as List?)?.cast<String>() ?? const [],
    );
  }

  bool matches(int percent) => percent >= min && percent <= max;
}

class DiagnosticConfig {
  final List<DiagnosticCategory> categories;
  final List<DiagnosticQuestion> questions;
  final List<DiagnosticLevel> levels;

  const DiagnosticConfig({
    required this.categories,
    required this.questions,
    required this.levels,
  });

  factory DiagnosticConfig.fromJson(Map<String, dynamic> json) {
    return DiagnosticConfig(
      categories: (json['categories'] as List)
          .map((c) => DiagnosticCategory.fromJson(c as Map<String, dynamic>))
          .toList(),
      questions: (json['questions'] as List)
          .map((q) => DiagnosticQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
      levels: (json['levels'] as List)
          .map((l) => DiagnosticLevel.fromJson(l as Map<String, dynamic>))
          .toList(),
    );
  }

  int get maxTotalScore =>
      questions.fold(0, (sum, q) => sum + q.maxScore);

  DiagnosticLevel levelFor(int percent) {
    return levels.firstWhere(
      (l) => l.matches(percent),
      orElse: () => levels.last,
    );
  }

  DiagnosticCategory categoryById(String id) {
    return categories.firstWhere(
      (c) => c.id == id,
      orElse: () => DiagnosticCategory(id: id, title: id),
    );
  }
}

/// Score obtenu pour une thématique donnée (ex: "Stratégie & Pilotage").
class DiagnosticCategoryScore {
  final DiagnosticCategory category;
  final int score;
  final int maxScore;

  const DiagnosticCategoryScore({
    required this.category,
    required this.score,
    required this.maxScore,
  });

  double get ratio => maxScore == 0 ? 0 : score / maxScore;
  int get percent => (ratio * 100).round();
}

/// Résultat complet du diagnostic, calculé à partir des réponses.
class DiagnosticResult {
  final int score;
  final int maxScore;
  final DiagnosticLevel level;
  final List<DiagnosticCategoryScore> categoryScores;

  const DiagnosticResult({
    required this.score,
    required this.maxScore,
    required this.level,
    required this.categoryScores,
  });

  int get percent =>
      maxScore == 0 ? 0 : ((score / maxScore) * 100).round();
}
