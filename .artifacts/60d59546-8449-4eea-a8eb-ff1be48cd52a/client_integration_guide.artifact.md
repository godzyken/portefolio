# Guide d'Intégration Analytics pour Apps Clientes

Pour que votre Portfolio affiche des statistiques en temps réel, vos applications (Bat_Track, EMAP, etc.) doivent envoyer des événements à la table `app_analytics`.

## 1. Service Flutter à copier dans vos projets clients

Créez un fichier `lib/core/services/analytics_service.dart` dans vos autres applications :

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class LiveAnalyticsService {
  final _supabase = Supabase.instance.client;
  final String appId; // Ex: 'bat_track_v1' ou 'emap_services'

  LiveAnalyticsService({required this.appId});

  /// Envoie un événement de tracking live au portfolio
  Future<void> trackEvent({
    required String eventType,
    double value = 1.0,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _supabase.from('app_analytics').insert({
        'app_id': appId,
        'event_type': eventType,
        'value': value,
        'metadata': metadata ?? {},
      });
    } catch (e) {
      // Échec silencieux pour ne pas bloquer l'utilisateur
      print('Analytics Error: $e');
    }
  }
}
```

## 2. Exemples d'utilisation

### Dans Bat_Track (lors d'une génération de PDF)
```dart
final analytics = LiveAnalyticsService(appId: 'bat_track_v1');

void onPdfGenerated() {
  analytics.trackEvent(
    eventType: 'pdf_generated',
    metadata: {'type': 'devis', 'amount': 1500.0}
  );
}
```

### Dans EMAP Services (lors d'une nouvelle session)
```dart
final analytics = LiveAnalyticsService(appId: 'emap_services');

// Au démarrage de l'app
analytics.trackEvent(eventType: 'session_start');
```

## 3. Pourquoi utiliser `app_analytics` ?

Bien que vous ayez des tables comme `analytics_events` ou `site_traffic`, utiliser `app_analytics` permet de :
1. **Standardiser** : Le Portfolio sait exactement quel format attendre.
2. **Realtime** : Cette table est optimisée pour le "Live Stream" du Portfolio.
3. **Isolation** : Ne mélange pas les logs techniques internes de vos apps avec les métriques de "vitrine" du Portfolio.

> [!TIP]
> Si vous voulez migrer vos anciennes données de `analytics_events` vers `app_analytics`, vous pouvez le faire via le SQL Editor :
> ```sql
> INSERT INTO app_analytics (app_id, event_type, created_at)
> SELECT 'mon_app_legacy', event_name, created_at FROM analytics_events;
> ```
