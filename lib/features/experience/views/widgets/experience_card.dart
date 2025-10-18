import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/features/generator/data/extention_models.dart';
import 'package:portefolio/features/generator/views/widgets/generator_widgets_extentions.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../constants/tech_logos.dart';

class ExperienceCard extends ConsumerWidget {
  final Experience experience;
  final double pageOffset;

  const ExperienceCard({
    super.key,
    required this.experience,
    this.pageOffset = 0.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    developer.log('experience : $experience');
    return HoverCard(
      id: experience.entreprise,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showDetails(context),
        child: AdaptiveCard(
          title: experience.entreprise,
          bulletPoints: [
            ...experience.objectifs.take(2), // aperçu : 2 objectifs
            ...experience.missions.take(1), // + 1 mission
            if (experience.periode.isNotEmpty)
              'Période : ${experience.periode}',
          ],
          imagePath: experience.image.isNotEmpty ? experience.image : null,
          onTap: () => _showDetails(context),
          imageBuilder: experience.image.isNotEmpty
              ? (context, size) => _buildImage(context, size)
              : null,
          trailingActions: [
            if (experience.logo.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Image.asset(
                  experience.logo,
                  height: 52,
                  fit: BoxFit.contain,
                ),
              ),
          ],
          videoBuilder: (context, size) {
            if (experience.lienProjet.isEmpty) return const SizedBox.shrink();
            return FadeSlideAnimation(
              duration: const Duration(milliseconds: 600),
              offset: const Offset(0, 0.1),
              child: YoutubeVideoPlayerIframe(
                videoUrl: experience.lienProjet,
                cardId: experience.entreprise,
              ),
            );
          },
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ExperienceDetails(experience: experience),
    );
  }

  // -------------------------------------------------------------------------
  Widget _buildImage(BuildContext context, Size size) {
    final parallax = pageOffset * 20; // ajuster l'effet parallax
    final scale = (1 - pageOffset.abs() * 0.2).clamp(0.85, 1.0);

    return Transform.translate(
      offset: Offset(parallax, 0),
      child: Transform.scale(
        scale: scale,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            experience.image,
            width: size.width,
            height: 180,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// DETAIL SHEET
// ===========================================================================
class _ExperienceDetails extends ConsumerWidget {
  final Experience experience;
  const _ExperienceDetails({required this.experience});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final info = ref.watch(responsiveInfoProvider);
    final isWide = info.size.width > 900;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (experience.tags.isNotEmpty && experience.tags.contains('SIG'))
          const Align(
            alignment: Alignment.bottomCenter,
            child: Opacity(
              opacity: 0.3,
              child: AspectRatio(aspectRatio: 16 / 9, child: SigDiscoveryMap()),
            ),
          ),
        SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 32,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: isWide ? _buildWide(theme) : _buildNarrow(theme),
        ),
        // Bulle flottante au-dessus
        if (experience.poste.isNotEmpty)
          Positioned(
            right: -150, // marge à Droite
            bottom: 28,
            child: SizedBox(
              child: _BulletString(message: experience.poste),
            ),
          ),
      ],
    );
  }

  // ------------------------- 2 colonnes (desktop) --------------------------
  Widget _buildWide(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(experience: experience),
              const SizedBox(height: 24),
              const _SectionTitle('🎯 Objectifs'),
              _BulletList(items: experience.objectifs),
              const SizedBox(height: 24),
              const _SectionTitle('🛠 Missions'),
              _BulletList(items: experience.missions),
              if (experience.stack.isNotEmpty) ...[
                const SizedBox(height: 24),
                const _SectionTitle('🧰 Stack'),
                const SizedBox(height: 8),
                _ExperienceStack(stack: experience.stack),
              ],
            ],
          ),
        ),
        const SizedBox(width: 40),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (experience.resultats.isNotEmpty) ...[
                const _SectionTitle('📈 Résultats'),
                _BulletList(items: experience.resultats),
                const SizedBox(height: 24),
              ],
              if (experience.lienProjet.isNotEmpty)
                _ProjectLinkButton(url: experience.lienProjet),
              if (experience.code.isNotEmpty)
                _ExperienceCodeSnippet(code: experience.code),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------- 1 colonne (mobile/tablette) -------------------
  Widget _buildNarrow(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _Header(experience: experience),
        const SizedBox(height: 24),
        const _SectionTitle('🎯 Objectifs'),
        _BulletList(items: experience.objectifs),
        const SizedBox(height: 20),
        const _SectionTitle('🛠 Missions'),
        _BulletList(items: experience.missions),
        if (experience.stack.isNotEmpty) ...[
          const SizedBox(height: 20),
          const _SectionTitle('🧰 Stack'),
          const SizedBox(height: 8),
          _ExperienceStack(stack: experience.stack),
        ],
        if (experience.resultats.isNotEmpty) ...[
          const SizedBox(height: 20),
          const _SectionTitle('📈 Résultats'),
          _ExperienceResults(resultats: experience.resultats),
        ],
        if (experience.lienProjet.isNotEmpty) ...[
          const SizedBox(height: 12),
          _ProjectLinkButton(url: experience.lienProjet),
        ],
        if (experience.code.isNotEmpty) ...[
          const SizedBox(height: 12),
          _ExperienceCodeSnippet(code: experience.code),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// ---------- WIDGETS UTILITAIRES (header, listes, stack, etc.) --------------
// ---------------------------------------------------------------------------
class _Header extends StatelessWidget {
  final Experience experience;
  const _Header({required this.experience});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        if (experience.image.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(experience.image, height: 70, width: 70),
          ),
        if (experience.image.isNotEmpty) const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                experience.entreprise,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (experience.periode.isNotEmpty)
                Text(
                  experience.periode,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.deepOrangeAccent[600],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      );
}

class _BulletList extends StatelessWidget {
  final List<String> items;
  const _BulletList({required this.items});

  bool _hasProgrammingTag() {
    const programmingTags = [
      'dart',
      'flutter',
      'angular',
      'javascript',
      'typescript',
      'java',
      'python',
      'c#',
      'c++',
      'rust',
      'github',
      'git',
      'go',
      'php',
      'swift',
      'kotlin',
      'mysql',
      'prestashop',
      'magento',
      'ovh',
    ];
    return items.any((tag) => programmingTags.contains(tag.toLowerCase()));
  }

  /// Vérifie si le contenu ressemble à du code
  bool _looksLikeCode() {
    final regex = RegExp(r'(class|import|final|=>|{|}|\(|\))');
    return items.any((bp) => regex.hasMatch(bp));
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_hasProgrammingTag() || _looksLikeCode())
            CodeHighlightList(items: items, tag: '//')
          else
            ...buildListItems,
        ],
      );

  List<Padding> get buildListItems {
    return items
        .map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• '),
                Expanded(child: Text(e)),
              ],
            ),
          ),
        )
        .toList();
  }
}

class _BulletString extends ConsumerWidget {
  final String message;
  final IconData icon;
  final Color? color;

  const _BulletString({
    required this.message,
    this.icon = Icons.work_outline_rounded,
    this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = color ?? Colors.deepPurple;

    final info = ref.watch(responsiveInfoProvider);

    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- Bulle principale ---
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            width: info.isMobile ? double.infinity : null,
            child: IntrinsicWidth(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor.withValues(alpha: 0.08),
                      primaryColor.withValues(alpha: 0.03),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.15),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize:
                        info.isMobile ? MainAxisSize.max : MainAxisSize.min,
                    children: [
                      // Icône circulaire
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primaryColor,
                              primaryColor.withValues(alpha: 0.08),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, size: 24, color: Colors.white),
                      ),
                      const SizedBox(width: 16),

                      // Texte
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Label
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'POSTE',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: primaryColor,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Texte du poste
                            Text(
                              message,
                              softWrap: true,
                              overflow: TextOverflow.visible,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.white70,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // --- Petit triangle ---
          CustomPaint(
            painter: _TrianglePainter(
              color: primaryColor.withValues(alpha: 0.15),
            ),
            size: const Size(16, 8),
          ),
        ],
      ),
    );
  }
}

/// Dessine le petit triangle (flèche de bulle)
class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 0.15);
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ExperienceStack extends StatelessWidget {
  final Map<String, List<String>> stack;
  const _ExperienceStack({required this.stack});

  @override
  Widget build(BuildContext context) {
    if (stack.isEmpty) return const SizedBox.shrink();

    final allTechnos = stack.entries
        .expand(
          (entry) => entry.value.map(
            (tech) => {
              'type': entry.key,
              'name': tech,
              'logo': techLogos[tech.toLowerCase()],
            },
          ),
        )
        .toList();

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: allTechnos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final t = allTechnos[i];
          return Column(
            children: [
              Tooltip(
                message: '${t['type'].toString().toUpperCase()} - ${t['name']}',
                child: t['logo'] != null
                    ? Image.asset(t['logo']!, width: 32, height: 32)
                    : Chip(label: Text(t['name']!)),
              ),
              if (t['logo'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    t['name']!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ExperienceResults extends StatelessWidget {
  final List<String> resultats;
  const _ExperienceResults({required this.resultats});
  @override
  Widget build(BuildContext context) => _BulletList(items: resultats);
}

class _ExperienceCodeSnippet extends StatelessWidget {
  final String code;
  const _ExperienceCodeSnippet({required this.code});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text('💻 Code (extrait)'),
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          padding: const EdgeInsets.all(12),
          child: HighlightView(
            code,
            language: 'dart',
            theme: githubTheme,
            padding: const EdgeInsets.all(12),
            textStyle: const TextStyle(fontFamily: 'monospace', fontSize: 13.5),
          ),
        ),
      ],
    );
  }
}

class _ProjectLinkButton extends StatelessWidget {
  final String url;
  const _ProjectLinkButton({required this.url});

  @override
  Widget build(BuildContext context) => TextButton.icon(
        icon: const Icon(Icons.link),
        label: const Text('Voir le projet'),
        onPressed: () async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Impossible d’ouvrir le lien.')),
              );
            }
          }
        },
      );
}
