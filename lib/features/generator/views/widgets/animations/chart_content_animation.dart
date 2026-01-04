import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

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
        return SizedBox(
          height: height,
          child: Stack(
            children: [
              // Ligne principale (courbe)
              LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: widget.spots
                          .map((e) => FlSpot(e.x, e.y * _animation.value))
                          .toList(),
                      isCurved: true,
                      color: widget.color.withValues(alpha: 0.7),
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            widget.color.withValues(alpha: 0.15),
                            Colors.transparent
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
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
                  minX: -1,
                  maxX: (widget.spots.length * 2).toDouble(),
                  minY: 0,
                  maxY: maxValue * 1.3,
                ),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
              ),

              // Points + labels au-dessus
              ...List.generate(widget.spots.length, (i) {
                final spot = widget.spots[i];
                final xPos = (spot.x / (widget.spots.length * 2)) *
                    width; // proportionnel
                final yPos = height -
                    (spot.y / (maxValue * 1.3)) * height * _animation.value;
                final opacity = (spot.y / maxValue).clamp(0.4, 1.0);

                return Positioned(
                  left: xPos.clamp(0, width - 60),
                  top: yPos - 20,
                  child: Column(
                    children: [
                      // Label
                      Opacity(
                        opacity: opacity,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: widget.color.withValues(alpha: 0.3),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            widget.labels[i],
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: opacity),
                              fontSize: widget.info.isMobile ? 10 : 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Point
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        width: (spot.y / maxValue * 14).clamp(6, 14),
                        height: (spot.y / maxValue * 14).clamp(6, 14),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.color.withValues(alpha: opacity),
                          boxShadow: [
                            BoxShadow(
                              color: widget.color.withValues(alpha: 0.6),
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
        );
      },
    );
  }
}
