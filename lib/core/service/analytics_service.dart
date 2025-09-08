import 'dart:js_interop';

@JS('sendEvent')
external void _sendEvent(JSAny name, [JSAny? params]);

class AnalyticsService {
  final String trackingId;

  AnalyticsService(this.trackingId);

  void pageview(String path) {
    // On passe directement des types Dart simples
    _sendEvent(
      'page_view'.toJS,
      ({'page_path': path, 'page_title': path}).toJSBox,
    );
  }

  void event(String name, {Map<String, Object?>? params}) {
    _sendEvent(name.toJS, (params ?? {}).toJSBox);
  }
}
