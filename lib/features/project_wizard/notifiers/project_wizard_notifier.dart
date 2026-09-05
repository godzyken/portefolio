import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/provider/tracking_provider.dart';
import '../../../../core/service/tracking_service.dart';
import '../data/models/project_wizard_models.dart';
import '../services/project_wizard_ai_service.dart';
import '../services/project_wizard_lead_service.dart';

enum ProjectSubmitStatus { idle, loading, success, error }

class ProjectWizardState {
  final int currentStep;
  final ProjectDescription description;
  final ProjectWizardStatus status; // Status for AI analysis
  final AIStrategicAdvice? advice;
  final String? selectedOptionId;
  final String? errorMessage;

  // Lead Info
  final String leadName;
  final String leadEmail;
  final ProjectSubmitStatus submitStatus;
  final String? submitError;

  const ProjectWizardState({
    this.currentStep = 0,
    this.description = const ProjectDescription(),
    this.status = ProjectWizardStatus.idle,
    this.advice,
    this.selectedOptionId,
    this.errorMessage,
    this.leadName = '',
    this.leadEmail = '',
    this.submitStatus = ProjectSubmitStatus.idle,
    this.submitError,
  });

  ProjectWizardState copyWith({
    int? currentStep,
    ProjectDescription? description,
    ProjectWizardStatus? status,
    AIStrategicAdvice? advice,
    String? selectedOptionId,
    String? errorMessage,
    String? leadName,
    String? leadEmail,
    ProjectSubmitStatus? submitStatus,
    String? submitError,
  }) {
    return ProjectWizardState(
      currentStep: currentStep ?? this.currentStep,
      description: description ?? this.description,
      status: status ?? this.status,
      advice: advice ?? this.advice,
      selectedOptionId: selectedOptionId ?? this.selectedOptionId,
      errorMessage: errorMessage ?? this.errorMessage,
      leadName: leadName ?? this.leadName,
      leadEmail: leadEmail ?? this.leadEmail,
      submitStatus: submitStatus ?? this.submitStatus,
      submitError: submitError ?? this.submitError,
    );
  }
}

class ProjectWizardNotifier extends Notifier<ProjectWizardState> {
  @override
  ProjectWizardState build() {
    return const ProjectWizardState();
  }

  void updateContext(String value) {
    state =
        state.copyWith(description: state.description.copyWith(context: value));
  }

  void updateTarget(String value) {
    state = state.copyWith(
        description: state.description.copyWith(targetAudience: value));
  }

  void updateGoals(String value) {
    state =
        state.copyWith(description: state.description.copyWith(goals: value));
  }

  void updateTechnical(String value) {
    state = state.copyWith(
        description: state.description.copyWith(technicalConstraints: value));
  }

  void updateBudget(String value) {
    state = state.copyWith(
        description: state.description.copyWith(budgetRange: value));
  }

  void updateLeadName(String value) => state = state.copyWith(leadName: value);
  void updateLeadEmail(String value) =>
      state = state.copyWith(leadEmail: value);

  void nextStep() {
    state = state.copyWith(currentStep: state.currentStep + 1);
  }

  void prevStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  Future<void> analyzeProject(ProjectWizardAiService aiService) async {
    state = state.copyWith(
        status: ProjectWizardStatus.analyzing,
        currentStep: 4); // Step 4 is analysis
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

  Future<void> submitLead() async {
    state = state.copyWith(
        submitStatus: ProjectSubmitStatus.loading, submitError: null);

    try {
      final service = ref.read(projectWizardLeadServiceProvider);

      final selectedStrategy = state.advice?.options.firstWhere(
        (o) => o.id == state.selectedOptionId,
        orElse: () => state.advice!.options.first,
      );

      await service.submit(
        name: state.leadName,
        email: state.leadEmail,
        description: state.description,
        selectedStrategy:
            state.selectedOptionId != null ? selectedStrategy : null,
        aiSummary: state.advice?.summary,
      );

      ref.read(trackingServiceProvider).trackInteraction(
        projectId: 'portfolio',
        projectName: 'Portfolio',
        action: TrackingAction.formSubmit,
        details: {
          'type': 'project_wizard',
          'strategy': selectedStrategy?.title,
          'has_ai': state.advice != null,
        },
      );

      state = state.copyWith(submitStatus: ProjectSubmitStatus.success);
    } catch (e) {
      state = state.copyWith(
        submitStatus: ProjectSubmitStatus.error,
        submitError: e.toString(),
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
