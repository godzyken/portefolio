import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/service/supabase_service.dart';
import '../../../core/service/turnstile_service.dart';

sealed class AdminAuthState {
  const AdminAuthState();
}

class AdminAuthIdle extends AdminAuthState {
  const AdminAuthIdle();
}

class AdminAuthLoading extends AdminAuthState {
  const AdminAuthLoading();
}

class AdminAuthError extends AdminAuthState {
  final String message;
  const AdminAuthError(this.message);
}

class AdminAuthSuccess extends AdminAuthState {
  const AdminAuthSuccess();
}

class AdminAuthRecoverySent extends AdminAuthState {
  const AdminAuthRecoverySent();
}

/// Gère la connexion/déconnexion au formulaire d'admin.
/// Un seul compte (le tien) doit exister côté Supabase Auth, et doit être
/// référencé dans la table `portfolio_admins` pour avoir le droit d'écrire.
class AdminAuthController extends Notifier<AdminAuthState> {
  @override
  AdminAuthState build() => const AdminAuthIdle();

  Future<void> signIn(String email, String password,
      {String? captchaToken}) async {
    if (!SupabaseService.isReady) {
      state = const AdminAuthError(
          'Supabase non configuré (SUPABASE_URL / SUPABASE_ANON_KEY manquants).');
      return;
    }

    if (TurnstileService.isConfigured && captchaToken == null) {
      state = const AdminAuthError(
          'Vérification anti-robot requise. Complète le captcha ci-dessus.');
      return;
    }

    state = const AdminAuthLoading();

    try {
      await SupabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
        captchaToken: captchaToken,
      );
      state = const AdminAuthSuccess();
    } on AuthException catch (e) {
      state = AdminAuthError(e.message);
    } catch (e) {
      state = AdminAuthError('Erreur de connexion: $e');
    }
  }

  Future<void> signOut() async {
    if (!SupabaseService.isReady) return;
    await SupabaseService.client.auth.signOut();
    state = const AdminAuthIdle();
  }

  Future<void> sendRecoveryEmail(String email) async {
    if (!SupabaseService.isReady) return;

    state = const AdminAuthLoading();

    try {
      // Appel de la Edge Function 'send-recovery'
      await SupabaseService.client.functions.invoke(
        'send-recovery',
        body: {'email': email},
      );
      state = const AdminAuthRecoverySent();
    } on AuthException catch (e) {
      state = AdminAuthError(e.message);
    } catch (e) {
      state = AdminAuthError('Erreur lors de l\'envoi de l\'email: $e');
    }
  }
}

final adminAuthControllerProvider =
    NotifierProvider<AdminAuthController, AdminAuthState>(
  AdminAuthController.new,
  name: 'AdminAuthController',
);
