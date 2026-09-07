import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';

import '../../../../../core/affichage/tech_maturity_framework.dart';
import '../../../../wakatime/views/widgets/wakatime_badge.dart';
import '../../../data/extention_models.dart';
import '../../../services/section_manager.dart';
import 'emap_video_player.dart';

/// Section Hero (présentation principale du projet)
///
/// Affiche:
/// - Titre du projet avec badge WakaTime
/// - Média principal (vidéo promotionnelle pour EMAP, carousel sinon)
/// - Description avec bullet points
///
/// Layout adaptatif:
/// - Desktop: Row (description + média)
/// - Mobile: Column (média + description)
class HeroSection extends ConsumerWidget {
  final ProjectInfo project;
  final ResponsiveInfo info;
  final bool hasProgrammingTag;

  const HeroSection({
    super.key,
    required this.project,
    required this.info,
    this.hasProgrammingTag = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manager = SectionManager(project);
    final maturity = manager.analyzeMaturity();
    developer.log(
        'DEBUG: HeroSection maturity for ${project.title}: ${maturity.length} pillars found',
        name: 'UI_DEBUG');

    final images = _getImages();
    final useRowLayout = info.size.width > 900;
    final isEmap = project.analyticsId == 'emap_services';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec titre et badge
          _CompactHeader(
            title: project.title,
            showWakaTime: hasProgrammingTag,
            projectName: project.title,
            info: info,
            project: project,
          ),

          const SizedBox(height: 24),

          // Contenu principal (adaptatif)
          if (useRowLayout)
            _DesktopLayout(
              media: isEmap
                  ? const EmapVideoPlayer()
                  : _ImageCarousel(images: images, info: info),
              description: project.points,
              info: info,
            )
          else
            _MobileLayout(
              media: isEmap
                  ? const EmapVideoPlayer()
                  : _ImageCarousel(images: images, info: info),
              description: project.points,
              info: info,
            ),
        ],
      ),
    );
  }

  List<String> _getImages() {
    return project.cleanedImages ?? project.image ?? [];
  }
}

/// Header compact avec titre et badge WakaTime
class _CompactHeader extends StatelessWidget {
  final String title;
  final bool showWakaTime;
  final String projectName;
  final ResponsiveInfo info;
  final ProjectInfo project;

  const _CompactHeader({
    required this.title,
    required this.showWakaTime,
    required this.projectName,
    required this.info,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    final manager = SectionManager(project);
    final maturity = manager.analyzeMaturity();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ResponsiveText.titleLarge(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: info.isMobile ? 20 : 28,
                ),
              ),
            ),
            if (showWakaTime) ...[
              const SizedBox(width: 16),
              WakaTimeBadgeWidget(
                projectName: projectName,
                variant: WakaTimeBadgeVariant.compact,
                showTrackingIndicator: true,
              ),
            ],
          ],
        ),
        if (maturity.isNotEmpty) ...[
          const SizedBox(height: 12),
          TechMaturityRadar(scores: maturity, compact: true),
        ],
      ],
    );
  }
}

/// Layout desktop (description à gauche, média à droite)
class _DesktopLayout extends StatelessWidget {
  final Widget media;
  final List<String> description;
  final ResponsiveInfo info;

  const _DesktopLayout({
    required this.media,
    required this.description,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Description (40%)
          Expanded(
            flex: 4,
            child: _DescriptionCard(
              points: description,
              info: info,
            ),
          ),

          const SizedBox(width: 24),

          // Média (60%)
          Expanded(
            flex: 6,
            child: media,
          ),
        ],
      ),
    );
  }
}

/// Layout mobile (média en haut, description en bas)
class _MobileLayout extends StatelessWidget {
  final Widget media;
  final List<String> description;
  final ResponsiveInfo info;

  const _MobileLayout({
    required this.media,
    required this.description,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        media,
        const SizedBox(height: 24),
        _DescriptionCard(points: description, info: info),
      ],
    );
  }
}

/// Carousel d'images optimisé
class _ImageCarousel extends StatelessWidget {
  final List<String> images;
  final ResponsiveInfo info;

  const _ImageCarousel({
    required this.images,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
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
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
                responsiveSize: ResponsiveImageSize.large,
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Card de description avec bullet points
class _DescriptionCard extends StatelessWidget {
  final List<String> points;
  final ResponsiveInfo info;

  const _DescriptionCard({
    required this.points,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ResponsiveText.titleMedium(
            '📜 Description',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...points.map((text) => _BulletPoint(text: text)),
        ],
      ),
    );
  }
}

/// Point de liste avec icône check
class _BulletPoint extends StatelessWidget {
  final String text;

  const _BulletPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
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
    );
  }
}
