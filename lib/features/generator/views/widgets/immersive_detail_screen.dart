import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/widgets/responsive_text.dart';
import 'package:portefolio/core/ui/widgets/smart_image.dart';

import '../../../projets/data/project_data.dart';
import 'particle_background.dart';

class ImmersiveDetailScreen extends ConsumerStatefulWidget {
  final ProjectInfo project;
  final VoidCallback? onClose;

  const ImmersiveDetailScreen({
    super.key,
    required this.project,
    this.onClose,
  });

  @override
  ConsumerState<ImmersiveDetailScreen> createState() =>
      _ImmersiveDetailScreenState();
}

class _ImmersiveDetailScreenState extends ConsumerState<ImmersiveDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late ScrollController _scrollController;
  late Timer _imageTimer;

  int _currentImageIndex = 0;

  // ----- Pré-calcul des charts -----
  late List<BarChartGroupData> barGroups;
  late List<Widget> venteXLabels;
  late List<PieChartSectionData> clientSections;
  late List<PieChartSectionData> followersSections;
  late List<FlSpot> demoSpots;
  late List<Widget> demoXLabels;
  late List<FlSpot> diffusionsSpots;
  late List<Widget> diffusionsXLabels;
  late List<FlSpot> representationsSpots;
  late List<Widget> representationsXLabels;
  late List<FlSpot> videoSpots;
  late List<Widget> videoXLabels;
  late List<PieChartSectionData> stockSections;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _setupImageRotation();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();

    _prepareChartData();
  }

  void _setupImageRotation() {
    if (widget.project.image == null || widget.project.image!.length <= 1) {
      return;
    }
    _imageTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      setState(() {
        _currentImageIndex =
            (_currentImageIndex + 1) % widget.project.image!.length;
      });
    });
  }

  void _prepareChartData() {
    final resultats = widget.project.resultsMap;
    if (resultats == null) {
      barGroups = [];
      venteXLabels = [];
      clientSections = [];
      demoSpots = [];
      demoXLabels = [];
      videoSpots = [];
      videoXLabels = [];
      stockSections = [];
      followersSections = [];
      representationsSpots = [];
      representationsXLabels = [];
      diffusionsSpots = [];
      diffusionsXLabels = [];
      return;
    }

    // Ventes
    final ventes = resultats['ventes'] as List<dynamic>? ?? [];
    barGroups = ventes.asMap().entries.map((entry) {
      final x = entry.key;
      final y = (entry.value['quantite'] as num).toDouble();
      return BarChartGroupData(
        x: x,
        barRods: [BarChartRodData(toY: y, color: Colors.blueAccent)],
      );
    }).toList();
    venteXLabels = ventes.asMap().entries.map((entry) {
      return Text(
        entry.value['gamme'].toString(),
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      );
    }).toList();

    // Clients
    final clients = resultats['clients'] as List<dynamic>? ?? [];
    clientSections = clients.asMap().entries.map((entry) {
      final c = entry.value;
      return PieChartSectionData(
        value: (c['nombre'] as num).toDouble(),
        title: c['age'],
        color: Colors.primaries[entry.key % Colors.primaries.length],
        radius: 50,
        titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
      );
    }).toList();

    // Démonstrations
    final demonstrations = resultats['demonstrations'] as List<dynamic>? ?? [];
    demoSpots = demonstrations.asMap().entries.map((entry) {
      final x = entry.key.toDouble();
      final y = (entry.value['evenements'] as num).toDouble();
      return FlSpot(x, y);
    }).toList();
    demoXLabels = demonstrations.asMap().entries.map((entry) {
      return Text(
        entry.value['mois'].toString(),
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      );
    }).toList();

    // Vidéos
    final videos = resultats['videos'] as List<dynamic>? ?? [];
    videoSpots = videos.asMap().entries.map((entry) {
      final x = entry.key.toDouble();
      final y = (entry.value['vues'] as num).toDouble();
      return FlSpot(x, y);
    }).toList();
    videoXLabels = videos.asMap().entries.map((entry) {
      return Text(
        entry.value['titre'].toString(),
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      );
    }).toList();

    // Stock
    final stock = resultats['stock'] as List<dynamic>? ?? [];
    stockSections = stock.asMap().entries.map((entry) {
      final s = entry.value;
      return PieChartSectionData(
        value: (s['nombre'] as num).toDouble(),
        title: s['etat'],
        color: Colors.primaries[entry.key % Colors.primaries.length],
        radius: 50,
        titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
      );
    }).toList();

    // Diffusions
    final diffusions = resultats['diffusions'] as List<dynamic>? ?? [];
    diffusionsSpots = diffusions.asMap().entries.map((entry) {
      final x = entry.key.toDouble();
      final y = (entry.value['musics'] as num).toDouble();
      return FlSpot(x, y);
    }).toList();
    diffusionsXLabels = diffusions.asMap().entries.map((entry) {
      return ResponsiveText.bodySmall(
        entry.value['annee'].toString(),
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      );
    }).toList();

    // Followers
    final followers = resultats['followers'] as List<dynamic>? ?? [];
    followersSections = followers.asMap().entries.map((entry) {
      final f = entry.value;
      return PieChartSectionData(
        value: (f['nombre'] as num).toDouble(),
        title: f['plateforme'],
        color: Colors.primaries[entry.key % Colors.primaries.length],
        radius: 50,
        titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
      );
    }).toList();

    // Representations
    final representations =
        resultats['representations'] as List<dynamic>? ?? [];
    representationsSpots = representations.asMap().entries.map((entry) {
      final x = entry.key.toDouble();
      final y = (entry.value['evenements'] as num).toDouble();
      return FlSpot(x, y);
    }).toList();
    representationsXLabels = representations.asMap().entries.map((entry) {
      return ResponsiveText.bodySmall(
        entry.value['annee'].toString(),
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      );
    }).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _imageTimer.cancel();
    super.dispose();
  }

  String? _getCurrentImage() {
    final images = widget.project.cleanedImages ?? widget.project.image;
    if (images == null || images.isEmpty) return null;
    return images[_currentImageIndex % images.length];
  }

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(responsiveInfoProvider);
    final theme = Theme.of(context);
    final randomImage = _getCurrentImage();

    Widget yLabel(double value) => ResponsiveBox(
          padding: const EdgeInsets.only(right: 6),
          child: ResponsiveText.bodySmall(
            value.toInt().toString(),
            style: TextStyle(
              color: Colors.white70,
              fontSize: info.isMobile ? 10 : 12,
            ),
          ),
        );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          if (randomImage != null)
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 1000),
                child: SmartImage(
                  key: UniqueKey(),
                  path: randomImage,
                  responsiveSize: ResponsiveImageSize.xlarge,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Positioned.fill(
            child: ResponsiveBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.black.withValues(alpha: 0.85),
                    Colors.black.withValues(alpha: 0.95),
                  ],
                ),
              ),
            ),
          ),
          const Positioned.fill(
              child: ParticleBackground(
                  particleCount: 40,
                  particleColor: Colors.white,
                  minSize: 1.5,
                  maxSize: 4.0)),
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SafeArea(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: EdgeInsets.all(info.isMobile ? 24 : 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitle(theme, info),
                      ResponsiveBox(height: info.isMobile ? 32 : 48),
                      _buildSection(
                          "📜 Description", widget.project.points, theme, info),
                      if (widget.project.techDetails != null &&
                          widget.project.techDetails!.isNotEmpty) ...[
                        ResponsiveBox(height: 32),
                        _buildTechDetails(
                            widget.project.techDetails!, theme, info),
                      ],
                      if (widget.project.results != null &&
                          widget.project.results!.isNotEmpty) ...[
                        ResponsiveBox(height: 32),
                        _buildSection("🏁 Résultats & livrables",
                            widget.project.results!, theme, info),
                        ResponsiveBox(height: 32),
                        _buildKPISection(theme, info, yLabel),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: IconButton(
                icon: const Icon(Icons.close, size: 32),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.5),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  _controller.reverse().then((_) {
                    widget.onClose?.call();
                    if (mounted) Navigator.of(context).pop();
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----- Widgets de contenu (inchangés) -----
  Widget _buildTitle(ThemeData theme, ResponsiveInfo info) {
    return ResponsiveBox(
      padding: EdgeInsets.all(info.isMobile ? 24 : 32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.1), width: 2),
      ),
      child: ResponsiveText.titleLarge(
        widget.project.title,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: info.isMobile ? 28 : 48,
        ),
      ),
    );
  }

  Widget _buildSection(
      String title, List<String> points, ThemeData theme, ResponsiveInfo info) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText.titleLarge(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: info.isMobile ? 20 : 24,
          ),
        ),
        const ResponsiveBox(height: 16),
        ResponsiveBox(
          padding: EdgeInsets.all(info.isMobile ? 20 : 32),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: points.map((text) {
              return ResponsiveBox(
                padding: const EdgeInsets.only(bottom: 12),
                child: ResponsiveText.bodyLarge(
                  text,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: info.isMobile ? 16 : 18,
                    height: 1.6,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTechDetails(
      Map<String, dynamic> details, ThemeData theme, ResponsiveInfo info) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText.titleLarge(
          "⚙️ Détails techniques",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: info.isMobile ? 20 : 24,
          ),
        ),
        const ResponsiveBox(height: 16),
        ResponsiveBox(
          padding: EdgeInsets.all(info.isMobile ? 20 : 32),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: details.entries.map((entry) {
              return ResponsiveBox(
                padding: const EdgeInsets.only(bottom: 12),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "• ${entry.key}: ",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: info.isMobile ? 16 : 18,
                        ),
                      ),
                      TextSpan(
                        text: "${entry.value}",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: info.isMobile ? 16 : 18,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildKPISection(
    ThemeData theme,
    ResponsiveInfo info,
    Widget Function(double) yLabel,
  ) {
    /// Calcul automatique d'un interval Y pour éviter la surcharge
    double computeYInterval(List<FlSpot> spots) {
      if (spots.isEmpty) return 1;
      final maxY = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
      final minY = spots.map((e) => e.y).reduce((a, b) => a < b ? a : b);
      final range = maxY - minY;
      if (range <= 5) return 1; // petite plage, interval simple
      if (range <= 20) return 5;
      if (range <= 50) return 10;
      if (range <= 100) return 20;
      return (range / 5).ceilToDouble(); // 5 graduations max
    }

    // Fonction utilitaire pour espacer proprement les sections présentes
    Widget sectionSpacing() => const ResponsiveBox(height: 32);

    // Utilitaire : construit un graphique linéaire avec labels espacés
    Widget buildLineChart({
      required List<FlSpot> spots,
      required List<Widget> labels,
      required Color color,
      int step = 1, // on affiche toutes les X labels sur l'axe X selon step
    }) {
      if (spots.isEmpty) return const SizedBox.shrink();

      // Calcul des labels uniques pour l'axe X
      final uniqueLabels = <int, Widget>{};
      for (var i = 0; i < labels.length; i++) {
        if (i % step == 0) {
          uniqueLabels[i] = labels[i];
        }
      }

      return ResponsiveBox(
        height: 200,
        child: LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: color,
                barWidth: 3,
                dotData: FlDotData(
                  show: true,
                  checkToShowDot: (spot, barData) {
                    // par exemple, afficher seulement si y > 10
                    return spot.y > 10;
                  },
                  getDotPainter: (spot, percent, bar, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: Colors.white,
                      strokeWidth: 1,
                      strokeColor: Colors.greenAccent,
                    );
                  },
                ),
              ),
            ],
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  getTitlesWidget: (value, meta) {
                    final idx = value.toInt();
                    if (!uniqueLabels.containsKey(idx)) {
                      return const SizedBox.shrink();
                    }
                    return Transform.rotate(
                      angle: -0.2,
                      alignment: Alignment.center,
                      child: uniqueLabels[idx]!,
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: info.isMobile ? 32 : 40,
                  interval: computeYInterval(spots),
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: info.isMobile ? 10 : 12,
                      ),
                    );
                  },
                ),
              ),
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: computeYInterval(spots),
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.white12,
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.white24),
            ),
          ),
        ),
      );
    }

    // Utilitaire : construit un graphique en barres (ventes)
    Widget buildBarChart() {
      if (barGroups.isEmpty) return const SizedBox.shrink();

      return ResponsiveBox(
        height: 200,
        child: BarChart(
          BarChartData(
            barGroups: barGroups,
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  getTitlesWidget: (value, meta) {
                    final idx = value.toInt();
                    if (idx < venteXLabels.length) {
                      final show = idx % (info.isMobile ? 2 : 1) == 0;
                      return show ? venteXLabels[idx] : const SizedBox.shrink();
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: info.isMobile ? 32 : 40,
                  getTitlesWidget: (v, m) => yLabel(v),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Utilitaire : graphique camembert
    Widget buildPieChart(List<PieChartSectionData> sections) {
      if (sections.isEmpty) return const SizedBox.shrink();
      return ResponsiveBox(
        height: 200,
        child: PieChart(
          PieChartData(
            sections: sections,
            centerSpaceRadius: 40,
            sectionsSpace: 2,
          ),
        ),
      );
    }

    // Contenu dynamique selon ce que le projet contient
    final List<Widget> charts = [];

    if (barGroups.isNotEmpty) {
      charts.addAll([
        ResponsiveText.headlineMedium(
          "Ventes par gamme de prix",
          style: TextStyle(
            color: Colors.white70,
            fontSize: info.isMobile ? 16 : 18,
          ),
        ),
        buildBarChart(),
        sectionSpacing(),
      ]);
    }

    if (clientSections.isNotEmpty) {
      charts.addAll([
        ResponsiveText.headlineMedium(
          "Répartition des clients par âge",
          style: TextStyle(
            color: Colors.white70,
            fontSize: info.isMobile ? 16 : 18,
          ),
        ),
        buildPieChart(clientSections),
        sectionSpacing(),
      ]);
    }

    if (demoSpots.isNotEmpty) {
      charts.addAll([
        ResponsiveText.headlineMedium(
          "Démonstrations / événements",
          style: TextStyle(
            color: Colors.white70,
            fontSize: info.isMobile ? 16 : 18,
          ),
        ),
        buildLineChart(
          spots: demoSpots,
          labels: demoXLabels,
          color: Colors.orangeAccent,
          step: info.isMobile ? 2 : 1,
        ),
        sectionSpacing(),
      ]);
    }

    if (videoSpots.isNotEmpty) {
      charts.addAll([
        ResponsiveText.headlineMedium(
          "Audience par publications",
          style: TextStyle(
            color: Colors.white70,
            fontSize: info.isMobile ? 16 : 18,
          ),
        ),
        buildLineChart(
          spots: videoSpots,
          labels: videoXLabels,
          color: Colors.greenAccent,
          step: info.isMobile ? 3 : 2,
        ),
        sectionSpacing(),
      ]);
    }

    if (stockSections.isNotEmpty) {
      charts.addAll([
        ResponsiveText.headlineMedium(
          "État du stock",
          style: TextStyle(
            color: Colors.white70,
            fontSize: info.isMobile ? 16 : 18,
          ),
        ),
        buildPieChart(stockSections),
      ]);
    }

    if (diffusionsSpots.isNotEmpty) {
      charts.addAll([
        ResponsiveText.headlineMedium(
          "Taux de publications par an",
          style: TextStyle(
              color: Colors.white70, fontSize: info.isMobile ? 16 : 18),
        ),
        buildLineChart(
            spots: diffusionsSpots,
            labels: diffusionsXLabels,
            color: Colors.blueAccent),
        sectionSpacing(),
      ]);
    }

    if (representationsSpots.isNotEmpty) {
      charts.addAll([
        ResponsiveText.headlineMedium(
          "Participations aux evenements / Representation Scenes / interviews",
          style: TextStyle(
              color: Colors.white70, fontSize: info.isMobile ? 16 : 18),
        ),
        buildLineChart(
            spots: representationsSpots,
            labels: representationsXLabels,
            color: Colors.blueAccent),
        sectionSpacing(),
      ]);
    }

    if (followersSections.isNotEmpty) {
      charts.addAll([
        ResponsiveText.headlineMedium(
          "Followers",
          style: TextStyle(
              color: Colors.white70, fontSize: info.isMobile ? 16 : 18),
        ),
        buildPieChart(followersSections),
        sectionSpacing(),
      ]);
    }

    // Rien à afficher ?
    if (charts.isEmpty) {
      return ResponsiveText.bodyMedium(
        "Aucune donnée de performance à afficher pour ce projet.",
        style: const TextStyle(color: Colors.white60),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: charts,
    );
  }
}
