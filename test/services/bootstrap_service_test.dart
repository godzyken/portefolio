import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portefolio/core/service/bootstrap_service.dart';
import 'package:portefolio/features/parametres/themes/theme/theme_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockBootstrapService extends Mock implements BootstrapService {
  @override
  final BasicTheme theme = BasicTheme.fallback;

  @override
  final SharedPreferences prefs;
  MockBootstrapService(this.prefs);

  @override
  Future<void> loadJsonData() async {
    // On ne fait rien ou on simule un chargement immédiat sans 'compute'
    developer.log("Simple loadJsonData pour le test");
  }

  @override
  Future<void> prefetchAll(WidgetRef ref, BuildContext context) async {
    // On vide cette méthode pour éviter de charger des images/svg qui n'existent pas
    developer.log("Skip prefetch pour le test");
  }
}
