import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/widgets/ui_widgets_extentions.dart';
import 'package:portefolio/features/experience/data/experiences_data.dart';
import 'package:portefolio/features/generator/views/generator_widgets_extentions.dart';

import '../../../../core/provider/image_providers.dart';

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

  Widget _build3DIcon({
    required IconData icon,
    required Color color,
    double size = 24.0,
    double padding = 8.0,
  }) {
    final double containerSize = size + padding * 2;

    return Transform(
      // Ajout de perspective et d'une légère rotation pour l'effet 3D
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001) // Perspective
        ..rotateX(0.1) // Tilt up
        ..rotateY(-0.1), // Tilt left
      alignment: Alignment.center,
      child: Container(
        width: containerSize,
        height: containerSize,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2), // Fond semi-transparent
          borderRadius: BorderRadius.circular(containerSize / 3),
          // Ombres pour simuler la profondeur
          boxShadow: [
            // Ombre sombre pour la profondeur
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.7),
              blurRadius: 12,
              offset: const Offset(4, 4),
            ),
            // Highlight pour le relief
            BoxShadow(
              color: color.withValues(alpha: 0.6),
              blurRadius: 6,
              offset: const Offset(-2, -2),
            ),
          ],
          // Dégradé pour simuler l'éclairage
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.2,
            colors: [
              Colors.white.withValues(alpha: 0.3), // Source de lumière
              color.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            size: size,
            color: Colors.white, // Icône claire pour le contraste
          ),
        ),
      ),
    );
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
    final theme = Theme.of(context);

    return Theme(
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
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.1),
                ),
              ),
            ),
          )
        ],
      ));
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

  Widget _buildSliverHeader(ResponsiveInfo info, Color themeColor) {
    final logoSize = info.isMobile ? 100.0 : 150.0;

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
                _build3DIcon(
                  icon: Icons.work_outline,
                  color: theme.colorScheme.primary,
                  size: 20,
                  padding: 4,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ResponsiveText.titleLarge(
                    widget.experience.poste,
                    style: TextStyle(
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
                _build3DIcon(
                  icon: Icons.calendar_today,
                  color: theme.colorScheme.primary.withValues(alpha: 0.7),
                  size: 26,
                  padding: 4,
                ),
                const SizedBox(width: 16),
                ResponsiveText.bodyLarge(
                  widget.experience.periode,
                  style: TextStyle(
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
            ResponsiveText.bodyMedium(
              widget.experience.contexte,
              style: TextStyle(
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
              _build3DIcon(
                icon: icon,
                color: theme.colorScheme.primary,
                size: 24,
                padding: 4,
              ),
              const SizedBox(width: 12),
              ResponsiveText.titleLarge(
                title,
                style: TextStyle(
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
                      child: ResponsiveText.bodyMedium(
                        item,
                        style: TextStyle(
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

  Widget _buildTech3DChip(String tech, Color primaryColor, ThemeData theme) {
    final techLower = tech.toLowerCase();
    final fallbackIcon = TechIconHelper.getIconForTech(tech);
    final String? logoPath = ref.read(skillLogoPathProvider(techLower));
    const double logoSize = 20.0;
    const double containerSize = logoSize + 8.0;

    final Widget logoContent = logoPath != null
        ? SmartImage(
            path: logoPath,
            width: logoSize,
            height: logoSize,
            fit: BoxFit.contain,
            color: Colors.white, // Teinte pour le contraste
            colorBlendMode: BlendMode.modulate,
            fallbackIcon: fallbackIcon,
            useCache: true,
            enableShimmer: false,
          )
        : Icon(
            fallbackIcon,
            size: logoSize,
            color: Colors.white,
          );

    final Widget logoBubble = Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.6), // Couleur de fond du logo
        shape: BoxShape.circle,
        boxShadow: [
          // Ombre foncée pour la profondeur (bas)
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.7),
            blurRadius: 8,
            offset: const Offset(3, 3),
          ),
          // Highlight claire pour le relief (haut)
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.4),
            blurRadius: 4,
            offset: const Offset(-2, -2),
          ),
        ],
        // Dégradé pour simuler la forme sphérique
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 1.5,
          colors: [
            Colors.white.withValues(alpha: 0.5),
            primaryColor.withValues(alpha: 0.6),
          ],
        ),
      ),
      child: Center(child: logoContent),
    );

    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: primaryColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Légère transformation pour simuler le 3D sur l'icône
          Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(0.05)
              ..rotateY(-0.05),
            alignment: Alignment.center,
            child: logoBubble,
          ),
          const SizedBox(width: 8),
          ResponsiveText.bodyMedium(
            tech,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
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
              _build3DIcon(
                icon: Icons.code,
                color: theme.colorScheme.primary,
                size: 24,
                padding: 4,
              ),
              const SizedBox(width: 12),
              ResponsiveText.titleLarge(
                'Stack Technique',
                style: TextStyle(
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
                .expand((entry) => entry.value.map((tech) => _buildTech3DChip(
                      tech,
                      theme.colorScheme.primary,
                      theme,
                    )))
                .toList(),
          ),
        ],
      ),
    );
  }
}
