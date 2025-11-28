import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/widgets/responsive_text.dart';
import 'package:portefolio/core/ui/widgets/smart_image.dart';

import '../../../projets/data/project_data.dart';
import '../../../projets/providers/projects_wakatime_service_provider.dart';
import '../../data/chart_data.dart';
import '../../services/wakatime_service.dart';
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
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late ScrollController _scrollController;
  late Timer _imageTimer;

  int _currentImageIndex = 0;

  List<ChartData> _charts = [];

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
      _charts = [];
      return;
    }

    _charts = ChartDataFactory.createChartsFromResults(resultats);
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

  bool _hasProgrammingTag() {
    const programmingTags = ['e-commerce', 'flutter', 'angular', 'digital'];
    final titleLower = widget.project.title.toLowerCase();
    return programmingTags.any((tag) => titleLower.contains(tag));
  }

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(responsiveInfoProvider);
    final theme = Theme.of(context);
    final randomImage = _getCurrentImage();
    final isTracked = ref.watch(isProjectTrackedProvider(widget.project.title));

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
                  fit: BoxFit.contain,
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

                      // 🎯 Section WakaTime si projet de programmation
                      if (_hasProgrammingTag() && isTracked) ...[
                        _buildWakaTimeSection(theme, info),
                        ResponsiveBox(height: 32),
                      ],

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
                        _buildKPISection(theme, info),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Badge WakaTime floating en haut à gauche
          if (_hasProgrammingTag() && isTracked)
            Positioned(
              top: 16,
              left: 16,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: WakaTimeDetailedBadge(
                  projectName: widget.project.title,
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

  // 🎯 Section WakaTime complète
  Widget _buildWakaTimeSection(ThemeData theme, ResponsiveInfo info) {
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
              child: Column(
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
                  if (stats.languages.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 16),
                    _buildLanguagesSection(stats.languages, info),
                  ],
                ],
              ),
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

  Widget _buildLanguagesSection(
      List<WakaTimeLanguage> languages, ResponsiveInfo info) {
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
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: languages.take(5).map((lang) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ResponsiveText.bodySmall(
                    lang.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  ResponsiveText.bodySmall(
                    '${lang.percent.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
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
