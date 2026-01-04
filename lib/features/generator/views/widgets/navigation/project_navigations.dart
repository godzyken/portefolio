import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';

import '../../../../projets/views/widgets/project_section.dart';

/// Sidebar de navigation (desktop)
class ProjectNavigationSidebar extends StatelessWidget {
  final String projectTitle;
  final List<ProjectSection> sections;
  final String activeSection;
  final ValueChanged<String> onSectionTap;
  final Widget? headerExtra;

  const ProjectNavigationSidebar({
    super.key,
    required this.projectTitle,
    required this.sections,
    required this.activeSection,
    required this.onSectionTap,
    this.headerExtra,
  });

  @override
  Widget build(BuildContext context) {
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
              _buildHeader(),
              Expanded(
                child: _buildSectionsList(),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
            projectTitle,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
          ),
          if (headerExtra != null) ...[
            const SizedBox(height: 8),
            headerExtra!,
          ],
        ],
      ),
    );
  }

  Widget _buildSectionsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final section = sections[index];
        final isActive = section.id == activeSection;

        return SidebarItem(
          section: section,
          isActive: isActive,
          onTap: () => onSectionTap(section.id),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Container(
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
    );
  }
}

/// Item de sidebar
class SidebarItem extends StatelessWidget {
  final ProjectSection section;
  final bool isActive;
  final VoidCallback onTap;

  const SidebarItem({
    super.key,
    required this.section,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
}

/// Bottom navigation (mobile)
class ProjectBottomNavigation extends StatelessWidget {
  final List<ProjectSection> sections;
  final String activeSection;
  final ValueChanged<String> onSectionTap;

  const ProjectBottomNavigation({
    super.key,
    required this.sections,
    required this.activeSection,
    required this.onSectionTap,
  });

  @override
  Widget build(BuildContext context) {
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
                  onTap: () => onSectionTap(section.id),
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
}

/// Flèches de navigation (desktop)
class NavigationArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isLeft;

  const NavigationArrow({
    super.key,
    required this.icon,
    required this.onTap,
    this.isLeft = false,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: isLeft ? 24 : null,
      right: isLeft ? null : 24,
      top: 0,
      bottom: 0,
      child: Center(
        child: InkWell(
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
        ),
      ),
    );
  }
}
