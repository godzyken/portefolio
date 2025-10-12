import 'analytics_service.dart'; // Importe l'interface IAnalyticsService

// Implémentation native (Android, iOS, Desktop, etc.) : ne fait rien.
class _AnalyticsServiceImpl implements IAnalyticsService {
  _AnalyticsServiceImpl(String trackingId);

  @override
  void pageview(String path) {
    // Ne fait rien sur les plateformes natives.
  }

  @override
  void event(String name, {Map<String, Object?>? params}) {
    // Ne fait rien sur les plateformes natives.
  }
}
