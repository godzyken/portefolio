import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/provider/json_data_provider.dart';
import '../core/provider/providers.dart';
import '../features/experience/views/widgets/experience_filter_chips.dart';
import '../features/parametres/themes/views/widgets/theme_selector.dart';
import '../features/projets/data/project_data.dart';
import '../features/projets/providers/projet_providers.dart';

class AppBarConfig {
  final String title;
  final List<Widget> actions;
  final Widget? drawer;

  const AppBarConfig({
    required this.title,
    this.actions = const [],
    this.drawer,
  });
}

enum AppTab {
  home(path: '/', label: 'Home', icon: Icons.home),
  experiences(path: '/experiences', label: 'Exp', icon: Icons.history),
  projects(path: '/projects', label: 'Projets', icon: Icons.work),
  contact(path: '/contact', label: 'Contact', icon: Icons.mail);

  final String path;
  final String label;
  final IconData icon;

  const AppTab({required this.path, required this.label, required this.icon});

// 🔥 Chaque onglet expose sa config d’AppBar
  AppBarConfig config(BuildContext context, WidgetRef ref) {
    switch (this) {
      case AppTab.home:
        return AppBarConfig(title: "Godzyken Portefolio", actions: [
          // Bouton de debug (à retirer en production)
/*          IconButton(
            icon: const Icon(Icons.bug_report),
            tooltip: 'Debug Assets',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AssetsDebugger()),
              );
            },
          ),*/
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: 'Personnaliser le thème',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ThemeSelector()),
              );
            },
          ),
        ]);

      case AppTab.experiences:
        final expAsync = ref.watch(experiencesProvider);
        final isPageView = ref.watch(isPageViewProvider);

        return AppBarConfig(
            title: "Expériences",
            drawer: Drawer(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: expAsync.when(
                    data: (allExperiences) {
                      final allTags =
                          allExperiences.expand((e) => e.tags).toSet().toList();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Filtres',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: SingleChildScrollView(
                              child: ExperienceFilterChips(tags: allTags),
                            ),
                          ),
                        ],
                      );
                    },
                    error: (e, _) =>
                        Text("Erreur de chargement: ${e.toString()}"),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Row(
                  children: [
                    const Text('Vue:', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    ToggleButtons(
                      constraints:
                          const BoxConstraints(minHeight: 30, minWidth: 40),
                      isSelected: <bool>[isPageView, !isPageView],
                      onPressed: (index) {
                        // ✅ Logique corrigée
                        if (index == 0) {
                          // Clic sur Swipe
                          ref
                              .read(isPageViewProvider.notifier)
                              .enablePageView();
                        } else {
                          // Clic sur Timeline
                          ref
                              .read(isPageViewProvider.notifier)
                              .disablePageView();
                        }
                      },
                      selectedColor: Theme.of(context).colorScheme.onPrimary,
                      color: Theme.of(context).colorScheme.primary,
                      fillColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      children: const [
                        Tooltip(
                          message: 'Mode Swipe (glisser)',
                          child: Text("⇆", style: TextStyle(fontSize: 12)),
                        ),
                        Tooltip(
                          message: 'Mode Timeline',
                          child: Text("⏱", style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ]);

      case AppTab.projects:
        final projects = ref
            .read(projectsProvider)
            .maybeWhen(data: (list) => list, orElse: () => <ProjectInfo>[]);

        return AppBarConfig(
          title: "Mes Projets",
          actions: [
            IconButton(
              icon: const Icon(Icons.select_all),
              tooltip: "Tout sélectionner",
              onPressed: () {
                ref.read(selectedProjectsProvider.notifier).toggleAll(projects);
              },
            ),
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: "Exporter PDF",
              onPressed: () {
                final selected = ref.read(selectedProjectsProvider);
                if (selected.isNotEmpty) {
                  ref.read(pdfExportProvider).export(selected);
                  context.pushNamed("pdf");
                }
              },
            ),
          ],
        );

      case AppTab.contact:
        return const AppBarConfig(title: "Contact");
    }
  }

  static AppTab fromLocation(String location) {
    if (location.startsWith('/experiences')) return AppTab.experiences;
    if (location.startsWith('/projects')) return AppTab.projects;
    if (location.startsWith('/contact')) return AppTab.contact;
    return AppTab.home;
  }
}
