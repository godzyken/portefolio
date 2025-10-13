import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/theme_repository.dart';
import '../theme/theme_data.dart';

final sharedPreferencesProvider =
    Provider<SharedPreferences>((ref) => throw UnimplementedError());

final themeRepositoryProvider = Provider<ThemeRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeRepository(prefs: prefs);
});

final themeLoaderProvider = FutureProvider<BasicTheme>((ref) async {
  final repo = ref.read(themeRepositoryProvider);
  return repo.loadTheme();
});
