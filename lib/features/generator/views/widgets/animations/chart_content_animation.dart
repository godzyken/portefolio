import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../core/ui/widgets/responsive_text.dart';
import '../cards/compact_charts_card.dart';

class BuildAnimatedChartContent extends StatelessWidget {
  const BuildAnimatedChartContent({
    super.key,
    required Animation<double> animation,
    required this.height,
    required this.widget,
    required this.maxValue,
    required this.width,
  }) : _animation = animation;

  final Animation<double> _animation;
  final double height;
  final CompactScatterTrendChart widget;
  final double maxValue;
  final double width;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final spots = widget.spots;
        final color = widget.color;

        // Calcul de la tendance
        final a = _computeSlope(spots);
        final b = _computeIntercept(spots, a);
        final minX = 0.0;
        final maxX = (spots.length - 1).toDouble();
        final trendSpots = [
          FlSpot(minX, a * minX + b),
          FlSpot(maxX, a * maxX + b),
        ];

        final trendLabel = _getTrendLabel(a);
        final trendColor = _getTrendColor(a);

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // === GRAPHIQUE PRINCIPAL ===
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Courbe principale
                  Positioned.fill(
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots
                                .map((e) => FlSpot(e.x, e.y * _animation.value))
                                .toList(),
                            isCurved: true,
                            color: color.withValues(alpha: 0.7),
                            barWidth: 2,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  color.withValues(alpha: 0.15),
                                  Colors.transparent
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),

                          // Courbe de tendance (pointillée)
                          LineChartBarData(
                            spots: trendSpots,
                            isCurved: false,
                            color: color.withValues(alpha: 0.5),
                            barWidth: 1.5,
                            dashArray: [6, 6],
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                          ),
                        ],
                        titlesData: FlTitlesData(show: false),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.white.withValues(alpha: 0.05),
                            strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minX: minX,
                        maxX: maxX,
                        minY: 0,
                        maxY: maxValue * 1.2,
                      ),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutCubic,
                    ),
                  ),

                  // Points + labels
                  ...List.generate(spots.length, (i) {
                    final spot = spots[i];
                    final xStep = (width - 60) / (spots.length - 1);
                    final xPos = 30 + (xStep * i);
                    final yScale = (spot.y / (maxValue * 1.3));
                    final yPos = height * (1 - yScale * _animation.value);
                    final opacity = (spot.y / maxValue).clamp(0.4, 1.0);

                    return Positioned(
                      left: xPos,
                      top: yPos.clamp(20.0, height - 30.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Opacity(
                            opacity: opacity,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: color.withValues(alpha: 0.3),
                                  width: 0.8,
                                ),
                              ),
                              child: ResponsiveText.bodySmall(
                                widget.labels[i],
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            width: (spot.y / maxValue * 14).clamp(6, 14),
                            height: (spot.y / maxValue * 14).clamp(6, 14),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color.withValues(alpha: opacity),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.6),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            // === ÉTIQUETTE DE TENDANCE ===
            AnimatedOpacity(
              opacity: _animation.value,
              duration: const Duration(milliseconds: 700),
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      trendLabel.icon,
                      color: trendColor,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    ResponsiveText.bodySmall(
                      trendLabel.text,
                      style: TextStyle(
                        color: trendColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // === CALCULS ===
  double _computeSlope(List<FlSpot> spots) {
    final n = spots.length;
    final sumX = spots.fold<double>(0, (acc, s) => acc + s.x);
    final sumY = spots.fold<double>(0, (acc, s) => acc + s.y);
    final sumXY = spots.fold<double>(0, (acc, s) => acc + s.x * s.y);
    final sumX2 = spots.fold<double>(0, (acc, s) => acc + s.x * s.x);
    return (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
  }

  double _computeIntercept(List<FlSpot> spots, double a) {
    final meanX = spots.map((s) => s.x).reduce((a, b) => a + b) / spots.length;
    final meanY = spots.map((s) => s.y).reduce((a, b) => a + b) / spots.length;
    return meanY - a * meanX;
  }

  // === LABEL DE TENDANCE ===

  _TrendLabel _getTrendLabel(double slope) {
    if (slope > 0.1) {
      return _TrendLabel('Tendance haussière', Icons.trending_up);
    } else if (slope < -0.1) {
      return _TrendLabel('Tendance baissière', Icons.trending_down);
    } else {
      return _TrendLabel('Tendance stable', Icons.trending_flat);
    }
  }

  Color _getTrendColor(double slope) {
    if (slope > 0.1) return Colors.greenAccent;
    if (slope < -0.1) return Colors.redAccent;
    return Colors.grey.shade300;
  }
}

class _TrendLabel {
  final String text;
  final IconData icon;
  const _TrendLabel(this.text, this.icon);
}
