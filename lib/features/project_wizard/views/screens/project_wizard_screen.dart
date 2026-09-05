import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/affichage/screen_size_detector.dart';
import '../../../generator/views/widgets/animations/diagnostic_progress_bar.dart';
import '../../notifiers/project_wizard_notifier.dart';
import '../../providers/project_wizard_providers.dart';
import '../../services/project_wizard_ai_service.dart';
import '../widgets/project_step_frames.dart';

class ProjectWizardScreen extends ConsumerWidget {
  const ProjectWizardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final info = ref.watch(responsiveInfoProvider);
    final state = ref.watch(projectWizardProvider);
    final notifier = ref.read(projectWizardProvider.notifier);
    final aiService = ref.watch(projectWizardAiServiceProvider);

    final totalSteps =
        8; // 0-3 inputs, 4 loading, 5 advice, 6 selection, 7 final info

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Assistant de Projet IA',
            style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (state.currentStep > 0 && state.currentStep < 4) {
              notifier.prevStep();
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  DiagnosticProgressBar(
                    current: state.currentStep + 1,
                    total: totalSteps,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child:
                          _buildCurrentStep(state, notifier, aiService, theme),
                    ),
                  ),
                  if (state.currentStep < 4 || state.currentStep >= 5)
                    _buildNavigation(
                        state, notifier, aiService, theme, context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(
    ProjectWizardState state,
    ProjectWizardNotifier notifier,
    ProjectWizardAiService? aiService,
    ThemeData theme,
  ) {
    switch (state.currentStep) {
      case 0:
        return ProjectContextFrame(
          initialValue: state.description.context,
          onChanged: notifier.updateContext,
        );
      case 1:
        return ProjectTargetFrame(
          initialValue: state.description.targetAudience,
          onChanged: notifier.updateTarget,
        );
      case 2:
        return ProjectGoalsFrame(
          initialValue: state.description.goals,
          onChanged: notifier.updateGoals,
        );
      case 3:
        return ProjectTechnicalFrame(
          initialValue: state.description.technicalConstraints,
          onChanged: notifier.updateTechnical,
          budgetInitial: state.description.budgetRange,
          onBudgetChanged: notifier.updateBudget,
        );
      case 4:
        return const ProjectAnalysisLoadingFrame();
      case 5:
        return ProjectAdviceFrame(
          advice: state.advice,
          errorMessage: state.errorMessage,
        );
      case 6:
        return ProjectSelectionFrame(
          advice: state.advice,
          selectedId: state.selectedOptionId,
          onSelected: notifier.selectOption,
        );
      case 7:
        return ProjectFinalFrame(state: state, notifier: notifier);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildNavigation(
    ProjectWizardState state,
    ProjectWizardNotifier notifier,
    ProjectWizardAiService? aiService,
    ThemeData theme,
    BuildContext context,
  ) {
    final isFirstStep = state.currentStep == 0;
    final isAnalysisStep = state.currentStep == 3;
    final isLastStep = state.currentStep == 7;
    final isSubmitting = state.submitStatus == ProjectSubmitStatus.loading;

    // Handle Success Redirection
    if (state.submitStatus == ProjectSubmitStatus.success) {
      Future.microtask(() {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Projet envoyé avec succès !')),
          );
          notifier.reset();
          context.pop();
        }
      });
    }

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Row(
        children: [
          if (!isFirstStep && state.currentStep != 5 && !isSubmitting)
            Expanded(
              child: OutlinedButton(
                onPressed: notifier.prevStep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Précédent'),
              ),
            ),
          if (!isFirstStep && state.currentStep != 5 && !isSubmitting)
            const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: _isNextEnabled(state) && !isSubmitting
                  ? () {
                      if (isAnalysisStep) {
                        if (aiService != null) {
                          notifier.analyzeProject(aiService);
                        }
                      } else if (isLastStep) {
                        notifier.submitLead();
                      } else if (state.currentStep == 5 &&
                          state.errorMessage != null) {
                        notifier.nextStep(); // to 6
                        notifier.nextStep(); // to 7
                      } else {
                        notifier.nextStep();
                      }
                    }
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Text(isAnalysisStep
                      ? 'Analyser avec l\'IA'
                      : (isLastStep
                          ? 'Envoyer'
                          : (state.currentStep == 5 &&
                                  state.errorMessage != null
                              ? 'Continuer sans analyse'
                              : 'Suivant'))),
            ),
          ),
        ],
      ),
    );
  }

  bool _isNextEnabled(ProjectWizardState state) {
    switch (state.currentStep) {
      case 0:
        return state.description.context.isNotEmpty;
      case 1:
        return state.description.targetAudience.isNotEmpty;
      case 2:
        return state.description.goals.isNotEmpty;
      case 3:
        return true; // Optional fields
      case 5:
        return state.advice != null || state.errorMessage != null;
      case 6:
        return state.selectedOptionId != null;
      case 7:
        return state.leadName.isNotEmpty &&
            state.leadEmail.isNotEmpty &&
            RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(state.leadEmail);
      default:
        return true;
    }
  }
}
