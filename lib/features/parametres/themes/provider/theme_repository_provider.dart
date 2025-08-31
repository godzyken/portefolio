import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/theme_repository.dart';
import '../theme/theme_data.dart';

final themeRepositoryProvider = Provider((ref) => ThemeRepository());

final themeLoaderProvider = FutureProvider<BasicTheme>((ref) async {
  final repo = ref.read(themeRepositoryProvider);
  return repo.loadTheme();
});
