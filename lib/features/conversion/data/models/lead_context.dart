enum MaturityStage {
  contact,
  needIdentified,
  projectFramed,
  scopeIdentified,
  complexityEvaluated,
  budgetIdentified,
  timelineIdentified,
  readyForQuote
}

class LeadContext {
  final String name;
  final String email;
  final String company;
  final MaturityStage stage;
  final double quoteReadinessScore;
  final Map<String, dynamic> metadata;

  const LeadContext({
    this.name = '',
    this.email = '',
    this.company = '',
    this.stage = MaturityStage.contact,
    this.quoteReadinessScore = 0.0,
    this.metadata = const {},
  });

  LeadContext copyWith({
    String? name,
    String? email,
    String? company,
    MaturityStage? stage,
    double? quoteReadinessScore,
    Map<String, dynamic>? metadata,
  }) {
    return LeadContext(
      name: name ?? this.name,
      email: email ?? this.email,
      company: company ?? this.company,
      stage: stage ?? this.stage,
      quoteReadinessScore: quoteReadinessScore ?? this.quoteReadinessScore,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'company': company,
      'stage': stage.name,
      'quoteReadinessScore': quoteReadinessScore,
      'metadata': metadata,
    };
  }
}
