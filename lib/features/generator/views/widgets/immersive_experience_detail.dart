import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';
import 'package:portefolio/features/experience/data/experiences_data.dart';
import 'package:portefolio/features/generator/views/generator_widgets_extentions.dart';

import '../../../projets/data/project_data.dart';
import '../../../projets/data/project_section.dart';
import '../../services/experience_section_manager.dart';

/// Écran de détail immersif — expériences professionnelles.
///
/// Utilise [ExperienceSectionManager] pour détecter automatiquement
/// si l'expérience est IT et afficher les sections enrichies en conséquence.
class ImmersiveExperienceDetail extends ConsumerStatefulWidget {
  final Experience experience;
  final ProjectInfo? project;

  const ImmersiveExperienceDetail(
      {super.key, required this.experience, this.project});

  @override
  ConsumerState<ImmersiveExperienceDetail> createState() =>
      _ImmersiveExperienceDetailState();
}

class _ImmersiveExperienceDetailState
    extends ConsumerState<ImmersiveExperienceDetail>
    with SingleTickerProviderStateMixin {
  late final ExperienceSectionManager _sectionManager;
  late final AnimationController _entryCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;
  late final ScrollController _scrollCtrl;

  // État de navigation local au widget — pas de provider partagé,
  // pas de risque de conflit entre écrans ou instances.
  String _activeSection = 'presentation';

  double _scrollOffset = 0;
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    _sectionManager =
        ExperienceSectionManager(widget.experience, project: widget.project);

    _entryCtrl = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..forward();

    _fadeAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeInOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic),
    );

    _scrollCtrl = ScrollController()
      ..addListener(() {
        if (mounted) setState(() => _scrollOffset = _scrollCtrl.offset);
      });
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _navigateToSection(String id) {
    if (mounted) setState(() => _activeSection = id);
  }

  // ── Couleur thématique ─────────────────────────────────────────────────────

  Color get _themeColor {
    final tags = widget.experience.tags;
    if (tags.contains('Flutter')) return const Color(0xFF02569B);
    if (tags.contains('Angular')) return const Color(0xFFDD0031);
    if (tags.contains('Node.js')) return const Color(0xFF68A063);
    if (tags.contains('SIG')) return const Color(0xFF00796B);
    if (tags.contains('IoT')) return const Color(0xFF00BCD4);
    if (_sectionManager.isIT) return const Color(0xFF3D5AFE);
    return const Color(0xFF6200EA);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(responsiveInfoProvider);
    final sections = _sectionManager.buildSections(context);
    final activeSection = _activeSection;
    final showSidebar = info.size.width > 1100;

    final immersiveTheme = _buildImmersiveTheme(context);

    return Theme(
      data: immersiveTheme,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // ── Fond ──────────────────────────────────────────────────────
            _buildBackground(info),

            // ── Layout principal ──────────────────────────────────────────
            Positioned.fill(
              child: Row(
                children: [
                  if (showSidebar)
                    ProjectNavigationSidebar(
                      projectTitle: widget.experience.entreprise,
                      sections: sections,
                      activeSection: activeSection,
                      onSectionTap: _navigateToSection,
                    ),
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: IgnorePointer(
                        ignoring: _isExiting,
                        child: SlideTransition(
                          position: _slideAnim,
                          child: _buildMainContent(
                            sections,
                            activeSection,
                            info,
                            showSidebar,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Bouton fermer ─────────────────────────────────────────────
            Positioned(
              top: 16,
              right: 16,
              child: SafeArea(
                child: _CloseButton(
                  onPressed: () {
                    setState(() => _isExiting = true);
                    _entryCtrl.reverse().then((_) {
                      if (mounted) Navigator.of(context).pop();
                    });
                  },
                ),
              ),
            ),

            // ── Navigation mobile ─────────────────────────────────────────
            if (!showSidebar && sections.length > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ProjectBottomNavigation(
                  sections: sections,
                  activeSection: activeSection,
                  onSectionTap: _navigateToSection,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Contenu central ────────────────────────────────────────────────────────

  Widget _buildMainContent(
    List<ProjectSection> sections,
    String activeSection,
    ResponsiveInfo info,
    bool showSidebar,
  ) {
    final section = sections.firstWhere(
      (s) => s.id == activeSection,
      orElse: () => sections.first,
    );
    final idx = sections.indexOf(section);
    final canGoBack = idx > 0;
    final canGoForward = idx < sections.length - 1;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0 && canGoBack) {
          _navigateToSection(sections[idx - 1].id);
        } else if (details.primaryVelocity! < 0 && canGoForward) {
          _navigateToSection(sections[idx + 1].id);
        }
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                transitionBuilder: (child, anim) {
                  final isEntering = anim.status == AnimationStatus.forward ||
                      anim.status == AnimationStatus.completed;
                  return IgnorePointer(
                    ignoring: !isEntering,
                    child: FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.04, 0),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey(activeSection),
                  // Chaque section gère son propre scroll (SingleChildScrollView),
                  // on ajoute juste le padding horizontal + bottom (nav mobile).
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      info.isMobile ? 20 : 48,
                      info.isMobile ? 20 : 40,
                      info.isMobile ? 20 : 48,
                      !showSidebar && sections.length > 1 ? 88 : 40,
                    ),
                    child: section.builder(context, info),
                  ),
                ),
              ),
            ),
          ),

          // Flèches desktop
          if (info.size.width > 1100) ...[
            if (canGoBack)
              NavigationArrow(
                icon: Icons.arrow_back_ios,
                isLeft: true,
                onTap: () => _navigateToSection(sections[idx - 1].id),
              ),
            if (canGoForward)
              NavigationArrow(
                icon: Icons.arrow_forward_ios,
                onTap: () => _navigateToSection(sections[idx + 1].id),
              ),
          ],
        ],
      ),
    );
  }

  // ── Fond ───────────────────────────────────────────────────────────────────

  Widget _buildBackground(ResponsiveInfo info) {
    final hasSIG = widget.experience.tags.contains('SIG');
    final hasImage = widget.experience.image.isNotEmpty;

    return Stack(
      children: [
        // Fond image ou particules
        if (hasSIG)
          Positioned.fill(
            child: Opacity(
              opacity: 0.25,
              child: SigDiscoveryMap(key: ValueKey(widget.experience.id)),
            ),
          )
        else if (hasImage)
          Positioned.fill(
            child: Transform.translate(
              offset: Offset(0, _scrollOffset * 0.4),
              child: SmartImage(
                path: widget.experience.image,
                fit: BoxFit.cover,
                enableShimmer: true,
              ),
            ),
          )
        else
          Positioned.fill(
            child: ParticleBackground(
              particleCount: 40,
              particleColor: _themeColor,
              minSize: 1.5,
              maxSize: 4,
            ),
          ),

        // Overlay flou uniforme
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.black.withValues(alpha: 0.8),
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

  // ── Thème ──────────────────────────────────────────────────────────────────

  ThemeData _buildImmersiveTheme(BuildContext context) {
    return ThemeData.dark(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: Colors.black,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _themeColor,
        brightness: Brightness.dark,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bouton de fermeture glassmorphique
// ─────────────────────────────────────────────────────────────────────────────

class _CloseButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CloseButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: Colors.white10,
          child: IconButton(
            icon: const Icon(Icons.close, size: 26, color: Colors.white),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}
