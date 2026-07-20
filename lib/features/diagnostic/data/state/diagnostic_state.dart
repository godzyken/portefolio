enum DiagnosticStep { intro, questions, result }

enum LeadSubmitStatus { idle, loading, success, error }

class DiagnosticState {
  final DiagnosticStep step;
  final int currentQuestionIndex;

  /// questionId -> score de la réponse choisie
  final Map<String, int> answers;

  final String leadName;
  final String leadEmail;
  final String companyName;

  final LeadSubmitStatus submitStatus;
  final String? submitError;

  const DiagnosticState({
    this.step = DiagnosticStep.intro,
    this.currentQuestionIndex = 0,
    this.answers = const {},
    this.leadName = '',
    this.leadEmail = '',
    this.companyName = '',
    this.submitStatus = LeadSubmitStatus.idle,
    this.submitError,
  });

  DiagnosticState copyWith({
    DiagnosticStep? step,
    int? currentQuestionIndex,
    Map<String, int>? answers,
    String? leadName,
    String? leadEmail,
    String? companyName,
    LeadSubmitStatus? submitStatus,
    String? submitError,
    bool clearSubmitError = false,
  }) {
    return DiagnosticState(
      step: step ?? this.step,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      answers: answers ?? this.answers,
      leadName: leadName ?? this.leadName,
      leadEmail: leadEmail ?? this.leadEmail,
      companyName: companyName ?? this.companyName,
      submitStatus: submitStatus ?? this.submitStatus,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
    );
  }
}
