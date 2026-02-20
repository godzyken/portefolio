// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portefolio/app.dart';
import 'package:portefolio/core/provider/providers.dart';
import 'package:portefolio/features/home/views/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/bootstrap_service_test.dart';
import 'services/http_service_test.dart';

void main() {
  // Un "smoke test" qui vérifie que l'application démarre sans erreur
  // et que la page d'accueil affiche des informations de base.
  // On prépare les objets Mock
  late MockHttpClient mockClient;
  late MockHttpClientRequest mockRequest;
  late MockHttpClientResponse mockResponse;

  setUpAll(() {
    mockClient = MockHttpClient();
    mockRequest = MockHttpClientRequest();
    mockResponse = MockHttpClientResponse();

    // On force Flutter à utiliser notre Mock globalement
    HttpOverrides.global = MyHttpOverrides();

    // Enregistrement par défaut pour Mocktail (nécessaire pour les types complexes)
    registerFallbackValue(Uri());

    // --- CONFIGURATION DU MOCK HTTP ---
    // On simule une réponse 200 OK avec un corps vide pour éviter les plantages
    when(() => mockClient.getUrl(any())).thenAnswer((_) async => mockRequest);
    when(() => mockRequest.close()).thenAnswer((_) async => mockResponse);
    when(() => mockResponse.statusCode).thenReturn(200);
    when(() => mockResponse.listen(any(),
        onError: any(named: 'onError'),
        onDone: any(named: 'onDone'),
        cancelOnError: any(named: 'cancelOnError'))).thenAnswer((invocation) {
      final onData =
          invocation.positionalArguments[0] as void Function(List<int>);
      final onDone = invocation.namedArguments[#onDone] as void Function()?;
      onData(utf8.encode('{}')); // On renvoie une liste d'octets vide
      onDone?.call();
      return MockStreamSubscription<
          List<int>>(); // Il faudra définir un petit mock de stream
    });
  });

  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App starts and displays HomePage smoke test',
      (WidgetTester tester) async {
    setupTestAssets();

    // 1. Simuler SharedPreferences au lieu de SharedPreferences.getInstance()
    SharedPreferences.setMockInitialValues({});
    final mockPrefs = await SharedPreferences.getInstance();

    // 2. Créer un BootstrapService "léger" sans lancer les méthodes statiques lourdes
    // On injecte manuellement les dépendances pour éviter Hive et FMTC
    final bootstrap = MockBootstrapService(mockPrefs);

    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bootstrapProvider.overrideWithValue(bootstrap),
            bootstrapFutureProvider.overrideWith((ref) => bootstrap),
            //  assetServiceProvider.overrideWithValue(MockAssetService()),
          ],
          child: MyFullApp(
            bootstrap: bootstrap,
          ),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 500));

      await tester.pump();
    });

    // 2. Attendez que tous les widgets et les animations se terminent.
    await tester.pumpAndSettle();

    final exception = tester.takeException();
    expect(exception, isNull,
        reason: 'The app threw an exception during startup: $exception');

    // 3. Vérifiez que la page d'accueil (HomePage) est bien présente.
    //    Elle devrait être la première chose que l'utilisateur voit.
    expect(find.byType(HomeScreen), findsOneWidget);

    await tester.pump();

    // 4. Vérifiez la présence d'un texte clé de votre page d'accueil.
    //    Changez ce texte pour qu'il corresponde à un vrai texte de votre UI.
    //    Par exemple, si vous avez un titre "Développeur Flutter" ou votre nom.
    //    `findsOneWidget` signifie "trouve exactement un widget correspondant".
    expect(find.textContaining("Développeur Flutter"), findsOneWidget);

    // 5. Vous pouvez aussi chercher un autre widget, comme votre image de profil,
    //    si vous lui avez donné une clé de test.
    //    Exemple : expect(find.byKey(const Key('profile_picture')), findsOneWidget);
  });
}

void setupTestAssets() {
  // 1. Définir les données pour chaque fichier
  final Map<String, dynamic> mockData = {
    'assets/data/services.json': [
      {'id': '1', 'name': 'Service Test'}
    ],
    'assets/data/projects.json': [
      {'id': '1', 'name': 'Projet Test'}
    ],
    'assets/data/experiences.json': [
      {'id': '1', 'name': 'Experience Test'}
    ],
    'assets/data/comparaison.json': [
      {'id': '1', 'name': 'Comparaison Test'}
    ],
    'assets/data/expertise.json': [
      {'id': '1', 'name': 'Expertise Test'}
    ],
    'assets/data/wakatime_stats.json': [
      {'id': '1', 'name': 'Wakatime Test'}
    ],
  };

  final manifest = {
    'assets/data/services.json': ['assets/data/services.json'],
    'assets/data/projects.json': ['assets/data/projects.json'],
    'assets/data/experience.json': ['assets/data/experience.json'],
    'assets/data/comparaison.json': ['assets/data/comparaison.json'],
    'assets/data/expertise.json': ['assets/data/expertise.json'],
    'assets/data/wakatime_stats.json': ['assets/data/wakatime_stats.json'],
  };

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', (ByteData? message) async {
    final String key = utf8.decode(message!.buffer.asUint8List());

    if (key == 'AssetManifest.json' || key == 'AssetManifest.bin') {
      return ByteData.view(utf8.encode(json.encode(manifest)).buffer);
    }

    // 2. Vérifier si la clé demandée est dans nos données simulées
    if (mockData.containsKey(key)) {
      final encoded = utf8.encode(json.encode(mockData[key]));
      return ByteData.view(encoded.buffer);
    }

    // 3. Pour les images ou fichiers non gérés, renvoyer null au lieu de planter
    return null;
  });
}

class MockStreamSubscription<T> extends Mock implements StreamSubscription<T> {}
