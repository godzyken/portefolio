import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/service/supabase_service.dart';

import '../../contact/providers/emailjs_provider.dart';
import '../data/models/complexity_assessment.dart';
import '../data/models/project_context.dart';
import '../data/models/quote_preparation.dart';

class ConversionLeadService {
  final Ref ref;

  ConversionLeadService(this.ref);

  Future<void> submit({
    required String name,
    required String email,
    required String company,
    required ProjectContext project,
    required ComplexityAssessment complexity,
    required QuotePreparation quote,
  }) async {
    // 1. Sauvegarde Supabase
    if (SupabaseService.isReady) {
      try {
        await SupabaseService.client.from('portfolio_diagnostic_leads').insert({
          'name': name.isEmpty ? null : name,
          'email': email,
          'company': company.isEmpty ? null : company,
          'project_type': project.type.name,
          'objective': project.objective,
          'complexity_score': complexity.averageScore,
          'budget_min': quote.budgetEstimationMin,
          'budget_max': quote.budgetEstimationMax,
          'timeline': quote.timelineRange,
          'full_context': {
            'project': project.toJson(),
            'complexity': complexity.toJson(),
            'quote': quote.toJson(),
          },
        });
        developer.log('✅ Lead projet enregistré dans Supabase',
            name: 'ConversionLeadService');
      } catch (e, st) {
        developer.log('❌ Erreur insertion Supabase Projet: $e',
            name: 'ConversionLeadService', error: e, stackTrace: st);
      }
    }

    // 2. Envoi EmailJS (Auto-réponse au prospect)
    try {
      final emailJs = ref.read(emailJsProvider);

      final projectSummary = """
BILAN DE CADRAGE DE VOTRE PROJET
----------------------------------------
Type : ${project.type.name}
Objectif : ${project.objective}
Complexité évaluée : ${complexity.averageScore.toStringAsFixed(1)}/10

ESTIMATION PRÉLIMINAIRE
----------------------------------------
Enveloppe budgétaire : ${quote.budgetEstimationMin.toInt()} € - ${quote.budgetEstimationMax.toInt()} €
Durée estimée : ${quote.timelineRange}
Prochaine étape conseillée : ${quote.recommendedStep.name}

Note : Ce document est une pré-évaluation automatique destinée à cadrer nos futurs échanges.
----------------------------------------
""";

      await emailJs.sendEmail(
        name: name.isEmpty ? 'Client' : name,
        email: email,
        emailTitle: "Votre bilan de cadrage projet - Godzyken Portfolio",
        message: projectSummary,
      );

      developer.log('✅ Email de bilan projet envoyé au prospect',
          name: 'ConversionLeadService');
    } catch (e, st) {
      developer.log('❌ Erreur envoi EmailJS Projet: $e',
          name: 'ConversionLeadService', error: e, stackTrace: st);
      if (!SupabaseService.isReady) rethrow;
    }
  }
}

final conversionLeadServiceProvider = Provider<ConversionLeadService>(
  (ref) => ConversionLeadService(ref),
  name: 'ConversionLeadService',
);
