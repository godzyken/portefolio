enum NextStepCommercial {
  estimation,
  development,
  framing,
  audit,
  continueQualification
}

class TechnicalStack {
  final List<String> frontend;
  final List<String> backend;
  final List<String> api;
  final List<String> thirdPartyServices;

  const TechnicalStack({
    this.frontend = const [],
    this.backend = const [],
    this.api = const [],
    this.thirdPartyServices = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'frontend': frontend,
      'backend': backend,
      'api': api,
      'thirdPartyServices': thirdPartyServices,
    };
  }
}

class QuotePreparation {
  final TechnicalStack technicalStack;
  final double budgetEstimationMin;
  final double budgetEstimationMax;
  final String timelineRange;
  final NextStepCommercial recommendedStep;

  const QuotePreparation({
    this.technicalStack = const TechnicalStack(),
    this.budgetEstimationMin = 0.0,
    this.budgetEstimationMax = 0.0,
    this.timelineRange = 'À déterminer',
    this.recommendedStep = NextStepCommercial.continueQualification,
  });

  Map<String, dynamic> toJson() {
    return {
      'technicalStack': technicalStack.toJson(),
      'budgetEstimationMin': budgetEstimationMin,
      'budgetEstimationMax': budgetEstimationMax,
      'timelineRange': timelineRange,
      'recommendedStep': recommendedStep.name,
    };
  }
}
