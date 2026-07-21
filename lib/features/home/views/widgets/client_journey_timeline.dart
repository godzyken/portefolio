import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/provider/business_plan_provider.dart';
import '../../../../core/ui/widgets/responsive_text.dart';
import '../../../generator/data/models/business_plan_models.dart';

/// Timeline du parcours client, construite à partir de l'ordre des
/// `services` dans `business_plan.json` : Audit → AMOA → Pilotage de projet
/// → Développement → Transformation digitale → IA → Formation.
///
/// Changer l'ordre ou le contenu des services dans le JSON met à jour
/// automatiquement la timeline, sans toucher au code.
class ClientJourneyTimeline extends ConsumerWidget {
  const ClientJourneyTimeline({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final plan = ref.watch(businessPlanProvider).asData?.value;

    if (plan == null || plan.services.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const ResponsiveText.titleLarge(
          'Votre parcours, étape par étape',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const ResponsiveText.bodyMedium(
          'De l\'audit initial à la formation de vos équipes, une méthode claire à chaque étape.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 32),
        for (var i = 0; i < plan.services.length; i++)
          _TimelineStep(
            index: i,
            isLast: i == plan.services.length - 1,
            service: plan.services[i],
            color: i.isEven ? theme.colorScheme.primary : theme.colorScheme.secondary,
          ),
      ],
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.index,
    required this.isLast,
    required this.service,
    required this.color,
  });

  final int index;
  final bool isLast;
  final BusinessPlanService service;
  final Color color;

  IconData get _icon => switch (service.id) {
    'audit' => Icons.fact_check_outlined,
    'amoa' => Icons.assignment_outlined,
    'project' => Icons.timeline_outlined,
    'flutter' => Icons.phone_iphone_outlined,
    'transformation' => Icons.sync_alt_outlined,
    'ai' => Icons.smart_toy_outlined,
    'training' => Icons.school_outlined,
    _ => Icons.check_circle_outline,
  };

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.18),
                  border: Border.all(color: color, width: 2),
                ),
                child: Icon(_icon, color: color, size: 20),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: color.withValues(alpha: 0.25),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ResponsiveText.bodySmall(
                    'ÉTAPE ${index + 1}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ResponsiveText.titleMedium(
                    service.title,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  ResponsiveText.bodyMedium(
                    service.description,
                    style: const TextStyle(color: Colors.white70, height: 1.5),
                  ),
                  if (service.deliverables.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: service.deliverables
                          .map((d) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: color.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          d,
                          style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}