import 'package:flutter/material.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/widgets/ui_widgets_extentions.dart';

import '../../../data/extention_models.dart';
import '../../generator_widgets_extentions.dart';

/// Section Hero (présentation principale du projet)
///
/// Affiche:
/// - Titre du projet avec badge WakaTime
/// - Carousel d'images
/// - Description avec bullet points
///
/// Layout adaptatif:
/// - Desktop: Row (description + carousel)
/// - Mobile: Column (carousel + description)
class HeroSection extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final images = _getImages();
    final useRowLayout = info.size.width > 900;

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
          ),

          const SizedBox(height: 24),

          // Contenu principal (adaptatif)
          if (useRowLayout)
            _DesktopLayout(
              images: images,
              description: project.points,
              info: info,
            )
          else
            _MobileLayout(
              images: images,
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

  const _CompactHeader({
    required this.title,
    required this.showWakaTime,
    required this.projectName,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}

/// Layout desktop (description à gauche, carousel à droite)
class _DesktopLayout extends StatelessWidget {
  final List<String> images;
  final List<String> description;
  final ResponsiveInfo info;

  const _DesktopLayout({
    required this.images,
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

          // Carousel (60%)
          if (images.isNotEmpty)
            Expanded(
              flex: 6,
              child: _ImageCarousel(
                images: images,
                info: info,
              ),
            ),
        ],
      ),
    );
  }
}

/// Layout mobile (carousel en haut, description en bas)
class _MobileLayout extends StatelessWidget {
  final List<String> images;
  final List<String> description;
  final ResponsiveInfo info;

  const _MobileLayout({
    required this.images,
    required this.description,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (images.isNotEmpty) _ImageCarousel(images: images, info: info),
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
          ResponsiveText.titleMedium(
            '📜 Description',
            style: const TextStyle(
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

// ==============================================================================
// COMPARAISON AVANT/APRÈS
// ==============================================================================

/*

📊 AVANT (dans immersive_detail_screen.dart):

Widget _buildHeroContent(BuildContext context, ResponsiveInfo info) {
  final images = _getImages();
  final useRowLayout = info.size.width > 900;

  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCompactHeader(info),
        const SizedBox(height: 24),

        if (useRowLayout)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 4, child: _buildDescription(info)),
                const SizedBox(width: 24),
                if (images.isNotEmpty)
                  Expanded(flex: 6, child: _buildOptimizedCarousel(images, info)),
              ],
            ),
          )
        else
          Column(
            children: [
              if (images.isNotEmpty) _buildOptimizedCarousel(images, info),
              const SizedBox(height: 24),
              _buildDescription(info),
            ],
          ),
      ],
    ),
  );
}

Widget _buildCompactHeader(ResponsiveInfo info) { ... }  // 30 lignes
Widget _buildOptimizedCarousel(...) { ... }              // 40 lignes
Widget _buildDescription(ResponsiveInfo info) { ... }    // 50 lignes

TOTAL: ~200 lignes dans le fichier principal

---

✅ APRÈS (section extraite):

// Dans _buildSections():
ProjectSection(
  id: 'hero',
  title: 'Présentation',
  icon: Icons.home,
  builder: (context, info) => HeroSection(
    project: project,
    info: info,
    hasProgrammingTag: _sectionManager.hasProgrammingTag(),
  ),
)

// Fichier hero_section.dart: ~250 lignes
// Fichier principal: 5 lignes

TOTAL DANS PRINCIPAL: 5 lignes (-97.5% ! 🎉)

---

🎯 AVANTAGES:

✅ Code isolé et testable
✅ Widgets privés (_CompactHeader, _DesktopLayout, etc.)
✅ Réutilisable dans d'autres contextes
✅ Documentation claire
✅ Aucune dépendance au State parent
✅ Facilite les tests de régression
✅ Performance (widgets const partout)

---

📝 PATTERN À REPRODUIRE:

Chaque section doit:
1. Recevoir uniquement les données dont elle a besoin
2. Être un StatelessWidget si possible
3. Décomposer en sous-widgets privés
4. Utiliser const constructors
5. Documenter son rôle

*/
