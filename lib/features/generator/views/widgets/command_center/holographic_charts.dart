import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:portefolio/core/affichage/colors_spec.dart';

/// Donut des langages holographique et vivant avec rotation lente & interaction au survol
class HolographicDonutChart extends StatefulWidget {
  final Map<String, double> languageData;

  const HolographicDonutChart({
    super.key,
    required this.languageData,
  });

  @override
  State<HolographicDonutChart> createState() => _HolographicDonutChartState();
}

class _HolographicDonutChartState extends State<HolographicDonutChart>
    with SingleTickerProviderStateMixin {
  int? _touchedIndex;
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.languageData.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text('Aucune donnée linguistique',
              style: TextStyle(color: Colors.white54)),
        ),
      );
    }

    final entries = widget.languageData.entries.toList();
    final colors = [
      ColorHelpers.cyan,
      ColorHelpers.magenta,
      const Color(0xFF7C4DFF),
      const Color(0xFF00E676),
      const Color(0xFFFFEA00),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: ColorHelpers.cyan.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: ColorHelpers.cyan.withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.donut_large, color: ColorHelpers.cyan, size: 18),
              SizedBox(width: 8),
              Text(
                'RÉPARTITION DES LANGAGES',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                RotationTransition(
                  turns: _rotationController,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              _touchedIndex = null;
                              return;
                            }
                            _touchedIndex = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      sectionsSpace: 4,
                      centerSpaceRadius: 65,
                      sections: List.generate(entries.length, (i) {
                        final isTouched = i == _touchedIndex;
                        final entry = entries[i];
                        final color = colors[i % colors.length];

                        return PieChartSectionData(
                          color: color,
                          value: entry.value,
                          title: isTouched
                              ? '${entry.value.toStringAsFixed(1)}%'
                              : '',
                          radius: isTouched ? 45.0 : 38.0,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          badgeWidget: isTouched
                              ? Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: color),
                                  ),
                                  child: Text(
                                    entry.key,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 10),
                                  ),
                                )
                              : null,
                          badgePositionPercentageOffset: 1.3,
                        );
                      }),
                    ),
                  ),
                ),
                // Centre du Donut holographique
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.code, color: ColorHelpers.cyan, size: 20),
                    const SizedBox(height: 4),
                    Text(
                      _touchedIndex != null
                          ? entries[_touchedIndex!].key
                          : 'STACK',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Radar de compétences 3D incliné avec effet de profondeur et lignes de lumière
class HolographicRadarChart extends StatelessWidget {
  final Map<String, double> skillsData;

  const HolographicRadarChart({
    super.key,
    required this.skillsData,
  });

  @override
  Widget build(BuildContext context) {
    if (skillsData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: ColorHelpers.magenta.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: ColorHelpers.magenta.withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.radar, color: ColorHelpers.magenta, size: 18),
              SizedBox(width: 8),
              Text(
                'RADAR DE COMPÉTENCES 3D',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.003) // Effet de perspective 3D
                ..rotateX(0.15)
                ..rotateY(-0.1),
              alignment: FractionalOffset.center,
              child: RadarChart(
                RadarChartData(
                  dataSets: [
                    RadarDataSet(
                      fillColor: ColorHelpers.magenta.withValues(alpha: 0.25),
                      borderColor: ColorHelpers.magenta,
                      entryRadius: 3.5,
                      dataEntries: skillsData.values
                          .map((v) => RadarEntry(value: v))
                          .toList(),
                    ),
                  ],
                  radarBackgroundColor: Colors.transparent,
                  borderData: FlBorderData(show: false),
                  radarBorderData: const BorderSide(
                    color: Colors.white24,
                    width: 1,
                  ),
                  getTitle: (index, angle) {
                    final key = skillsData.keys.elementAt(index);
                    return RadarChartTitle(
                      text: key,
                      angle: 0,
                    );
                  },
                  titleTextStyle: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  tickCount: 3,
                  ticksTextStyle:
                      const TextStyle(color: Colors.transparent, fontSize: 0),
                  gridBorderData: const BorderSide(
                    color: Colors.white10,
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
