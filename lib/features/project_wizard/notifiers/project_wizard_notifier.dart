import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/project_wizard_models.dart';
import '../services/project_wizard_ai_service.dart';

class ProjectWizardState {
  final int currentStep;
  final ProjectDescription description;
  final ProjectWizardStatus status;
  final AIStrategicAdvice? advice;
  final String? selectedOptionId;
  final String? errorMessage;

  const ProjectWizardState({
    this.currentStep = 0,
    this.description = const ProjectDescription(),
    this.status = ProjectWizardStatus.idle,
    this.advice,
    this.selectedOptionId,
    this.errorMessage,
  });

  ProjectWizardState copyWith({
    int? currentStep,
    ProjectDescription? description,
    ProjectWizardStatus? status,
    AIStrategicAdvice? advice,
    String? selectedOptionId,
    String? errorMessage,
  }) {
    return ProjectWizardState(
      currentStep: currentStep ?? this.currentStep,
      description: description ?? this.description,
      status: status ?? this.status,
      advice: advice ?? this.advice,
      selectedOptionId: selectedOptionId ?? this.selectedOptionId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ProjectWizardNotifier extends Notifier<ProjectWizardState> {
  @override
  ProjectWizardState build() {
    return const ProjectWizardState();
  }

  void updateContext(String value) {
    state = state.copyWith(description: state.description.copyWith(context: value));
  }

  void updateTarget(String value) {
    state = state.copyWith(description: state.description.copyWith(targetAudience: value));
  }

  void updateGoals(String value) {
    state = state.copyWith(description: state.description.copyWith(goals: value));
  }

  void updateTechnical(String value) {
    state = state.copyWith(description: state.description.copyWith(technicalConstraints: value));
  }

  void updateBudget(String value) {
    state = state.copyWith(description: state.description.copyWith(budgetRange: value));
  }

  void nextStep() {
    state = state.copyWith(currentStep: state.currentStep + 1);
  }

  void prevStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  Future<void> analyzeProject(ProjectWizardAiService aiService) async {
    state = state.copyWith(status: ProjectWizardStatus.analyzing, currentStep: 4); // Step 4 is analysis
    try {
      final advice = await aiService.getStrategicAdvice(state.description);
      state = state.copyWith(
        status: ProjectWizardStatus.success,
        advice: advice,
        currentStep: 5, // Step 5 is advice display
      );
    } catch (e) {
      state = state.copyWith(
        status: ProjectWizardStatus.error,
        errorMessage: e.toString(),
        currentStep: 5,
      );
    }
  }

  void selectOption(String optionId) {
    state = state.copyWith(selectedOptionId: optionId);
  }

  void reset() {
    state = const ProjectWizardState();
  }
}
