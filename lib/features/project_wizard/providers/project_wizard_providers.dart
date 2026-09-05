import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/provider/config_env_provider.dart';
import '../notifiers/project_wizard_notifier.dart';
import '../services/project_wizard_ai_service.dart';

final projectWizardAiServiceProvider = Provider<ProjectWizardAiService?>((ref) {
  final apiKey = ref.watch(openAiApiKeyProvider);
  if (apiKey == null || apiKey.isEmpty) return null;
  return ProjectWizardAiService(apiKey);
});

final projectWizardProvider =
    NotifierProvider<ProjectWizardNotifier, ProjectWizardState>(
  ProjectWizardNotifier.new,
);
