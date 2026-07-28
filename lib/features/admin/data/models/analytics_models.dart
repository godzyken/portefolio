class ProjectAnalytics {
  final String projectId;
  final String? projectName;
  final int totalInteractions;
  final int totalConversions;
  final Map<String, int> actionsByType;

  ProjectAnalytics({
    required this.projectId,
    this.projectName,
    required this.totalInteractions,
    required this.totalConversions,
    required this.actionsByType,
  });

  double get conversionRate => totalInteractions == 0 ? 0 : (totalConversions / totalInteractions) * 100;
}
