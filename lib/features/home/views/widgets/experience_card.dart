import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../constants/tech_logos.dart';
import '../../data/extentions_models.dart';

class ModernExperienceCard extends StatelessWidget {
  final Experience experience;

  const ModernExperienceCard({super.key, required this.experience});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 1000;

    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: SingleChildScrollView(
            child: InteractiveViewer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (experience.image.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            experience.image,
                            height: 70,
                            width: 70,
                            fit: BoxFit.contain,
                          ),
                        ),
                      if (experience.image.isNotEmpty)
                        const SizedBox(width: 16),
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
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- Contexte
                  Text(
                    experience.contexte,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                  const Divider(height: 32),

                  // --- Corps adaptatif
                  isWide
                      ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Colonne gauche
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SectionTitle("🎯 Objectif"),
                                Text(experience.objectifs),
                                const SizedBox(height: 24),
                                _SectionTitle("🛠 Missions"),
                                Text(experience.missions),
                              ],
                            ),
                          ),
                          const SizedBox(width: 40),
                          // Colonne droite
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (experience.stack.isNotEmpty) ...[
                                  _SectionTitle("🧰 Stack"),
                                  const SizedBox(height: 8),
                                  _ExperienceStack(stack: experience.stack),
                                  const SizedBox(height: 12),
                                ],
                                if (experience.resultats.isNotEmpty) ...[
                                  _SectionTitle("📈 Résultats"),
                                  _ExperienceResults(
                                    resultats: experience.resultats,
                                  ),
                                  const SizedBox(height: 24),
                                ],
                                if (experience.lienProjet.isNotEmpty)
                                  TextButton.icon(
                                    onPressed: () async {
                                      final url = Uri.parse(
                                        experience.lienProjet,
                                      );
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(
                                          url,
                                          mode: LaunchMode.inAppBrowserView,
                                        );
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Impossible d'ouvrir le lien.",
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.link),
                                    label: const Text("Voir le projet"),
                                  ),
                                _ExperienceCodeSnippet(code: experience.code),
                              ],
                            ),
                          ),
                        ],
                      )
                      : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionTitle("🎯 Objectif"),
                          Text(experience.objectifs),
                          const SizedBox(height: 16),
                          _SectionTitle("🛠 Missions"),
                          Text(experience.missions),
                          if (experience.stack.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            _SectionTitle("🧰 Stack"),
                            const SizedBox(height: 8),
                            _ExperienceStack(stack: experience.stack),
                          ],
                          if (experience.resultats.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            _SectionTitle("📈 Résultats"),
                            _ExperienceResults(resultats: experience.resultats),
                          ],
                          if (experience.lienProjet.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: TextButton.icon(
                                onPressed: () async {
                                  final url = Uri.parse(experience.lienProjet);
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Impossible d'ouvrir le lien.",
                                        ),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.link),
                                label: const Text("Voir le projet"),
                              ),
                            ),
                          const SizedBox(height: 12),
                          if (experience.code.isNotEmpty)
                            _ExperienceCodeSnippet(code: experience.code),
                        ],
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _ExperienceStack extends StatelessWidget {
  final Map<String, List<String>> stack;
  const _ExperienceStack({required this.stack});

  @override
  Widget build(BuildContext context) {
    final allTechnos =
        stack.entries
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
        itemBuilder: (context, index) {
          final tech = allTechnos[index];
          return Column(
            children: [
              Tooltip(
                message:
                    '${tech['type'].toString().toUpperCase()} - ${tech['name']}',
                child:
                    tech['logo'] != null
                        ? Image.asset(tech['logo']!, width: 32, height: 32)
                        : Chip(label: Text(tech['name']!)),
              ),
              const SizedBox(height: 4),
              tech['logo'] != null
                  ? Text(
                    tech['name']!,
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                  : const SizedBox(),
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
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children:
              resultats
                  .map(
                    (r) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.check_circle_outline,
                        color: Colors.green,
                      ),
                      title: Text(r),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }
}

class _ExperienceCodeSnippet extends StatelessWidget {
  final String code;
  const _ExperienceCodeSnippet({required this.code});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text("💻 Code (extrait)"),
      children: [
        Container(
          width: double.infinity,
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
            textStyle: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          ),
        ),
      ],
    );
  }
}
