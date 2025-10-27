import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

void main() async {
  final file = File(
      'pub_deps.json'); // exporté avec `dart pub deps --json > pub_deps.json`
  if (!file.existsSync()) {
    developer.log('⚠️ Fichier pub_deps.json introuvable !');
    return;
  }

  final content = await file.readAsString();
  final Map<String, dynamic> jsonData = jsonDecode(content);

  final packages = List<Map<String, dynamic>>.from(jsonData['packages']);

  developer.log('🔍 Analyse des packages à risque :\n');

  for (var pkg in packages) {
    final name = pkg['name'];
    final version = pkg['version'];
    final kind = pkg['kind']; // direct / dev / transitive

    // Critères simples de risque
    final risky = <String>[];

    // 1. Packages dev / lint avec beaucoup de dépendances transitive
    if (kind == 'dev' || kind == 'transitive') {
      if ((pkg['dependencies'] as List).length > 5) {
        risky.add('⚠️ beaucoup de dépendances transitive');
      }
    }

    // 2. Packages connus pour causer des conflits Flutter Web
    if ([
      'youtube_player_iframe',
      'youtube_player_iframe_web',
      'webview_flutter_platform_interface'
    ].contains(name)) {
      risky.add('⚠️ potentiel conflit Flutter Web');
    }

    // 3. Packages non mis à jour depuis longtemps (approche simplifiée : version < 1.0.0)
    if (version.startsWith('0.')) {
      risky.add('⚠️ version <1.0.0');
    }

    if (risky.isNotEmpty) {
      developer.log('Package: $name ($version) [$kind]');
      for (var r in risky) {
        developer.log('  - $r');
      }
      developer.log('');
    }
  }

  developer.log('✅ Analyse terminée.');
}
