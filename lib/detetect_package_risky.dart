import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:typed_data';

void main() async {
  final file = File('pub_deps.json');
  if (!file.existsSync()) {
    developer.log('⚠️ Fichier pub_deps.json introuvable !');
    return;
  }

  final bytes = await file.readAsBytes();
  final content = _decodeBytes(bytes);

  final Map<String, dynamic> jsonData = jsonDecode(content);
  final packages = List<Map<String, dynamic>>.from(jsonData['packages']);

  developer.log('🔍 Analyse des packages à risque :\n');

  for (var pkg in packages) {
    final name = pkg['name'];
    final version = pkg['version'];
    final kind = pkg['kind']; // direct / dev / transitive

    final risky = <String>[];

    // 1. Packages dev / transitive avec beaucoup de dépendances
    if (kind == 'dev' || kind == 'transitive') {
      if ((pkg['dependencies'] as List).length > 5) {
        risky.add('⚠️ beaucoup de dépendances transitive');
      }
    }

    // 2. Packages connus pour causer des conflits Flutter Web
    if ([
      'youtube_player_iframe',
      'youtube_player_iframe_web',
      'webview_flutter_platform_interface',
    ].contains(name)) {
      risky.add('⚠️ potentiel conflit Flutter Web');
    }

    // 3. Version pre-stable
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

/// Détecte et décode UTF-16 LE, UTF-16 BE, UTF-8 BOM, ou UTF-8 brut.
String _decodeBytes(Uint8List bytes) {
  // UTF-16 Little Endian (BOM: FF FE)
  if (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xFE) {
    return _decodeUtf16LE(bytes.sublist(2));
  }
  // UTF-16 Big Endian (BOM: FE FF)
  if (bytes.length >= 2 && bytes[0] == 0xFE && bytes[1] == 0xFF) {
    return _decodeUtf16BE(bytes.sublist(2));
  }
  // UTF-8 avec BOM (EF BB BF)
  if (bytes.length >= 3 &&
      bytes[0] == 0xEF &&
      bytes[1] == 0xBB &&
      bytes[2] == 0xBF) {
    return utf8.decode(bytes.sublist(3));
  }
  // UTF-8 standard
  return utf8.decode(bytes, allowMalformed: true);
}

String _decodeUtf16LE(Uint8List bytes) {
  final charCodes = <int>[];
  for (var i = 0; i + 1 < bytes.length; i += 2) {
    charCodes.add(bytes[i] | (bytes[i + 1] << 8));
  }
  return String.fromCharCodes(charCodes);
}

String _decodeUtf16BE(Uint8List bytes) {
  final charCodes = <int>[];
  for (var i = 0; i + 1 < bytes.length; i += 2) {
    charCodes.add((bytes[i] << 8) | bytes[i + 1]);
  }
  return String.fromCharCodes(charCodes);
}
