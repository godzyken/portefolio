import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/provider/providers.dart';

import '../widgets/experience_widgets_extentions.dart';
import 'experience_slide_screen.dart';

class ExperiencesScreen extends ConsumerWidget {
  const ExperiencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final experiencesAsync = ref.watch(experiencesFutureProvider);
    final isPageView = ref.watch(isPageViewProvider);

    final appBarActions = [
      Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Row(
          children: [
            const Text('Vue:', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            ToggleButtons(
              constraints: const BoxConstraints(minHeight: 30, minWidth: 40),
              isSelected: <bool>[isPageView, !isPageView],
              onPressed: (index) {
                ref.read(isPageViewProvider.notifier).state = index == 0;
              },
              selectedColor: Theme.of(context).colorScheme.onPrimary,
              color: Theme.of(context).colorScheme.primary,
              fillColor: Theme.of(context).colorScheme.primary.withAlpha(50),
              borderRadius: BorderRadius.circular(8),
              children: const [
                Text("⇆", style: TextStyle(fontSize: 12)), // Swipe
                Text("⏱", style: TextStyle(fontSize: 12)), // Timeline
              ],
            ),
          ],
        ),
      ),
    ];

    final customDrawer = Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: experiencesAsync.when(
            data: (allExperiences) {
              final allTags = allExperiences
                  .expand((e) => e.tags)
                  .toSet()
                  .toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filtres',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
            error: (e, _) => Text("Erreur de chargement: ${e.toString()}"),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );

    return experiencesAsync.when(
      data: (allExperiences) {
        final filteredExperiences = ref.watch(filterExperiencesProvider);
        return filteredExperiences.isEmpty
            ? const Center(child: Text('Aucune expérience pour ce filtre.'))
            : isPageView
            ? ExperienceSlideScreen(experiences: filteredExperiences)
            : ExperienceTimeline(experiences: filteredExperiences);
      },
      error: (e, _) =>
          Center(child: Text('Une erreur est survenue: ${e.toString()}')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}
