import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';
import 'package:portefolio/features/experience/data/experiences_data.dart';
import 'package:portefolio/features/generator/views/generator_widgets_extentions.dart';

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
  bool _isExiting = false;
  bool _isMapLoading = true;
  bool _hasMapError = false;

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

    if (widget.experience.tags.contains('SIG')) {
      _loadMap();
    }
  }

  Future<void> _loadMap() async {
    try {
      // Laisser le temps à la carte de se charger
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _isMapLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isMapLoading = false;
          _hasMapError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.stop();
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

  Widget _buildLogo3D(String logoPath, Color themeColor, double size) {
    return Transform(
      // Transformation 3D pour le logo
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001) // Perspective
        ..rotateX(0.08) // Légère inclinaison vers le haut
        ..rotateY(-0.08), // Légère inclinaison vers la gauche
      alignment: Alignment.center,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: themeColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20), // Coins arrondis
          // Ombres pour simuler la profondeur et le relief
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.8),
              blurRadius: 20,
              offset: const Offset(8, 8),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(-4, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: SmartImage(
          path: logoPath,
          responsiveSize: ResponsiveImageSize.medium,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
          enableShimmer: true,
          autoPreload: true,
          color: Colors.white.withValues(alpha: 0.9),
          colorBlendMode: BlendMode.modulate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(responsiveInfoProvider);
    final themeColor = _getThemeColor();
    final baseTheme = ThemeData.dark(useMaterial3: true);
    final immersiveTheme = baseTheme.copyWith(
      scaffoldBackgroundColor: Colors.black,
      cardColor: Colors.white.withValues(alpha: 0.08),
      textTheme: baseTheme.textTheme.apply(fontFamily: 'Montserrat'),
      colorScheme: ColorScheme.fromSeed(
        seedColor: themeColor,
        brightness: Brightness.dark,
      ),
    );

    return Theme(
      data: immersiveTheme,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            _buildBackground(themeColor),
            _buildGlassOverlay(themeColor),
            // Contenu principal
            FadeTransition(
              opacity: _fadeAnimation,
              child: IgnorePointer(
                  ignoring: _isExiting ||
                      _controller.status == AnimationStatus.reverse,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SafeArea(
                      child: CustomScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          _buildSliverHeader(info, themeColor),

                          // Contenu détaillé
                          SliverPadding(
                            padding: EdgeInsets.all(info.isMobile ? 24 : 48),
                            sliver: SliverList(
                              delegate: SliverChildListDelegate([
                                _buildInfoCard(immersiveTheme, info),
                                const SizedBox(height: 24),
                                _buildObjectifsSection(immersiveTheme),
                                const SizedBox(height: 24),
                                _buildMissionsSection(immersiveTheme),
                                const SizedBox(height: 24),
                                _buildStackSection(immersiveTheme, info),
                                const SizedBox(height: 24),
                                _buildResultatsSection(immersiveTheme),
                                const SizedBox(height: 100),
                              ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
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
                      setState(() {
                        _isExiting = true;
                      });
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
    if (_isExiting) return Container(color: Colors.black);

    final hasSIG = widget.experience.tags.contains('SIG');
    final hasImage = widget.experience.image.isNotEmpty;

    if (hasSIG) {
      // ✅ Afficher un loader pendant le chargement de la carte
      if (_isMapLoading) {
        return Positioned.fill(
          child: Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.teal),
            ),
          ),
        );
      }

      // ✅ Afficher une erreur si la carte a échoué
      if (_hasMapError) {
        return Positioned.fill(
          child: Container(
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.map_outlined, size: 64, color: Colors.teal),
                  const SizedBox(height: 16),
                  const Text(
                    'Erreur de chargement de la carte',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isMapLoading = true;
                        _hasMapError = false;
                      });
                      _loadMap();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      // ✅ Carte chargée avec succès
      return Positioned.fill(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (!mounted || constraints.maxWidth <= 0) {
              return const SizedBox.shrink();
            }

            return Opacity(
              opacity: 0.3,
              child: SigDiscoveryMap(
                key: ValueKey('map_detail_${widget.experience.id}'),
              ),
            );
          },
        ),
      );
    } else if (hasImage) {
      return Positioned.fill(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Transform.translate(
              offset: Offset(0, _scrollOffset * 0.5),
              child: SmartImage(
                path: widget.experience.image,
                fit: BoxFit.cover,
                enableShimmer: true,
              ),
            ),
            ResponsiveBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.black.withValues(alpha: 0.8),
                  ],
                  stops: const [0.0, 0.7],
                ),
              ),
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.1),
                  ),
                ),
              ),
            )
          ],
        ),
      );
    } else {
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

  Widget _buildGlassOverlay(Color themeColor) {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          color: themeColor.withValues(alpha: 0.05),
        ),
      ),
    );
  }

  Widget _buildSliverHeader(ResponsiveInfo info, Color themeColor) {
    final logoSize = info.isMobile ? 100.0 : 150.0;

    return SliverAppBar(
      expandedHeight: info.isMobile ? 200 : 300,
      pinned: true,
      backgroundColor: Colors.black.withValues(alpha: 0.8),
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        title: ResponsiveText(
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
                  child: _buildLogo3D(
                    widget.experience.logo,
                    themeColor,
                    logoSize,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme, ResponsiveInfo info) {
    return ExperienceInfoCard(
      theme: theme,
      info: info,
      experience: widget.experience,
    );
  }

  Widget _buildObjectifsSection(ThemeData theme) {
    if (widget.experience.objectifs.isEmpty) return const SizedBox.shrink();

    return SectionBuilder.simple(
      icon: Icons.flag_outlined,
      title: 'Objectifs',
      child: BulletListBuilder(items: widget.experience.objectifs),
    );
  }

  Widget _buildMissionsSection(ThemeData theme) {
    if (widget.experience.missions.isEmpty) return const SizedBox.shrink();

    return SectionBuilder.simple(
      icon: Icons.task_alt,
      title: 'Missions',
      child: BulletListBuilder.checks(items: widget.experience.missions),
    );
  }

  Widget _buildResultatsSection(ThemeData theme) {
    if (widget.experience.resultats.isEmpty) return const SizedBox.shrink();

    return SectionBuilder.simple(
      icon: Icons.trending_up,
      title: 'Résultats',
      child: BulletListBuilder(items: widget.experience.resultats),
    );
  }

  Widget _buildStackSection(ThemeData theme, ResponsiveInfo info) {
    if (widget.experience.stack.isEmpty) return const SizedBox.shrink();

    return ExperienceStackSection(
        experience: widget.experience, theme: theme, info: info);
  }
}
