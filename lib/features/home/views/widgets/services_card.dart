import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/provider/image_providers.dart';
import 'package:portefolio/features/generator/data/extention_models.dart';
import 'package:portefolio/features/generator/views/widgets/hover_card.dart';
import 'package:portefolio/features/home/views/widgets/service_expertise_card.dart';

import '../../../../constants/tech_logos.dart';
import '../../../../core/affichage/screen_size_detector.dart';
import '../../../../core/provider/expertise_provider.dart';
import '../../../../core/ui/widgets/ui_widgets_extentions.dart';

class ServicesCard extends ConsumerStatefulWidget {
  final Service service;
  final VoidCallback? onTap;

  const ServicesCard({
    super.key,
    required this.service,
    this.onTap,
  });

  @override
  ConsumerState<ServicesCard> createState() => _ServicesCardState();
}

class _ServicesCardState extends ConsumerState<ServicesCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scrollController;
  late Animation<double> _scrollAnimation;
  int _currentSkillIndex = 0;

  OverlayEntry? _overlayEntry;
  final GlobalKey _buttonKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    /// Initialisation du contrôleur d'animation
    // Durée totale du cycle pour une compétence (par exemple 2.5 secondes)
    _scrollController = AnimationController(
      vsync: this,
      duration: 2500.ms,
    );

    // L'animation va de 0.0 à 1.0 (une seule fois pour ce contrôleur,
    // l'index sera mis à jour dans le listener)
    _scrollAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_scrollController);

    // Démarrer l'animation en boucle
    _scrollController.repeat();

    // Écouter l'animation pour mettre à jour l'index
    _scrollController.addListener(() {
      final expertise = ref.read(serviceExpertiseProvider(widget.service.id));
      final skillCount = expertise?.topSkills.take(5).length ?? 0;

      if (skillCount > 0) {
        // Calcul de l'index basé sur la valeur actuelle de l'animation (0.0 à 1.0)
        final newIndex =
            (_scrollAnimation.value * skillCount).floor() % skillCount;

        // Mettre à jour l'état uniquement si l'index change
        if (newIndex != _currentSkillIndex) {
          setState(() {
            _currentSkillIndex = newIndex;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  void _toggleSkillBubbles(ServiceExpertise expertise, ResponsiveInfo info) {
    if (_overlayEntry == null) {
      _overlayEntry =
          _createOverlayEntry(context, expertise.skills, expertise, info);
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
    setState(() {});
  }

  OverlayEntry _createOverlayEntry(
      BuildContext context,
      List<TechSkill> techSkills,
      ServiceExpertise expertise,
      ResponsiveInfo info) {
    final RenderBox? renderBox =
        _buttonKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null || !renderBox.attached) {
      return OverlayEntry(builder: (_) => const SizedBox.shrink());
    }

    final buttonPosition = renderBox.localToGlobal(Offset.zero);
    final topSkills = expertise.topSkills.take(5).toList();

    const double bubbleSize = 70.0; // Taille max de la bulle
    const double spacing = 8.0;
    final double overlayWidth = (topSkills.length * (bubbleSize + spacing));

    // Hauteur de l'Overlay: hauteur d'une bulle + un peu de padding
    final double overlayHeight = bubbleSize + 16.0;

    // 4. DÉTERMINER LE POINT DE DÉPART FINAL (TOP et LEFT)
    final double top = buttonPosition.dy -
        overlayHeight; // Place l'Overlay JUSTE AU-DESSUS du bouton 3D

    // Centre l'Overlay horizontalement par rapport au bouton (largeur du bouton ~48px)
    final double left =
        buttonPosition.dx - (overlayWidth / 2) + (renderBox.size.width / 2);

    return OverlayEntry(builder: (context) {
      return Positioned(
          left: left,
          top: top,
          width: overlayWidth,
          height: overlayHeight,
          child: Material(
              color: Colors.transparent,
              child: Container(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: topSkills.asMap().entries.map((entry) {
                      final index = entry.key;
                      final skill = entry.value;
                      final bool isActive = index == _currentSkillIndex;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentSkillIndex = index;
                            _overlayEntry?.markNeedsBuild();
                          });
                        },
                        onLongPress: () {
                          _overlayEntry?.remove();
                          _overlayEntry = null;

                          _showExpandedDialog(context, expertise, skill);
                        },
                        child: Animate(
                          effects: [
                            FadeEffect(
                                delay: (index * 100).ms, duration: 300.ms),
                            ScaleEffect(
                                delay: (index * 100).ms, duration: 300.ms),
                          ],
                          child: _buildSkillBubble(skill, index, isActive, info,
                              Theme.of(context), ref),
                        ),
                      );
                    }).toList(),
                  ))));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final info = ref.watch(responsiveInfoProvider);

    return GestureDetector(
      // onTap: widget.onTap ?? () => _showExpertiseDialog(context, ref),
      child: HoverCard(
        id: widget.service.id,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_getBorderRadius(info)),
          child: LayoutBuilder(builder: (context, constraints) {
            return Column(
              children: [
                // Section supérieure : Image + Badge + Titre (ratio fixe)
                SizedBox(
                  height: _getTopSectionHeight(info),
                  child: _buildTopSection(context, theme, info, ref),
                ),

                // Section inférieure : Graphique (prend l'espace restant)
                Expanded(
                  child: _buildBottomSection(context, theme, info, ref),
                ),
              ],
            );
          }),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 150.ms)
        .slideY(begin: 0.2, duration: 500.ms, curve: Curves.easeOutBack);
  }

  double _getTopSectionHeight(ResponsiveInfo info) {
    if (info.isWatch) return 120;
    if (info.isMobile) return 160;
    if (info.isTablet) return 180;
    return info.cardWidth * info.cardHeightRatio;
  }

  Widget _buildExpertiseDialogButton(
      ThemeData theme, ResponsiveInfo info, WidgetRef ref) {
    final expertise = ref.watch(serviceExpertiseProvider(widget.service.id));
    final size = _getIconSize(info) * 1.2;

    return InkWell(
      key: _buttonKey,
      onTap: () {
        if (expertise != null) {
          _toggleSkillBubbles(expertise, info);
        }
      },
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        padding: EdgeInsets.all(size * 0.25),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.6),
          border: Border.all(color: Colors.white, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
              blurRadius: 10,
            ),
          ],
        ),
        child: Icon(
          _overlayEntry != null ? Icons.close : Icons.psychology_outlined,
          size: size * 0.6,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSkillBubble(TechSkill skill, int index, bool isActive,
      ResponsiveInfo info, ThemeData theme, WidgetRef ref) {
    final size = info.isMobile ? 50.0 : 70.0;
    final color = _getColorForIndex(index);
    final String skillName = skill.name.toLowerCase();
    final String? logoPath = ref.read(skillLogoPathProvider(skillName));

    final IconData skillIcon = getIconFromName(skillName);

    final Widget centerIcon;

    if (logoPath != null) {
      centerIcon = SmartImage(
        path: logoPath,
        width: size * 0.45,
        height: size * 0.45,
        fit: BoxFit.contain,
        enableShimmer: false,
        useCache: true, // Utiliser le cache de SmartImage
        fallbackIcon: skillIcon,
        fallbackColor: Colors.white,
      );
    } else {
      centerIcon = Icon(
        skillIcon,
        size: size * 0.45,
        color: Colors.white,
      );
    }

    return ResponsiveBox(
      margin: const EdgeInsets.only(right: 8.0),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: isActive
            ? Border.all(
                color: Colors.white, width: 3) // Highlight l'élément actif
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icône (simple)
          centerIcon,
          // Niveau
          ResponsiveText.bodySmall(
            '${skill.levelPercent}%',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: info.isMobile ? 10 : 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      Colors.blue.shade600,
      Colors.green.shade600,
      Colors.orange.shade600,
      Colors.purple.shade600,
      Colors.red.shade600,
    ];
    return colors[index % colors.length];
  }

  /// Section supérieure avec image de fond
  Widget _buildTopSection(
    BuildContext context,
    ThemeData theme,
    ResponsiveInfo info,
    WidgetRef ref,
  ) {
    final expertise = ref.watch(serviceExpertiseProvider(widget.service.id));

    return Stack(
      fit: StackFit.expand,
      children: [
        // Image de fond
        _buildBackgroundImage(theme),

        // Overlay gradient
        _buildOverlay(),

        // Contenu
        ResponsiveBox(
          padding: EdgeInsets.all(_getPadding(info)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Badge d'expertise en haut à droite
              Row(
                mainAxisAlignment: MainAxisAlignment.start, // Aligner à droite
                children: [
                  // Badge d'expertise (optionnel)
                  if (expertise != null)
                    _buildExpertiseBadge(expertise, theme, info),

                  // Espacement si le badge est présent
                  if (expertise != null)
                    SizedBox(
                        width:
                            _getSpacing(info, small: 8, medium: 10, large: 12)),

                  // Bouton d'expertise 3D simulé
                  _buildExpertiseDialogButton(theme, info, ref),
                ],
              ),

              // Titre et icône en bas
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildIconBadge(theme, info),
                      ResponsiveBox(
                          width: _getSpacing(info,
                              small: 8, medium: 10, large: 12)),
                      Expanded(
                        child: ResponsiveText.titleMedium(
                          widget.service.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: _getFontSize(info,
                                small: 14, medium: 16, large: 18),
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  ResponsiveBox(
                      height: _getSpacing(info, small: 4, medium: 6, large: 8)),
                  ResponsiveText.bodySmall(
                    widget.service.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize:
                          _getFontSize(info, small: 11, medium: 12, large: 13),
                      height: 1.3,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Section inférieure avec graphique camembert
  Widget _buildBottomSection(
    BuildContext context,
    ThemeData theme,
    ResponsiveInfo info,
    WidgetRef ref,
  ) {
    final expertise = ref.watch(serviceExpertiseProvider(widget.service.id));

    if (expertise == null) {
      return Card(
        color: theme.colorScheme.surface,
        margin: EdgeInsets.all(_getPadding(info)),
        child: Center(
          child: ResponsiveText.bodyMedium(
            'Aucune donnée disponible',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      );
    }

    return Card(
      color: theme.colorScheme.surface,
      margin: EdgeInsets.all(_getPadding(info)),
      child: Padding(
          padding: EdgeInsets.all(_getPadding(info)),
          child: Column(
            mainAxisSize: MainAxisSize.min, // la carte s’adapte au contenu
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: ResponsiveText.titleSmall(
                  'Technologies',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:
                          _getFontSize(info, small: 12, medium: 14, large: 16)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                  height: _getSpacing(info, small: 8, medium: 12, large: 16)),

              // Pie chart + légende
              Expanded(
                flex: 5,
                child: _buildChartSection(expertise, theme, info),
              ),

              SizedBox(
                  height: _getSpacing(info, small: 8, medium: 10, large: 12)),

              Expanded(
                flex: 1,
                child: _buildStats(expertise, theme, info),
              ),
            ],
          )).animate().fadeIn(duration: 1000.ms, delay: 150.ms),
    );
  }

  Widget _buildChartSection(
    ServiceExpertise expertise,
    ThemeData theme,
    ResponsiveInfo info,
  ) {
    // Déterminer la structure en fonction de l'écran
    if (info.isWatch || info.isMobile) {
      // Sur petit écran, empiler la légende au-dessus/en-dessous
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Graphique (laisse l'espace nécessaire)
          Expanded(
            child: AspectRatio(
              aspectRatio: 1.0,
              child: _buildPieChart(expertise, theme, info),
            ),
          ),
          SizedBox(height: _getSpacing(info, small: 8, medium: 10, large: 12)),
        ],
      );
    }

    // Tablette et plus (côte à côte)
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Légende flexible
        Expanded(
          flex: 5,
          child: _buildLegend(expertise, theme, info)
              .animate()
              .fadeIn(delay: 1000.ms, duration: 800.ms)
              .slideX(begin: -0.2),
        ),
        SizedBox(width: _getSpacing(info, small: 8, medium: 12, large: 16)),
        // Pie chart
        Expanded(
          flex: 5,
          child: AspectRatio(
            aspectRatio: 1.0,
            child: _buildPieChart(expertise, theme, info)
                .animate()
                .fadeIn(delay: 1000.ms, duration: 800.ms)
                .slideX(begin: 0.2),
          ),
        ),
      ],
    );
  }

  /// Graphique camembert
  Widget _buildPieChart(
    ServiceExpertise expertise,
    ThemeData theme,
    ResponsiveInfo info,
  ) {
    final skills = expertise.topSkills.take(5).toList();

    final colors = [
      Colors.blue.shade600,
      Colors.green.shade600,
      Colors.orange.shade600,
      Colors.purple.shade600,
      Colors.red.shade600,
    ];

    return Stack(
      alignment: Alignment.center,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: 360),
          duration: 1500.ms,
          curve: Curves.easeInOut,
          builder: (context, rotation, child) {
            return PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: _getCenterRadius(info),
                startDegreeOffset: rotation,
                sections: skills.asMap().entries.map((entry) {
                  final index = entry.key;
                  final skill = entry.value;

                  return PieChartSectionData(
                    color: colors[index % colors.length],
                    value: skill.level * 100,
                    title:
                        _shouldShowTitle(info) ? '${skill.levelPercent}%' : '',
                    radius: _getRadius(info),
                    titleStyle: TextStyle(
                      fontSize:
                          _getFontSize(info, small: 8, medium: 10, large: 11),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
        _buildCenterLegend(expertise, theme, info),
      ],
    );
  }

  Widget _buildCenterLegend(
    ServiceExpertise expertise,
    ThemeData theme,
    ResponsiveInfo info,
  ) {
    final skills = expertise.topSkills.take(5).toList();
    if (skills.isEmpty) return const SizedBox.shrink();

    // Utilisation de l'index de l'état local
    final skill = skills[_currentSkillIndex];
    final double fontSize = _getFontSize(info, small: 9, medium: 10, large: 12);
    final double size = _getCenterRadius(info) * 2;

    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ResponsiveText.bodySmall(
              'Top ${skills.length} Skills',
              style: TextStyle(
                fontSize: fontSize * 0.7,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              // Container de taille fixe pour éviter les sauts
              height: fontSize * 1.5,
              child: AnimatedSwitcher(
                duration: 900.ms, // Temps de la transition
                transitionBuilder: (Widget child, Animation<double> animation) {
                  // Effet de transition Slide-Fade
                  final slideAnimation = Tween<Offset>(
                    begin: const Offset(0.0, 1.0), // Vient du bas
                    end: Offset.zero,
                  ).animate(animation);

                  return SlideTransition(
                    position: slideAnimation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: ResponsiveText.bodyMedium(
                  // La clé est essentielle pour forcer AnimatedSwitcher à reconstruire
                  skill.name,
                  key: ValueKey(skill.name),
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getCenterRadius(ResponsiveInfo info) {
    if (info.isWatch) return 15;
    if (info.isMobile) return 20;
    if (info.isTablet) return 25;
    return 30;
  }

  double _getRadius(ResponsiveInfo info) {
    if (info.isWatch) return 35;
    if (info.isMobile) return 50;
    if (info.isTablet) return 55;
    return 60;
  }

  bool _shouldShowTitle(ResponsiveInfo info) {
    return !info.isWatch && !info.isMobile;
  }

  /// Légende du graphique
  Widget _buildLegend(
    ServiceExpertise expertise,
    ThemeData theme,
    ResponsiveInfo info,
  ) {
    final skills = expertise.topSkills.take(5).toList();
    final double size = _getFontSize(info, small: 9, medium: 10, large: 11);

    final colors = [
      Colors.blue.shade600,
      Colors.green.shade600,
      Colors.orange.shade600,
      Colors.purple.shade600,
      Colors.red.shade600,
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: skills.asMap().entries.map((entry) {
        final index = entry.key;
        final skill = entry.value;

        return Padding(
          padding: EdgeInsets.symmetric(
            vertical: _getSpacing(info, small: 2, medium: 3, large: 4),
          ),
          child: Row(
            children: [
              Container(
                width: _getSpacing(info, small: 8, medium: 10, large: 12),
                height: _getSpacing(info, small: 8, medium: 10, large: 12),
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: _getSpacing(info, small: 4, medium: 6, large: 8)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ResponsiveText.bodySmall(
                      skill.name,
                      style: TextStyle(
                        fontSize: size,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    ResponsiveText.bodySmall(
                      '${skill.levelPercent}% • ${skill.projectCount} projets',
                      style: TextStyle(
                        fontSize: size - 1,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Stats en bas de la carte
  Widget _buildStats(
    ServiceExpertise expertise,
    ThemeData theme,
    ResponsiveInfo info,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(
          icon: Icons.work_outline,
          label: '${expertise.totalProjects} projets',
          color: theme.colorScheme.primary,
          info: info,
        ),
        Container(
          width: 1,
          height: _getSpacing(info, small: 16, medium: 18, large: 20),
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        _buildStatItem(
          icon: Icons.calendar_today,
          label: '${expertise.totalYearsExperience} ans',
          color: theme.colorScheme.secondary,
          info: info,
        ),
        Container(
          width: 1,
          height: _getSpacing(info, small: 16, medium: 18, large: 20),
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        _buildStatItem(
          icon: Icons.star,
          label: '${(expertise.averageLevel * 100).toInt()}%',
          color: Colors.orange,
          info: info,
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required Color color,
    required ResponsiveInfo info,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: _getFontSize(info, small: 12, medium: 14, large: 16),
          color: color,
        ),
        SizedBox(width: _getSpacing(info, small: 3, medium: 4, large: 6)),
        Text(
          label,
          style: TextStyle(
            fontSize: _getFontSize(info, small: 9, medium: 10, large: 11),
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // WIDGETS DE BASE (inchangés)
  // ============================================================================

  Widget _buildBackgroundImage(ThemeData theme) {
    if (!widget.service.hasValidImage) {
      return _buildFallbackGradient(theme);
    }

    return SmartImage(
      path: widget.service.cleanedImageUrl!,
      fit: BoxFit.cover,
      responsiveSize: ResponsiveImageSize.medium,
      fallbackIcon: widget.service.icon,
      fallbackColor: theme.colorScheme.primary,
    );
  }

  Widget _buildOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.6),
            Colors.black.withValues(alpha: 0.3),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildFallbackGradient(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.4),
            theme.colorScheme.secondary.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          widget.service.icon,
          size: 120,
          color: Colors.white.withValues(alpha: 0.15),
        ),
      ),
    );
  }

  Widget _buildIconBadge(ThemeData theme, ResponsiveInfo info) {
    final size = _getIconSize(info);

    return Container(
      padding: EdgeInsets.all(size * 0.3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(widget.service.icon, size: size, color: Colors.white),
    );
  }

  Widget _buildExpertiseBadge(
      ServiceExpertise expertise, ThemeData theme, ResponsiveInfo info) {
    final level = (expertise.averageLevel * 100).toInt();

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: _getSpacing(info, small: 4, medium: 6, large: 8),
          vertical: _getSpacing(info, small: 4, medium: 6, large: 8)),
      decoration: BoxDecoration(
        color: _getColorForLevel(expertise.averageLevel),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: _getFontSize(info, small: 10, medium: 12, large: 14),
            color: Colors.white,
          ),
          SizedBox(width: _getSpacing(info, small: 3, medium: 4, large: 5)),
          Text(
            '$level% expertise',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: _getFontSize(info, small: 9, medium: 10, large: 11),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForLevel(double level) {
    if (level >= 0.9) return Colors.green.shade600;
    if (level >= 0.7) return Colors.blue.shade600;
    if (level >= 0.5) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  void _showExpandedDialog(BuildContext context, ServiceExpertise expertise,
      TechSkill? selectedSkill) {
    final info = ref.read(responsiveInfoProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth * 0.75; // 3/4 de l'écran

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        // ⭐️ Contrainte de taille agrandie
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: BoxConstraints(maxWidth: dialogWidth, maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ... (Titre et bouton de fermeture) ...
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ResponsiveText.headlineSmall(
                      'Détails d\'Expertise - ${widget.service.title}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (selectedSkill != null)
                        _buildSkillDetails(
                            selectedSkill, info, Theme.of(context)),
                      const Divider(height: 32),
                      ServiceExpertiseCard(expertise: expertise),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkillDetails(
      TechSkill skill, ResponsiveInfo info, ThemeData theme) {
    // Ceci est juste un exemple simple de ce que vous pouvez afficher
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText.titleLarge(skill.name,
            style: TextStyle(color: theme.colorScheme.primary)),
        const SizedBox(height: 8),
        ResponsiveText.bodyLarge('Niveau d\'Expertise: ${skill.levelPercent}%',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        ResponsiveText.bodyLarge('Projets Utilisés: ${skill.projectCount}'),
        // Ajoutez ici des graphiques détaillés ou des descriptions longues si disponibles.
      ],
    );
  }

  // ============================================================================
  // HELPERS
  // ============================================================================

  double _getBorderRadius(ResponsiveInfo info) => info.isWatch
      ? 12
      : info.isMobile
          ? 16
          : info.isTablet
              ? 20
              : 24;

  double _getPadding(ResponsiveInfo info) => info.isWatch
      ? 12
      : info.isMobile
          ? 16
          : info.isTablet
              ? 20
              : 24;

  double _getSpacing(
    ResponsiveInfo info, {
    required double small,
    required double medium,
    required double large,
  }) =>
      info.isWatch || info.isMobile
          ? small
          : info.isTablet
              ? medium
              : large;

  double _getFontSize(
    ResponsiveInfo info, {
    required double small,
    required double medium,
    required double large,
  }) =>
      info.isWatch || info.isMobile
          ? small
          : info.isTablet
              ? medium
              : large;

  double _getIconSize(ResponsiveInfo info) => info.isWatch
      ? 20
      : info.isMobile
          ? 24
          : info.isTablet
              ? 28
              : 32;
}
