import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/ui/widgets/responsive_text.dart';

import '../../../../core/affichage/screen_size_detector.dart';
import '../../../../core/provider/sensor_provider.dart';

class IotDashboardScreen extends ConsumerWidget {
  const IotDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sensors = ref.watch(sensorProvider);
    final theme = Theme.of(context);
    final info = ref.watch(responsiveInfoProvider);
    final crossAxisCount = info.isTablet ? 2 : 1;

    return ResponsiveBox(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ResponsiveText('Chantier A12 - Zone de maintenance',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
              child: GridView.count(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _SensorCard(
                icon: LucideIcons.thermometer,
                title: 'Température',
                value: '${sensors['Température']?.toStringAsFixed(1)}°C',
                color: Colors.orangeAccent,
              ),
              _SensorCard(
                icon: LucideIcons.bolt,
                title: 'Consommation',
                value: '${sensors['Consommation']?.toStringAsFixed(1)} kWh',
                color: Colors.yellowAccent,
              ),
              _SensorCard(
                icon: LucideIcons.activity,
                title: 'Vibrations',
                value: sensors['Vibrations']! < 1.5 ? 'Normal' : 'Élevé',
                color: sensors['Vibrations']! < 1.5
                    ? Colors.lightGreenAccent
                    : Colors.redAccent,
              ),
              _SensorCard(
                icon: LucideIcons.droplet,
                title: 'Humidité',
                value: '${sensors['Humidité']?.toStringAsFixed(1)}%',
                color: Colors.cyanAccent,
              ),
            ],
          )),
          const SizedBox(height: 12),
          const ResponsiveText('Flux de données en temps réel',
              style: TextStyle(
                  color: Colors.white70, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ResponsiveBox(
            child: LineChart(LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  color: Colors.lightGreenAccent,
                  belowBarData: BarAreaData(show: false),
                  spots: List.generate(
                      6,
                      (i) => FlSpot(
                          i.toDouble(),
                          sensors['Température']! / 10 +
                              Random().nextDouble())),
                ),
              ],
            )),
          )
        ],
      ),
    );
  }
}

class _SensorCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _SensorCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 48),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Text(
                value,
                key: ValueKey(value),
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
