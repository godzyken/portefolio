import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/widgets/ui_widgets_extentions.dart';

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
class CompactBarChart extends StatelessWidget {
  final List<BarChartGroupData> barGroups;
  final ResponsiveInfo info;

  const CompactBarChart({
    super.key,
    required this.barGroups,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barGroups: barGroups,
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
          bottomTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
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
          touchTooltipData: BarTouchTooltipData(getTooltipColor: (group) {
            final color = group.barRods.first.color;
            final alpha = color?.withValues(alpha: 09);
            final red = color?.withValues(red: 255);
            final green = color?.withValues(green: 255);
            final blue = color?.withValues(blue: 255);
            return Color.from(
                alpha: alpha!.a, red: red!.r, green: green!.g, blue: blue!.b);
          }, getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
                formatCompact(rod.toY), const TextStyle(color: Colors.white));
          }),
        ),
        backgroundColor: Colors.white.withValues(alpha: 0.05),
      ),
    );
  }
}

/// LineChart version compacte
class CompactLineChart extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: color.withValues(alpha: 0.2),
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
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          bottomTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
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

class _CompactPieChartState extends State<CompactPieChart> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    final info = widget.info;

    return Container(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      height: info.isMobile ? 200 : 220,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: info.isMobile ? 20 : 40,
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
                          sections: List.generate(widget.sections.length, (i) {
                            final section = widget.sections[i];
                            final isTouched = i == touchedIndex;
                            final double radius =
                                isTouched ? 70 : (info.isMobile ? 50 : 60);
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
                                      color:
                                          Colors.black.withValues(alpha: 0.3),
                                      blurRadius: 12),
                                ],
                              ),
                              radius: radius,
                            );
                          }),
                        ),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeInOutCubic,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 8,
                      children: widget.sections.map((s) {
                        return Row(mainAxisSize: MainAxisSize.min, children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: s.gradient ??
                                  LinearGradient(
                                    colors: [
                                      s.color,
                                      s.color.withValues(alpha: 0.7)
                                    ],
                                  ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          ResponsiveText.bodySmall(
                            "${s.title}: ${formatCompact(s.value)}",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 13,
                            ),
                          ),
                        ]);
                      }).toList(),
                    )
                  ],
                ))));
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
