import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/widgets/responsive_text.dart';
import 'package:portefolio/core/ui/widgets/smart_image.dart';

import '../../../projets/data/project_data.dart';
import '../../data/chart_data.dart';
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

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(responsiveInfoProvider);
    final theme = Theme.of(context);
    final randomImage = _getCurrentImage();

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
                        _buildKPISection(theme, info),
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

    // SIMPLIFIÉ : Un seul appel !
    return ChartRenderer.renderCharts(_charts, info, yLabel);
  }
}
