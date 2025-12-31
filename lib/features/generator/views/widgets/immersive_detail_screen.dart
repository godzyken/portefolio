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
import 'benchmark_widgets.dart';

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

  void _navigateToSection(String sectionId) {
    // On s'assure que la modification se fait en dehors du build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(activeSectionProvider.notifier).update(sectionId);
      }
    });
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

    // NOUVELLE SECTION Infrastructure
    if (widget.project.development != null &&
        widget.project.development!.isNotEmpty) {
      sections.add(ProjectSection(
        id: 'infrastructure',
        title: 'Infrastructure',
        icon: Icons.architecture,
        builder: _buildInfrastructureContent,
      ));
    }

    // Section Analyse économique (avec graphiques)
    if (widget.project.development != null &&
        widget.project.development!.isNotEmpty) {
      sections.add(ProjectSection(
        id: 'economic',
        title: 'Analyse économique',
        icon: Icons.bar_chart_rounded,
        builder: _buildEconomicAnalysisContent,
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
      behavior: HitTestBehavior.opaque, // Améliore la détection du swipe
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0 && canGoBack) {
          _navigateToSection(sections[currentIndex - 1].id);
        } else if (details.primaryVelocity! < 0 && canGoForward) {
          _navigateToSection(sections[currentIndex + 1].id);
        }
      },
      child: Stack(
        children: [
          // CONTENU PRINCIPAL
          Positioned.fill(
            // Utilise tout l'espace disponible
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: info.isLandscape ? 1100 : double.infinity,
                  // On force la hauteur à prendre tout l'espace disponible moins les paddings
                  maxHeight: info.size.height,
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    info.isMobile
                        ? 16
                        : 60, // Plus de padding sur les côtés pour les flèches
                    info.isMobile ? 16 : 32,
                    info.isMobile ? 16 : 60,
                    info.isMobile ? 16 : 32,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    // Important pour que le switcher prenne toute la place
                    layoutBuilder:
                        (Widget? currentChild, List<Widget> previousChildren) {
                      return Stack(
                        children: <Widget>[
                          ...previousChildren,
                          if (currentChild != null) currentChild,
                        ],
                      );
                    },
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(
                                0.05, 0), // Translation plus subtile
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: SizedBox.expand(
                      // Force la section à remplir l'espace
                      key: ValueKey(activeSection),
                      child: section.builder(context, info),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // FLÈCHES DE NAVIGATION (Desktop)
          if (info.size.width > 1200) ...[
            if (canGoBack)
              _buildFixedArrow(Icons.arrow_back_ios, true, () {
                _navigateToSection(sections[currentIndex - 1].id);
              }),
            if (canGoForward)
              _buildFixedArrow(Icons.arrow_forward_ios, false, () {
                _navigateToSection(sections[currentIndex + 1].id);
              }),
          ],
        ],
      ),
    );
  }

// Helper pour les flèches pour éviter la répétition de code
  Widget _buildFixedArrow(IconData icon, bool isLeft, VoidCallback onTap) {
    return Positioned(
      left: isLeft ? 24 : null,
      right: isLeft ? null : 24,
      top: 0,
      bottom: 0,
      child: Center(
        child: _buildNavigationArrow(
          icon: icon,
          onTap: onTap,
        ),
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

          /*     // ✅ AJOUT : Afficher les stats WakaTime si le projet est tracké
          if (_hasProgrammingTag()) ...[
            Consumer(
              builder: (context, ref, child) {
                final isTracked =
                    ref.watch(isProjectTrackedProvider(widget.project.title));

                if (isTracked) {
                  return Column(
                    children: [
                      _buildWakaTimeContent(context, info),
                      const SizedBox(height: 24),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],*/

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

        final projectStat =
            stats.projects.cast<WakaTimeProjectStat?>().firstWhere(
          (p) {
            if (p == null) return false;
            final cleanApiName =
                p.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
            final cleanLocalName = widget.project.title
                .toLowerCase()
                .replaceAll(RegExp(r'[^a-z0-9]'), '');
            return cleanApiName.contains(cleanLocalName) ||
                cleanLocalName.contains(cleanApiName);
          },
          orElse: () => null, // ✅ Retourner null au lieu du premier projet
        );

        // Si aucun projet trouvé, afficher le message approprié
        if (projectStat == null) {
          return _buildEmptyWakaTimeCard(info);
        }

        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: info.size.height * 0.7),
            child: _buildCompactWakaTimeStats(stats, projectStat, info),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => _buildErrorWakaTimeCard(info),
    );
  }

  Widget _buildCompactWakaTimeStats(WakaTimeStats stats,
      WakaTimeProjectStat projectStat, ResponsiveInfo info) {
    final languages = stats.languages;

    return Row(
      children: [
        Expanded(
          flex: info.isMobile ? 1 : 2,
          child: Column(
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
        ),
        SizedBox(width: info.isMobile ? 16 : 24),
        if (languages.isNotEmpty)
          Expanded(
              flex: info.isMobile ? 1 : 3,
              child: Column(
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
              ))
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

  Widget _buildEconomicAnalysisContent(
      BuildContext context, ResponsiveInfo info) {
    final dev = widget.project.development!;
    final charts = ChartDataFactory.createChartsFromDevelopment(dev);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText.titleMedium(
          '💼 Analyse Économique & ROI',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Liste compacte des résultats économiques clés (badges horizontaux)
        if (dev.containsKey('6_roi_global'))
          Container(
            height: 60,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _getEconomicBadges(dev).length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final badge = _getEconomicBadges(dev)[index];
                return _buildEconomicBadge(badge['label']!, badge['value']!);
              },
            ),
          ),

        // Graphiques en grille compacte avec scroll (même logique que results)
        Expanded(
          child: charts.isEmpty
              ? Center(
                  child: ResponsiveText.bodyMedium(
                    'Aucun graphique économique disponible',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                )
              : _buildCompactEconomicChartsGrid(charts, info),
        ),
      ],
    );
  }

  List<Map<String, String>> _getEconomicBadges(Map<String, dynamic> dev) {
    final badges = <Map<String, String>>[];

    if (dev.containsKey('6_roi_global')) {
      final roi = dev['6_roi_global'] as Map<String, dynamic>;
      badges
          .add({'label': '💰 ROI 3 ans', 'value': roi['roi_3_ans'].toString()});
      badges.add({'label': '💶 Gains', 'value': '${roi['gains_totaux']}€'});
      badges.add({'label': '💸 Coûts', 'value': '${roi['couts_totaux']}€'});
    }

    if (dev.containsKey('7_interpretation_business')) {
      final business = dev['7_interpretation_business'] as Map<String, dynamic>;
      if (business.containsKey('temps_economise_total')) {
        badges.add({
          'label': '⏰ Temps gagné',
          'value': business['temps_economise_total'].toString()
        });
      }
      if (business.containsKey('reactivite')) {
        badges.add({
          'label': '⚡ Réactivité',
          'value': business['reactivite'].toString()
        });
      }
    }

    return badges;
  }

  Widget _buildEconomicBadge(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ResponsiveText.bodySmall(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(width: 6),
          ResponsiveText.bodySmall(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactEconomicChartsGrid(
      List<ChartData> charts, ResponsiveInfo info) {
    int crossAxisCount;
    if (info.size.width > 1200) {
      crossAxisCount = 4;
    } else if (info.size.width > 800) {
      crossAxisCount = 3;
    } else if (info.size.width > 600) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 1;
    }

    double aspectRatio = (info.size.width / crossAxisCount) / 400;
    aspectRatio = aspectRatio.clamp(1.1, 10.0);

    double getChartHeight(ChartData chart) {
      switch (chart.type) {
        case ChartType.kpiCards:
          return info.isMobile ? 200 : 250;
        case ChartType.lineChart:
        case ChartType.barChart:
          return info.isMobile ? 300 : 350;
        default:
          return info.isMobile ? 300 : 350;
      }
    }

    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: charts.length,
      itemBuilder: (context, index) {
        final chart = charts[index];
        return _buildChartCard(chart, info, getChartHeight(chart));
      },
    );
  }

  Widget _buildResultsContent(BuildContext context, ResponsiveInfo info) {
    int count =
        widget.project.results!.length + widget.project.resultsMap!.length;
    return Column(
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

        // Liste compacte des résultats (badges horizontaux)
        if (widget.project.results != null &&
            widget.project.results!.isNotEmpty)
          Container(
            height: 60, // Hauteur fixe pour le scroll horizontal
            margin: const EdgeInsets.only(bottom: 16),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: count,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return _buildResultBadge(result(index));
              },
            ),
          ),

        // Graphiques en grille compacte avec scroll
        Expanded(
          child: _charts.isEmpty
              ? Center(
                  child: ResponsiveText.bodyMedium(
                    'Aucun graphique disponible',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                )
              : _buildCompactChartsGrid(info),
        ),
      ],
    );
  }

  String result(int index) {
    return widget.project.results![index] +
        widget.project.resultsMap!.length.toString();
  }

  // 🆕 Grille de graphiques compacte avec gestion responsive
  Widget _buildCompactChartsGrid(ResponsiveInfo info) {
    // Déterminer le nombre de colonnes selon la taille d'écran
    int crossAxisCount;
    if (info.size.width > 1200) {
      crossAxisCount = 4;
    } else if (info.size.width > 800) {
      crossAxisCount = 3; // Idéal pour iPad Pro paysage
    } else if (info.size.width > 600) {
      crossAxisCount = 2; // iPad Pro portrait / Split view
    } else {
      crossAxisCount = 1;
    }

    double aspectRatio = (info.size.width / crossAxisCount) / 400;
    aspectRatio = aspectRatio.clamp(1.1, 10.0);

    // Hauteur adaptative selon le type de chart
    double getChartHeight(ChartData chart) {
      switch (chart.type) {
        case ChartType.kpiCards:
          return info.isMobile ? 200 : 250;

        case ChartType.lineChart:
        case ChartType.pieChart:
          return info.isMobile ? 300 : 350;

        case ChartType.benchmarkGlobal:
        case ChartType.benchmarkRadar:
          return info.isMobile ? 250 : 300;

        case ChartType.benchmarkComparison:
        case ChartType.benchmarkTable:
          return info.isMobile ? 400 : 500;

        default:
          return info.isMobile ? 300 : 350;
      }
    }

    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _charts.length,
      itemBuilder: (context, index) {
        final chart = _charts[index];
        return _buildChartCard(chart, info, getChartHeight(chart));
      },
    );
  }

// 🆕 Card individuelle pour chaque graphique
  Widget _buildChartCard(ChartData chart, ResponsiveInfo info, double height) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre du chart
          Row(
            children: [
              Expanded(
                child: ResponsiveText.bodyLarge(
                  chart.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Bouton pour voir en plein écran
              IconButton(
                icon: const Icon(Icons.fullscreen, size: 18),
                color: Colors.white70,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _showChartFullscreen(chart, info),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Contenu du chart (limité en hauteur)
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  height: constraints.maxHeight,
                  child: _buildChartContent(chart, info),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

// 🆕 Contenu du graphique optimisé
  Widget _buildChartContent(ChartData chart, ResponsiveInfo info) {
    switch (chart.type) {
      case ChartType.kpiCards:
        return _buildCompactKPICards(chart.kpiValues!, info);

      case ChartType.benchmarkGlobal:
        return BenchmarkGlobalWidget(
          benchmark: chart.benchmarkInfo!,
          info: info,
        );

      case ChartType.benchmarkComparison:
        return BenchmarkComparisonWidget(
          benchmarks: chart.benchmarkComparison!,
          info: info,
        );

      case ChartType.benchmarkRadar:
        return BenchmarkRadarWidget(
          benchmark: chart.benchmarkInfo!,
          info: info,
        );

      case ChartType.benchmarkTable:
        return SingleChildScrollView(
          child: BenchmarkTableWidget(
            benchmarks: chart.benchmarkComparison!,
            info: info,
          ),
        );

      case ChartType.barChart:
        return _buildCompactBarChart(chart.barGroups!, info);

      case ChartType.lineChart:
        return _buildCompactLineChart(
          chart.lineSpots!,
          chart.xLabels!,
          chart.lineColor!,
          info,
        );

      case ChartType.pieChart:
        return _buildCompactPieChart(chart.pieSections!, info);
    }
  }

// 🆕 KPI Cards version compacte
  Widget _buildCompactKPICards(Map<String, String> kpis, ResponsiveInfo info) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: info.isMobile ? 2 : 3,
        childAspectRatio: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: kpis.length,
      itemBuilder: (context, index) {
        final entry = kpis.entries.elementAt(index);
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

// 🆕 BarChart version compacte
  Widget _buildCompactBarChart(
      List<BarChartGroupData> barGroups, ResponsiveInfo info) {
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
      ),
    );
  }

// 🆕 LineChart version compacte
  Widget _buildCompactLineChart(
    List<FlSpot> spots,
    List<Widget> xLabels,
    Color color,
    ResponsiveInfo info,
  ) {
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

// 🆕 PieChart version compacte
  Widget _buildCompactPieChart(
      List<PieChartSectionData> sections, ResponsiveInfo info) {
    return PieChart(
      PieChartData(
        sections: sections,
        sectionsSpace: 2,
        centerSpaceRadius: info.isMobile ? 25 : 35,
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            // Optionnel: ajouter une interaction
          },
        ),
      ),
    );
  }

// 🆕 Afficher un graphique en plein écran
  void _showChartFullscreen(ChartData chart, ResponsiveInfo info) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: info.size.width * 0.9,
            maxHeight: info.size.height * 0.8,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ResponsiveText.titleLarge(
                      chart.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _buildChartContent(chart, info),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultBadge(String result) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check, size: 12, color: Colors.green),
          const SizedBox(width: 4),
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

  Widget _buildInfrastructureContent(
      BuildContext context, ResponsiveInfo info) {
    final dev = widget.project.development!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText.titleMedium(
            '🏗️ Infrastructure & Architecture',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Hypothèses du projet
          if (dev.containsKey('1_hypotheses'))
            _buildInfrastructureSection(
              '📋 Hypothèses du projet',
              dev['1_hypotheses'] as Map<String, dynamic>,
              Icons.article_outlined,
              Colors.blue,
            ),

          const SizedBox(height: 20),

          // Gains de productivité
          if (dev.containsKey('2_gains_productivite'))
            _buildInfrastructureSection(
              '⚡ Gains de productivité',
              dev['2_gains_productivite'] as Map<String, dynamic>,
              Icons.trending_up,
              Colors.green,
            ),

          const SizedBox(height: 20),

          // Autres gains
          if (dev.containsKey('3_autres_gains'))
            _buildInfrastructureSection(
              '💎 Autres gains',
              dev['3_autres_gains'] as Map<String, dynamic>,
              Icons.emoji_events,
              Colors.amber,
            ),

          const SizedBox(height: 20),

          // Coûts
          if (dev.containsKey('4_couts'))
            _buildInfrastructureSection(
              '💰 Structure des coûts',
              dev['4_couts'] as Map<String, dynamic>,
              Icons.account_balance_wallet,
              Colors.orange,
            ),

          const SizedBox(height: 20),

          // Synthèse annuelle
          if (dev.containsKey('5_synthese_annuelle'))
            _buildSyntheseAnnuelle(
              dev['5_synthese_annuelle'] as List<dynamic>,
              info,
            ),
        ],
      ),
    );
  }

  Widget _buildInfrastructureSection(
    String title,
    Map<String, dynamic> data,
    IconData icon,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ResponsiveText.titleMedium(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...data.entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ResponsiveText.bodySmall(
                            _formatKey(entry.key),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          ResponsiveText.bodyMedium(
                            entry.value.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSyntheseAnnuelle(List<dynamic> synthese, ResponsiveInfo info) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.withValues(alpha: 0.2),
            Colors.blue.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.purple.withValues(alpha: 0.4),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.calendar_today,
                    color: Colors.purple, size: 24),
              ),
              const SizedBox(width: 12),
              const ResponsiveText.titleMedium(
                '📊 Synthèse annuelle',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...synthese.asMap().entries.map((entry) {
            final index = entry.key;
            final year = entry.value as Map<String, dynamic>;
            return _buildYearCard(year, index, info);
          }),
        ],
      ),
    );
  }

  Widget _buildYearCard(
      Map<String, dynamic> year, int index, ResponsiveInfo info) {
    final colors = [Colors.green, Colors.blue, Colors.purple];
    final color = colors[index % colors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText.titleSmall(
            'Année ${year['annee']} - ${year['intervenants']} intervenants',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricColumn(
                    'Gains', '${year['gains']}€', Colors.green),
              ),
              Expanded(
                child: _buildMetricColumn(
                    'Coûts', '${year['couts']}€', Colors.orange),
              ),
              Expanded(
                child: _buildMetricColumn(
                    'Net', '${year['resultat_net']}€', color),
              ),
              Expanded(
                child: _buildMetricColumn('ROI', year['roi'], Colors.amber),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value, Color color) {
    return Column(
      children: [
        ResponsiveText.bodySmall(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        ResponsiveText.bodyMedium(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  String _formatKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) =>
            word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
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
