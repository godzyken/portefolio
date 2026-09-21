enum InformationStatus { confirmed, deduced, toConfirm, unknown }

enum ProjectType {
  siteWeb,
  applicationMobile,
  logicielMetier,
  audit,
  automatisation,
  transformationDigitale,
  unknown
}

class ProjectContext {
  final ProjectType type;
  final InformationStatus typeStatus;
  final String sector;
  final String objective;
  final String problem;
  final List<String> targetUsers;
  final bool hasExternalSystem;
  final bool requiresData;
  final Map<String, dynamic> rawAnswers;

  const ProjectContext({
    this.type = ProjectType.unknown,
    this.typeStatus = InformationStatus.unknown,
    this.sector = '',
    this.objective = '',
    this.problem = '',
    this.targetUsers = const [],
    this.hasExternalSystem = false,
    this.requiresData = false,
    this.rawAnswers = const {},
  });

  ProjectContext copyWith({
    ProjectType? type,
    InformationStatus? typeStatus,
    String? sector,
    String? objective,
    String? problem,
    List<String>? targetUsers,
    bool? hasExternalSystem,
    bool? requiresData,
    Map<String, dynamic>? rawAnswers,
  }) {
    return ProjectContext(
      type: type ?? this.type,
      typeStatus: typeStatus ?? this.typeStatus,
      sector: sector ?? this.sector,
      objective: objective ?? this.objective,
      problem: problem ?? this.problem,
      targetUsers: targetUsers ?? this.targetUsers,
      hasExternalSystem: hasExternalSystem ?? this.hasExternalSystem,
      requiresData: requiresData ?? this.requiresData,
      rawAnswers: rawAnswers ?? this.rawAnswers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'typeStatus': typeStatus.name,
      'sector': sector,
      'objective': objective,
      'problem': problem,
      'targetUsers': targetUsers,
      'hasExternalSystem': hasExternalSystem,
      'requiresData': requiresData,
      'rawAnswers': rawAnswers,
    };
  }
}
