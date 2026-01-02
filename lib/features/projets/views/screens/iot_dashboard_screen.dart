import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/ui/widgets/responsive_text.dart';

import '../../../../core/affichage/screen_size_detector.dart';
import '../../../../core/provider/iot_view_provider.dart';
import '../../../../core/provider/sensor_provider.dart';
import 'iot_dashboard_widgets.dart';

class EnhancedIotDashboardScreen extends ConsumerStatefulWidget {
  const EnhancedIotDashboardScreen({super.key});

  @override
  ConsumerState<EnhancedIotDashboardScreen> createState() =>
      _EnhancedIotDashboardScreenState();
}

class _EnhancedIotDashboardScreenState
    extends ConsumerState<EnhancedIotDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sensors = ref.watch(sensorProvider);
    final theme = Theme.of(context);
    final info = ref.watch(responsiveInfoProvider);
    final isGridView = ref.watch(iotViewModeProvider);
    final activeFilters = ref.watch(iotSensorFilterProvider);

    // Filtrer les capteurs
    final filteredSensors = Map.fromEntries(
      sensors.entries.where((entry) => activeFilters.contains(entry.key)),
    );

    return ResponsiveBox(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.9),
            theme.colorScheme.secondary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec titre et contrôles
          _buildHeader(info, theme),
          const SizedBox(height: 16),

          // Filtres de capteurs
          _buildSensorFilters(info),
          const SizedBox(height: 16),

          // Contenu principal
          Expanded(
            child: isGridView
                ? _buildGridView(filteredSensors, info)
                : _buildListView(filteredSensors, info),
          ),

          const SizedBox(height: 12),

          // Graphique en temps réel
          const ResponsiveText(
            'Flux de données en temps réel',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          // Mini graphique animé
          _buildRealtimeChart(filteredSensors, info),
        ],
      ),
    );
  }

  Widget _buildHeader(ResponsiveInfo info, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ResponsiveText(
                'Chantier A12 - Zone de maintenance',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  // Indicateur en direct
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withValues(
                                alpha: _animationController.value,
                              ),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  const ResponsiveText(
                    'En direct',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Toggle vue liste/grille
        _buildViewToggle(),
      ],
    );
  }

  Widget _buildViewToggle() {
    final isGridView = ref.watch(iotViewModeProvider);

    return IoTViewToggle(isGridView: isGridView);
  }

  Widget _buildSensorFilters(ResponsiveInfo info) {
    final sensors = ref.watch(sensorProvider);
    final activeFilters = ref.watch(iotSensorFilterProvider);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: sensors.keys.map((sensorName) {
        final isActive = activeFilters.contains(sensorName);
        final color = IoTSensorHelpers.getColor(sensorName);

        return FilterChip(
          label: ResponsiveText(
            sensorName,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white70,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          selected: isActive,
          onSelected: (selected) {
            final notifier = ref.read(iotSensorFilterProvider.notifier);
            final newFilters = Set<String>.from(activeFilters);

            if (selected) {
              newFilters.add(sensorName);
            } else {
              // Garder au moins un capteur actif
              if (newFilters.length > 1) {
                newFilters.remove(sensorName);
              }
            }

            notifier.toggleSensor(sensorName);
          },
          backgroundColor: color.withValues(alpha: 0.2),
          selectedColor: color.withValues(alpha: 0.4),
          checkmarkColor: Colors.white,
          side: BorderSide(
            color: isActive ? color : color.withValues(alpha: 0.3),
            width: 1.5,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGridView(Map<String, double> sensors, ResponsiveInfo info) {
    int crossAxisCount = 2;
    if (info.size.width > 1100)
      crossAxisCount = 4;
    else if (info.size.width > 750) crossAxisCount = 3;

    return LayoutBuilder(builder: (context, constraints) {
      final double itemWidth = constraints.maxWidth / crossAxisCount;
      final double aspectRatio = (itemWidth / 180).clamp(1.0, 1.6);

      return GridView.builder(
        itemCount: sensors.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: aspectRatio,
        ),
        itemBuilder: (context, index) {
          final entry = sensors.entries.elementAt(index);
          return IoTSensorCard(
            icon: IoTSensorHelpers.getIcon(entry.key),
            title: entry.key,
            value: IoTSensorHelpers.formatValue(entry.key, entry.value),
            rawValue: entry.value,
            color: IoTSensorHelpers.getColor(entry.key),
            trend: IoTSensorHelpers.calculateTrend(entry.value),
            pulseController: _animationController,
          );
        },
      );
    });
  }

  Widget _buildListView(Map<String, double> sensors, ResponsiveInfo info) {
    return ListView.separated(
      shrinkWrap: false,
      itemCount: sensors.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final entry = sensors.entries.elementAt(index);
        return IoTSensorListCard(
          icon: IoTSensorHelpers.getIcon(entry.key),
          title: entry.key,
          value: IoTSensorHelpers.formatValue(entry.key, entry.value),
          color: IoTSensorHelpers.getColor(entry.key),
          trend: IoTSensorHelpers.calculateTrend(entry.value),
          progress: entry.value / 100,
        );
      },
    );
  }

  Widget _buildRealtimeChart(Map<String, double> sensors, ResponsiveInfo info) {
    return ResponsiveBox(
      height: 120,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: sensors.entries.map((entry) {
            final color = IoTSensorHelpers.getColor(entry.key);
            return LineChartBarData(
              isCurved: true,
              color: color,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: color.withValues(alpha: 0.2),
              ),
              spots: List.generate(
                6,
                (i) => FlSpot(
                  i.toDouble(),
                  entry.value / 10 + Random().nextDouble() * 2,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
