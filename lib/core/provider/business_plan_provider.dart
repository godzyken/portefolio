import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/generator/data/models/business_plan_models.dart';

/// Charge et parse `assets/data/business_plan.json` (objet unique, donc pas
/// de `loadJsonFile<T>` générique qui attend une liste).
final businessPlanProvider = FutureProvider<BusinessPlan>((ref) async {
  final jsonStr = await rootBundle.loadString('assets/data/business_plan.json');
  final Map<String, dynamic> data = jsonDecode(jsonStr) as Map<String, dynamic>;
  return BusinessPlan.fromJson(data);
}, name: 'BusinessPlan');

/// Accès rapide à un service du business plan par id
/// (`audit`, `amoa`, `project`, `flutter`, `transformation`, `ai`, `training`).
final businessPlanServiceProvider =
Provider.family<BusinessPlanService?, String>((ref, id) {
  final plan = ref.watch(businessPlanProvider).asData?.value;
  return plan?.serviceById(id);
}, name: 'BusinessPlanServiceById');

/// Chiffres clés dérivés du business plan, prêts pour une section
/// "compteurs animés" sur la home (+X services, +X types de clients, etc.).
final businessPlanStatsProvider = Provider<BusinessPlanStats>((ref) {
  final plan = ref.watch(businessPlanProvider).asData?.value;
  if (plan == null) return const BusinessPlanStats.empty();

  final averageExpertiseLevel = plan.expertise.isEmpty
      ? 0
      : (plan.expertise.fold<int>(0, (sum, e) => sum + e.level) /
      plan.expertise.length)
      .round();

  return BusinessPlanStats(
    servicesCount: plan.services.length,
    clientTypesCount: plan.clients.length,
    expertiseCount: plan.expertise.length,
    averageExpertiseLevel: averageExpertiseLevel,
    targetYear: plan.roadmap.isEmpty ? 0 : plan.roadmap.last.year,
    targetRevenue: plan.roadmap.isEmpty ? 0 : plan.roadmap.last.revenue,
  );
}, name: 'BusinessPlanStats');

class BusinessPlanStats {
  final int servicesCount;
  final int clientTypesCount;
  final int expertiseCount;
  final int averageExpertiseLevel;
  final int targetYear;
  final num targetRevenue;

  const BusinessPlanStats({
    required this.servicesCount,
    required this.clientTypesCount,
    required this.expertiseCount,
    required this.averageExpertiseLevel,
    required this.targetYear,
    required this.targetRevenue,
  });

  const BusinessPlanStats.empty()
      : servicesCount = 0,
        clientTypesCount = 0,
        expertiseCount = 0,
        averageExpertiseLevel = 0,
        targetYear = 0,
        targetRevenue = 0;
}