import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Modèle pour les données analytiques
class AppAnalytics {
  final String appId;
  final String eventType;
  final double value;
  final DateTime createdAt;

  AppAnalytics({
    required this.appId,
    required this.eventType,
    required this.value,
    required this.createdAt,
  });

  factory AppAnalytics.fromJson(Map<String, dynamic> json) {
    return AppAnalytics(
      appId: json['app_id'],
      eventType: json['event_type'],
      value: (json['value'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

/// Provider pour le stream des analytiques en temps réel depuis Supabase
final liveAnalyticsStreamProvider =
    StreamProvider.family<List<AppAnalytics>, String>((ref, appId) {
  final supabase = Supabase.instance.client;

  return supabase
      .from('app_analytics')
      .stream(primaryKey: ['id'])
      .eq('app_id', appId)
      .order('created_at', ascending: false)
      .limit(100)
      .map((data) => data.map((json) => AppAnalytics.fromJson(json)).toList());
});

/// Provider pour les KPIs agrégés (ex: volume sur 24h)
final liveKpiProvider =
    FutureProvider.family<double, String>((ref, appId) async {
  final supabase = Supabase.instance.client;

  final now = DateTime.now().toUtc();
  final yesterday = now.subtract(const Duration(hours: 24));

  final response = await supabase
      .from('app_analytics')
      .select('value')
      .eq('app_id', appId)
      .gt('created_at', yesterday.toIso8601String());

  if (response.isEmpty) return 0.0;

  double total = 0;
  for (final item in response) {
    total += (item['value'] as num).toDouble();
  }
  return total;
});
