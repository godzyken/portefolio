import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/widgets/duration_formatter.dart';
import '../../../projets/providers/projects_extentions_providers.dart';

/// Widget de débogage pour WakaTime
class WakaTimeDebugPanel extends ConsumerWidget {
  const WakaTimeDebugPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiKeyAsync = ref.watch(wakaTimeApiKeyProvider);
    final projectsAsync = ref.watch(wakaTimeProjectsProvider);
    final statsAsync = ref.watch(wakaTimeStatsProvider('last_7_days'));

    return Card(
      margin: const EdgeInsets.all(16),
      child: ExpansionTile(
        leading: const Icon(Icons.bug_report),
        title: const Text('🔍 WakaTime Debug Panel'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // État de l'API Key
                _buildSection(
                  'API Key',
                  apiKeyAsync.when(
                    data: (key) => key != null && key.isNotEmpty
                        ? '✅ Configurée (${key.substring(0, 10)}...)'
                        : '❌ Non configurée',
                    loading: () => '⏳ Chargement...',
                    error: (e, _) => '❌ Erreur: $e',
                  ),
                ),

                const Divider(height: 32),

                // État des projets
                _buildSection(
                  'Projets WakaTime',
                  projectsAsync.when(
                    data: (projects) {
                      if (projects.isEmpty) {
                        return '⚠️ Aucun projet trouvé';
                      }
                      return '✅ ${projects.length} projets chargés\n\n${projects.take(5).map((p) => '• ${p.name}${p.badge != null ? ' (badge ✓)' : ''}').join('\n')}';
                    },
                    loading: () => '⏳ Chargement...',
                    error: (e, _) => '❌ Erreur: $e',
                  ),
                ),

                const Divider(height: 32),

                // État des stats
                _buildSection(
                  'Statistiques (7 jours)',
                  statsAsync.when(
                    data: (stats) {
                      if (stats == null) {
                        return '⚠️ Aucune statistique';
                      }
                      return '✅ Temps total: ${_formatSeconds(stats.totalSeconds)}\n'
                          '📊 ${stats.projects.length} projets\n'
                          '💻 ${stats.languages.length} langages';
                    },
                    loading: () => '⏳ Chargement...',
                    error: (e, _) => '❌ Erreur: $e',
                  ),
                ),

                const SizedBox(height: 16),

                // Boutons d'action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.invalidate(wakaTimeProjectsProvider);
                        ref.invalidate(wakaTimeStatsProvider);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Rafraîchir'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        _showProjectsList(context, ref);
                      },
                      icon: const Icon(Icons.list),
                      label: const Text('Voir tous'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          ),
          child: Text(
            content,
            style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
          ),
        ),
      ],
    );
  }

  String _formatSeconds(double seconds) {
    final duration = Duration(seconds: seconds.toInt());
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}min';
  }

  void _showProjectsList(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.read(wakaTimeProjectsProvider);

    projectsAsync.whenData((projects) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Projets WakaTime'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return ListTile(
                  leading: Icon(
                    project.badge != null ? Icons.verified : Icons.folder,
                    color: project.badge != null ? Colors.blue : Colors.grey,
                  ),
                  title: Text(project.name),
                  subtitle: Text(
                    'Dernier heartbeat: ${project.lastHeartbeatAt?.toString() ?? 'N/A'}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: project.hasPublicUrl
                      ? const Icon(Icons.public, size: 16)
                      : null,
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        ),
      );
    });
  }
}

/// Widget pour tester le matching d'un projet spécifique
class WakaTimeProjectMatcher extends ConsumerWidget {
  final String projectTitle;

  const WakaTimeProjectMatcher({
    super.key,
    required this.projectTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wakaProject = ref.watch(wakaTimeProjectProvider(projectTitle));
    final isTracked = ref.watch(isProjectTrackedProvider(projectTitle));
    final timeSpentAsync = ref.watch(projectTimeSpentProvider(projectTitle));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test: "$projectTitle"',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('✓ Tracké: ${isTracked ? 'Oui' : 'Non'}'),
            Text('✓ Projet trouvé: ${wakaProject?.name ?? 'Aucun'}'),
            Text('✓ Badge: ${wakaProject?.badge != null ? 'Oui' : 'Non'}'),
            const SizedBox(height: 4),
            timeSpentAsync.when(
              data: (duration) => Text(
                '⏱ Temps: ${duration != null ? DurationFormatter.formatDuration(duration) : 'N/A'}',
              ),
              loading: () => const Text('⏱ Temps: Chargement...'),
              error: (e, _) => Text('⏱ Temps: Erreur - $e'),
            ),
          ],
        ),
      ),
    );
  }
}
