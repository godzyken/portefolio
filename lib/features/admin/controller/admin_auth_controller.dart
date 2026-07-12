import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/service/supabase_service.dart';

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

class AdminAuthController extends Notifier<AdminAuthState> {
  @override
  AdminAuthState build() => const AdminAuthIdle();

  Future<void> signIn(String email, String password) async {
    if (!SupabaseService.isReady) {
      state = const AdminAuthError(
          'Supabase non configuré (SUPABASE_URL / SUPABASE_ANON_KEY manquants).');
      return;
    }

    state = const AdminAuthLoading();
    try {
      await SupabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
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
}

final adminAuthControllerProvider =
    NotifierProvider<AdminAuthController, AdminAuthState>(
  AdminAuthController.new,
  name: 'AdminAuthController',
);
