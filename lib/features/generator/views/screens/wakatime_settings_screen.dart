import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/ui/widgets/responsive_text.dart';

import '../../../../core/ui/widgets/duration_formatter.dart';
import '../../../projets/providers/projects_extentions_providers.dart';
import '../../data/extention_models.dart';
import '../../services/wakatime_service.dart';
import '../widgets/wakatime_debug.dart';

class WakaTimeSettingsScreen extends ConsumerStatefulWidget {
  const WakaTimeSettingsScreen({super.key});

  @override
  ConsumerState<WakaTimeSettingsScreen> createState() =>
      _WakaTimeSettingsScreenState();
}

class _WakaTimeSettingsScreenState
    extends ConsumerState<WakaTimeSettingsScreen> {
  final _apiKeyController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isKeyVisible = false;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    final apiKey = await ref.read(wakaTimeApiKeyProvider.future);
    if (apiKey != null || apiKey!.isNotEmpty && mounted) {
      _apiKeyController.text = apiKey;
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _testAndSaveApiKey() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiKey = _apiKeyController.text.trim();
      if (apiKey.isEmpty) throw Exception('La clé API ne peut pas être vide');

      final service = WakaTimeService(apiKey: apiKey);
      final stats = await service.getStats(range: 'last_7_days');
      if (stats == null) {
        throw Exception('Clé API invalide ou erreur de connexion');
      }

      await ref.read(wakaTimeApiKeyNotifierProvider.notifier).setApiKey(apiKey);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: ResponsiveText.bodyMedium(
                '✅ Clé API WakaTime configurée avec succès!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _clearApiKey() async {
    await ref.read(wakaTimeApiKeyNotifierProvider.notifier).clearApiKey();
    _apiKeyController.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: ResponsiveText.bodyMedium('Clé API supprimée')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentApiKey = ref.watch(wakaTimeApiKeyNotifierProvider);
    final statsAsync = ref.watch(wakaTimeStatsProvider('last_7_days'));
    final projectsAsync = currentApiKey != null
        ? ref.watch(wakaTimeProjectsProvider)
        : const AsyncValue.data(<WakaTimeProject>[]);

    return Scaffold(
      appBar: AppBar(
          title: const ResponsiveText.titleLarge('Configuration WakaTime')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoCard(),
            const ResponsiveBox(paddingSize: ResponsiveSpacing.l),
            _buildApiKeyField(currentApiKey),
            const ResponsiveBox(paddingSize: ResponsiveSpacing.m),
            _buildActionButtons(),
            const ResponsiveBox(paddingSize: ResponsiveSpacing.l),
            if (currentApiKey != null) ...[
              const Divider(),
              const ResponsiveBox(paddingSize: ResponsiveSpacing.m),
              const ResponsiveText.headlineSmall(
                'Statistiques (7 derniers jours)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const ResponsiveBox(paddingSize: ResponsiveSpacing.m),
              statsAsync.when(
                data: (stats) {
                  // Si on a des stats valides, on affiche tout
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Divider(),
                      const SizedBox(height: 16),
                      // ✅ VOICI LA CONFIRMATION VISUELLE
                      _buildConnectionStatus(
                          true, "Connexion à WakaTime active."),
                      const SizedBox(height: 24),
                      const ResponsiveText.headlineSmall(
                        'Statistiques (7 derniers jours)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildStatsCard(
                          stats!), // stats ne peut pas être null ici
                      const SizedBox(height: 24),
                      const ResponsiveText.headlineSmall(
                        'Répartition par projet',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      // Vous pouvez passer stats.projects directement ici
                      _buildProjectsStatChart(stats.projects),
                    ],
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, _) => _buildErrorCard(err.toString()),
              ),
              const ResponsiveBox(paddingSize: ResponsiveSpacing.l),
              const ResponsiveText.bodyMedium(
                'Vos projets WakaTime',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const ResponsiveBox(paddingSize: ResponsiveSpacing.m),
              projectsAsync.when(
                data: (projects) {
                  if (projects.isEmpty) {
                    return const ResponsiveText.headlineMedium(
                        "Aucun projet trouvé sur votre compte.");
                  }
                  return _buildProjectsChart(projects);
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, _) => _buildErrorCard(err.toString()),
              ),
            ],

            // Panel de débogage
            if (kDebugMode) const WakaTimeDebugPanel(),

            // Tests de matching
            if (kDebugMode) ...[
              WakaTimeProjectMatcher(projectTitle: 'portefolio'),
              WakaTimeProjectMatcher(projectTitle: 'Egote Services'),
              WakaTimeProjectMatcher(projectTitle: 'Portfolio'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatus(bool isSuccess, String message) {
    return Card(
      elevation: 2,
      color: isSuccess ? Colors.green.shade50 : Colors.orange.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSuccess ? Colors.green.shade300 : Colors.orange.shade300,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.warning,
              color: isSuccess ? Colors.green.shade700 : Colors.orange.shade700,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ResponsiveText.bodyMedium(
                message,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSuccess
                      ? Colors.green.shade800
                      : Colors.orange.shade800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.info_outline, color: Colors.blue.shade700),
            const SizedBox(width: 8),
            const Text(
              'Comment obtenir votre clé API ?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ]),
          const SizedBox(height: 12),
          const Text(
            '1. Rendez-vous sur wakatime.com/settings/account\n'
            '2. Copiez votre "Secret API Key"\n'
            '3. Collez-la dans le champ ci-dessous',
            style: TextStyle(fontSize: 14),
          ),
        ]),
      ),
    );
  }

  Widget _buildApiKeyField(String? currentApiKey) {
    return TextField(
      controller: _apiKeyController,
      obscureText: !_isKeyVisible,
      decoration: InputDecoration(
        labelText: 'Clé API WakaTime',
        hintText: 'waka_xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx',
        border: const OutlineInputBorder(),
        errorText: _errorMessage,
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon:
                  Icon(_isKeyVisible ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _isKeyVisible = !_isKeyVisible),
            ),
            if (currentApiKey != null)
              IconButton(
                  icon: const Icon(Icons.clear), onPressed: _clearApiKey),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(children: [
      Expanded(
        child: ResponsiveButton.icon(
          onPressed: _isLoading ? null : _testAndSaveApiKey,
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.save),
          label: _isLoading ? 'Test en cours...' : 'Tester et Sauvegarder',
        ),
      ),
    ]);
  }

  Widget _buildErrorCard(String message) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Erreur : $message',
            style: const TextStyle(color: Colors.red)),
      ),
    );
  }

  Widget _buildStatsCard(WakaTimeStats stats) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ListTile(
            leading: const Icon(Icons.timer, color: Colors.blue),
            title: const Text('Temps total de code'),
            trailing: Text(
              DurationFormatter.formatSeconds(stats.totalSeconds),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          const Text('Répartition des langages',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 200, child: _LanguagesPieChart()),
          const Divider(),
          if (stats.projects.isNotEmpty) ...[
            const Text('Top 3 projets',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...stats.projects.take(3).map((p) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.work_outline, color: Colors.green),
                  title: Text(p.name),
                  subtitle:
                      Text('${p.text} • ${p.percent.toStringAsFixed(1)}%'),
                  trailing: Text(p.digital,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                )),
          ],
        ]),
      ),
    );
  }

  Widget _buildProjectsStatChart(List<WakaTimeProjectStat> projects) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Activité par projet (durée totale estimée)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 200),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                titlesData: FlTitlesData(
                  leftTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: true)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= projects.length) {
                          return const SizedBox();
                        }
                        return Transform.rotate(
                          angle: -0.7,
                          child: Text(
                            projects[index].name,
                            style: const TextStyle(fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: projects.take(8).toList().asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: (e.key + 1) * 3.0,
                        color: Colors.blueAccent,
                        width: 14,
                        borderRadius: BorderRadius.circular(4),
                      )
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildProjectsChart(List<WakaTimeProject> projects) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Activité par projet (durée totale estimée)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 200),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                titlesData: FlTitlesData(
                  leftTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: true)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= projects.length) {
                          return const SizedBox();
                        }
                        return Transform.rotate(
                          angle: -0.7,
                          child: Text(
                            projects[index].name,
                            style: const TextStyle(fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: projects.take(8).toList().asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: (e.key + 1) * 3.0,
                        color: Colors.blueAccent,
                        width: 14,
                        borderRadius: BorderRadius.circular(4),
                      )
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _LanguagesPieChart extends StatelessWidget {
  const _LanguagesPieChart();

  @override
  Widget build(BuildContext context) {
    final stats = context
        .findAncestorStateOfType<_WakaTimeSettingsScreenState>()
        ?.ref
        .read(wakaTimeStatsProvider('last_7_days'))
        .maybeWhen(data: (s) => s, orElse: () => null);

    if (stats == null || stats.languages.isEmpty) {
      return const Center(child: Text('Aucune donnée de langage.'));
    }

    final sections = stats.languages.take(5).map((l) {
      return PieChartSectionData(
        value: l.percent,
        title: '${l.name} ${l.percent.toStringAsFixed(1)}%',
        radius: 70,
      );
    }).toList();

    return PieChart(PieChartData(sections: sections, centerSpaceRadius: 40));
  }
}
