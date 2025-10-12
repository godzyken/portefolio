// Définition de l'interface
abstract class IAnalyticsService {
  void pageview(String path);
  void event(String name, {Map<String, Object?>? params});
}

// 🛑 IMPORTANT: Déclarez le nom de l'implémentation choisie comme abstraite/générique
abstract class _AnalyticsServiceImpl implements IAnalyticsService {
  factory _AnalyticsServiceImpl(String trackingId) =>
      throw UnimplementedError();
}

// Classe publique qui fait office de Factory/Router
class AnalyticsService implements IAnalyticsService {
  final IAnalyticsService _platformService;

  factory AnalyticsService(String trackingId) {
    // 💡 Le compilateur résout cette classe 'AnalyticsServiceImpl'
    // vers l'implémentation Native ou Web automatiquement.
    return AnalyticsService._internal(_AnalyticsServiceImpl(trackingId));
  }

  // Constructeur privé pour encapsulation
  AnalyticsService._internal(this._platformService);

  @override
  void pageview(String path) => _platformService.pageview(path);

  @override
  void event(String name, {Map<String, Object?>? params}) =>
      _platformService.event(name, params: params);
}
