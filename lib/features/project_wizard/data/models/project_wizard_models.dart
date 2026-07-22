enum ProjectWizardStatus { idle, analyzing, success, error }

class ProjectDescription {
  final String context;
  final String targetAudience;
  final String goals;
  final String technicalConstraints;
  final String budgetRange;

  const ProjectDescription({
    this.context = '',
    this.targetAudience = '',
    this.goals = '',
    this.technicalConstraints = '',
    this.budgetRange = '',
  });

  ProjectDescription copyWith({
    String? context,
    String? targetAudience,
    String? goals,
    String? technicalConstraints,
    String? budgetRange,
  }) {
    return ProjectDescription(
      context: context ?? this.context,
      targetAudience: targetAudience ?? this.targetAudience,
      goals: goals ?? this.goals,
      technicalConstraints: technicalConstraints ?? this.technicalConstraints,
      budgetRange: budgetRange ?? this.budgetRange,
    );
  }

  bool get isValid =>
      context.isNotEmpty &&
      targetAudience.isNotEmpty &&
      goals.isNotEmpty;
}

class StrategicOption {
  final String id;
  final String title;
  final String description;
  final List<String> pros;
  final List<String> cons;

  const StrategicOption({
    required this.id,
    required this.title,
    required this.description,
    required this.pros,
    required this.cons,
  });

  factory StrategicOption.fromJson(Map<String, dynamic> json) {
    return StrategicOption(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      pros: List<String>.from(json['pros'] as List),
      cons: List<String>.from(json['cons'] as List),
    );
  }
}

class AIStrategicAdvice {
  final String summary;
  final List<StrategicOption> options;
  final String technicalRecommendation;

  const AIStrategicAdvice({
    required this.summary,
    required this.options,
    required this.technicalRecommendation,
  });

  factory AIStrategicAdvice.fromJson(Map<String, dynamic> json) {
    return AIStrategicAdvice(
      summary: json['summary'] as String,
      options: (json['options'] as List)
          .map((o) => StrategicOption.fromJson(o as Map<String, dynamic>))
          .toList(),
      technicalRecommendation: json['technicalRecommendation'] as String,
    );
  }
}
