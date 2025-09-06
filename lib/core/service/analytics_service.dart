import 'dart:js_interop';

@JS()
external void gtag(String command, String event, [Object? params]);

class AnalyticsService {
  void pageview(String path) {
    gtag('event', 'page_view', {'page_path': path});
  }

  void event(String name, {Map<String, dynamic>? params}) {
    gtag('event', name, params ?? <String, dynamic>{});
  }
}
