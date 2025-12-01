import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:portefolio/core/provider/config_env_provider.dart';

import '../services/google_calendar_service.dart';
import '../services/google_sign_in_service.dart';

// Définir les scopes nécessaires
const List<String> scopes = [
  calendar.CalendarApi.calendarScope,
  calendar.CalendarApi.calendarEventsScope,
];

class GoogleCalendarNotifier extends AsyncNotifier<GoogleCalendarService?> {
  GoogleSignIn? _googleSignIn;

  @override
  Future<GoogleCalendarService?> build() async {
    final clientId = ref.read(googleCalendarClientIdProvider);

    if (clientId == null || clientId.isEmpty) {
      developer.log('⚠️ Google Calendar Client ID non configuré');
    }
    _initializeGoogleSignIn(clientId);
    return null;
  }

  void _initializeGoogleSignIn(String? clientId) {
    _googleSignIn = GoogleSignIn.instance;

    // Configuration via initialize()
    if (kIsWeb && clientId != null) {
      _googleSignIn!.initialize(
        clientId: clientId,
      );
    }
  }

  /// Appelé par l'UI (dans un handler d'interaction utilisateur).
  Future<void> signInAndInit() async {
    state = const AsyncValue.loading();
    try {
      final clientId = ref.read(googleCalendarClientIdProvider);

      if (clientId == null || clientId.isEmpty) {
        throw Exception('Google Calendar Client ID non configuré');
      }

      // La logique de connexion est maintenant dans le service !
      final api = await GoogleSignInService.signInAndGetApi(scopes, clientId);

      // Si la connexion réussit, créez le service d'interaction
      final service = GoogleCalendarService(api);

      state = AsyncValue.data(service);
      developer.log('✅ Connexion et Service Calendar prêts');
    } catch (e, st) {
      // Gérer l'erreur
      state = AsyncValue.error(e, st);
    }
  }

  /// Optionnel : déconnecter
  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
      developer.log('✅ Déconnexion réussie');
    } catch (e) {
      developer.log('⚠️ Erreur déconnexion: $e');
    }
    state = const AsyncValue.data(null);
  }
}
