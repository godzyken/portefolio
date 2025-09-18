import 'dart:js_interop';

@JS('gtag')
external void gtag(String command, String eventName, [Object? params]);

class AnalyticsService {
  final String trackingId;

  AnalyticsService(this.trackingId);

  void pageview(String path) {
    // On passe directement des types Dart simples
    gtag("event", "page_view", {'page_path': path, 'page_title': path});
  }

  void event(String name, {Map<String, Object?>? params}) {
    gtag("event", name, params ?? {});
  }
}
