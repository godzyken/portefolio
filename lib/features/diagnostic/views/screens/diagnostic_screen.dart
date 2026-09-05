import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/sections/section_system.dart';
import '../../../../core/ui/widgets/responsive_text.dart';
import '../../../generator/views/widgets/animations/diagnostic_category_bar.dart';
import '../../../generator/views/widgets/animations/diagnostic_progress_bar.dart';
import '../../../generator/views/widgets/animations/diagnostic_score_gauge.dart';
import '../../../generator/views/widgets/cards/diagnostic_option_card.dart';
import '../../../parametres/themes/views/widgets/space_background.dart';
import '../../../../core/provider/tracking_provider.dart';
import '../../../../core/service/tracking_service.dart';
import '../../data/models/diagnostic_models.dart';
import '../../data/state/diagnostic_state.dart';
import '../../providers/diagnostic_provider.dart';
import 'diagnostic_lead_form.dart';

class DiagnosticScreen extends ConsumerWidget {
  const DiagnosticScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final configAsync = ref.watch(diagnosticConfigProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostic de maturité numérique'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
      ),
      body: SpaceBackground(
        primaryColor: theme.colorScheme.primary,
        secondaryColor: theme.colorScheme.secondary,
        starCount: 80,
        child: SafeArea(
          child: configAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text(
                'Erreur de chargement du diagnostic : $e',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            data: (config) => Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 32),
                    child: _DiagnosticBody(config: config),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DiagnosticBody extends ConsumerWidget {
  const _DiagnosticBody({required this.config});
  final DiagnosticConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(
      diagnosticNotifierProvider.select((s) => s.step),
    );

    return switch (step) {
      DiagnosticStep.intro => _IntroView(config: config),
      DiagnosticStep.questions => _QuestionsView(config: config),
      DiagnosticStep.result => _ResultView(config: config),
    };
  }
}

// ---------------------------------------------------------------------------
// Étape 1 : Intro
// ---------------------------------------------------------------------------

class _IntroView extends ConsumerWidget {
  const _IntroView({required this.config});
  final DiagnosticConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.insights, size: 56, color: theme.colorScheme.primary),
        const SizedBox(height: 24),
        const ResponsiveText.titleLarge(
          'Évaluez la maturité numérique de votre organisation',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ResponsiveText.bodyLarge(
          'En 3 minutes, ${config.questions.length} questions pour obtenir un score, '
          'une synthèse visuelle par thématique et des recommandations concrètes '
          'pour accélérer votre transformation digitale.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, height: 1.5),
        ),
        const SizedBox(height: 32),
        Align(
          alignment: Alignment.centerLeft,
          child: BulletListBuilder.checks(
            items: const [
              'Un score de maturité numérique',
              'Une synthèse visuelle par thématique',
              'Des recommandations personnalisées',
            ],
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              ref.read(trackingServiceProvider).trackInteraction(
                projectId: 'portfolio',
                projectName: 'Portfolio',
                action: TrackingAction.linkClick,
                details: {'type': 'diagnostic_start'},
              );
              ref.read(diagnosticNotifierProvider.notifier).start();
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Démarrer le diagnostic'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              backgroundColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
  }
}

// ---------------------------------------------------------------------------
// Étape 2 : Questions
// ---------------------------------------------------------------------------

class _QuestionsView extends ConsumerStatefulWidget {
  const _QuestionsView({required this.config});
  final DiagnosticConfig config;

  @override
  ConsumerState<_QuestionsView> createState() => _QuestionsViewState();
}

class _QuestionsViewState extends ConsumerState<_QuestionsView> {
  int? _pendingScore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(diagnosticNotifierProvider);
    final notifier = ref.read(diagnosticNotifierProvider.notifier);
    final questions = widget.config.questions;
    final index = state.currentQuestionIndex.clamp(0, questions.length - 1);
    final question = questions[index];
    final category = widget.config.categoryById(question.categoryId);

    void select(int score) {
      setState(() => _pendingScore = score);
      Future.delayed(const Duration(milliseconds: 350), () {
        if (!mounted) return;
        notifier.answer(question.id, score, totalQuestions: questions.length);
        setState(() => _pendingScore = null);
      });
    }

    return Column(
      key: ValueKey(question.id),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: _pendingScore == null ? notifier.goBack : null,
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            Expanded(
              child: DiagnosticProgressBar(
                current: index + 1,
                total: questions.length,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ResponsiveText.bodySmall(
          category.title.toUpperCase(),
          style: TextStyle(
            color: theme.colorScheme.secondary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        ResponsiveText.titleLarge(
          question.text,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        ...question.options.map((opt) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DiagnosticOptionCard(
                label: opt.label,
                selected: _pendingScore == opt.score,
                onTap: _pendingScore == null ? () => select(opt.score) : null,
              ),
            )),
      ],
    )
        .animate(key: ValueKey('${question.id}_anim'))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.04, end: 0);
  }
}

// ---------------------------------------------------------------------------
// Étape 3 : Résultat
// ---------------------------------------------------------------------------

class _ResultView extends ConsumerWidget {
  const _ResultView({required this.config});
  final DiagnosticConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final result = ref.watch(diagnosticResultProvider);
    final state = ref.watch(diagnosticNotifierProvider);
    final notifier = ref.read(diagnosticNotifierProvider.notifier);

    if (result == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        DiagnosticScoreGauge(
          percent: result.percent,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 16),
        ResponsiveText.titleLarge(
          result.level.title,
          textAlign: TextAlign.center,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ResponsiveText.bodyLarge(
          result.level.description,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, height: 1.5),
        ),
        const SizedBox(height: 32),
        Align(
          alignment: Alignment.centerLeft,
          child: ResponsiveText.titleMedium(
            'Votre score par thématique',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        ...result.categoryScores.map((cs) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: DiagnosticCategoryBar(
                label: cs.category.title,
                percent: cs.percent,
                color: theme.colorScheme.secondary,
              ),
            )),
        const SizedBox(height: 16),
        const Align(
          alignment: Alignment.centerLeft,
          child: ResponsiveText.titleMedium(
            'Nos recommandations pour vous',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: BulletListBuilder.arrows(
            items: result.level.recommendedActions,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 32),
        if (state.submitStatus == LeadSubmitStatus.success)
          _ThankYouCard(theme: theme)
        else
          DiagnosticLeadForm(result: result),
        const SizedBox(height: 16),
        TextButton(
          onPressed: notifier.reset,
          child: const Text(
            'Recommencer le diagnostic',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
  }
}

class _ThankYouCard extends ConsumerWidget {
  const _ThankYouCard({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: Colors.greenAccent, size: 40),
          const SizedBox(height: 12),
          const ResponsiveText.titleMedium(
            'Merci ! Votre rapport vous sera envoyé sous peu.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                ref.read(trackingServiceProvider).trackInteraction(
                  projectId: 'portfolio',
                  projectName: 'Portfolio',
                  action: TrackingAction.linkClick,
                  details: {'type': 'diagnostic_to_contact'},
                );
                context.go('/contact');
              },
              icon: const Icon(Icons.calendar_month),
              label: const Text('Prendre rendez-vous'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
