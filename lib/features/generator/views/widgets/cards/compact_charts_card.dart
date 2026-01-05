import 'dart:math';
import 'dart:ui';

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
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: info.isMobile
            ? 2
            : info.isTablet
                ? 3
                : 4,
        childAspectRatio: info.isMobile ? 2.1 : 2.5,
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
            border: Border.all(
              color: Colors.blue.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ResponsiveText.bodySmall(
                entry.key,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              ResponsiveText.titleMedium(
                entry.value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
                            (_animation.value - (i * 0.03)).clamp(0, 1),
                        color: rod.color ??
                            Colors.blueAccent.withValues(alpha: 0.8),
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
                alignment: BarChartAlignment.spaceAround,
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        return ResponsiveText.bodySmall(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: widget.info.isMobile ? 40 : 50,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (widget.xLabels != null &&
                            index < widget.xLabels!.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: widget.xLabels![index],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withValues(alpha: 0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  touchTooltipData:
                      BarTouchTooltipData(getTooltipColor: (group) {
                    final color =
                        group.barRods.first.color ?? Colors.blueAccent;
                    final alpha = color.withValues(alpha: 0.9);
                    final red = color.withValues(red: 255);
                    final green = color.withValues(green: 255);
                    final blue = color.withValues(blue: 255);
                    return Color.from(
                        alpha: alpha.a,
                        red: red.r,
                        green: green.g,
                        blue: blue.b);
                  }, getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(formatCompact(rod.toY),
                        const TextStyle(color: Colors.white));
                  }),
                ),
                backgroundColor: Colors.white.withValues(alpha: 0.05),
              ),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
            );
          },
        ));
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
    return ChartAnimator(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutBack,
        child: AnimatedBuilder(
          animation: _lineAnimation,
          builder: (context, child) {
            final progress = _lineAnimation.value;

            if (widget.spots.isEmpty) return const SizedBox.shrink();

            // On multiplie le y de chaque point par progress
            final animatedSpots =
                widget.spots.map((s) => FlSpot(s.x, s.y * progress)).toList();

            // Point lumineux : dernier point actuel
            final lightSpot = animatedSpots.last;

            return LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    // Ligne principale (courbe)
                    LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: animatedSpots,
                            isCurved: true,
                            color: widget.color.withValues(alpha: 0.9),
                            barWidth: 2.5,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: false,
                              getDotPainter: (spot, percent, bar, index) =>
                                  FlDotCirclePainter(
                                radius: 3.5 + 2 * _lineAnimation.value,
                                color: widget.color.withValues(
                                    alpha: (0.5 + 0.5 * _lineAnimation.value)),
                                strokeWidth: 1.5,
                                strokeColor:
                                    Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: widget.color.withValues(alpha: 0.15),
                            ),
                          ),
                        ],
                        titlesData: FlTitlesData(
                          show: true,
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              getTitlesWidget: (value, meta) {
                                return ResponsiveText.bodySmall(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                // 🔹 Saut d’un label sur 2 en mobile, ou sur 1 en desktop
                                final availableWidth = constraints.maxWidth;
                                final labelWidth = 60.0;
                                final step = (availableWidth /
                                        (labelWidth * widget.xLabels.length))
                                    .clamp(1, 3)
                                    .round();

                                if (index % step != 0 ||
                                    index >= widget.xLabels.length) {
                                  return const SizedBox.shrink();
                                }

                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Transform.rotate(
                                    angle: -0.4,
                                    child: widget.xLabels[index],
                                  ),
                                );
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.white.withValues(alpha: 0.1),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        borderData: FlBorderData(show: false),
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
        ));
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
    final info = widget.info;

    return ChartAnimator(
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeOutBack,
        child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              backgroundBlendMode: BlendMode.modulate,
            ),
            padding: const EdgeInsets.all(8),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Transform.scale(
                              scale: 0.9 + 0.1 * _animation.value,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                height: info.isMobile ? 200 : 220,
                                curve: Curves.easeOutBack,
                                child: PieChart(
                                  PieChartData(
                                    sectionsSpace: 2,
                                    centerSpaceRadius: info.isMobile ? 20 : 30,
                                    pieTouchData: PieTouchData(
                                      touchCallback: (event, response) {
                                        if (!event
                                                .isInterestedForInteractions ||
                                            response == null) {
                                          setState(() => touchedIndex = null);
                                          return;
                                        }
                                        setState(() => touchedIndex = response
                                            .touchedSection
                                            ?.touchedSectionIndex);
                                      },
                                    ),
                                    sections: List.generate(
                                        widget.sections.length, (i) {
                                      final section = widget.sections[i];
                                      final isTouched = i == touchedIndex;
                                      final double radius = isTouched
                                          ? 70
                                          : (info.isMobile ? 50 : 60);
                                      return PieChartSectionData(
                                        title: section.title,
                                        value: section.value,
                                        color: section.color,
                                        gradient: section.gradient,
                                        titleStyle: TextStyle(
                                          fontSize: isTouched ? 18 : 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          shadows: [
                                            Shadow(
                                                color: Colors.black
                                                    .withValues(alpha: 0.3),
                                                blurRadius: 12),
                                          ],
                                        ),
                                        radius: radius,
                                      );
                                    }),
                                  ),
                                  duration: const Duration(milliseconds: 1000),
                                  curve: Curves.easeInOutCubic,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            AnimatedOpacity(
                              opacity: _animation.value,
                              duration: const Duration(milliseconds: 600),
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 12,
                                runSpacing: 8,
                                children: widget.sections.map((s) {
                                  return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 600),
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: s.gradient ??
                                                LinearGradient(
                                                  colors: [
                                                    s.color,
                                                    s.color
                                                        .withValues(alpha: 0.7)
                                                  ],
                                                ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        ResponsiveText.bodySmall(
                                          "${s.title}: ${formatCompact(s.value)}",
                                          style: TextStyle(
                                            color: Colors.white
                                                .withValues(alpha: 0.9),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ]);
                                }).toList(),
                              ),
                            ),
                          ],
                        );
                      },
                    )))));
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
    final width = MediaQuery.of(context).size.width;
    final height = 220.0; // hauteur fixe pour l’affichage compact

    return ChartAnimator(
        child: BuildAnimatedChartContent(
            animation: _animation,
            height: height,
            widget: widget,
            maxValue: maxValue,
            width: width));
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
