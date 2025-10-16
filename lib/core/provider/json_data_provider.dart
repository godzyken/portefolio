import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/generator/data/extention_models.dart';

final _jsonCache = <String, dynamic>{};

/// 🔹 Fonction principale de chargement JSON générique
Future<List<T>> loadJsonFile<T>(
  String path,
  T Function(Map<String, dynamic>) fromJson,
) async {
  if (_jsonCache.containsKey(path)) return _jsonCache[path] as List<T>;

  final jsonStr = await rootBundle.loadString(path);
  final result = await compute(
    (String jsonStr) {
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      return jsonList.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    },
    jsonStr,
  );

  _jsonCache[path] = result;
  return result;
}

/// 🔹 Providers
final projectsProvider = FutureProvider<List<ProjectInfo>>((ref) async {
  return loadJsonFile('assets/data/projects.json', ProjectInfo.fromJson);
});

final experiencesProvider = FutureProvider<List<Experience>>((ref) async {
  return loadJsonFile('assets/data/experiences.json', Experience.fromJson);
});

final servicesJsonProvider = FutureProvider<List<Service>>((ref) async {
  return loadJsonFile('assets/data/services.json', Service.fromJson);
});
