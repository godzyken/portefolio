import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/journey_definition.dart';
import '../../data/models/quote_preparation.dart';
import '../../notifiers/conversion_notifier.dart';

class QualificationWizardScreen extends ConsumerStatefulWidget {
  const QualificationWizardScreen({super.key});

  @override
  ConsumerState<QualificationWizardScreen> createState() =>
      _QualificationWizardScreenState();
}

class _QualificationWizardScreenState
    extends ConsumerState<QualificationWizardScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(conversionSessionProvider);
    final stages = session.journey.stages;
    final isDone = session.isCompleted;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: const Text("Cadrage de votre Projet",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: isDone
              ? _buildSummaryReport(session.quote)
              : _buildActiveStep(stages[session.currentStepIndex],
                  session.currentStepIndex, stages.length),
        ),
      ),
    );
  }

  Widget _buildActiveStep(JourneyStep step, int index, int total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(
          value: (index + 1) / total,
          backgroundColor: Colors.white10,
          color: const Color(0xFF00F0FF),
        ),
        const SizedBox(height: 16),
        Text("Étape ${index + 1} sur $total",
            style: const TextStyle(color: Colors.white38, fontSize: 13)),
        const SizedBox(height: 24),
        Text(
          step.questionText,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              height: 1.4),
        ),
        const SizedBox(height: 32),
        if (step.type == StepType.understanding ||
            step.type == StepType.commercial)
          TextField(
            controller: _textController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Décrivez votre besoin ici...",
              hintStyle: const TextStyle(color: Colors.white24),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
            maxLines: 3,
          )
        else if (step.id == 'type_detection')
          Column(
            children: [
              'Application mobile',
              'Site web ou Application Web',
              'Logiciel métier interne'
            ].map((opt) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white10,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _submit(step.id, opt),
                  child: Text(opt, style: const TextStyle(fontSize: 16)),
                ),
              );
            }).toList(),
          )
        else
          Row(
            children:
                ['Oui, tout à fait', 'Non, pas pour le moment'].map((opt) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white10,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _submit(step.id, opt),
                    child: Text(opt, style: const TextStyle(fontSize: 15)),
                  ),
                ),
              );
            }).toList(),
          ),
        const Spacer(),
        if (step.type == StepType.understanding ||
            step.type == StepType.commercial)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00F0FF),
              foregroundColor: Colors.black,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                final text = _textController.text;
                _textController.clear();
                _submit(step.id, text);
              }
            },
            child: const Text("Continuer",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }

  void _submit(String stepId, dynamic answer) {
    ref.read(conversionSessionProvider.notifier).submitAnswer(stepId, answer);
  }

  Widget _buildSummaryReport(QuotePreparation quote) {
    String stepLabel = "Mission de Cadrage";
    if (quote.recommendedStep == NextStepCommercial.development) {
      stepLabel = "Proposition de Développement";
    }
    if (quote.recommendedStep == NextStepCommercial.estimation) {
      stepLabel = "Estimation budgétaire";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.check_circle_outline,
            color: Color(0xFF00F0FF), size: 64),
        const SizedBox(height: 24),
        const Text(
          "Analyse de votre projet terminée !",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          "Notre moteur intelligent a qualifié votre besoin. Voici la recommandation stratégique pour la prochaine étape :",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("ORIENTATION CONSEILLÉE",
                  style: TextStyle(
                      color: Color(0xFF00F0FF),
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(stepLabel,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const Divider(color: Colors.white10, height: 24),
              const Text("ENVELOPPE BUDGÉTAIRE ESTIMÉE",
                  style: TextStyle(color: Colors.white38, fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                  "${quote.budgetEstimationMin.toInt()} € - ${quote.budgetEstimationMax.toInt()} €",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              const Text("DURÉE ESTIMÉE",
                  style: TextStyle(color: Colors.white38, fontSize: 12)),
              const SizedBox(height: 4),
              Text(quote.timelineRange,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const Spacer(),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00F0FF),
            foregroundColor: Colors.black,
            minimumSize: const Size.fromHeight(56),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text("Retour au Portfolio",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
