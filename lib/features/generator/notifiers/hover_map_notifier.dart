import 'package:flutter_riverpod/flutter_riverpod.dart';

class HoverMapNotifier extends Notifier<Map<String, bool>> {
  @override
  Map<String, bool> build() {
    return {};
  }

  void setHover(String key, bool value) {
    state = {...state, key: value};
  }
}
