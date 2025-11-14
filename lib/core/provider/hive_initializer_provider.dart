import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:portefolio/core/exceptions/state/global_error_state.dart';
import 'package:portefolio/core/notifier/error_notifiers.dart';

import '../../features/parametres/themes/theme/theme_data.dart'; // Assurez-vous que ce chemin est correct

// L'ID de l'adaptateur BasicTheme (à vérifier dans votre code)
const int basicThemeAdapterId = 10;

// Ce fournisseur s'occupe de l'initialisation de Hive et de l'ouverture de la boîte 'themes'.
final hiveInitializerProvider = FutureProvider<void>((ref) async {
  // 1. Initialiser Hive
  try {
    // Si l'application tourne sur le web, path_provider n'est pas nécessaire
    if (!kIsWeb) {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      Hive.init(appDocumentDir.path);
    }

    // 2. Enregistrer l'adaptateur pour BasicTheme
    if (!Hive.isAdapterRegistered(basicThemeAdapterId)) {
      // NOTE: Vous devez importer et utiliser ici votre BasicThemeAdapter !
      // Exemple (décommentez et modifiez si nécessaire) :
      Hive.registerAdapter(BasicThemeAdapter());
    }

    // 3. Ouvrir la boîte 'themes'
    // La fonction doit retourner void (ou tout type) après l'opération.
    await Hive.openBox<BasicTheme>('themes');
    developer.log("Hive box 'themes' successfully opened by provider.");
  } on GlobalErrorState catch (e, st) {
    developer.log("Error initializing Hive: $e");
    // Remonter l'erreur pour que Riverpod gère l'état d'erreur
    GlobalErrorNotifier().setError(
        GlobalErrorState(message: e.message, updateUrl: st.toString()));
  }
});
