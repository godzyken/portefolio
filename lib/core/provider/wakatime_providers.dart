import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/projets/data/wakatime_state.dart';
// Créez les modèles de données correspondants à la réponse de WakaTime

/// Provider pour charger et parser les statistiques WakaTime depuis le fichier JSON local.
final wakatimeStatsProvider = FutureProvider<WakatimeData>((ref) async {
  try {
    // 1. Charge le contenu brut du fichier JSON depuis les assets
    final jsonString =
        await rootBundle.loadString('assets/data/wakatime_stats.json');

    // 2. Décode la chaîne JSON en une structure Map<String, dynamic>
    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;

    // 3. Transforme la Map en un objet WakatimeStats typé
    //    (il faut créer la classe WakatimeStats avec une factory `fromJson`)
    return FullWakatimeStats.fromJson(jsonMap).data;
  } catch (e, st) {
    developer.log('Erreur lors du chargement des statistiques WakaTime',
        error: e, stackTrace: st);
    throw Exception('Erreur lors du chargement des statistiques WakaTime');
  }
});
