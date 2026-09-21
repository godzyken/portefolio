class ComplexityAssessment {
  final int functional;
  final int technical;
  final int integration;
  final int data;
  final int security;
  final int deployment;

  const ComplexityAssessment({
    this.functional = 1,
    this.technical = 1,
    this.integration = 1,
    this.data = 1,
    this.security = 1,
    this.deployment = 1,
  });

  double get averageScore =>
      (functional + technical + integration + data + security + deployment) /
      6.0;

  ComplexityAssessment copyWith({
    int? functional,
    int? technical,
    int? integration,
    int? data,
    int? security,
    int? deployment,
  }) {
    return ComplexityAssessment(
      functional: functional ?? this.functional,
      technical: technical ?? this.technical,
      integration: integration ?? this.integration,
      data: data ?? this.data,
      security: security ?? this.security,
      deployment: deployment ?? this.deployment,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'functional': functional,
      'technical': technical,
      'integration': integration,
      'data': data,
      'security': security,
      'deployment': deployment,
      'averageScore': averageScore,
    };
  }
}
