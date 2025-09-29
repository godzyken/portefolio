import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/parametres/themes/provider/theme_repository_provider.dart';

import '../services/theme_repository.dart';
import '../theme/theme_data.dart';

final themeControllerProvider =
    NotifierProvider<ThemeController, BasicTheme>(ThemeController.new);

class ThemeController extends Notifier<BasicTheme> {
  late final ThemeRepository repo;

  @override
  BasicTheme build() {
    repo = ref.watch(themeRepositoryProvider);
    return BasicTheme.fallback;
  }

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
  final repo = ref.watch(themeRepositoryProvider);
  return await repo.loadTheme();
});
