enum StepType {
  understanding,
  business,
  functional,
  technical,
  complexity,
  scope,
  commercial,
  recommendation
}

class JourneyStep {
  final String id;
  final StepType type;
  final String questionText;
  final bool required;
  final String conditionKey;
  final dynamic conditionValue;

  const JourneyStep({
    required this.id,
    required this.type,
    required this.questionText,
    this.required = false,
    this.conditionKey = '',
    this.conditionValue,
  });
}

class JourneyDefinition {
  final String journeyId;
  final List<JourneyStep> stages;

  const JourneyDefinition({
    required this.journeyId,
    required this.stages,
  });
}
