import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:portefolio/core/provider/hive_initializer_provider.dart';

import '../theme/theme_data.dart';

final customThemesProvider =
    NotifierProvider<CustomThemesNotifier, List<BasicTheme>>(
        CustomThemesNotifier.new);

class CustomThemesNotifier extends Notifier<List<BasicTheme>> {
  late final Box<BasicTheme> _box;

  @override
  List<BasicTheme> build() {
    ref.watch(hiveInitializerProvider);

    _box = Hive.box<BasicTheme>('themes');
    return _box.values.toList();
  }

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
