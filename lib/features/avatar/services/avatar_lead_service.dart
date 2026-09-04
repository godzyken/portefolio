import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/service/supabase_service.dart';
import '../../contact/providers/emailjs_provider.dart';

/// Enregistre un lead qualifié via l'Avatar.
///
/// Schéma Supabase attendu :
/// ```sql
/// create table avatar_leads (
///   id uuid primary key default gen_random_uuid(),
///   name text,
///   email text not null,
///   conversation_summary text not null,
///   pillars_explored text[] not null,
///   max_depth_score int not null,
///   created_at timestamptz not null default now()
/// );
/// ```
class AvatarLeadService {
  final Ref ref;

  AvatarLeadService(this.ref);

  Future<void> submit({
    required String name,
    required String email,
    required String conversationSummary,
    required List<String> pillarsExplored,
    required int maxDepthScore,
  }) async {
    if (SupabaseService.isReady) {
      try {
        await SupabaseService.client.from('avatar_leads').insert({
          'name': name.isEmpty ? null : name,
          'email': email,
          'conversation_summary': conversationSummary,
          'pillars_explored': pillarsExplored,
          'max_depth_score': maxDepthScore,
        });
        developer.log('✅ Lead Avatar enregistré dans Supabase', name: 'AvatarLeadService');
      } catch (e, st) {
        developer.log('❌ Erreur insertion Supabase Lead Avatar: $e', 
            name: 'AvatarLeadService', error: e, stackTrace: st);
      }
    }

    // Fallback EmailJS
    try {
      final emailJs = ref.read(emailJsProvider);
      await emailJs.sendEmail(
        name: name.isEmpty ? 'Prospect Avatar' : name,
        email: email,
        siteName: "Portfolio (Avatar IA)",
        emailTitle: "🤖 Nouvel engagement via l'IA",
        siteFooter: "Emryck Doré — Expertise IA & Flutter",
        bcc: "isgodzy@gmail.com", // Ton email de contrôle
        message: 'NOUVEL ENGAGEMENT AVATAR DÉTECTÉ\n'
            '----------------------------------------\n'
            'Client : ${name.isEmpty ? "Anonyme" : name} ($email)\n'
            'Piliers explorés : ${pillarsExplored.join(', ')}\n'
            'Score engagement max : $maxDepthScore\n'
            '----------------------------------------\n'
            'RÉSUMÉ CONVERSATION :\n$conversationSummary',
      );
      developer.log('✅ Email de notification Avatar envoyé', name: 'AvatarLeadService');
    } catch (e, st) {
      developer.log('❌ Erreur envoi EmailJS Lead Avatar: $e', 
          name: 'AvatarLeadService', error: e, stackTrace: st);
      if (!SupabaseService.isReady) rethrow;
    }
  }
}

final avatarLeadServiceProvider = Provider<AvatarLeadService>(
  (ref) => AvatarLeadService(ref),
  name: 'AvatarLeadService',
);
