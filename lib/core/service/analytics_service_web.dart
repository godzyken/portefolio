import 'dart:js_interop';

import 'analytics_service.dart'; // Importe l'interface IAnalyticsService

// Annotation et fonction JS (UNIQUEMENT pour le Web)
@JS('gtag')
external void gtag(JSAny name, [JSAny? params]);

// Implémentation Web
class _AnalyticsServiceImpl implements IAnalyticsService {
  _AnalyticsServiceImpl(String trackingId);

  @override
  void pageview(String path) {
    // toJSBox est une extension fournie par dart:js_interop_unsafe
    // Si cela échoue, il faudra utiliser une conversion via package:js/js_util.dart
    // (qui est compatible avec l'approche conditionnelle).
    // Pour l'instant, on suppose que cela fonctionne dans le contexte Web.
    gtag('page_view'.toJS, ({'page_path': path, 'page_title': path}).toJSBox);
  }

  @override
  void event(String name, {Map<String, Object?>? params}) {
    gtag(name.toJS, (params ?? {}).toJSBox);
  }
}
