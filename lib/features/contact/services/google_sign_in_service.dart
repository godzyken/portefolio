import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:http/http.dart' as http;

// Définir les scopes nécessaires
const List<String> scopes = [
  calendar.CalendarApi.calendarScope,
  calendar.CalendarApi.calendarEventsScope,
];

class GoogleSignInService {
  // Rôle : Gérer tout le flux d'authentification
  static Future<calendar.CalendarApi> signInAndGetApi(
      List<String> scopes, String clientId) async {
    final signIn = GoogleSignIn.instance;

    // Initialisation
    await signIn.initialize(
      clientId: kIsWeb ? clientId : null,
    );

    // Tentative d'authentification légère
    GoogleSignInAccount? account =
        await signIn.attemptLightweightAuthentication();

    // Tentative interactive si échec
    account ??= await signIn.authenticate(
      scopeHint: scopes,
    );

    if (account.email.isEmpty || account.id.isEmpty) {
      throw Exception('Authentification annulée.');
    }

    // Récupération des headers d'autorisation
    final headers =
        await account.authorizationClient.authorizationHeaders(scopes);
    if (headers == null || headers.isEmpty) {
      throw Exception('Impossible d’obtenir les headers d’authentification');
    }

    // Création de l'API avec le client HTTP autorisé
    final client = GoogleHttpClient(headers);
    final api = calendar.CalendarApi(client);

    // Test de l'API (important)
    await api.calendarList.list();

    return api;
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

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
