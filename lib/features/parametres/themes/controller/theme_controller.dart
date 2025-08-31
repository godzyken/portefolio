import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/parametres/themes/provider/theme_repository_provider.dart';

import '../services/theme_repository.dart';
import '../theme/theme_data.dart';

final themeControllerProvider =
    StateNotifierProvider<ThemeController, BasicTheme>(
  (ref) =>
      ThemeController(ref.watch(themeRepositoryProvider), BasicTheme.fallback),
);

class ThemeController extends StateNotifier<BasicTheme> {
  final ThemeRepository repo;

  ThemeController(this.repo, BasicTheme initial) : super(initial);

  void toggleBrightness() {
    final next = switch (state.mode) {
      AppThemeMode.light => AppThemeMode.dark,
      AppThemeMode.dark => AppThemeMode.system,
      AppThemeMode.system => AppThemeMode.light,
      AppThemeMode.custom => AppThemeMode.custom,
    };

    _updateTheme(
      state.copyWith(
        mode: next,
      ),
    );
  }

  void applyTheme(BasicTheme theme) {
    _updateTheme(theme);
  }

  Future<void> _updateTheme(BasicTheme theme) async {
    state = theme;
    await repo.saveTheme(theme);
  }

  Future<void> loadTheme() async {
    final loaded = await repo.loadTheme();
    state = loaded;
  }
}

final themeFutureProvider = FutureProvider<BasicTheme>((ref) async {
  final repo = ThemeRepository();
  return await repo.loadTheme();
});
