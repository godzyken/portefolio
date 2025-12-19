import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/colors_spec.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/provider/image_providers.dart';
import 'package:portefolio/core/ui/widgets/ui_widgets_extentions.dart';

import '../../../projets/providers/projects_extentions_providers.dart';
import '../../../projets/views/screens/iot_dashboard_screen.dart';
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
  late PageController _verticalController;
  late PageController _imageCarouselController;
  late AnimationController _autoPlayController;

  List<ChartData> _charts = [];

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    _verticalController = PageController();
    _imageCarouselController = PageController();

    _autoPlayController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _autoPlayController.addListener(() {
      if (_autoPlayController.value > 0.99 &&
          _imageCarouselController.hasClients) {
        final images = _getImages();
        if (images.length > 1) {
          int next =
              (_imageCarouselController.page!.round() + 1) % images.length;
          _imageCarouselController.animateToPage(next,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut);
        }
      }
    });

    _prepareChartData();
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
    _imageCarouselController.dispose();
    _verticalController.dispose();
    _autoPlayController.dispose();
    super.dispose();
  }

  List<String> _getImages() {
    final images = widget.project.cleanedImages ?? widget.project.image;
    return images ?? [];
  }

  bool _hasProgrammingTag() {
    final titleLower = widget.project.title.toLowerCase();

    final titleMatches = TechIconHelper.getProgrammingTags()
        .any((tag) => titleLower.contains(tag));

    final pointsMatch = widget.project.points.any((p) {
      return TechIconHelper.isProgrammingTech(p);
    });

    return titleMatches || pointsMatch;
  }

  bool _hasIoTFeatures() {
    final titleLower = widget.project.title.toLowerCase();
    final pointsText = widget.project.points.join(' ').toLowerCase();

    // Détection de mots-clés IoT
    final iotKeywords = [
      'iot',
      'capteur',
      'sensor',
      'température',
      'consommation',
      'vibration',
      'humidité',
      'esp8266',
      'raspberry',
      'temps réel',
      'monitoring',
      'surveillance',
      'chantier'
    ];

    return iotKeywords.any((keyword) =>
        titleLower.contains(keyword) || pointsText.contains(keyword));
  }

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(responsiveInfoProvider);
    final theme = Theme.of(context);
    final pages = _buildPages(info, theme);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Image de fond
          _buildBackground(info),

          // Contenu principal
          PageView.builder(
            controller: _verticalController,
            scrollDirection: Axis.vertical,
            itemCount: pages.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) =>
                _buildPageWrapper(pages[index], info),
          ),

          // Indicateurs de navigation (Points)
          if (pages.length > 1)
            Positioned(
              right: 24,
              top: 0,
              bottom: 0,
              child: _buildSideNavigator(pages.length),
            ),

          Positioned(
            top: 24,
            right: 24,
            child: _buildCloseButton(),
          ),

          if (_currentPage == 0)
            const Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Icon(Icons.keyboard_arrow_down,
                  color: Colors.white54, size: 40),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildPages(ResponsiveInfo info, ThemeData theme) {
    List<Widget> pages = [];

    // Page 1: Hero (Titre + Description + Images)
    pages.add(_buildHeroSection(info, theme));

    // Page 2: WakaTime
    if (_hasProgrammingTag()) pages.add(_buildWakaTimeSectionPage(info, theme));

    // Page 3: IoT
    if (_hasIoTFeatures()) pages.add(_buildIoTSectionPage(info, theme));

    // Page 4: Tech Details
    if (widget.project.techDetails?.isNotEmpty ?? false) {
      pages.add(_buildTechDetailsSectionPage(info, theme));
    }

    // Page 5: Résultats
    if (widget.project.results?.isNotEmpty ?? false) {
      pages.add(_buildResultsSectionPage(info, theme));
    }

    return pages;
  }

  // Wrapper pour centrer et limiter la largeur (L'aspect "Justifié")
  Widget _buildPageWrapper(Widget page, ResponsiveInfo info) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 1200, // Largeur max pour que ce soit joli sur Desktop
          maxHeight: info.isMobile ? double.infinity : 900,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: info.isMobile ? 24 : 48),
          child: page,
        ),
      ),
    );
  }

  Widget _buildHeroSection(ResponsiveInfo info, ThemeData theme) {
    final images = _getImages();
    final useRow = info.isDesktop && !info.isMobile;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCompactTitle(theme, info),
        const SizedBox(height: 40),
        if (useRow)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 4, child: _buildCompactDescription(theme, info)),
              const SizedBox(width: 48),
              if (images.isNotEmpty)
                Expanded(
                    flex: 6, child: _buildImageCarousel(images, info, theme)),
            ],
          )
        else
          Column(
            children: [
              if (images.isNotEmpty) _buildImageCarousel(images, info, theme),
              const SizedBox(height: 24),
              _buildCompactDescription(theme, info),
            ],
          ),
      ],
    );
  }

  Widget _buildWakaTimeSectionPage(ResponsiveInfo info, ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPageHeader("⏱️ Statistiques de développement", info, theme),
        const SizedBox(height: 32),
        _buildWakaTimeContent(info, theme, info.isDesktop),
      ],
    );
  }

  Widget _buildIoTSectionPage(ResponsiveInfo info, ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPageHeader("🛰️ Données du projet", info, theme),
        const SizedBox(height: 24),
        Container(
          height: info.isMobile ? 500 : 600,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border:
                Border.all(color: Colors.cyan.withValues(alpha: 0.3), width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: const EnhancedIotDashboardScreen(),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsSectionPage(ResponsiveInfo info, ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPageHeader("🏁 Résultats & Impact", info, theme),
        const SizedBox(height: 20),
        Flexible(
            child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // 1. Liste des livrables (ex: les 13 vidéos)
              _buildCompactBulletList(widget.project.results!, info),

              const SizedBox(height: 32),

              // 2. Les Graphiques (ChartRenderer)
              // On lui donne une contrainte de largeur pour éviter l'effet "géant"
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: ChartRenderer.renderChartsWithBenchmarks(
                    _charts,
                    info,
                    (v) => Text("${v.toInt()}",
                        style: const TextStyle(fontSize: 10))),
              ),
              const SizedBox(height: 40), // Marge de confort en bas
            ],
          ),
        )),
      ],
    );
  }

  // Widget pour rendre les listes de résultats (les strings dans ton JSON)
  Widget _buildCompactBulletList(List<String> results, ResponsiveInfo info) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: results
          .map((res) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_outline,
                        size: 14, color: Colors.greenAccent),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        res,
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: info.isMobile ? 11 : 13),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  // --- PETITS COMPOSANTS ---

  Widget _buildSideNavigator(int total) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        bool isActive = _currentPage == index;
        return GestureDetector(
          onTap: () => _verticalController.animateToPage(index,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOutCubic),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(vertical: 8),
            height: isActive ? 30 : 8,
            width: 8,
            decoration: BoxDecoration(
              color: isActive ? Colors.blueAccent : Colors.white24,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBackground(ResponsiveInfo info) {
    final images = _getImages();
    return Stack(
      children: [
        if (images.isNotEmpty)
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: SmartImage(path: images[0], fit: BoxFit.cover),
            ),
          ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCloseButton() {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: Colors.white10,
          child: IconButton(
            icon: const Icon(Icons.close, size: 28, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  // Composants compacts
  Widget _buildCompactTitle(ThemeData theme, ResponsiveInfo info) {
    return Container(
      padding: EdgeInsets.all(info.isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ResponsiveText(
            widget.project.title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: info.isMobile ? 20 : (info.isTablet ? 24 : 28),
            ),
          ),
          if (_hasProgrammingTag()) ...[
            const SizedBox(height: 8),
            WakaTimeBadgeWidget(
              projectName: widget.project.title,
              variant: WakaTimeBadgeVariant.simple,
              showTrackingIndicator: true,
              showLoadingFallback: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactDescription(ThemeData theme, ResponsiveInfo info) {
    return Container(
      padding: EdgeInsets.all(info.isMobile ? 16 : 20),
      constraints: BoxConstraints(
        maxHeight: info.isMobile ? 300 : 400,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ResponsiveText(
            "📜 Description",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...widget.project.points.take(4).map((text) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ResponsiveText(
                text,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.4,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(
      List<String> images, ResponsiveInfo info, ThemeData theme) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: info.isMobile ? 250 : 400,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            PageView.builder(
              controller: _imageCarouselController,
              itemCount: images.length,
              itemBuilder: (context, index) {
                return SmartImage(
                  key: ValueKey('carousel_image_$index'),
                  path: images[index],
                  fit: BoxFit.cover,
                  responsiveSize: ResponsiveImageSize.large,
                  fallbackIcon: Icons.image_not_supported_outlined,
                );
              },
            ),
            if (images.length > 1)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: _buildCarouselIndicators(images.length, theme),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselIndicators(int count, ThemeData theme) {
    return AnimatedBuilder(
      animation: _imageCarouselController,
      builder: (context, child) {
        final currentPage = _imageCarouselController.hasClients
            ? (_imageCarouselController.page ?? 0).round()
            : 0;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(count, (index) {
            final isActive = index == currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 6,
              width: isActive ? 20 : 6,
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildPageHeader(String title, ResponsiveInfo info, ThemeData theme) {
    return ResponsiveText(
      title,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: info.isMobile ? 18 : (info.isTablet ? 22 : 26),
      ),
    );
  }

  Widget _buildCompactTechDetails(
      Map<String, dynamic> details, ThemeData theme, ResponsiveInfo info) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: details.entries.map((entry) {
        return Container(
          width: info.isMobile ? (info.size.width / 2) - 32 : 220,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // LABEL (ex: "STACK", "DB", "OS")
              ResponsiveText(
                entry.key.toUpperCase(),
                style: TextStyle(
                  color: Colors.blue.shade300,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              // VALEUR (ex: "Flutter", "MySQL")
              ResponsiveText.displaySmall(
                "${entry.value}",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: info.isMobile ? 13 : 15,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWakaTimeContent(
      ResponsiveInfo info, ThemeData theme, bool useRowLayout) {
    final statsAsync = ref.watch(wakaTimeStatsProvider('last_7_days'));

    return statsAsync.when(
      data: (stats) {
        if (stats == null || stats.projects.isEmpty) {
          return _buildEmptyWakaTimeCard(info);
        }

        final projectStat = stats.projects.firstWhere(
          (p) => p.name.toLowerCase().contains(
                widget.project.title.toLowerCase(),
              ),
          orElse: () => WakaTimeProjectStat(
            name: widget.project.title,
            totalSeconds: 0,
            percent: 0,
            digital: '0:00',
            text: '0 secs',
          ),
        );
        final languages = stats.languages;

        return Container(
          padding: EdgeInsets.all(info.isMobile ? 16 : 24),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.blue.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: useRowLayout && languages.isNotEmpty
              ? IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 4,
                        child: _buildWakaTimeStats(projectStat, info),
                      ),
                      SizedBox(width: info.isMobile ? 16 : 24),
                      Expanded(
                        flex: 6,
                        child: _buildLanguagesSection(
                            languages, info, useRowLayout),
                      ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWakaTimeStats(projectStat, info),
                    if (languages.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 16),
                      _buildLanguagesSection(languages, info, useRowLayout),
                    ],
                  ],
                ),
        );
      },
      loading: () => Container(
        padding: EdgeInsets.all(info.isMobile ? 16 : 24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
      error: (err, _) => _buildErrorWakaTimeCard(info),
    );
  }

  Widget _buildWakaTimeStats(
      WakaTimeProjectStat projectStat, ResponsiveInfo info) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildWakaTimeStat(
          icon: Icons.timer,
          label: 'Temps de développement',
          value: projectStat.text,
          color: Colors.blue,
          info: info,
        ),
        const SizedBox(height: 12),
        _buildWakaTimeStat(
          icon: Icons.trending_up,
          label: 'Part du temps total',
          value: '${projectStat.percent.toStringAsFixed(1)}%',
          color: Colors.green,
          info: info,
        ),
        const SizedBox(height: 12),
        _buildWakaTimeStat(
          icon: Icons.schedule,
          label: 'Format détaillé',
          value: projectStat.digital,
          color: Colors.orange,
          info: info,
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
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color.withValues(alpha: 0.8), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ResponsiveText(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: info.isMobile ? 12 : 13,
                ),
              ),
              const SizedBox(height: 2),
              ResponsiveText(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: info.isMobile ? 16 : 18,
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
    final colors = ColorHelpers.chartColors;

    final sections = displayLanguages.asMap().entries.map((entry) {
      final index = entry.key;
      final lang = entry.value;
      final color = colors[index % colors.length];

      return PieChartSectionData(
          color: color,
          value: lang.percent,
          title: '',
          radius: info.isMobile ? 50 : 65,
          badgeWidget: ThreeDTechIcon(
            logoPath: lang.name,
            color: color,
            size: info.isMobile ? 38 : 48,
          ),
          badgePositionPercentageOffset: 1.5);
    }).toList();

    final pieChartWidget = SizedBox(
      height: useRowLayout ? 200 : 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pie Chart
          PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: info.isMobile ? 40 : 55,
              sections: sections,
            ),
          ),
          // Centre du pie chart
          Container(
            width: info.isMobile ? 80 : 110,
            height: info.isMobile ? 80 : 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.6),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: Center(
              child: ResponsiveText(
                '${displayLanguages.length}\nLangages',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: info.isMobile ? 11 : 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final legendWidget = Wrap(
      spacing: 10,
      runSpacing: 10,
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
    );

    if (useRowLayout) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Col 2.1: Pie Chart (prend 40% de l'espace alloué)
          Expanded(flex: 4, child: pieChartWidget),
          ResponsiveBox(width: 16),
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
              fontSize: info.isMobile ? 14 : 16,
            ),
          ),
          const SizedBox(height: 12),
          pieChartWidget,
          const SizedBox(height: 16),
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
          padding: EdgeInsets.all(info.isMobile ? 6 : 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo ou icône
              if (logoPath != null)
                SmartImage(
                  path: logoPath,
                  width: info.isMobile ? 20 : 24,
                  height: info.isMobile ? 20 : 24,
                  fit: BoxFit.contain,
                  enableShimmer: false,
                  useCache: true,
                  fallbackIcon: Icons.code,
                  fallbackColor: color,
                )
              else
                Icon(
                  Icons.code,
                  size: info.isMobile ? 20 : 24,
                  color: color,
                ),
              SizedBox(width: info.isMobile ? 6 : 8),
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
                      fontSize: info.isMobile ? 11 : 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  ResponsiveText.bodySmall(
                    '${lang.percent.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: info.isMobile ? 9 : 10,
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

  Widget _buildTechDetailsSectionPage(ResponsiveInfo info, ThemeData theme) {
    return SingleChildScrollView(
        // Sécurité anti-débordement
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Centre le contenu verticalement
          children: [
            // En-tête de section cohérent avec le reste
            const SizedBox(height: 60),
            _buildPageHeader("⚙️ Détails techniques", info, theme),
            const SizedBox(height: 8),
            ResponsiveText(
              "Stack logicielle et environnement système",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: info.isMobile ? 12 : 14,
              ),
            ),
            const SizedBox(height: 30),

            // Conteneur du contenu technique
            ConstrainedBox(
              constraints: const BoxConstraints(
                  maxWidth: 1000), // Empêche l'étalement excessif
              child: _buildCompactTechDetails(
                  widget.project.techDetails!, theme, info),
            ),
            const SizedBox(height: 60),
          ],
        ));
  }
}
