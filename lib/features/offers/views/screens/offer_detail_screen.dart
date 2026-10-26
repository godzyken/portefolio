import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/provider/pricing_provider.dart';
import '../../../../core/provider/tracking_provider.dart';
import '../../../../core/service/tracking_service.dart';
import '../../../home/data/services_data.dart';

/// Fiche offre orientée conversion (remplace la page lecture seule).
class OfferDetailScreen extends ConsumerWidget {
  const OfferDetailScreen({super.key, required this.serviceId});

  final String serviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(portfolioServicesProvider);
    final rationaleAsync = ref.watch(pricingRationaleProvider(serviceId));
    final packsAsync = ref.watch(pricingPacksForServiceProvider(serviceId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offre'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/offres'),
        ),
        actions: [
          TextButton(
            onPressed: () => context.go('/offres'),
            child: const Text('Toutes les offres'),
          ),
        ],
      ),
      body: servicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (services) {
          final service = services.where((s) => s.id == serviceId).firstOrNull;
          if (service == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Offre introuvable'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context.go('/offres'),
                    child: const Text('Retour au catalogue'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 960),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Hero
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: service.category.color
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(service.icon,
                                      color: service.category.color, size: 28),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(service.title,
                                          style: theme.textTheme.headlineSmall
                                              ?.copyWith(
                                                  fontWeight: FontWeight.w800)),
                                      const SizedBox(height: 6),
                                      Text(
                                        service.priceLabel,
                                        style: theme.textTheme.titleLarge
                                            ?.copyWith(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(service.description,
                                style: theme.textTheme.bodyLarge),
                            const SizedBox(height: 20),
                            Wrap(
                              spacing: 12,
                              runSpacing: 10,
                              children: [
                                FilledButton.icon(
                                  onPressed: () {
                                    ref
                                        .read(trackingServiceProvider)
                                        .trackInteraction(
                                      projectId: 'portfolio',
                                      projectName: 'Portfolio',
                                      action: TrackingAction.linkClick,
                                      details: {
                                        'type': 'offer_start_project',
                                        'source_service': serviceId,
                                      },
                                    );
                                    context.push('/project-wizard');
                                  },
                                  icon: const Icon(Icons.rocket_launch_outlined),
                                  label: const Text('Démarrer mon projet'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () => context.go('/contact'),
                                  icon: const Icon(Icons.chat_bubble_outline),
                                  label: const Text('Parler à un expert'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),

                            // Bénéfices
                            Text('Ce qui est inclus',
                                style: theme.textTheme.titleLarge),
                            const SizedBox(height: 12),
                            ...service.features.map(
                              (f) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.check_circle,
                                        size: 18,
                                        color: service.category.color),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(f)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Packs
                            packsAsync.when(
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                              data: (packs) {
                                if (packs.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Choisissez votre formule',
                                        style: theme.textTheme.titleLarge),
                                    const SizedBox(height: 14),
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        final wide = constraints.maxWidth > 720;
                                        final children = packs.map((p) {
                                          return _PackCard(
                                            pack: p,
                                            accent: service.category.color,
                                            onChoose: () =>
                                                context.go('/contact'),
                                          );
                                        }).toList();
                                        if (wide) {
                                          return Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              for (var i = 0;
                                                  i < children.length;
                                                  i++) ...[
                                                if (i > 0)
                                                  const SizedBox(width: 12),
                                                Expanded(child: children[i]),
                                              ],
                                            ],
                                          );
                                        }
                                        return Column(
                                          children: [
                                            for (final c in children) ...[
                                              c,
                                              const SizedBox(height: 12),
                                            ],
                                          ],
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 28),
                                  ],
                                );
                              },
                            ),

                            // Rationale marché
                            rationaleAsync.when(
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                              data: (rationale) {
                                if (rationale == null) {
                                  return const SizedBox.shrink();
                                }
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (rationale.introText.isNotEmpty) ...[
                                      Text('Pourquoi ce tarif ?',
                                          style: theme.textTheme.titleLarge),
                                      const SizedBox(height: 10),
                                      Text(rationale.introText,
                                          style: theme.textTheme.bodyMedium),
                                      const SizedBox(height: 20),
                                    ],
                                    if (rationale
                                        .marketComparison.isNotEmpty) ...[
                                      Text('Prix constatés sur le marché',
                                          style: theme.textTheme.titleMedium),
                                      const SizedBox(height: 10),
                                      _MarketTable(
                                          rows: rationale.marketComparison),
                                      const SizedBox(height: 20),
                                    ],
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Sticky CTA
              Material(
                elevation: 8,
                color: theme.colorScheme.surface,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 960),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(service.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                  Text(
                                    service.priceLabel,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            FilledButton.icon(
                              onPressed: () => context.push('/project-wizard'),
                              icon: const Icon(Icons.rocket_launch, size: 18),
                              label: const Text('Démarrer'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PackCard extends StatelessWidget {
  const _PackCard({
    required this.pack,
    required this.accent,
    required this.onChoose,
  });

  final PricingPack pack;
  final Color accent;
  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: pack.isFeatured
              ? accent.withValues(alpha: 0.8)
              : theme.dividerColor.withValues(alpha: 0.4),
          width: pack.isFeatured ? 1.6 : 1,
        ),
        color: pack.isFeatured
            ? accent.withValues(alpha: 0.08)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(pack.name,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ),
              if (pack.isFeatured)
                const Text('★', style: TextStyle(color: Colors.amber)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            pack.priceLabel,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (pack.description != null) ...[
            const SizedBox(height: 6),
            Text(pack.description!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                )),
          ],
          const SizedBox(height: 10),
          ...pack.features.take(5).map(
                (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.check, size: 14, color: accent),
                      const SizedBox(width: 6),
                      Expanded(
                          child: Text(f, style: theme.textTheme.bodySmall)),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: pack.isFeatured
                ? FilledButton(
                    onPressed: onChoose,
                    child: Text('Choisir ${pack.name}'),
                  )
                : OutlinedButton(
                    onPressed: onChoose,
                    child: Text('Choisir ${pack.name}'),
                  ),
          ),
        ],
      ),
    );
  }
}

class _MarketTable extends StatelessWidget {
  const _MarketTable({required this.rows});
  final List<MarketComparisonRow> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(1.4),
          2: FlexColumnWidth(1.4),
        },
        border: TableBorder(
          horizontalInside: BorderSide(color: theme.dividerColor),
        ),
        children: [
          TableRow(
            decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest),
            children: [
              _cell('Prestation', context, bold: true),
              _cell('Freelance', context, bold: true),
              _cell('Agence', context, bold: true),
            ],
          ),
          for (final row in rows)
            TableRow(children: [
              _cell(row.label, context),
              _cell(row.freelanceRange, context),
              _cell(row.agencyRange, context),
            ]),
        ],
      ),
    );
  }

  Widget _cell(String text, BuildContext context, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(
        text,
        style:
            TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal),
      ),
    );
  }
}
