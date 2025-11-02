import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/widgets/responsive_text.dart';
import 'package:portefolio/core/ui/widgets/smart_image.dart';
import 'package:portefolio/features/experience/data/experiences_data.dart';
import 'package:portefolio/features/generator/views/widgets/generator_widgets_extentions.dart';

/// Écran de détails immersif pour une expérience
/// Affiche tous les détails avec animations et thème dynamique
class ImmersiveExperienceDetail extends ConsumerStatefulWidget {
  final Experience experience;

  const ImmersiveExperienceDetail({
    super.key,
    required this.experience,
  });

  @override
  ConsumerState<ImmersiveExperienceDetail> createState() =>
      _ImmersiveExperienceDetailState();
}

class _ImmersiveExperienceDetailState
    extends ConsumerState<ImmersiveExperienceDetail>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late ScrollController _scrollController;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _scrollOffset = _scrollController.offset;
        });
      });

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
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Extraction de la couleur dominante depuis les tags ou le logo
  Color _getThemeColor() {
    final tags = widget.experience.tags;
    if (tags.contains('Flutter')) return const Color(0xFF02569B);
    if (tags.contains('Angular')) return const Color(0xFFDD0031);
    if (tags.contains('Node.js')) return const Color(0xFF68A063);
    if (tags.contains('SIG')) return const Color(0xFF00796B);
    return const Color(0xFF6200EA); // Violet par défaut
  }

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(responsiveInfoProvider);
    final themeColor = _getThemeColor();
    final theme = Theme.of(context);

    return Theme(
      // Thème dynamique basé sur l'expérience
      data: theme.copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeColor,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.black,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Background avec image parallaxe ou particules
            _buildBackground(themeColor),

            // Contenu principal
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SafeArea(
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Header avec média en arrière-plan
                      _buildSliverHeader(info, themeColor),

                      // Contenu détaillé
                      SliverPadding(
                        padding: EdgeInsets.all(info.isMobile ? 24 : 48),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _buildInfoCard(theme, info),
                            const SizedBox(height: 24),
                            _buildObjectifsSection(theme),
                            const SizedBox(height: 24),
                            _buildMissionsSection(theme),
                            const SizedBox(height: 24),
                            _buildStackSection(theme, info),
                            const SizedBox(height: 24),
                            _buildResultatsSection(theme),
                            const SizedBox(height: 100),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bouton fermer
            Positioned(
              top: 16,
              right: 16,
              child: SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 32),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.6),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      _controller.reverse().then((_) {
                        if (mounted) Navigator.of(context).pop();
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground(Color themeColor) {
    final hasSIG = widget.experience.tags.contains('SIG');
    final hasImage = widget.experience.image.isNotEmpty;

    if (hasSIG) {
      // Fond avec carte SIG en opacité réduite
      return Positioned.fill(
        child: Opacity(
          opacity: 0.3,
          child: const SigDiscoveryMap(),
        ),
      );
    } else if (hasImage) {
      // Fond avec image parallaxe
      return Positioned.fill(
          child: Stack(
        fit: StackFit.expand,
        children: [
          Transform.translate(
            offset: Offset(0, _scrollOffset * 0.5),
            child: SmartImage(
              path: widget.experience.image,
              fit: BoxFit.cover,
            ),
          ),
          ResponsiveBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.4), // Moins sombre en haut
                  Colors.black.withValues(
                      alpha: 0.8), // Plus sombre en bas où le texte défile
                ],
                stops: const [
                  0.0,
                  0.7
                ], // Le dégradé commence à s'assombrir à 70% de la page
              ),
            ),
            child: ClipRect(
              // Le BackdropFilter doit être dans un ClipRect
              child: BackdropFilter(
                filter: ImageFilter.blur(
                    sigmaX: 5.0, sigmaY: 5.0), // Ajustez la force du flou
                child: Container(
                  color: Colors.black.withValues(alpha: 0.1),
                ),
              ),
            ),
          )
        ],
      ));
    } else {
      // Fond avec particules animées
      return Positioned.fill(
        child: ParticleBackground(
          particleCount: 50,
          particleColor: themeColor,
          minSize: 2.0,
          maxSize: 6.0,
        ),
      );
    }
  }

  Widget _buildSliverHeader(ResponsiveInfo info, Color themeColor) {
    return SliverAppBar(
      expandedHeight: info.isMobile ? 200 : 300,
      pinned: true,
      backgroundColor: Colors.black.withValues(alpha: 0.8),
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.experience.entreprise,
          style: TextStyle(
            fontSize: info.isMobile ? 18 : 24,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.8),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                themeColor.withValues(alpha: 0.3),
                Colors.black.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: widget.experience.logo.isNotEmpty
              ? Center(
                  child: SmartImage(
                    path: widget.experience.logo,
                    responsiveSize: ResponsiveImageSize.medium,
                    fit: BoxFit.contain,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme, ResponsiveInfo info) {
    return Container(
      padding: EdgeInsets.all(info.isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.experience.poste.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.work_outline,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.experience.poste,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          if (widget.experience.periode.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: theme.colorScheme.primary.withValues(alpha: 0.7),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  widget.experience.periode,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          if (widget.experience.contexte.isNotEmpty) ...[
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            Text(
              widget.experience.contexte,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.6,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildObjectifsSection(ThemeData theme) {
    if (widget.experience.objectifs.isEmpty) return const SizedBox.shrink();

    return _buildSection(
      theme: theme,
      icon: Icons.flag_outlined,
      title: 'Objectifs',
      items: widget.experience.objectifs,
    );
  }

  Widget _buildMissionsSection(ThemeData theme) {
    if (widget.experience.missions.isEmpty) return const SizedBox.shrink();

    return _buildSection(
      theme: theme,
      icon: Icons.task_alt,
      title: 'Missions',
      items: widget.experience.missions,
    );
  }

  Widget _buildResultatsSection(ThemeData theme) {
    if (widget.experience.resultats.isEmpty) return const SizedBox.shrink();

    return _buildSection(
      theme: theme,
      icon: Icons.trending_up,
      title: 'Résultats',
      items: widget.experience.resultats,
    );
  }

  Widget _buildSection({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
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
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          height: 1.5,
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

  Widget _buildStackSection(ThemeData theme, ResponsiveInfo info) {
    if (widget.experience.stack.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
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
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.code,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Stack Technique',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.experience.stack.entries
                .expand((entry) => entry.value.map((tech) => Chip(
                      avatar: Icon(
                        _getTechIcon(tech),
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      label: Text(tech),
                      backgroundColor:
                          theme.colorScheme.primary.withValues(alpha: 0.1),
                      side: BorderSide(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    )))
                .toList(),
          ),
        ],
      ),
    );
  }

  IconData _getTechIcon(String tech) {
    final techLower = tech.toLowerCase();
    if (techLower.contains('flutter') || techLower.contains('dart')) {
      return Icons.phone_android;
    }
    if (techLower.contains('angular') ||
        techLower.contains('react') ||
        techLower.contains('vue')) {
      return Icons.web;
    }
    if (techLower.contains('node') || techLower.contains('express')) {
      return Icons.dns;
    }
    if (techLower.contains('firebase') || techLower.contains('cloud')) {
      return Icons.cloud;
    }
    if (techLower.contains('database') ||
        techLower.contains('sql') ||
        techLower.contains('mongo')) {
      return Icons.storage;
    }
    return Icons.star;
  }
}
