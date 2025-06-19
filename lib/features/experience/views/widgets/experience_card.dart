import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/generator/data/extention_models.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../constants/tech_logos.dart';
import '../../../generator/views/widgets/adaptive_card.dart';

class ExperienceCard extends ConsumerWidget {
  final Experience experience;
  const ExperienceCard({super.key, required this.experience});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AdaptiveCard(
      title: experience.entreprise,
      bulletPoints: [
        ...experience.objectifs.take(2), // aperçu : 2 objectifs
        ...experience.missions.take(1), // + 1 mission
        if (experience.periode.isNotEmpty) 'Période : ${experience.periode}',
      ],
      imagePath: experience.image.isNotEmpty ? experience.image : null,
      onTap: () => _showDetails(context),
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
}

// ===========================================================================
// DETAIL SHEET
// ===========================================================================
class _ExperienceDetails extends StatelessWidget {
  final Experience experience;
  const _ExperienceDetails({required this.experience});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 900;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 32,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: isWide ? _buildWide(theme) : _buildNarrow(theme),
      ),
    );
  }

  // ------------------------- 2 colonnes (desktop) --------------------------
  Widget _buildWide(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(experience: experience),
              const SizedBox(height: 24),
              _SectionTitle('🎯 Objectifs'),
              _BulletList(items: experience.objectifs),
              const SizedBox(height: 24),
              _SectionTitle('🛠 Missions'),
              _BulletList(items: experience.missions),
              if (experience.stack.isNotEmpty) ...[
                const SizedBox(height: 24),
                _SectionTitle('🧰 Stack'),
                const SizedBox(height: 8),
                _ExperienceStack(stack: experience.stack),
              ]
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
                _SectionTitle('📈 Résultats'),
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
      children: [
        _Header(experience: experience),
        const SizedBox(height: 24),
        _SectionTitle('🎯 Objectifs'),
        _BulletList(items: experience.objectifs),
        const SizedBox(height: 20),
        _SectionTitle('🛠 Missions'),
        _BulletList(items: experience.missions),
        if (experience.stack.isNotEmpty) ...[
          const SizedBox(height: 20),
          _SectionTitle('🧰 Stack'),
          const SizedBox(height: 8),
          _ExperienceStack(stack: experience.stack),
        ],
        if (experience.resultats.isNotEmpty) ...[
          const SizedBox(height: 20),
          _SectionTitle('📈 Résultats'),
          _BulletList(items: experience.resultats),
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
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (experience.periode.isNotEmpty)
                Text(
                  experience.periode,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.grey[600]),
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
        child: Text(title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
      );
}

class _BulletList extends StatelessWidget {
  final List<String> items;
  const _BulletList({required this.items});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• '),
                      Expanded(child: Text(e)),
                    ],
                  ),
                ))
            .toList(),
      );
}

class _ExperienceStack extends StatelessWidget {
  final Map<String, List<String>> stack;
  const _ExperienceStack({required this.stack});

  @override
  Widget build(BuildContext context) {
    final allTechnos = stack.entries
        .expand((entry) => entry.value.map((tech) => {
              'type': entry.key,
              'name': tech,
              'logo': techLogos[tech.toLowerCase()],
            }))
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
                  child: Text(t['name']!,
                      style: Theme.of(context).textTheme.bodySmall),
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Impossible d’ouvrir le lien.')),
            );
          }
        },
      );
}
