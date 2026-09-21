import '../../data/models/complexity_assessment.dart';
import '../../data/models/journey_definition.dart';
import '../../data/models/project_context.dart';
import '../../data/models/quote_preparation.dart';
import '../../data/models/scope_definition.dart';

class ConversionEngine {
  static JourneyDefinition getSoftwareJourney() {
    return const JourneyDefinition(
      journeyId: 'software_and_apps',
      stages: [
        JourneyStep(
          id: 'discovery',
          type: StepType.understanding,
          questionText:
              "Quel problème ou objectif souhaitez-vous résoudre avec ce projet ?",
          required: true,
        ),
        JourneyStep(
          id: 'type_detection',
          type: StepType.business,
          questionText:
              "S'agit-il d'une application mobile, d'un site web, ou d'un logiciel métier ?",
          required: true,
        ),
        JourneyStep(
          id: 'integrations',
          type: StepType.technical,
          questionText:
              "Ce projet doit-il se connecter à des systèmes externes ou outils existants ?",
          conditionKey: 'project.hasExternalSystem',
          conditionValue: true,
        ),
        JourneyStep(
          id: 'data_complexity',
          type: StepType.technical,
          questionText:
              "Le système va-t-il manipuler des volumes importants de données ou du temps réel ?",
          conditionKey: 'project.requiresData',
          conditionValue: true,
        ),
        JourneyStep(
          id: 'budget_commercial',
          type: StepType.commercial,
          questionText:
              "Avez-vous déjà défini une enveloppe budgétaire ou un délai souhaité ?",
        ),
      ],
    );
  }

  static QuotePreparation calculateOutputs(ProjectContext project,
      ComplexityAssessment complexity, ScopeDefinition scope) {
    double minB = 1500;
    double maxB = 3000;
    NextStepCommercial step = NextStepCommercial.estimation;

    if (project.type == ProjectType.applicationMobile ||
        project.type == ProjectType.logicielMetier) {
      minB = 8000;
      maxB = 15000;
      step = NextStepCommercial.development;
    }

    if (complexity.averageScore >= 5.0 || project.hasExternalSystem) {
      minB += 5000;
      maxB += 12000;
      step = NextStepCommercial.framing;
    }

    return QuotePreparation(
      technicalStack: TechnicalStack(
        frontend: project.type == ProjectType.applicationMobile
            ? ['Flutter', 'Dart']
            : ['Flutter Web'],
        backend:
            project.requiresData ? ['Supabase', 'PostgreSQL'] : ['Firebase'],
        thirdPartyServices: project.hasExternalSystem ? ['REST API Sync'] : [],
      ),
      budgetEstimationMin: minB,
      budgetEstimationMax: maxB,
      timelineRange:
          complexity.averageScore >= 5.0 ? "2 à 4 mois" : "3 à 6 semaines",
      recommendedStep: step,
    );
  }
}
