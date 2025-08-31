import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../theme/theme_data.dart';

final customThemesProvider =
    StateNotifierProvider<CustomThemesNotifier, List<BasicTheme>>((ref) {
  return CustomThemesNotifier();
});

class CustomThemesNotifier extends StateNotifier<List<BasicTheme>> {
  static final _box = Hive.box<BasicTheme>('themes');

  CustomThemesNotifier() : super(_box.values.toList());

  void addTheme(BasicTheme theme) {
    _box.add(theme);
    state = _box.values.toList();
  }

  void deleteTheme(int index) {
    _box.deleteAt(index);
    state = _box.values.toList();
  }

  void clearThemes() {
    _box.clear();
    state = [];
  }
}
