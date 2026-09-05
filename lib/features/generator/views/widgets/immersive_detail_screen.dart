import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/colors_spec.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/provider/unified_image_provider.dart';
import 'package:portefolio/core/ui/widgets/narrative_bubble.dart';
import 'package:portefolio/features/generator/services/section_manager.dart';

import '../../../projets/data/project_section.dart';
import '../../../projets/providers/projects_extentions_providers.dart';
import '../../../wakatime/views/widgets/wakatime_badge.dart';
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
  late final SectionManager _sectionManager;

  @override
  void initState() {
    super.initState();
    _sectionManager = SectionManager(widget.project);
  }

  void _navigateToSection(String sectionId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(activeSectionProvider.notifier).update(sectionId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(responsiveInfoProvider);
    final sections = _sectionManager.buildSections(context);
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
                // Sidebar de navigation
                if (showSidebar)
                  ProjectNavigationSidebar(
                    projectTitle: widget.project.title,
                    sections: sections,
                    activeSection: activeSection,
                    onSectionTap: _navigateToSection,
                    headerExtra: _sectionManager.hasProgrammingTag()
                        ? WakaTimeBadgeWidget(
                            projectName: widget.project.title,
                            variant: WakaTimeBadgeVariant.compact,
                          )
                        : null,
                  ),

                // Contenu principal
                Expanded(
                  child: _buildMainContent(sections, activeSection, info),
                ),
              ],
            ),
          ),

          // PERSONNAGE 3D ET BULLE NARRATIVE (DESKTOP SEULEMENT)
          if (!info.isMobile)
            Positioned(
              left: showSidebar ? 280 : 20,
              bottom: 20,
              child: SizedBox(
                width: 250,
                height: 350,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const CharacterViewer(),
                    Positioned(
                      top: -40,
                      left: 100,
                      child: SizedBox(
                        width: 200,
                        child: NarrativeBubble(
                          text: _getNarrativeText(activeSection),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Bouton fermer
          Positioned(
            top: 24,
            right: 24,
            child: _buildCloseButton(),
          ),

          // Navigation mobile
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
    );
  }

  String _getNarrativeText(String sectionId) {
    final manager = SectionManager(widget.project);

    switch (sectionId) {
      case 'hero':
        return manager.storyline;
      case 'tech':
        return "La forge technique. C'est ici que la magie opère avec une stack moderne et robuste.";
      case 'artifacts':
        return "Plongez dans les détails. J'ai documenté chaque étape pour une transparence totale.";
      default:
        return "Chaque pixel a été pensé pour offrir une expérience utilisateur sans compromis.";
    }
  }

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
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0 && canGoBack) {
          _navigateToSection(sections[currentIndex - 1].id);
        } else if (details.primaryVelocity! < 0 && canGoForward) {
          _navigateToSection(sections[currentIndex + 1].id);
        }
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: info.isLandscape ? 1100 : double.infinity,
                  maxHeight: info.size.height,
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    info.isMobile ? 16 : 60,
                    info.isMobile ? 16 : 32,
                    info.isMobile ? 16 : 60,
                    info.isMobile ? 16 : 32,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
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
                            begin: const Offset(0.05, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: SizedBox.expand(
                      key: ValueKey(activeSection),
                      child: section.builder(context, info),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (info.size.width > 1200) ...[
            if (canGoBack)
              NavigationArrow(
                icon: Icons.arrow_back_ios,
                isLeft: true,
                onTap: () => _navigateToSection(sections[currentIndex - 1].id),
              ),
            if (canGoForward)
              NavigationArrow(
                icon: Icons.arrow_forward_ios,
                onTap: () => _navigateToSection(sections[currentIndex + 1].id),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildBackground(ResponsiveInfo info) {
    final images = _sectionManager.getImages();
    return Stack(
      children: [
        if (images.isNotEmpty)
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: CachedImage(
                  path: images[0],
                  fit: BoxFit.cover,
                  height: info.size.height,
                  width: info.size.width),
            ),
          ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ColorHelpers.surface.withValues(alpha: 0.8),
                    Colors.black,
                    ColorHelpers.cyan.withValues(alpha: 0.1),
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
}
