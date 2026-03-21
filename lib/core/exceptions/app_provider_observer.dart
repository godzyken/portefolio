import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logging/app_logger.dart';

base class AppProviderObserver extends ProviderObserver {
  static const _log = AppLogger('ProviderObserver');

  const AppProviderObserver();

  @override
  void didAddProvider(
    ProviderObserverContext context,
    Object? value,
  ) {
    assert(() {
      final name = _name(context);

      if (value is AsyncError) {
        _log.warning(
          'AsyncError à la création de $name',
          error: value.error,
          stackTrace: value.stackTrace,
        );
      }
      return true;
    }());
  }

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    assert(() {
      final name = _name(context);

      if (newValue is AsyncError) {
        _log.warning(
          'AsyncError dans $name',
          error: newValue.error,
          stackTrace: newValue.stackTrace,
        );
      }
      return true;
    }());
  }

  @override
  void didFailProvider(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    _log.error(
      'Provider en erreur : ${_name(context)}',
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void didRemoveProvider(
    ProviderObserverContext context,
    Object? value,
  ) {
    _log.info('Provider supprimé : ${_name(context)}');
  }

  String _name(ProviderObserverContext context) =>
      context.provider.name ?? context.provider.runtimeType.toString();
}
