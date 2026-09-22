import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/service/supabase_service.dart';

import '../../contact/providers/emailjs_provider.dart';
import '../data/models/complexity_assessment.dart';
import '../data/models/project_context.dart';
import '../data/models/quote_preparation.dart';

/// Service gérant la finalisation d'un lead de conversion.
///
/// Note: Pour que cela fonctionne, vous devez créer la table suivante dans Supabase :
/// ```sql
/// create table portfolio_project_leads (
///   id uuid primary key default gen_random_uuid(),
///   name text,
///   email text not null,
///   company text,
///   project_type text,
///   objective text,
///   complexity_score float8,
///   budget_min float8,
///   budget_max float8,
///   timeline text,
///   full_context text, -- Type text car on va jsonEncode
///   created_at timestamptz not null default now()
/// );
/// ```
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
    // 1. Sauvegarde Supabase (Table dédiée)
    if (SupabaseService.isReady) {
      try {
        await SupabaseService.client.from('portfolio_project_leads').insert({
          'name': name.isEmpty ? null : name,
          'email': email,
          'company': company.isEmpty ? null : company,
          'project_type': project.type.name,
          'objective': project.objective,
          'complexity_score': complexity.averageScore,
          'budget_min': quote.budgetEstimationMin,
          'budget_max': quote.budgetEstimationMax,
          'timeline': quote.timelineRange,
          'full_context': jsonEncode({
            'project': project.toJson(),
            'complexity': complexity.toJson(),
            'quote': quote.toJson(),
          }),
        });
        developer.log('✅ Lead projet enregistré dans Supabase',
            name: 'ConversionLeadService');
      } catch (e, st) {
        developer.log('❌ Erreur insertion Supabase Projet: $e',
            name: 'ConversionLeadService', error: e, stackTrace: st);
        // Fallback sur la table diagnostic si la table projet n'existe pas encore
        try {
          await SupabaseService.client
              .from('portfolio_diagnostic_leads')
              .insert({
            'name': name,
            'email': email,
            'company': company,
            'score': complexity.averageScore.toInt(),
            'max_score': 10,
            'percent': (complexity.averageScore * 10).toInt(),
            'level_title': 'Cadrage Projet: ${project.type.name}',
          });
        } catch (_) {}
      }
    }

    // 2. Envoi EmailJS (Notification à l'owner + Auto-réponse possible via template)
    try {
      final emailJs = ref.read(emailJsProvider);

      final projectSummary = """
BILAN DE CADRAGE DE PROJET
----------------------------------------
Client : ${name.isEmpty ? 'Anonyme' : name} ($email)
Entreprise : ${company.isEmpty ? '-' : company}
Type de projet : ${project.type.name}
Objectif : ${project.objective}
Complexité : ${complexity.averageScore.toStringAsFixed(1)}/10

ESTIMATION PRÉLIMINAIRE
----------------------------------------
Budget : ${quote.budgetEstimationMin.toInt()} € - ${quote.budgetEstimationMax.toInt()} €
Délai : ${quote.timelineRange}
Action : ${quote.recommendedStep.name}
""";

      // On envoie un email de notification (qui peut déclencher un auto-reply EmailJS vers le prospect)
      await emailJs.sendEmail(
        name: name.isEmpty ? 'Nouveau Prospect' : name,
        email: email,
        emailTitle: "Nouveau Cadrage Projet - $name",
        message: projectSummary,
      );

      developer.log('✅ Email de bilan projet envoyé',
          name: 'ConversionLeadService');
    } catch (e, st) {
      developer.log('❌ Erreur envoi EmailJS Projet: $e',
          name: 'ConversionLeadService', error: e, stackTrace: st);
    }
  }
}

final conversionLeadServiceProvider = Provider<ConversionLeadService>(
  (ref) => ConversionLeadService(ref),
  name: 'ConversionLeadService',
);
