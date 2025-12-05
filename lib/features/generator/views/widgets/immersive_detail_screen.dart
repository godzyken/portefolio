import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/provider/image_providers.dart';
import 'package:portefolio/core/ui/widgets/ui_widgets_extentions.dart';

import '../../../projets/providers/projects_extentions_providers.dart';
import '../../data/extention_models.dart';
import '../generator_widgets_extentions.dart';

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
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late ScrollController _scrollController;
  late PageController _pageController;

  List<ChartData> _charts = [];

  late AnimationController _carouselController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _pageController = PageController();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _carouselController = AnimationController(
      duration: const Duration(milliseconds: 5900),
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

    _startContinuousCarousel();
  }

  void _startContinuousCarousel() {
    final images = _getImages();
    if (images.length <= 1) return;

    _carouselController.addListener(() {
      if (_carouselController.value > 0.98) {
        final currentPage =
            _pageController.hasClients ? _pageController.page?.round() ?? 0 : 0;

        final nextPage = (currentPage + 1) % images.length;

        // Changer la page avec une transition
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeInOut,
        );
      }
    });

    _carouselController.repeat();
  }

  void _prepareChartData() {
    final resultats = widget.project.resultsMap;
    if (resultats == null) {
      _charts = [];
      return;
    }
    _charts = ChartDataFactory.createChartsFromResults(resultats);
  }

  @override
  void dispose() {
    _carouselController.dispose();

    _controller.dispose();
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  List<String> _getImages() {
    final images = widget.project.cleanedImages ?? widget.project.image;
    return images ?? [];
  }

  bool _hasProgrammingTag() {
    const programmingTags = [
      'dart',
      'flutter',
      'angular',
      'javascript',
      'typescript',
      'java',
      'python',
      'c#',
      'c++',
      'rust',
      'github',
      'git',
      'go',
      'php',
      'swift',
      'kotlin',
      'mysql',
      'prestashop',
      'magento',
      'ovh',
      'html',
      'css',
      'Laravel',
      'e-commerce',
      'digital'
    ];
    final titleLower = widget.project.title.toLowerCase();
    final pointsLower = widget.project.points.map((p) => p.toLowerCase());

    return programmingTags.any((tag) =>
        titleLower.contains(tag.toLowerCase()) ||
        pointsLower.any((p) {
          p.contains(tag.toLowerCase());
          return TechIconHelper.isProgrammingTech(p);
        }));
  }

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(responsiveInfoProvider);
    final theme = Theme.of(context);
    final images = _getImages();

    final useRowLayout = info.isDesktop || info.isTablet || info.isLandscape;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Image de fond
          if (images.isNotEmpty)
            Positioned.fill(
              child: PageView.builder(
                controller: _pageController,
                itemCount: images.length,
                onPageChanged: (index) {
                  _carouselController.reset();
                  _carouselController.repeat();
                },
                itemBuilder: (context, index) {
                  return SmartImage(
                    key: ValueKey('bg_image_$index'),
                    path: images[index],
                    fit: BoxFit.contain,
                    responsiveSize: ResponsiveImageSize.medium,
                    fallbackIcon: Icons.image_not_supported_outlined,
                  );
                },
              ),
            ),

          // Gradient overlay
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

          // Particules
          const Positioned.fill(
            child: ParticleBackground(
              particleCount: 40,
              particleColor: Colors.white,
              minSize: 1.5,
              maxSize: 4.0,
            ),
          ),

          if (images.length > 1)
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildPageIndicators(images.length),
              ),
            ),

          // Contenu principal
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
                      if (useRowLayout)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildTitle(theme, info)),
                            ResponsiveBox(width: info.isDesktop ? 48 : 32),
                            Expanded(
                              child: _buildSection("📜 Description",
                                  widget.project.points, theme, info),
                            ),
                          ],
                        )
                      else // Affichage en Colonne pour Mobile/Portrait
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTitle(theme, info),
                            ResponsiveBox(height: info.isMobile ? 32 : 48),
                            _buildSection("📜 Description",
                                widget.project.points, theme, info),
                          ],
                        ),
                      ResponsiveBox(height: 32),
                      WakaTimeConditionalWidget(
                        projectName: widget.project.title,
                        builder: (isTracked) {
                          if (!isTracked || !_hasProgrammingTag()) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            children: [
                              _buildWakaTimeSection(theme, info, useRowLayout),
                              ResponsiveBox(height: 32),
                            ],
                          );
                        },
                      ),
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
                        _buildKPISection(theme, info),
                      ],
                      if (images.length > 1)
                        const SizedBox(
                          height: 80,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bouton fermer
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

  Widget _buildPageIndicators(int count) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        final currentPage = _pageController.hasClients
            ? (_pageController.page ?? 0).round()
            : 0;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(count, (index) {
            final isActive = index == currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: isActive ? 24 : 8,
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        )
                      ]
                    : null,
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildTitle(ThemeData theme, ResponsiveInfo info) {
    return ResponsiveBox(
      padding: EdgeInsets.all(info.isMobile ? 24 : 32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.1), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText.titleLarge(
            widget.project.title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: info.isMobile ? 28 : 48,
            ),
          ),
          if (_hasProgrammingTag()) ...[
            const SizedBox(height: 12),
            SafeWakaTimeBadge(
              projectName: widget.project.title,
              showTimeSpent: true,
              showTrackingIndicator: true,
            ),
          ],
        ],
      ),
    );
  }

  // 🎯 Section WakaTime complète
  Widget _buildWakaTimeSection(
      ThemeData theme, ResponsiveInfo info, bool useRowLayout) {
    final statsAsync = ref.watch(wakaTimeStatsProvider('last_7_days'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText.titleLarge(
          "⏱️ Statistiques de développement",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: info.isMobile ? 20 : 24,
          ),
        ),
        const ResponsiveBox(height: 16),
        statsAsync.when(
          data: (stats) {
            if (stats == null) {
              return _buildEmptyWakaTimeCard(info);
            }

            final projectStat = stats.projects.firstWhere(
              (p) => p.name.toLowerCase().contains(
                    widget.project.title.toLowerCase(),
                  ),
              orElse: () => stats.projects.isNotEmpty
                  ? stats.projects.first
                  : WakaTimeProjectStat(
                      name: widget.project.title,
                      totalSeconds: 0,
                      percent: 0,
                      digital: '0:00',
                      text: '0 secs',
                    ),
            );

            Widget timeStatsColumn = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWakaTimeStat(
                  icon: Icons.timer,
                  label: 'Temps de développement',
                  value: projectStat.text,
                  color: Colors.blue,
                  info: info,
                ),
                const SizedBox(height: 16),
                _buildWakaTimeStat(
                  icon: Icons.trending_up,
                  label: 'Part du temps total',
                  value: '${projectStat.percent.toStringAsFixed(1)}%',
                  color: Colors.green,
                  info: info,
                ),
                const SizedBox(height: 16),
                _buildWakaTimeStat(
                  icon: Icons.schedule,
                  label: 'Format détaillé',
                  value: projectStat.digital,
                  color: Colors.orange,
                  info: info,
                ),
              ],
            );

            Widget languagesWidget =
                _buildLanguagesSection(stats.languages, info, useRowLayout);

            Widget content;

            if (useRowLayout && stats.languages.isNotEmpty) {
              // Alignement CÔTE À CÔTE : Temps (col 1), Graphique (col 2), Légende (col 3)
              content = Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Col 1: Temps de développement
                  Expanded(flex: 2, child: timeStatsColumn),
                  ResponsiveBox(width: 32),
                  // Col 2 & 3 : Graphique + Légende des langages
                  Expanded(flex: 3, child: languagesWidget),
                ],
              );
            } else {
              // Affichage en Colonne (Mobile/Portrait/Pas de langages)
              content = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  timeStatsColumn,
                  if (stats.languages.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 16),
                    languagesWidget,
                  ],
                ],
              );
            }

            return ResponsiveBox(
              padding: EdgeInsets.all(info.isMobile ? 20 : 32),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: content,
            );
          },
          loading: () => ResponsiveBox(
            padding: EdgeInsets.all(info.isMobile ? 20 : 32),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
          error: (err, _) => _buildErrorWakaTimeCard(info),
        ),
      ],
    );
  }

  Widget _buildWakaTimeStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required ResponsiveInfo info,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color.withValues(alpha: 0.5), size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResponsiveText.bodyMedium(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: info.isMobile ? 14 : 16,
                ),
              ),
              const SizedBox(height: 4),
              ResponsiveText.titleMedium(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: info.isMobile ? 18 : 22,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguagesSection(List<WakaTimeLanguage> languages,
      ResponsiveInfo info, bool useRowLayout) {
    final displayLanguages = languages.take(5).toList();
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.pink,
    ];

    final pieChartWidget = SizedBox(
      height: useRowLayout ? 250 : 300,
      width:
          useRowLayout ? double.infinity : null, // Fixe la largeur en mode Row
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pie Chart
          PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: info.isMobile ? 50 : 70,
              sections: displayLanguages.asMap().entries.map((entry) {
                final index = entry.key;
                final lang = entry.value;
                final color = colors[index % colors.length];

                return PieChartSectionData(
                  color: color,
                  value: lang.percent,
                  title: '',
                  radius: info.isMobile ? 60 : 80,
                );
              }).toList(),
            ),
          ),
          // Centre du pie chart
          Container(
            width: info.isMobile ? 100 : 140,
            height: info.isMobile ? 100 : 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.6),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: Center(
              child: ResponsiveText.bodyMedium(
                '${displayLanguages.length}\nLangages',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: info.isMobile ? 12 : 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final legendWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText.bodyLarge(
          'Légende',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: info.isMobile ? 16 : 18,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: displayLanguages.asMap().entries.map((entry) {
            final index = entry.key;
            final lang = entry.value;
            final color = colors[index % colors.length];

            return _buildLanguageLegendItem(
              lang: lang,
              color: color,
              info: info,
            );
          }).toList(),
        ),
      ],
    );

    if (useRowLayout) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Col 2.1: Pie Chart (prend 40% de l'espace alloué)
          Expanded(flex: 4, child: pieChartWidget),
          ResponsiveBox(width: 24),
          // Col 2.2: Légende des Langages (prend 60% de l'espace alloué)
          Expanded(flex: 6, child: legendWidget),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText.bodyLarge(
            'Langages utilisés',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: info.isMobile ? 16 : 18,
            ),
          ),
          const SizedBox(height: 16),
          pieChartWidget,
          const SizedBox(height: 24),
          legendWidget,
        ],
      );
    }
  }

  Widget _buildLanguageLegendItem({
    required WakaTimeLanguage lang,
    required Color color,
    required ResponsiveInfo info,
  }) {
    return Consumer(
      builder: (context, ref, child) {
        final logoPath =
            ref.watch(skillLogoPathProvider(lang.name.toLowerCase()));

        return Container(
          padding: EdgeInsets.all(info.isMobile ? 8 : 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.4),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo ou icône
              if (logoPath != null)
                SmartImage(
                  path: logoPath,
                  width: info.isMobile ? 24 : 32,
                  height: info.isMobile ? 24 : 32,
                  fit: BoxFit.contain,
                  enableShimmer: false,
                  useCache: true,
                  fallbackIcon: Icons.code,
                  fallbackColor: color,
                )
              else
                Icon(
                  Icons.code,
                  size: info.isMobile ? 24 : 32,
                  color: color,
                ),
              SizedBox(width: info.isMobile ? 8 : 12),
              // Nom et pourcentage
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ResponsiveText.bodySmall(
                    lang.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: info.isMobile ? 12 : 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  ResponsiveText.bodySmall(
                    '${lang.percent.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: info.isMobile ? 10 : 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyWakaTimeCard(ResponsiveInfo info) {
    return ResponsiveBox(
      padding: EdgeInsets.all(info.isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange.shade300, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: ResponsiveText.bodyMedium(
              'Aucune donnée WakaTime disponible pour ce projet',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: info.isMobile ? 14 : 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWakaTimeCard(ResponsiveInfo info) {
    return ResponsiveBox(
      padding: EdgeInsets.all(info.isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade300, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: ResponsiveText.bodyMedium(
              'Erreur lors du chargement des statistiques WakaTime',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: info.isMobile ? 14 : 16,
              ),
            ),
          ),
        ],
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

  Widget _buildKPISection(ThemeData theme, ResponsiveInfo info) {
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

    return ChartRendererBenchmark.renderChartsWithBenchmarks(
        _charts, info, yLabel);
  }
}
