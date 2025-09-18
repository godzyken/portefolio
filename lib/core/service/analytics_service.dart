import 'dart:js_interop';

@JS('gtag')
external void gtag(JSAny name, [JSAny? params]);

class AnalyticsService {
  final String trackingId;

  AnalyticsService(this.trackingId);

  void pageview(String path) {
    // On passe directement des types Dart simples
    gtag('page_view'.toJS, ({'page_path': path, 'page_title': path}).toJSBox);
  }

  void event(String name, {Map<String, Object?>? params}) {
    gtag(name.toJS, (params ?? {}).toJSBox);
  }
}
