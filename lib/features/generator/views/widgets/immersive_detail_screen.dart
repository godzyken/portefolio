import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/widgets/ui_widgets_extentions.dart';

import '../../../../core/affichage/colors_spec.dart';
import '../../../../core/provider/image_providers.dart';
import '../../../projets/providers/projects_extentions_providers.dart';
import '../../../projets/views/screens/iot_dashboard_screen.dart';
import '../../../projets/views/widgets/project_section.dart';
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
    with SingleTickerProviderStateMixin {
  late AnimationController _transitionController;
  List<ChartData> _charts = [];

  @override
  void initState() {
    super.initState();
    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _prepareChartData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(activeSectionProvider.notifier).update('hero');
      }
    });
  }

  @override
  void dispose() {
    _transitionController.dispose();
    super.dispose();
  }

  void _prepareChartData() {
    final resultats = widget.project.resultsMap;
    if (resultats == null) {
      _charts = [];
      return;
    }
    _charts = ChartDataFactory.createChartsFromResults(resultats);
  }

  List<ProjectSection> _buildSections() {
    final sections = <ProjectSection>[
      ProjectSection(
        id: 'hero',
        title: 'Présentation',
        icon: Icons.home,
        builder: _buildHeroContent,
      ),
    ];

    if (_hasProgrammingTag()) {
      sections.add(ProjectSection(
        id: 'wakatime',
        title: 'Développement',
        icon: Icons.code,
        builder: _buildWakaTimeContent,
      ));
    }

    if (_hasIoTFeatures()) {
      sections.add(ProjectSection(
        id: 'iot',
        title: 'IoT',
        icon: Icons.sensors,
        builder: _buildIoTContent,
      ));
    }

    if (widget.project.techDetails?.isNotEmpty ?? false) {
      sections.add(ProjectSection(
        id: 'tech',
        title: 'Techniques',
        icon: Icons.settings,
        builder: _buildTechDetailsContent,
      ));
    }

    if (widget.project.results?.isNotEmpty ?? false) {
      sections.add(ProjectSection(
        id: 'results',
        title: 'Résultats',
        icon: Icons.assessment,
        builder: _buildResultsContent,
      ));
    }

    return sections;
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
    final sections = _buildSections();
    final activeSection = ref.watch(activeSectionProvider);
    final showSidebar = info.size.width > 1200;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Fond
          _buildBackground(info),

          // Layout principal
          Positioned.fill(
            child: Row(
              children: [
                // Sidebar de navigation (desktop uniquement)
                if (showSidebar)
                  _buildNavigationSidebar(sections, activeSection, info),

                // Contenu principal
                Expanded(
                  child: _buildMainContent(sections, activeSection, info),
                ),
              ],
            ),
          ),

          // Bouton fermer
          Positioned(
            top: 24,
            right: 24,
            child: _buildCloseButton(),
          ),

          // Navigation mobile (bottom)
          if (!showSidebar && sections.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomNavigation(sections, activeSection, info),
            ),
        ],
      ),
    );
  }

  // ==========================================================================
  // COMPOSANTS DE NAVIGATION
  // ==========================================================================

  Widget _buildNavigationSidebar(
    List<ProjectSection> sections,
    String activeSection,
    ResponsiveInfo info,
  ) {
    return Container(
      width: 280,
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              // Header avec titre du projet
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ResponsiveText.titleMedium(
                      widget.project.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),
                    if (_hasProgrammingTag())
                      WakaTimeBadgeWidget(
                        projectName: widget.project.title,
                        variant: WakaTimeBadgeVariant.compact,
                      ),
                  ],
                ),
              ),

              // Liste des sections
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: sections.length,
                  itemBuilder: (context, index) {
                    final section = sections[index];
                    final isActive = section.id == activeSection;

                    return _buildSidebarItem(
                      section: section,
                      isActive: isActive,
                      onTap: () {
                        Future.microtask(() {
                          if (mounted) {
                            _navigateToSection(section.id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),

              // Indicateur de navigation
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.swipe,
                      size: 16,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 8),
                    ResponsiveText.bodySmall(
                      'Glissez pour naviguer',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarItem({
    required ProjectSection section,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color:
            isActive ? Colors.blue.withValues(alpha: 0.3) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? Colors.blue.withValues(alpha: 0.5)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                section.icon,
                color: isActive ? Colors.blue : Colors.white70,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ResponsiveText.bodyMedium(
                  section.title,
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.white70,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              if (isActive)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Colors.blue.withValues(alpha: 0.7),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(
    List<ProjectSection> sections,
    String activeSection,
    ResponsiveInfo info,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: sections.map((section) {
              final isActive = section.id == activeSection;
              return Expanded(
                child: InkWell(
                  onTap: () {
                    Future.microtask(() {
                      if (mounted) {
                        _navigateToSection(section.id);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isActive ? Colors.blue : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          section.icon,
                          color: isActive ? Colors.blue : Colors.white60,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        ResponsiveText.bodySmall(
                          section.title,
                          style: TextStyle(
                            color: isActive ? Colors.blue : Colors.white60,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // CONTENU PRINCIPAL
  // ==========================================================================

  Widget _buildMainContent(
    List<ProjectSection> sections,
    String activeSection,
    ResponsiveInfo info,
  ) {
    final section = sections.firstWhere(
      (s) => s.id == activeSection,
      orElse: () => sections.first,
    );

    final currentIndex = sections.indexOf(section);
    final canGoBack = currentIndex > 0;
    final canGoForward = currentIndex < sections.length - 1;

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0 && canGoBack) {
          // Swipe vers la droite = précédent
          Future.microtask(() {
            if (mounted) {
              _navigateToSection(sections[currentIndex - 1].id);
            }
          });
        } else if (details.primaryVelocity! < 0 && canGoForward) {
          // Swipe vers la gauche = suivant
          Future.microtask(() {
            if (mounted) {
              _navigateToSection(sections[currentIndex + 1].id);
            }
          });
        }
      },
      child: Stack(
        children: [
          // Contenu de la section
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: info.size.width > 1200 ? 1000 : double.infinity,
              ),
              child: Padding(
                padding: EdgeInsets.all(info.isMobile ? 16 : 32),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.1, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    key: ValueKey(activeSection),
                    child: section.builder(context, info),
                  ),
                ),
              ),
            ),
          ),

          // Flèches de navigation (desktop)
          if (info.size.width > 1200) ...[
            if (canGoBack)
              Positioned(
                left: 24,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _buildNavigationArrow(
                    icon: Icons.arrow_back_ios,
                    onTap: () {
                      Future.microtask(() {
                        if (mounted) {
                          _navigateToSection(sections[currentIndex - 1].id);
                        }
                      });
                    },
                  ),
                ),
              ),
            if (canGoForward)
              Positioned(
                right: 24,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _buildNavigationArrow(
                    icon: Icons.arrow_forward_ios,
                    onTap: () {
                      Future.microtask(() {
                        if (mounted) {
                          _navigateToSection(sections[currentIndex + 1].id);
                        }
                      });
                    },
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavigationArrow({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white70,
          size: 24,
        ),
      ),
    );
  }

  void _navigateToSection(String sectionId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(activeSectionProvider.notifier).update(sectionId);
      }
    });
  }

  // ==========================================================================
  // CONSTRUCTION DES SECTIONS
  // ==========================================================================

  Widget _buildHeroContent(BuildContext context, ResponsiveInfo info) {
    final images = _getImages();
    final useRowLayout = info.size.width > 900;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre avec WakaTime
          _buildCompactHeader(info),
          const SizedBox(height: 24),

          if (useRowLayout)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Description à gauche
                  Expanded(
                    flex: 4,
                    child: _buildDescription(info),
                  ),
                  const SizedBox(width: 24),
                  // Carousel à droite (taille optimale)
                  if (images.isNotEmpty)
                    Expanded(
                      flex: 6,
                      child: _buildOptimizedCarousel(images, info),
                    ),
                ],
              ),
            )
          else
            Column(
              children: [
                if (images.isNotEmpty) _buildOptimizedCarousel(images, info),
                const SizedBox(height: 24),
                _buildDescription(info),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCompactHeader(ResponsiveInfo info) {
    return Row(
      children: [
        Expanded(
          child: ResponsiveText.titleLarge(
            widget.project.title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: info.isMobile ? 20 : 28,
            ),
          ),
        ),
        if (_hasProgrammingTag()) ...[
          const SizedBox(width: 16),
          WakaTimeBadgeWidget(
            projectName: widget.project.title,
            variant: WakaTimeBadgeVariant.compact,
            showTrackingIndicator: true,
          ),
        ],
      ],
    );
  }

  Widget _buildOptimizedCarousel(List<String> images, ResponsiveInfo info) {
    return AspectRatio(
      aspectRatio: 16 / 9, // Ratio standard pour éviter l'étirement
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: PageView.builder(
            itemCount: images.length,
            itemBuilder: (context, index) {
              return SmartImage(
                path: images[index],
                fit: BoxFit.contain, // Contient l'image sans déformation
                responsiveSize: ResponsiveImageSize.large,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDescription(ResponsiveInfo info) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText.titleMedium(
            '📜 Description',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...widget.project.points.map((text) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: Colors.greenAccent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ResponsiveText.bodyMedium(
                        text,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildWakaTimeContent(BuildContext context, ResponsiveInfo info) {
    final statsAsync = ref.watch(wakaTimeStatsProvider('last_7_days'));

    return statsAsync.when(
      data: (stats) {
        if (stats == null || stats.projects.isEmpty) {
          return _buildEmptyWakaTimeCard(info);
        }

        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: info.size.height * 0.7),
            child: _buildCompactWakaTimeStats(stats, info),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => _buildErrorWakaTimeCard(info),
    );
  }

  Widget _buildCompactWakaTimeStats(WakaTimeStats stats, ResponsiveInfo info) {
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
            ));

    final languages = stats.languages;

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResponsiveText.titleMedium(
              '⏱️ Statistiques de développement',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Stats compactes
            _buildStatCard(
                'Temps de développement', projectStat.text, Icons.timer),
            const SizedBox(height: 12),
            _buildStatCard(
              'Part du temps total',
              '${projectStat.percent.toStringAsFixed(1)}%',
              Icons.trending_up,
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              'Format détaillé',
              projectStat.digital,
              Icons.schedule,
            ),
          ],
        ),
        SizedBox(width: info.isMobile ? 16 : 24),
        if (languages.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ResponsiveText.titleMedium(
                '⏱️ Statistiques de développement',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildLanguagesSection(languages, info),
            ],
          )
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResponsiveText.bodySmall(
                label,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 4),
              ResponsiveText.titleMedium(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIoTContent(BuildContext context, ResponsiveInfo info) {
    return Container(
      height: info.isMobile ? 400 : 500,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.cyan.withValues(alpha: 0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: const EnhancedIotDashboardScreen(),
      ),
    );
  }

  Widget _buildTechDetailsContent(BuildContext context, ResponsiveInfo info) {
    final techDetails = widget.project.techDetails!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText.titleMedium(
            '⚙️ Détails techniques',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: techDetails.entries.map((entry) {
              return Container(
                width: info.isMobile ? double.infinity : 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ResponsiveText.bodySmall(
                      entry.key.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ResponsiveText.bodyMedium(
                      '${entry.value}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsContent(BuildContext context, ResponsiveInfo info) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: info.size.height * 0.75),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResponsiveText.titleMedium(
              '🏁 Résultats & Impact',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Liste compacte des résultats
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.project.results!.map((result) {
                return _buildResultBadge(result);
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Charts optimisés
            if (_charts.isNotEmpty)
              Expanded(
                child: ChartRenderer.renderChartsWithBenchmarks(
                  _charts,
                  info,
                  (v) => Text(
                    "${v.toInt()}",
                    style: const TextStyle(fontSize: 10, color: Colors.white70),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Container _buildResultBadge(String result) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check, size: 14, color: Colors.green),
          const SizedBox(width: 6),
          ResponsiveText.bodySmall(
            result,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // HELPERS
  // ==========================================================================

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
                    Colors.black.withValues(alpha: 0.85),
                    Colors.black,
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

  Widget _buildLanguagesSection(
      List<WakaTimeLanguage> languages, ResponsiveInfo info) {
    final displayLanguages = languages.take(5).toList();
    final colors = ColorHelpers.chartColors;

    final sections = displayLanguages.asMap().entries.map((entry) {
      final index = entry.key;
      final lang = entry.value;
      final color = colors[index % colors.length];

      return PieChartSectionData(
          color: color,
          value: lang.percent,
          showTitle: false,
          radius: info.isMobile ? 50 : 65,
          borderSide: BorderSide(
              width: 2,
              color: color.withValues(alpha: 0.03),
              style: BorderStyle.solid,
              strokeAlign: 2.0),
          badgeWidget: ThreeDTechIcon(
            logoPath: lang.name,
            color: color,
            size: info.isMobile ? 38 : 48,
          ),
          badgePositionPercentageOffset: info.isMobile ? 0.5 : 1.5);
    }).toList();

    final pieChartWidget = SizedBox(
      height: info.isLandscape ? 200 : 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pie Chart
          PieChart(
            PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: info.isMobile ? 40 : 55,
                sections: sections,
                borderData: FlBorderData(
                    show: false,
                    border: Border(
                        bottom: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 2,
                    ))),
                startDegreeOffset: 20,
                pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {}),
                titleSunbeamLayout: true),
            curve: Curves.bounceInOut,
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

    if (info.isLandscape) {
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
}
