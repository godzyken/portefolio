import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/service/supabase_service.dart';

import '../../contact/providers/emailjs_provider.dart';

/// Enregistre un lead issu du diagnostic de maturité numérique.
///
/// Source de vérité : table Supabase `portfolio_diagnostic_leads`.
/// Si Supabase n'est pas configuré (ou en cas d'erreur), on retombe sur
/// l'envoi d'un email via EmailJS pour ne jamais perdre le lead, en
/// suivant le même principe de fallback que `pricingPacksProvider`.
///
/// Schéma Supabase attendu (à créer manuellement dans le dashboard) :
/// ```sql
/// create table portfolio_diagnostic_leads (
///   id uuid primary key default gen_random_uuid(),
///   name text,
///   email text not null,
///   company text,
///   score int not null,
///   max_score int not null,
///   percent int not null,
///   level_title text not null,
///   created_at timestamptz not null default now()
/// );
/// ```
class DiagnosticLeadService {
  final Ref ref;

  DiagnosticLeadService(this.ref);

  Future<void> submit({
    required String name,
    required String email,
    required String company,
    required String projectSummary,
    required int score,
    required int maxScore,
    required int percent,
    required String levelTitle,
  }) async {
    if (SupabaseService.isReady) {
      try {
        await SupabaseService.client.from('portfolio_diagnostic_leads').insert({
          'name': name.isEmpty ? null : name,
          'email': email,
          'company': company.isEmpty ? null : company,
          'project_summary': projectSummary.isEmpty ? null : projectSummary,
          'score': score,
          'max_score': maxScore,
          'percent': percent,
          'level_title': levelTitle,
        });
        developer.log('✅ Lead diagnostic enregistré dans Supabase',
            name: 'DiagnosticLeadService');
      } catch (e, st) {
        developer.log(
          '❌ Erreur insertion Supabase: $e',
          name: 'DiagnosticLeadService',
          error: e,
          stackTrace: st,
        );
        // On continue pour envoyer au moins l'email
      }
    }

    // ENVOI SYSTEMATIQUE DE L'EMAIL
    try {
      final emailJs = ref.read(emailJsProvider);
      await emailJs.sendEmail(
        name: name.isEmpty ? 'Anonyme' : name,
        email: email,
        message: 'NOUVEAU DIAGNOSTIC COMPLÉTÉ\n'
            '----------------------------------------\n'
            'Client : ${name.isEmpty ? "Anonyme" : name} ($email)\n'
            'Entreprise : ${company.isEmpty ? "-" : company}\n'
            'Résumé du projet : ${projectSummary.isEmpty ? "-" : projectSummary}\n'
            'Score : $score/$maxScore ($percent%)\n'
            'Niveau : $levelTitle\n'
            '----------------------------------------\n'
            'Note : Ce lead a également été tenté d\'être enregistré en BDD.',
      );
      developer.log('✅ Email de notification diagnostic envoyé',
          name: 'DiagnosticLeadService');
    } catch (e, st) {
      developer.log(
        '❌ Erreur envoi EmailJS: $e',
        name: 'DiagnosticLeadService',
        error: e,
        stackTrace: st,
      );
      // Si on n'a pas pu envoyer le mail ET qu'on n'a pas pu écrire en BDD (ou que Supabase est off), là c'est critique
      if (!SupabaseService.isReady) rethrow;
    }
  }
}

final diagnosticLeadServiceProvider = Provider<DiagnosticLeadService>(
  (ref) => DiagnosticLeadService(ref),
  name: 'DiagnosticLeadService',
);
