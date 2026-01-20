import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AssetService {
  final Map<String, List<dynamic>> _jsonCache = {};

  /// Charge et décode un JSON (utilise compute en prod, direct en test)
  Future<List<T>> loadJsonFile<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    if (_jsonCache.containsKey(path)) return _jsonCache[path] as List<T>;

    final jsonStr = await rootBundle.loadString(path);

    // Optimisation : Pas de compute si on est en test (évite les crashs d'isolates)
    if (kDebugMode && Platform.environment.containsKey('FLUTTER_TEST')) {
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      return jsonList.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    }

    final result = await compute(_parseJson, jsonStr);
    final typedResult =
        result.map((e) => fromJson(e as Map<String, dynamic>)).toList();

    _jsonCache[path] = typedResult;
    return typedResult;
  }

  static List<dynamic> _parseJson(String jsonStr) => jsonDecode(jsonStr);
}
