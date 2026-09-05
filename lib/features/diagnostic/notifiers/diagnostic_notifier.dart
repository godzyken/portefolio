import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/provider/tracking_provider.dart';
import '../../../../core/service/tracking_service.dart';
import '../service/diagnostic_lead_service.dart';
import '../data/models/diagnostic_models.dart';
import '../data/state/diagnostic_state.dart';

class DiagnosticNotifier extends Notifier<DiagnosticState> {
  @override
  DiagnosticState build() => const DiagnosticState();

  void start() {
    state = state.copyWith(
      step: DiagnosticStep.questions,
      currentQuestionIndex: 0,
    );
  }

  /// Enregistre la réponse et passe à la question suivante, ou au résultat
  /// si c'était la dernière question.
  void answer(String questionId, int score, {required int totalQuestions}) {
    final answers = Map<String, int>.from(state.answers)..[questionId] = score;
    final nextIndex = state.currentQuestionIndex + 1;

    if (nextIndex >= totalQuestions) {
      state = state.copyWith(answers: answers, step: DiagnosticStep.result);
    } else {
      state = state.copyWith(
        answers: answers,
        currentQuestionIndex: nextIndex,
      );
    }
  }

  void goBack() {
    if (state.currentQuestionIndex == 0) {
      state = state.copyWith(step: DiagnosticStep.intro);
    } else {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex - 1,
      );
    }
  }

  void updateLeadName(String value) => state = state.copyWith(leadName: value);

  void updateLeadEmail(String value) =>
      state = state.copyWith(leadEmail: value);

  void updateCompanyName(String value) =>
      state = state.copyWith(companyName: value);

  void updateProjectSummary(String value) =>
      state = state.copyWith(projectSummary: value);

  Future<void> submitLead(DiagnosticResult result) async {
    if (state.leadEmail.isEmpty) return;

    state = state.copyWith(
      submitStatus: LeadSubmitStatus.loading,
      clearSubmitError: true,
    );

    try {
      final service = ref.read(diagnosticLeadServiceProvider);
      await service.submit(
        name: state.leadName,
        email: state.leadEmail,
        company: state.companyName,
        projectSummary: state.projectSummary,
        score: result.score,
        maxScore: result.maxScore,
        percent: result.percent,
        levelTitle: result.level.title,
      );

      ref.read(trackingServiceProvider).trackInteraction(
        projectId: 'portfolio',
        projectName: 'Portfolio',
        action: TrackingAction.formSubmit,
        details: {
          'type': 'diagnostic',
          'score': result.percent,
          'level': result.level.title,
        },
      );

      state = state.copyWith(submitStatus: LeadSubmitStatus.success);
    } catch (e) {
      state = state.copyWith(
        submitStatus: LeadSubmitStatus.error,
        submitError: e.toString(),
      );
    }
  }

  void reset() => state = const DiagnosticState();
}
