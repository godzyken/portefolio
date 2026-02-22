import 'dart:math' as math;
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';

import '../../generator_widgets_extentions.dart';

/// KPI Cards version compacte
class CompactKPICards extends StatelessWidget {
  final Map<String, String> kpiValues;
  final ResponsiveInfo info;

  const CompactKPICards({
    super.key,
    required this.kpiValues,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = info.isMobile ? 2 : (info.isTablet ? 3 : 4);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: info.isMobile ? 1.8 : 2.2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: kpiValues.length,
      itemBuilder: (context, index) {
        final entry = kpiValues.entries.elementAt(index);
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: ResponsiveText.bodySmall(
                  entry.key,
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    entry.value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// BarChart version compacte
class CompactBarChart extends StatefulWidget {
  final List<BarChartGroupData> barGroups;
  final List<Widget>? xLabels;
  final ResponsiveInfo info;

  const CompactBarChart({
    super.key,
    required this.barGroups,
    required this.info,
    this.xLabels,
  });

  @override
  State<CompactBarChart> createState() => _CompactBarChartState();
}

class _CompactBarChartState extends State<CompactBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Réserver de l'espace pour les labels en bas si présents
    final hasLabels = widget.xLabels != null && widget.xLabels!.isNotEmpty;
    final bottomReservedSize =
        hasLabels ? (widget.info.isMobile ? 36.0 : 44.0) : 0.0;

    return ChartAnimator(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutBack,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return BarChart(
            BarChartData(
              barGroups: List.generate(widget.barGroups.length, (i) {
                final group = widget.barGroups[i];
                return BarChartGroupData(
                  x: group.x,
                  barRods: group.barRods.map((rod) {
                    return BarChartRodData(
                      toY: rod.toY *
                          Curves.easeOutCubic.transform(
                            (_animation.value * (1.0 - i * 0.05))
                                .clamp(0.0, 1.0),
                          ),
                      color:
                          rod.color ?? Colors.blueAccent.withValues(alpha: 0.8),
                      width: rod.width,
                      borderRadius: BorderRadius.circular(4),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: rod.toY,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    );
                  }).toList(),
                );
              }),
              groupsSpace: 12,
              alignment: BarChartAlignment.spaceAround,
              titlesData: FlTitlesData(
                show: true,
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Text(
                          formatCompact(value.toInt()),
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 9),
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: hasLabels,
                    reservedSize: bottomReservedSize,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      if (!hasLabels) return const SizedBox.shrink();
                      final labels = widget.xLabels!;
                      final index = value.round();
                      if (index < 0 || index >= labels.length) {
                        return const SizedBox.shrink();
                      }
                      final total = labels.length;
                      final step = total > 6 ? (total / 6).ceil() : 1;
                      if (index % step != 0) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Transform.rotate(
                          angle: -0.7,
                          alignment: Alignment.centerLeft,
                          child: labels[index],
                        ),
                      );
                    },
                  ),
                ),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 5,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.white.withValues(alpha: 0.08),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (group) {
                    final color =
                        group.barRods.first.color ?? Colors.blueAccent;
                    return color.withValues(alpha: 0.85);
                  },
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      formatCompact(rod.toY),
                      const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    );
                  },
                ),
              ),
              backgroundColor: Colors.white.withValues(alpha: 0.03),
            ),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
          );
        },
      ),
    );
  }
}

/// LineChart version compacte
class CompactLineChart extends StatefulWidget {
  final List<FlSpot> spots;
  final List<Widget> xLabels;
  final Color color;
  final ResponsiveInfo info;

  const CompactLineChart({
    super.key,
    required this.spots,
    required this.xLabels,
    required this.color,
    required this.info,
  });

  @override
  State<CompactLineChart> createState() => _CompactLineChartState();
}

class _CompactLineChartState extends State<CompactLineChart>
    with TickerProviderStateMixin {
  late AnimationController _lineController;
  late Animation<double> _lineAnimation;

  @override
  void initState() {
    super.initState();
    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _lineAnimation = CurvedAnimation(
      parent: _lineController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _lineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.spots.isEmpty) return const SizedBox.shrink();

    return ChartAnimator(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutBack,
      child: AnimatedBuilder(
        animation: _lineAnimation,
        builder: (context, child) {
          final progress = _lineAnimation.value;
          final animatedSpots =
              widget.spots.map((s) => FlSpot(s.x, s.y * progress)).toList();
          final lightSpot = animatedSpots.last;

          return LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              // Calcul dynamique du step pour éviter les labels qui se chevauchent
              final labelWidth = 40.0;
              final visibleCount = (availableWidth / labelWidth).floor();
              final step = widget.xLabels.isEmpty
                  ? 1
                  : (widget.xLabels.length / visibleCount).ceil().clamp(1, 6);

              return Stack(
                children: [
                  LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: animatedSpots,
                          isCurved: true,
                          color: widget.color.withValues(alpha: 0.9),
                          barWidth: 2.5,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: widget.color.withValues(alpha: 0.12),
                          ),
                        ),
                      ],
                      titlesData: FlTitlesData(
                        show: true,
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Text(
                                  formatCompact(value.toInt()),
                                  style: const TextStyle(
                                      color: Colors.white60, fontSize: 9),
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: widget.xLabels.isNotEmpty,
                            reservedSize: 32,
                            getTitlesWidget: (value, meta) {
                              if (widget.xLabels.isEmpty)
                                return const SizedBox.shrink();
                              final index = value.toInt();
                              if (index < 0 ||
                                  index >= widget.xLabels.length ||
                                  index % step != 0) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Transform.rotate(
                                  angle: -0.7,
                                  alignment: Alignment.centerLeft,
                                  child: widget.xLabels[index],
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.white.withValues(alpha: 0.08),
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      clipData:
                          const FlClipData.all(), // ← évite les débordements
                    ),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: TrailingLightPainter(
                          spot: lightSpot,
                          color: widget.color,
                          opacity: progress,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// PieChart version compacte
class CompactPieChart extends StatefulWidget {
  final List<PieChartSectionData> sections;
  final ResponsiveInfo info;

  const CompactPieChart({
    super.key,
    required this.sections,
    required this.info,
  });

  @override
  State<CompactPieChart> createState() => _CompactPieChartState();
}

class _CompactPieChartState extends State<CompactPieChart>
    with SingleTickerProviderStateMixin {
  int? touchedIndex;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChartAnimator(
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutBack,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final h = constraints.maxHeight;
              final w = constraints.maxWidth;

              // 36px pour la légende scrollable en bas
              const legendH = 36.0;
              const gap = 8.0;
              // Espace réel pour le chart (avec une borne min)
              final chartH = (h - legendH - gap).clamp(60.0, 500.0);

              // Rayon déduit de la plus petite dimension disponible
              final minSide = math.min(w, chartH);
              final baseRadius = (minSide / 4.2).clamp(20.0, 64.0);
              final centerSpace = baseRadius * 0.5;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Pie chart ──
                  SizedBox(
                    height: chartH,
                    width: w,
                    child: Transform.scale(
                      scale: 0.88 + 0.12 * _animation.value,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: centerSpace,
                          pieTouchData: PieTouchData(
                            touchCallback: (event, response) {
                              if (!event.isInterestedForInteractions ||
                                  response == null) {
                                setState(() => touchedIndex = null);
                                return;
                              }
                              setState(() => touchedIndex =
                                  response.touchedSection?.touchedSectionIndex);
                            },
                          ),
                          sections: List.generate(
                            widget.sections.length,
                            (i) {
                              final s = widget.sections[i];
                              final isTouched = i == touchedIndex;
                              // Ne montre les titres que si le rayon est suffisant
                              final showTitle = baseRadius >= 36;
                              return PieChartSectionData(
                                title: showTitle ? s.title : '',
                                value: s.value,
                                color: s.color,
                                gradient: s.gradient,
                                titleStyle: TextStyle(
                                  fontSize: isTouched ? 13 : 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                radius:
                                    isTouched ? baseRadius * 1.12 : baseRadius,
                              );
                            },
                          ),
                          startDegreeOffset: -45,
                        ),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeInOutCubic,
                      ),
                    ),
                  ),

                  const SizedBox(height: gap),

                  // ── Légende scrollable horizontale ──
                  AnimatedOpacity(
                    opacity: _animation.value,
                    duration: const Duration(milliseconds: 600),
                    child: SizedBox(
                      height: legendH,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: widget.sections.map((s) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 9,
                                    height: 9,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: s.gradient ??
                                          LinearGradient(colors: [
                                            s.color,
                                            s.color.withValues(alpha: 0.7),
                                          ]),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${s.title}: ${formatCompact(s.value)}',
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.82),
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// Graphique combiné : ligne de tendance + points + labels immersifs
class CompactScatterTrendChart extends StatefulWidget {
  final List<FlSpot> spots;
  final List<String> labels;
  final Color color;
  final ResponsiveInfo info;

  const CompactScatterTrendChart({
    super.key,
    required this.spots,
    required this.labels,
    required this.color,
    required this.info,
  });

  @override
  State<CompactScatterTrendChart> createState() =>
      _CompactScatterTrendChartState();
}

class _CompactScatterTrendChartState extends State<CompactScatterTrendChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.spots.isEmpty) return const SizedBox.shrink();

    final maxValue = widget.spots.map((e) => e.y).reduce(max);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Si la hauteur est infinie (ex: dans un Column sans contrainte),
        // on utilise une hauteur par défaut raisonnable.
        final height = constraints.maxHeight.isInfinite
            ? 200.0
            : constraints.maxHeight.clamp(140.0, 260.0);
        final width = constraints.maxWidth;

        return ChartAnimator(
          child: ClipRect(
            child: SizedBox(
              width: width,
              height: height,
              child: BuildAnimatedChartContent(
                animation: _animation,
                height: height,
                widget: widget,
                maxValue: maxValue,
                width: width,
              ),
            ),
          ),
        );
      },
    );
  }
}

String formatCompact(num value) {
  String formatted;
  if (value >= 1000000) {
    formatted = (value / 1000000).toStringAsFixed(1);
    return formatted.endsWith('.0')
        ? '${formatted.substring(0, formatted.length - 2)}M'
        : '${formatted}M';
  } else if (value >= 1000) {
    formatted = (value / 1000).toStringAsFixed(1);
    return formatted.endsWith('.0')
        ? '${formatted.substring(0, formatted.length - 2)}K'
        : '${formatted}K';
  } else {
    return value.toStringAsFixed(0);
  }
}
