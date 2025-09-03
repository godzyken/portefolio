import 'package:flutter_riverpod/flutter_riverpod.dart';

class HoverMapNotifier extends StateNotifier<Map<String, bool>> {
  HoverMapNotifier() : super({});

  void setHover(String key, bool value) {
    state = {...state, key: value};
  }
}
