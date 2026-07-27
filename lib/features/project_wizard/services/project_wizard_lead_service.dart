import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/provider/config_env_provider.dart';
import '../../../../core/service/supabase_service.dart';
import '../../contact/providers/emailjs_provider.dart';
import '../data/models/project_wizard_models.dart';

class ProjectWizardLeadService {
  final Ref ref;

  ProjectWizardLeadService(this.ref);

  Future<void> submit({
    required String name,
    required String email,
    required ProjectDescription description,
    StrategicOption? selectedStrategy,
    String? aiSummary,
  }) async {
    // 1. Tentative d'enregistrement en BDD Supabase
    if (SupabaseService.isReady) {
      try {
        await SupabaseService.client.from('portfolio_project_leads').insert({
          'name': name.isEmpty ? null : name,
          'email': email,
          'project_context': description.context,
          'target_audience': description.targetAudience,
          'goals': description.goals,
          'tech_constraints': description.technicalConstraints.isEmpty ? null : description.technicalConstraints,
          'budget': description.budgetRange.isEmpty ? null : description.budgetRange,
          'strategic_choice_id': selectedStrategy?.id,
          'strategic_choice_title': selectedStrategy?.title,
          'ai_summary': aiSummary,
        });
        developer.log('✅ Lead projet enregistré dans Supabase', name: 'ProjectWizardLeadService');
      } catch (e, st) {
        developer.log('❌ Erreur insertion Supabase: $e', name: 'ProjectWizardLeadService', error: e, stackTrace: st);
        // On continue pour envoyer le mail
      }
    }

    // 2. Envoi systématique de l'email
    try {
      final emailJs = ref.read(emailJsProvider);
      final projectTemplateId = ref.read(emailJsProjectTemplateIdProvider);
      
      final buffer = StringBuffer();
      buffer.writeln('NOUVELLE DEMANDE DE PROJET IA');
      buffer.writeln('=' * 40);
      buffer.writeln('👤 CONTACT');
      buffer.writeln('Nom : ${name.isEmpty ? "Anonyme" : name}');
      buffer.writeln('Email : $email');
      buffer.writeln();
      
      buffer.writeln('📝 DESCRIPTION DU PROJET');
      buffer.writeln('Contexte : ${description.context}');
      buffer.writeln('Cible : ${description.targetAudience}');
      buffer.writeln('Objectifs : ${description.goals}');
      buffer.writeln('Contraintes : ${description.technicalConstraints.isEmpty ? "-" : description.technicalConstraints}');
      buffer.writeln('Budget : ${description.budgetRange.isEmpty ? "-" : description.budgetRange}');
      buffer.writeln();
      
      String aiAnalysisText = "";
      if (selectedStrategy != null) {
        buffer.writeln('🎯 STRATÉGIE SÉLECTIONNÉE');
        buffer.writeln('Titre : ${selectedStrategy.title}');
        buffer.writeln('Description : ${selectedStrategy.description}');
        buffer.writeln();
        aiAnalysisText = "Stratégie choisie : ${selectedStrategy.title}\n${selectedStrategy.description}";
      } else if (aiSummary != null) {
        buffer.writeln('⚠️ NOTE : Le client n\'a pas sélectionné de stratégie mais l\'IA a analysé le projet.');
        aiAnalysisText = aiSummary;
      } else {
        buffer.writeln('ℹ️ NOTE : Analyse IA non disponible (possible quota épuisé).');
        aiAnalysisText = "Analyse IA non disponible.";
      }

      if (projectTemplateId != null) {
        // Option B: Template pro envoyé au client avec BCC (si configuré côté EmailJS)
        await emailJs.sendProjectReport(
          recipientEmail: email,
          templateId: projectTemplateId,
          projectData: {
            "to_email": email,
            "name": name.isEmpty ? 'Client Projet' : name,
            "message": buffer.toString(), // On garde le message complet pour le BCC
            "ai_analysis": aiAnalysisText,
            // Ajout des champs séparés au cas où le template les utilise
            "project_context": description.context,
            "project_target": description.targetAudience,
            "project_goals": description.goals,
          },
        );
      } else {
        // Fallback: Template classique envoyé à toi
        await emailJs.sendEmail(
          name: name.isEmpty ? 'Client Projet' : name,
          email: email,
          message: buffer.toString(),
        );
      }
      
      developer.log('✅ Email de notification projet envoyé', name: 'ProjectWizardLeadService');
    } catch (e, st) {
      developer.log('❌ Erreur envoi EmailJS: $e', name: 'ProjectWizardLeadService', error: e, stackTrace: st);
      if (!SupabaseService.isReady) rethrow;
    }
  }
}

final projectWizardLeadServiceProvider = Provider<ProjectWizardLeadService>(
  (ref) => ProjectWizardLeadService(ref),
  name: 'ProjectWizardLeadService',
);
