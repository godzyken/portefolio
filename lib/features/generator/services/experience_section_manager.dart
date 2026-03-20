import 'package:flutter/material.dart';

import '../../../core/ui/widgets/smart_image.dart';
import '../../experience/data/experiences_data.dart';
import '../../projets/data/project_data.dart';
import '../../projets/data/project_section.dart';
import '../views/generator_widgets_extentions.dart';
import '../views/widgets/sections/architecture_diagrame_section.dart';

/// Tags qui indiquent une expérience IT / développement logiciel
const _kItTags = {
  'flutter',
  'dart',
  'angular',
  'react',
  'vue',
  'javascript',
  'typescript',
  'node',
  'nodejs',
  'express',
  'php',
  'laravel',
  'python',
  'java',
  'c#',
  'kotlin',
  'swift',
  'firebase',
  'supabase',
  'hive',
  'mongodb',
  'postgresql',
  'mysql',
  'elasticsearch',
  'aws',
  'gcp',
  'azure',
  'docker',
  'ci/cd',
  'git',
  'github',
  'gitlab',
  'riverpod',
  'getx',
  'mobx',
  'redux',
  'bloc',
  'full‑stack',
  'fullstack',
  'frontend',
  'backend',
  'devops',
  'sig',
  'prestashop',
  'magento',
  'wordpress',
  'ionic',
  'capacitorjs',
  'amoa',
  'ui/ux',
  'iot',
  'vr',
  'pdf',
  'web',
};

/// Construit les sections à afficher dans ImmersiveExperienceDetail.
///
/// - Toujours présentes : présentation, missions, résultats
/// - Si IT : stack, code snippet, et (futur) dashboard IoT
class ExperienceSectionManager {
  final Experience experience;
  final ProjectInfo? project;

  ExperienceSectionManager(this.experience, {this.project});

  // ── Détection ──────────────────────────────────────────────────────────────

  bool get isIT {
    final tagsLower = experience.tags.map((t) => t.toLowerCase()).toSet();
    return tagsLower.intersection(_kItTags).isNotEmpty;
  }

  bool get hasStack => experience.stack.isNotEmpty;
  bool get hasCode =>
      experience.code.isNotEmpty && experience.code.trim() != '';
  bool get hasObjectifs => experience.objectifs.isNotEmpty;
  bool get hasMissions => experience.missions.isNotEmpty;
  bool get hasResultats => experience.resultats.isNotEmpty;
  bool get hasIoT =>
      isIT && experience.tags.any((t) => t.toLowerCase().contains('iot'));
  bool get hasSIG => experience.tags.any((t) => t.toLowerCase() == 'sig');

  // ── Construction des sections ──────────────────────────────────────────────

  List<ProjectSection> buildSections(BuildContext context) {
    final sections = <ProjectSection>[];

    // 1. Présentation (toujours)
    sections.add(_presentationSection());

    // 2. Stack technique (IT seulement)
    if (isIT && hasStack) {
      sections.add(_stackSection());
    }

    // 3. Objectifs
    if (hasObjectifs) {
      sections.add(_objectifsSection());
    }

    // 4. Missions
    if (hasMissions) {
      sections.add(_missionsSection());
    }

    // 5. Code snippet (IT avec code)
    if (isIT && hasCode) {
      sections.add(_codeSection());
    }

    // 6. IoT dashboard (si tag IoT)
    if (hasIoT) {
      sections.add(_iotSection());
    }

    // 7. Architecture (IT avec stack)
    if (isIT && hasStack) {
      sections.add(_architectureSection());
    }

    // 8. Résultats
    if (hasResultats) {
      sections.add(_resultatsSection());
    }

    return sections;
  }

  // ── Builders de sections individuelles ────────────────────────────────────

  ProjectSection _presentationSection() => ProjectSection(
        id: 'presentation',
        title: 'Présentation',
        icon: Icons.business_center_outlined,
        builder: (context, info) => ExperiencePresentationSection(
          experience: experience,
          info: info,
        ),
      );

  ProjectSection _stackSection() => ProjectSection(
        id: 'stack',
        title: 'Stack',
        icon: Icons.layers_outlined,
        builder: (context, info) => ExperienceStackSection(
          experience: experience,
          theme: Theme.of(context),
          info: info,
        ),
      );

  ProjectSection _objectifsSection() => ProjectSection(
        id: 'objectifs',
        title: 'Objectifs',
        icon: Icons.flag_outlined,
        builder: (context, info) => _SimpleListSection(
          title: 'Objectifs',
          icon: Icons.flag_outlined,
          color: Colors.cyan,
          items: experience.objectifs,
        ),
      );

  ProjectSection _missionsSection() => ProjectSection(
        id: 'missions',
        title: 'Missions',
        icon: Icons.task_alt_outlined,
        builder: (context, info) => _SimpleListSection(
          title: 'Missions',
          icon: Icons.task_alt_outlined,
          color: Colors.greenAccent,
          items: experience.missions,
          useCheck: true,
        ),
      );

  ProjectSection _codeSection() => ProjectSection(
        id: 'code',
        title: 'Code',
        icon: Icons.code,
        builder: (context, info) => _CodeSnippetSection(
          code: experience.code,
          tags: experience.tags,
        ),
      );

  ProjectSection _iotSection() => ProjectSection(
        id: 'iot',
        title: 'IoT',
        icon: Icons.sensors,
        builder: (context, info) => IoTSection(info: info),
      );

  ProjectSection _architectureSection() => ProjectSection(
        id: 'architecture',
        title: 'Architecture',
        icon: Icons.account_tree_outlined,
        builder: (context, info) => ArchitectureDiagramSection(
          experience: experience,
          project: project,
        ),
      );

  ProjectSection _resultatsSection() => ProjectSection(
        id: 'resultats',
        title: 'Résultats',
        icon: Icons.trending_up,
        builder: (context, info) => _SimpleListSection(
          title: 'Résultats',
          icon: Icons.trending_up,
          color: Colors.amber,
          items: experience.resultats,
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets de sections internes
// ─────────────────────────────────────────────────────────────────────────────

/// Section de présentation : logo, poste, période, contexte
class ExperiencePresentationSection extends StatelessWidget {
  final Experience experience;
  final dynamic info;

  const ExperiencePresentationSection({
    super.key,
    required this.experience,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo + infos
          Row(
            children: [
              if (experience.logo.isNotEmpty)
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white.withValues(alpha: 0.1),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: SmartImage(
                      path: experience.logo,
                      fit: BoxFit.contain,
                      enableShimmer: true,
                    ),
                  ),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      experience.poste,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF2D78),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          experience.entreprise,
                          style: const TextStyle(
                            color: Color(0xFFFF2D78),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_outlined,
                          size: 13,
                          color: Colors.white54,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          experience.periode,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Tags
          if (experience.tags.isNotEmpty) ...[
            const SizedBox(height: 20),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: experience.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      letterSpacing: 0.3,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          // Contexte
          if (experience.contexte.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Contexte',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    experience.contexte,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Image
          if (experience.image.isNotEmpty) ...[
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SmartImage(
                path: experience.image,
                fit: BoxFit.contain,
                width: double.infinity,
                height: 200,
                enableShimmer: true,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Section liste générique (objectifs, missions, résultats)
class _SimpleListSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;
  final bool useCheck;

  const _SimpleListSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
    this.useCheck = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    child: useCheck
                        ? Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: color,
                          )
                        : Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(top: 5),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section snippet de code avec coloration syntaxique simple
class _CodeSnippetSection extends StatelessWidget {
  final String code;
  final List<String> tags;

  const _CodeSnippetSection({
    required this.code,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.code, color: Colors.greenAccent, size: 20),
              SizedBox(width: 10),
              Text(
                'Extrait de code',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1117),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.greenAccent.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header type éditeur
                Row(
                  children: [
                    _dot(Colors.red),
                    const SizedBox(width: 6),
                    _dot(Colors.amber),
                    const SizedBox(width: 6),
                    _dot(Colors.green),
                  ],
                ),
                const SizedBox(height: 16),
                SelectableText(
                  code,
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontFamily: 'monospace',
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color c) => Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      );
}
