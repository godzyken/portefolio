import 'package:flutter/material.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';
import '../../data/models/project_wizard_models.dart';

class _StepLayout extends StatelessWidget {
  final String title;
  final String description;
  final Widget child;

  const _StepLayout({
    required this.title,
    required this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText.titleLarge(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ResponsiveText.bodyMedium(
          description,
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 32),
        Expanded(child: child),
      ],
    );
  }
}

class ProjectContextFrame extends StatelessWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;

  const ProjectContextFrame({super.key, required this.initialValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _StepLayout(
      title: 'Quel est votre projet ?',
      description: 'Décrivez brièvement le concept et l\'origine de votre idée.',
      child: TextFormField(
        initialValue: initialValue,
        onChanged: onChanged,
        maxLines: 5,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Ex: Je souhaite créer une plateforme de mise en relation pour...',
          hintStyle: const TextStyle(color: Colors.white24),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}

class ProjectTargetFrame extends StatelessWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;

  const ProjectTargetFrame({super.key, required this.initialValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _StepLayout(
      title: 'À qui s\'adresse-t-il ?',
      description: 'Définissez votre audience cible (B2B, B2C, âge, besoins...).',
      child: TextFormField(
        initialValue: initialValue,
        onChanged: onChanged,
        maxLines: 5,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Ex: Les jeunes actifs urbains qui cherchent à...',
          hintStyle: const TextStyle(color: Colors.white24),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}

class ProjectGoalsFrame extends StatelessWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;

  const ProjectGoalsFrame({super.key, required this.initialValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _StepLayout(
      title: 'Quels sont vos objectifs ?',
      description: 'Quels sont les indicateurs de succès (CA, nombre d\'utilisateurs...) ?',
      child: TextFormField(
        initialValue: initialValue,
        onChanged: onChanged,
        maxLines: 5,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Ex: Lancer un MVP sous 3 mois avec 100 bêta-testeurs...',
          hintStyle: const TextStyle(color: Colors.white24),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}

class ProjectTechnicalFrame extends StatelessWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;
  final String budgetInitial;
  final ValueChanged<String> onBudgetChanged;

  const ProjectTechnicalFrame({
    super.key,
    required this.initialValue,
    required this.onChanged,
    required this.budgetInitial,
    required this.onBudgetChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _StepLayout(
      title: 'Détails supplémentaires',
      description: 'Contraintes techniques ou budget approximatif (optionnel).',
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              initialValue: initialValue,
              onChanged: onChanged,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Contraintes techniques',
                labelStyle: const TextStyle(color: Colors.white70),
                hintText: 'Ex: Intégration avec un ERP existant...',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              initialValue: budgetInitial,
              onChanged: onBudgetChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Budget approximatif',
                labelStyle: const TextStyle(color: Colors.white70),
                hintText: 'Ex: 5k€ - 10k€',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProjectAnalysisLoadingFrame extends StatelessWidget {
  const ProjectAnalysisLoadingFrame({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 32),
          const ResponsiveText.titleMedium(
            'L\'IA analyse votre projet...',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const ResponsiveText.bodySmall(
            'Nous élaborons vos conseils stratégiques personnalisés.',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class ProjectAdviceFrame extends StatelessWidget {
  final AIStrategicAdvice? advice;
  final String? errorMessage;

  const ProjectAdviceFrame({super.key, this.advice, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              ResponsiveText.bodyMedium(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const ResponsiveText.bodySmall(
                'Votre description a bien été enregistrée. Vous pouvez continuer pour me l\'envoyer directement.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    if (advice == null) return const SizedBox.shrink();

    return _StepLayout(
      title: 'Analyse Stratégique',
      description: 'Voici une synthèse de votre projet vue par notre IA.',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: ResponsiveText.bodyMedium(
                advice!.summary,
                style: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 24),
            const ResponsiveText.titleMedium(
              'Recommandation Technique',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ResponsiveText.bodySmall(
              advice!.technicalRecommendation,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class ProjectSelectionFrame extends StatelessWidget {
  final AIStrategicAdvice? advice;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  const ProjectSelectionFrame({
    super.key,
    this.advice,
    this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (advice == null) return const SizedBox.shrink();

    return _StepLayout(
      title: 'Choisissez votre stratégie',
      description: 'Sélectionnez l\'approche qui vous semble la plus pertinente.',
      child: ListView.builder(
        itemCount: advice!.options.length,
        itemBuilder: (context, index) {
          final option = advice!.options[index];
          final isSelected = selectedId == option.id;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              onTap: () => onSelected(option.id),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.white10,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ResponsiveText.bodyLarge(
                            option.title,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (isSelected) const Icon(Icons.check_circle, color: Colors.blue),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ResponsiveText.bodySmall(
                      option.description,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProjectFinalFrame extends StatelessWidget {
  const ProjectFinalFrame({super.key});

  @override
  Widget build(BuildContext context) {
    return _StepLayout(
      title: 'Prêt à décoller ?',
      description: 'Envoyez votre projet pour une consultation approfondie.',
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rocket_launch, size: 80, color: Colors.blue),
            SizedBox(height: 24),
            ResponsiveText.bodyLarge(
              'Tout est prêt !',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ResponsiveText.bodySmall(
              'En cliquant sur envoyer, vous recevrez un récapitulatif par email et je vous recontacterai sous 48h.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
