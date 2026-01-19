// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:googleapis/merchantapi/accounts_v1.dart';
import 'package:portefolio/core/service/bootstrap_service.dart';
import 'package:portefolio/main.dart';

void main() {
  // Un "smoke test" qui vérifie que l'application démarre sans erreur
  // et que la page d'accueil affiche des informations de base.
  testWidgets('App starts and displays HomePage smoke test',
      (WidgetTester tester) async {
    final bootstrap = await BootstrapService.initialize();

    // 1. Lancez l'application dans un ProviderScope pour que Riverpod fonctionne
    //    Ceci est l'équivalent de votre `main.dart` pour les tests.
    await tester.pumpWidget(
      ProviderScope(
        child: MyFullApp(
          bootstrap: bootstrap,
        ),
      ),
    );

    // 2. Attendez que tous les widgets et les animations se terminent.
    await tester.pumpAndSettle();

    // 3. Vérifiez que la page d'accueil (HomePage) est bien présente.
    //    Elle devrait être la première chose que l'utilisateur voit.
    expect(find.byType(Homepage), findsOneWidget);

    // 4. Vérifiez la présence d'un texte clé de votre page d'accueil.
    //    Changez ce texte pour qu'il corresponde à un vrai texte de votre UI.
    //    Par exemple, si vous avez un titre "Développeur Flutter" ou votre nom.
    //    `findsOneWidget` signifie "trouve exactement un widget correspondant".
    expect(find.text("Développeur Flutter"), findsOneWidget);

    // 5. Vous pouvez aussi chercher un autre widget, comme votre image de profil,
    //    si vous lui avez donné une clé de test.
    //    Exemple : expect(find.byKey(const Key('profile_picture')), findsOneWidget);

    // Les anciens tests du compteur sont supprimés car ils ne sont plus pertinents.
  });
}
