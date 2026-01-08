import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/ui/widgets/responsive_text.dart';

import '../../../../core/provider/iot_view_provider.dart';

/// Toggle entre vue liste et grille
class IoTViewToggle extends ConsumerWidget {
  final bool isGridView;

  const IoTViewToggle({
    super.key,
    required this.isGridView,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _IoTToggleButton(
            icon: LucideIcons.list,
            isActive: !isGridView,
            onTap: () => ref.read(iotViewModeProvider.notifier).toggle(),
          ),
          Container(
            width: 1,
            height: 24,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          _IoTToggleButton(
            icon: LucideIcons.layout_grid,
            isActive: isGridView,
            onTap: () => ref.read(iotViewModeProvider.notifier).toggle(),
          ),
        ],
      ),
    );
  }
}

class _IoTToggleButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _IoTToggleButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.white60,
          size: 20,
        ),
      ),
    );
  }
}

/// Card de capteur pour vue grille
class IoTSensorCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final double rawValue;
  final Color color;
  final double trend;
  final AnimationController pulseController;

  const IoTSensorCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.rawValue,
    required this.color,
    required this.trend,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: animValue,
          child: Card(
            color: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: color.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icône avec animation de pulse
                  AnimatedBuilder(
                    animation: pulseController,
                    builder: (context, child) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withValues(alpha: 0.2),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(
                                alpha: 0.3 * pulseController.value,
                              ),
                              blurRadius: 15,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: Icon(icon, color: color, size: 32),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  ResponsiveText.displaySmall(
                    title,
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: ResponsiveText.bodySmall(
                      value,
                      key: ValueKey(value),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  IoTTrendIndicator(trend: trend, color: color),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Indicateur de tendance
class IoTTrendIndicator extends StatelessWidget {
  final double trend;
  final Color color;

  const IoTTrendIndicator({
    super.key,
    required this.trend,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = trend > 0;
    final trendColor = isPositive ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: trendColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? LucideIcons.trending_up : LucideIcons.trending_down,
            color: trendColor,
            size: 14,
          ),
          const SizedBox(width: 4),
          ResponsiveText.displaySmall(
            '${trend.abs().toStringAsFixed(1)}%',
            style: TextStyle(
              color: trendColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card de capteur pour vue liste
class IoTSensorListCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final double trend;
  final double progress;

  const IoTSensorListCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.trend,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ResponsiveText.displaySmall(
                        title,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: ResponsiveText.displaySmall(
                          value,
                          key: ValueKey(value),
                          style: TextStyle(
                            color: color,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IoTTrendIndicator(trend: trend, color: color),
              ],
            ),
            const SizedBox(height: 12),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: progress),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: value,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 6,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Helpers pour les capteurs IoT
class IoTSensorHelpers {
  static IconData getIcon(String sensorName) {
    switch (sensorName) {
      case 'Température':
        return LucideIcons.thermometer;
      case 'Consommation':
        return LucideIcons.bolt;
      case 'Vibrations':
        return LucideIcons.activity;
      case 'Humidité':
        return LucideIcons.droplet;
      default:
        return LucideIcons.gauge;
    }
  }

  static Color getColor(String sensorName) {
    switch (sensorName) {
      case 'Température':
        return Colors.orangeAccent;
      case 'Consommation':
        return Colors.yellowAccent;
      case 'Vibrations':
        return Colors.lightGreenAccent;
      case 'Humidité':
        return Colors.cyanAccent;
      default:
        return Colors.grey;
    }
  }

  static String formatValue(String sensorName, double value) {
    switch (sensorName) {
      case 'Température':
        return '${value.toStringAsFixed(1)}°C';
      case 'Consommation':
        return '${value.toStringAsFixed(1)} kWh';
      case 'Vibrations':
        return value < 1.5 ? 'Normal' : 'Élevé';
      case 'Humidité':
        return '${value.toStringAsFixed(1)}%';
      default:
        return value.toStringAsFixed(1);
    }
  }

  static double calculateTrend(double value) {
    return ((value * 100) % 10) - 5;
  }
}
