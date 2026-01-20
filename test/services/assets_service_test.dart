import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:portefolio/core/service/assets_service.dart';

class MockAssetService extends AssetService {
  @override
  Future<List<T>> loadJsonFile<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    // On simule une réponse immédiate selon le chemin
    if (path.contains('services.json')) {
      return [/* Ton objet Service Mocké ici */] as List<T>;
    }
    return [];
  }
}

class FakeAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    // Si c'est un JSON, on renvoie une liste vide []
    if (key.endsWith('.json')) {
      return ByteData.view(utf8.encode('[]').buffer);
    }
    // Pour tout le reste (images, etc.), on renvoie un pixel transparent ou vide
    return ByteData(0);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return '[]';
  }
}
