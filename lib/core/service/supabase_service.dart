import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';

/// Wrapper léger autour de Supabase pour centraliser l'init et l'accès
/// au client dans toute l'app (providers, formulaire admin, etc.)
class SupabaseService {
  SupabaseService._();

  static bool _initialized = false;

  static Future<void> init({
    required String url,
    required String anonKey,
  }) async {
    if (_initialized) return;

    if (url.isEmpty || anonKey.isEmpty) {
      developer.log(
        '⚠️ SUPABASE_URL / SUPABASE_ANON_KEY manquants : '
        'les tarifs afficheront le catalogue local (assets/data/services.json) '
        'et le formulaire admin sera indisponible.',
        name: 'SupabaseService',
      );
      return;
    }

    try {
      await Supabase.initialize(url: url, anonKey: anonKey);
      _initialized = true;
      developer.log('✅ Supabase initialisé', name: 'SupabaseService');
    } catch (e, st) {
      developer.log('❌ Échec init Supabase: $e',
          name: 'SupabaseService', error: e, stackTrace: st);
    }
  }

  static bool get isReady => _initialized;

  static SupabaseClient get client => Supabase.instance.client;
}
