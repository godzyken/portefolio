import 'package:flutter_riverpod/experimental/mutation.dart';
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
    final name = _name(context);

    assert(() {
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
  void didDisposeProvider(ProviderObserverContext context) {
    final name = _name(context);

    _log.info('Dispose de $name');
  }

  @override
  void mutationReset(
      ProviderObserverContext context, Mutation<Object?> mutation) {
    assert(() {
      _log.debug('Mutation reset : ${_name(context)}');
      return true;
    }());
  }

  @override
  void mutationStart(
      ProviderObserverContext context, Mutation<Object?> mutation) {
    assert(() {
      _log.debug('Mutation start : ${_name(context)}');
      return true;
    }());
  }

  @override
  void mutationError(
    ProviderObserverContext context,
    Mutation<Object?> mutation,
    Object error,
    StackTrace stackTrace,
  ) {
    _log.error(
      'Mutation error dans ${_name(context)}',
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void mutationSuccess(ProviderObserverContext context,
      Mutation<Object?> mutation, Object? result) {
    assert(() {
      _log.debug('Mutation success : ${_name(context)}');
      return true;
    }());
  }

  String _name(ProviderObserverContext context) =>
      context.provider.name ?? context.provider.runtimeType.toString();
}
