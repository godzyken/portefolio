import 'package:flutter_test/flutter_test.dart';
import 'package:portefolio/features/conversion/data/models/complexity_assessment.dart';
import 'package:portefolio/features/conversion/data/models/project_context.dart';
import 'package:portefolio/features/conversion/data/models/quote_preparation.dart';
import 'package:portefolio/features/conversion/data/models/scope_definition.dart';
import 'package:portefolio/features/conversion/domain/engine/conversion_engine.dart';

void main() {
  group('ConversionEngine Unit Tests', () {
    test('Calcul des outputs pour un projet simple', () {
      const project = ProjectContext(
        type: ProjectType.siteWeb,
        hasExternalSystem: false,
        requiresData: false,
      );
      const complexity = ComplexityAssessment();
      const scope = ScopeDefinition();

      final result =
          ConversionEngine.calculateOutputs(project, complexity, scope);

      expect(result.recommendedStep, NextStepCommercial.estimation);
      expect(result.budgetEstimationMin, 1500.0);
    });

    test('Calcul des outputs pour une application mobile complexe', () {
      const project = ProjectContext(
        type: ProjectType.applicationMobile,
        hasExternalSystem: true,
        requiresData: true,
      );
      const complexity = ComplexityAssessment(
        functional: 6,
        technical: 7,
        integration: 8,
        data: 8,
      );
      const scope = ScopeDefinition();

      final result =
          ConversionEngine.calculateOutputs(project, complexity, scope);

      expect(result.recommendedStep, NextStepCommercial.framing);
      expect(result.budgetEstimationMin, 13000.0); // 8000 + 5000
    });
  });
}
