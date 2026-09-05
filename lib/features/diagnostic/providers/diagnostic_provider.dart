import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/diagnostic_models.dart';
import '../data/state/diagnostic_state.dart';
import '../notifiers/diagnostic_notifier.dart';

/// Charge et parse `assets/data/diagnostic.json` (objet unique, donc pas de
/// `loadJsonFile<T>` générique qui attend une liste).
final diagnosticConfigProvider = FutureProvider<DiagnosticConfig>((ref) async {
  final jsonStr = await rootBundle.loadString('assets/data/diagnostic.json');
  final Map<String, dynamic> data = jsonDecode(jsonStr) as Map<String, dynamic>;
  return DiagnosticConfig.fromJson(data);
}, name: 'DiagnosticConfig');

final diagnosticNotifierProvider =
    NotifierProvider<DiagnosticNotifier, DiagnosticState>(
  DiagnosticNotifier.new,
  name: 'DiagnosticNotifier',
);

/// Résultat calculé à partir des réponses courantes. `null` tant que le
/// questionnaire n'est pas terminé (ou que la config n'est pas chargée).
final diagnosticResultProvider = Provider<DiagnosticResult?>((ref) {
  final config = ref.watch(diagnosticConfigProvider).asData?.value;
  final state = ref.watch(diagnosticNotifierProvider);

  if (config == null) return null;
  if (state.answers.length < config.questions.length) return null;

  final Map<String, List<DiagnosticQuestion>> questionsByCategory = {};
  for (final q in config.questions) {
    questionsByCategory.putIfAbsent(q.categoryId, () => []).add(q);
  }

  final categoryScores = config.categories.map((category) {
    final questions = questionsByCategory[category.id] ?? const [];
    final score =
        questions.fold<int>(0, (sum, q) => sum + (state.answers[q.id] ?? 0));
    final maxScore = questions.fold<int>(0, (sum, q) => sum + q.maxScore);
    return DiagnosticCategoryScore(
      category: category,
      score: score,
      maxScore: maxScore,
    );
  }).toList();

  final totalScore =
      state.answers.values.fold<int>(0, (sum, score) => sum + score);
  final maxTotal = config.maxTotalScore;
  final percent = maxTotal == 0 ? 0 : ((totalScore / maxTotal) * 100).round();

  return DiagnosticResult(
    score: totalScore,
    maxScore: maxTotal,
    level: config.levelFor(percent),
    categoryScores: categoryScores,
  );
}, name: 'DiagnosticResult');
