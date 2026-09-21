import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/complexity_assessment.dart';
import '../data/models/journey_definition.dart';
import '../data/models/lead_context.dart';
import '../data/models/project_context.dart';
import '../data/models/quote_preparation.dart';
import '../data/models/scope_definition.dart';
import '../domain/engine/conversion_engine.dart';
import '../services/conversion_lead_service.dart';

enum ConversionSubmitStatus { idle, loading, success, error }

class ConversionSessionState {
  final LeadContext lead;
  final ProjectContext project;
  final ComplexityAssessment complexity;
  final ScopeDefinition scope;
  final QuotePreparation quote;
  final JourneyDefinition journey;
  final int currentStepIndex;
  final bool isCompleted;
  final String leadName;
  final String leadEmail;
  final String leadCompany;
  final ConversionSubmitStatus submitStatus;
  final String? submitError;

  const ConversionSessionState({
    required this.lead,
    required this.project,
    required this.complexity,
    required this.scope,
    required this.quote,
    required this.journey,
    required this.currentStepIndex,
    required this.isCompleted,
    this.leadName = '',
    this.leadEmail = '',
    this.leadCompany = '',
    this.submitStatus = ConversionSubmitStatus.idle,
    this.submitError,
  });

  ConversionSessionState copyWith({
    LeadContext? lead,
    ProjectContext? project,
    ComplexityAssessment? complexity,
    ScopeDefinition? scope,
    QuotePreparation? quote,
    JourneyDefinition? journey,
    int? currentStepIndex,
    bool? isCompleted,
    String? leadName,
    String? leadEmail,
    String? leadCompany,
    ConversionSubmitStatus? submitStatus,
    String? submitError,
    bool clearSubmitError = false,
  }) {
    return ConversionSessionState(
      lead: lead ?? this.lead,
      project: project ?? this.project,
      complexity: complexity ?? this.complexity,
      scope: scope ?? this.scope,
      quote: quote ?? this.quote,
      journey: journey ?? this.journey,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      isCompleted: isCompleted ?? this.isCompleted,
      leadName: leadName ?? this.leadName,
      leadEmail: leadEmail ?? this.leadEmail,
      leadCompany: leadCompany ?? this.leadCompany,
      submitStatus: submitStatus ?? this.submitStatus,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
    );
  }
}

class ConversionSessionNotifier extends Notifier<ConversionSessionState> {
  @override
  ConversionSessionState build() {
    return ConversionSessionState(
      lead: const LeadContext(),
      project: const ProjectContext(),
      complexity: const ComplexityAssessment(),
      scope: const ScopeDefinition(),
      quote: const QuotePreparation(),
      journey: ConversionEngine.getSoftwareJourney(),
      currentStepIndex: 0,
      isCompleted: false,
    );
  }

  void updateLeadName(String value) => state = state.copyWith(leadName: value);
  void updateLeadEmail(String value) =>
      state = state.copyWith(leadEmail: value);
  void updateLeadCompany(String value) =>
      state = state.copyWith(leadCompany: value);

  void submitAnswer(String stepId, dynamic answer) {
    var updatedProject = state.project;
    var updatedComplexity = state.complexity;
    var updatedLead = state.lead;

    if (stepId == 'discovery') {
      updatedProject = updatedProject.copyWith(objective: answer.toString());
      updatedLead = updatedLead.copyWith(stage: MaturityStage.needIdentified);
    } else if (stepId == 'type_detection') {
      final input = answer.toString().toLowerCase();
      ProjectType type = ProjectType.unknown;
      if (input.contains('mobile')) {
        type = ProjectType.applicationMobile;
      } else if (input.contains('web') || input.contains('site')) {
        type = ProjectType.siteWeb;
      } else {
        type = ProjectType.logicielMetier;
      }
      updatedProject = updatedProject.copyWith(
        type: type,
        typeStatus: InformationStatus.confirmed,
      );
      updatedLead = updatedLead.copyWith(stage: MaturityStage.projectFramed);
    } else if (stepId == 'integrations') {
      final hasSys =
          answer.toString().toLowerCase().contains('oui') || answer == true;
      updatedProject = updatedProject.copyWith(hasExternalSystem: hasSys);
      if (hasSys) {
        updatedComplexity =
            updatedComplexity.copyWith(technical: 7, integration: 8);
      }
    } else if (stepId == 'data_complexity') {
      final reqData =
          answer.toString().toLowerCase().contains('oui') || answer == true;
      updatedProject = updatedProject.copyWith(requiresData: reqData);
      if (reqData) {
        updatedComplexity = updatedComplexity.copyWith(data: 8, functional: 6);
      }
    }

    final updatedQuote = ConversionEngine.calculateOutputs(
        updatedProject, updatedComplexity, state.scope);

    int nextIndex = state.currentStepIndex + 1;
    bool completed = nextIndex >= state.journey.stages.length;

    state = state.copyWith(
      project: updatedProject,
      complexity: updatedComplexity,
      lead: updatedLead,
      quote: updatedQuote,
      currentStepIndex: nextIndex,
      isCompleted: completed,
    );
  }

  Future<void> finalizeAndSubmit() async {
    if (state.leadEmail.isEmpty) return;

    state = state.copyWith(
      submitStatus: ConversionSubmitStatus.loading,
      clearSubmitError: true,
    );

    try {
      final service = ref.read(conversionLeadServiceProvider);
      await service.submit(
        name: state.leadName,
        email: state.leadEmail,
        company: state.leadCompany,
        project: state.project,
        complexity: state.complexity,
        quote: state.quote,
      );

      state = state.copyWith(submitStatus: ConversionSubmitStatus.success);
    } catch (e) {
      state = state.copyWith(
        submitStatus: ConversionSubmitStatus.error,
        submitError: e.toString(),
      );
    }
  }

  void reset() => state = ConversionSessionState(
        lead: const LeadContext(),
        project: const ProjectContext(),
        complexity: const ComplexityAssessment(),
        scope: const ScopeDefinition(),
        quote: const QuotePreparation(),
        journey: ConversionEngine.getSoftwareJourney(),
        currentStepIndex: 0,
        isCompleted: false,
      );
}

final conversionSessionProvider =
    NotifierProvider<ConversionSessionNotifier, ConversionSessionState>(
        ConversionSessionNotifier.new);
