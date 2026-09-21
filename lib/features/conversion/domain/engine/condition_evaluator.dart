import '../../data/models/complexity_assessment.dart';
import '../../data/models/project_context.dart';

class ConditionEvaluator {
  static bool evaluate(String key, dynamic expectedValue,
      ProjectContext project, ComplexityAssessment complexity) {
    if (key.isEmpty) return true;

    switch (key) {
      case 'project.hasExternalSystem':
        return project.hasExternalSystem == expectedValue;
      case 'project.requiresData':
        return project.requiresData == expectedValue;
      case 'project.type':
        return project.type.name == expectedValue;
      case 'complexity.technical':
        if (expectedValue is int) {
          return complexity.technical >= expectedValue;
        }
        return false;
      default:
        return true;
    }
  }
}
