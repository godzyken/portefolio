import 'package:flutter/material.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';

/// 🎯 Configuration pour une stat card
class StatCardConfig {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  const StatCardConfig({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
    this.onTap,
  });
}

/// 🎯 Factory pour créer différents types de cards statistiques
class StatsCardFactory {
  /// Card verticale compacte
  static Widget compact(StatCardConfig config) {
    final color = config.color ?? Colors.blue;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, color: color, size: 24),
          const SizedBox(height: 8),
          ResponsiveText.bodySmall(
            config.label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          const SizedBox(height: 4),
          ResponsiveText.titleMedium(
            config.value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  /// Card horizontale
  static Widget horizontal(StatCardConfig config) {
    final color = config.color ?? Colors.blue;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(config.icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText.bodySmall(
                  config.label,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 4),
                ResponsiveText.titleMedium(
                  config.value,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Card avec gradient
  static Widget gradient(StatCardConfig config) {
    final color = config.color ?? Colors.blue;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.3),
            color.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(config.icon, color: color, size: 32),
          const Spacer(),
          ResponsiveText.bodySmall(
            config.label,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 4),
          ResponsiveText.displaySmall(
            config.value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }

  /// Grid de stats compactes
  static Widget grid(
    List<StatCardConfig> configs, {
    int crossAxisCount = 2,
    double childAspectRatio = 1.5,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: configs.length,
      itemBuilder: (context, index) => compact(configs[index]),
    );
  }

  /// Liste horizontale scrollable
  static Widget horizontalList(List<StatCardConfig> configs) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: configs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) => SizedBox(
          width: 200,
          child: horizontal(configs[index]),
        ),
      ),
    );
  }
}

// ============================================================================
// UTILISATION
// ============================================================================

/*
/// ❌ AVANT : 3 fichiers différents (StatCard, MetricColumn, KPICard)
/// ✅ APRÈS : 1 seul factory

class WakaTimeStatsExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stats = [
      StatCardConfig(
        label: 'Temps total',
        value: '35h 30m',
        icon: Icons.timer,
        color: Colors.blue,
      ),
      StatCardConfig(
        label: 'Part du projet',
        value: '23.5%',
        icon: Icons.trending_up,
        color: Colors.green,
      ),
      StatCardConfig(
        label: 'Lignes de code',
        value: '12.4k',
        icon: Icons.code,
        color: Colors.purple,
      ),
    ];

    return StatsCardFactory.grid(stats, crossAxisCount: 3);
  }
}
*/
