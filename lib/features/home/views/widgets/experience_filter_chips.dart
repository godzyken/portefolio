import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/provider/providers.dart';

class ExperienceFilterChips extends ConsumerStatefulWidget {
  const ExperienceFilterChips({super.key, required this.tags});

  final List<String> tags;

  @override
  ConsumerState createState() => _ExperienceFilterChipsState();
}

class _ExperienceFilterChipsState extends ConsumerState<ExperienceFilterChips> {
  @override
  Widget build(BuildContext context) {
    final selectedTags = ref.watch(experienceFilterProvider);

    return Wrap(
      spacing: 2,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.start,
      runAlignment: WrapAlignment.center,
      runSpacing: 2,
      children:
          widget.tags.map((tag) {
            final isSelected = selectedTags == tag;
            return ChoiceChip(
              label: Text(tag),
              selected: isSelected,
              onSelected:
                  (_) =>
                      ref.read(experienceFilterProvider.notifier).state =
                          isSelected ? null : tag,
            );
          }).toList(),
    );
  }
}
