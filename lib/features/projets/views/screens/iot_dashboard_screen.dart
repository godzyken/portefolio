import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/ui/widgets/responsive_text.dart';

import '../../../../core/affichage/screen_size_detector.dart';
import '../../../../core/provider/iot_view_provider.dart';
import '../../../../core/provider/sensor_provider.dart';
import '../../../generator/views/widgets/three_d_tech_icon.dart';

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

    return ResponsiveBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(
            icon: LucideIcons.list,
            isActive: !isGridView,
            onTap: () => ref.read(iotViewModeProvider.notifier).toggle(),
          ),
          Container(
            width: 1,
            height: 24,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          _buildToggleButton(
            icon: LucideIcons.layout_grid,
            isActive: isGridView,
            onTap: () => ref.read(iotViewModeProvider.notifier).toggle(),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
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

  Widget _buildSensorFilters(ResponsiveInfo info) {
    final sensors = ref.watch(sensorProvider);
    final activeFilters = ref.watch(iotSensorFilterProvider);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: sensors.keys.map((sensorName) {
        final isActive = activeFilters.contains(sensorName);
        final color = _getSensorColor(sensorName);

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
          return _buildSensorCard(
            icon: _getSensorIcon(entry.key),
            title: entry.key,
            value: _getSensorValue(entry.key, entry.value),
            color: _getSensorColor(entry.key),
            trend: _calculateTrend(entry.value),
            rawValue: entry.value,
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
        return _buildSensorListCard(
          icon: _getSensorIcon(entry.key),
          title: entry.key,
          value: _getSensorValue(entry.key, entry.value),
          color: _getSensorColor(entry.key),
          trend: _calculateTrend(entry.value),
          progress: entry.value / 100,
        );
      },
    );
  }

  Widget _buildSensorCard({
    required IconData icon,
    required String title,
    required String value,
    required double rawValue,
    required Color color,
    required double trend,
  }) {
    // Logique d'intensité spécifique pour la température
    bool isTemperature = title.contains('Température');
    double intensity = (rawValue - 15) / 50; // Normalisation 15°C -> 65°C
    intensity = intensity.clamp(0.0, 1.0);

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
            child: ResponsiveBox(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icône avec animation de pulse
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return ResponsiveBox(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color.withValues(alpha: 0.2),
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(
                                  alpha: 0.3 * _animationController.value,
                                ),
                                blurRadius: 15,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: _buildHeatIconEffect(
                              icon, rawValue, color, isTemperature));
                    },
                  ),
                  const SizedBox(height: 12),
                  ResponsiveText.displaySmall(
                    title,
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
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
                  _buildTrendIndicator(trend, color),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSensorListCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required double trend,
    required double progress,
  }) {
    return Card(
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: ResponsiveBox(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                ResponsiveBox(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                ResponsiveBox(
                  paddingSize: ResponsiveSpacing.s,
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
                ResponsiveBox(
                  paddingSize: ResponsiveSpacing.s,
                  child: _buildTrendIndicator(trend, color),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Barre de progression
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

  Widget _buildTrendIndicator(double trend, Color color) {
    final isPositive = trend > 0;
    final trendColor = isPositive ? Colors.green : Colors.red;

    return ResponsiveBox(
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

  Widget _buildRealtimeChart(Map<String, double> sensors, ResponsiveInfo info) {
    return ResponsiveBox(
      height: 120,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: sensors.entries.map((entry) {
            final color = _getSensorColor(entry.key);
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

  Widget _buildHeatIconEffect(
      IconData icon, double temperature, Color baseColor, bool isTemp) {
    // Calcul de l'intensité (0.0 à 1.0)
    double intensity = isTemp ? (temperature / 100).clamp(0.0, 1.0) : 0.2;

    return Stack(
      alignment: Alignment.center,
      children: [
        // La "Bulle 3D" de chaleur
        AnimatedContainer(
          duration: const Duration(seconds: 1),
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                (isTemp && temperature > 40 ? Colors.red : baseColor)
                    .withValues(alpha: intensity * 0.4),
                (isTemp && temperature < 5 ? Colors.blue : baseColor)
                    .withValues(alpha: intensity * 0.8),
                Colors.transparent,
              ],
              stops: const [0.3, 0.7, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: (isTemp && temperature > 40 ? Colors.orange : baseColor)
                    .withValues(alpha: intensity * 0.5),
                blurRadius: 10 * intensity,
                spreadRadius: 2,
              )
            ],
          ),
        ),
        // L'icône technique existante
        ThreeDTechIcon(
          icon: icon,
          color: baseColor,
          size: 28,
        ),
      ],
    );
  }

  // Helpers
  IconData _getSensorIcon(String sensorName) {
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

  Color _getSensorColor(String sensorName) {
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

  String _getSensorValue(String sensorName, double value) {
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

  double _calculateTrend(double value) {
    // Simulation de tendance basée sur la valeur
    return ((value * 100) % 10) - 5;
  }
}
