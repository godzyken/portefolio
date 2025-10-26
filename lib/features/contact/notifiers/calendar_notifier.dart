import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:http/http.dart' as http;

// Définir les scopes nécessaires
const List<String> scopes = [
  calendar.CalendarApi.calendarScope,
];

class GoogleCalendarNotifier extends AsyncNotifier<calendar.CalendarApi?> {
  @override
  Future<calendar.CalendarApi?> build() async {
    // On initialise sans faire d'auth automatique.
    return null;
  }

  /// Appelé par l'UI (dans un handler d'interaction utilisateur).
  Future<void> signInAndInit() async {
    // Indique que l'opération est en cours
    state = const AsyncValue.loading();

    try {
      final signIn = GoogleSignIn.instance;

      // Sur certaines versions / plateformes, initialize() est requis.
      // On l'appelle si disponible (safe to call).
      try {
        await signIn.initialize();
      } catch (_) {
        // ignore: certains backend/platform ne nécessitent pas initialize
      }

      // Lancer l'authentification interactive (doit être démarrée depuis une interaction utilisateur)
      final account = await signIn.authenticate();

      if (account.id.isEmpty) {
        throw Exception('Authentification annulée ou aucun compte sélectionné');
      }

      // Récupérer les headers d'autorisation pour les scopes requis
      final headers =
          await account.authorizationClient.authorizationHeaders(scopes);

      if (headers == null || headers.isEmpty) {
        throw Exception('Impossible d’obtenir les headers d’authentification');
      }

      final client = GoogleHttpClient(headers);
      final api = calendar.CalendarApi(client);

      // Stocke l'API en état réussi
      state = AsyncValue.data(api);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Optionnel : déconnecter
  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    state = const AsyncValue.data(null);
  }
}

class GoogleHttpClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _inner = http.Client();

  GoogleHttpClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }
}
