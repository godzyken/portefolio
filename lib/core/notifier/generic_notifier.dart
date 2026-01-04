import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🔹 Notifier booléen générique avec toggle
class BooleanNotifier extends Notifier<bool> {
  final bool initialValue;

  BooleanNotifier([this.initialValue = false]);

  @override
  bool build() => initialValue;

  void toggle() => state = !state;
  void setTrue() => state = true;
  void setFalse() => state = false;
  void setValue(bool value) => state = value;
}

/// 🔹 Notifier nullable générique
class NullableNotifier<T> extends Notifier<T?> {
  @override
  T? build() => null;

  void setValue(T? value) => state = value;
  void clear() => state = null;
}

/// 🔹 Notifier de collection générique
class CollectionNotifier<T> extends Notifier<List<T>> {
  @override
  List<T> build() => [];

  void setItems(List<T> items) => state = items;
  void addItem(T item) => state = [...state, item];
  void removeItem(T item) => state = state.where((i) => i != item).toList();
  void clear() => state = [];
  bool contains(T item) => state.contains(item);
}

/// 🔹 Notifier de Set générique
class SetNotifier<T> extends Notifier<Set<T>> {
  @override
  Set<T> build() => {};

  void add(T item) => state = {...state, item};
  void remove(T item) => state = {...state}..remove(item);
  void toggle(T item) {
    final newSet = {...state};
    if (newSet.contains(item)) {
      newSet.remove(item);
    } else {
      newSet.add(item);
    }
    state = newSet;
  }

  void clear() => state = {};
  bool contains(T item) => state.contains(item);
}

/// 🔹 Notifier de Map générique
class MapNotifier<K, V> extends Notifier<Map<K, V>> {
  @override
  Map<K, V> build() => {};

  void set(K key, V value) => state = {...state, key: value};
  void remove(K key) => state = {...state}..remove(key);
  void clear() => state = {};
  V? get(K key) => state[key];
}
