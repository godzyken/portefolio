import 'package:flutter_riverpod/flutter_riverpod.dart';

extension SafeAsync<T> on AsyncValue<T> {
  T get safe {
    return when(
      data: (value) => value,
      loading: () => throw Exception('Loading'),
      error: (e, _) => throw e,
    );
  }
}
