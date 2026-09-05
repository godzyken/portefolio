import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/provider/pricing_provider.dart';
import '../../../../core/provider/tracking_provider.dart';
import '../../../../core/service/tracking_service.dart';
import '../../data/services_data.dart';

class PricingRationaleScreen extends ConsumerWidget {
  const PricingRationaleScreen({super.key, required this.serviceId});
  final String serviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rationaleAsync = ref.watch(pricingRationaleProvider(serviceId));
    final servicesAsync = ref.watch(portfolioServicesProvider);
    final packsAsync = ref.watch(pricingPacksForServiceProvider(serviceId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pourquoi ce tarif ?'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
      ),
      body: rationaleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (rationale) {
          final service = servicesAsync.maybeWhen(
            data: (list) => list.where((s) => s.id == serviceId).firstOrNull,
            orElse: () => null,
          );

          if (rationale == null) {
            return _EmptyState(serviceTitle: service?.title);
          }

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (service != null) ...[
                        Row(
                          children: [
                            Icon(service.icon,
                                color: service.category.color, size: 28),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(service.title,
                                  style: theme.textTheme.headlineSmall),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          service.priceLabel,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      Text(rationale.introText,
                          style: theme.textTheme.bodyLarge),
                      const SizedBox(height: 32),
                      if (rationale.marketComparison.isNotEmpty) ...[
                        Text('Prix constatés sur le marché',
                            style: theme.textTheme.titleLarge),
                        const SizedBox(height: 12),
                        _MarketTable(rows: rationale.marketComparison),
                        const SizedBox(height: 32),
                      ],
                      if (rationale.portageBreakdown.isNotEmpty) ...[
                        Text('Comment se construit ma rémunération',
                            style: theme.textTheme.titleLarge),
                        const SizedBox(height: 12),
                        _PortageBreakdownCard(data: rationale.portageBreakdown),
                        const SizedBox(height: 32),
                      ],
                      if (rationale.hasExample) ...[
                        Text('Exemple concret',
                            style: theme.textTheme.titleLarge),
                        const SizedBox(height: 12),
                        _ExampleCard(data: rationale.anonymizedExample),
                        const SizedBox(height: 32),
                      ],
                      packsAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (packs) {
                          if (packs.isEmpty) return const SizedBox.shrink();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Mes offres pour ce service',
                                  style: theme.textTheme.titleLarge),
                              const SizedBox(height: 12),
                              ...packs.map((p) => Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      leading: p.isFeatured
                                          ? const Icon(Icons.star,
                                              color: Colors.amber)
                                          : const Icon(
                                              Icons.card_giftcard_outlined),
                                      title:
                                          Text('${p.name} — ${p.priceLabel}'),
                                      subtitle: Text(p.description ??
                                          p.features.join(' · ')),
                                    ),
                                  )),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () {
                          ref.read(trackingServiceProvider).trackInteraction(
                            projectId: 'portfolio',
                            projectName: 'Portfolio',
                            action: TrackingAction.linkClick,
                            details: {
                              'type': 'project_wizard_start',
                              'source_service': serviceId,
                            },
                          );
                          context.push('/project-wizard');
                        },
                        icon: const Icon(Icons.rocket_launch_outlined),
                        label: const Text('Lancer l\'assistant projet IA'),
                      ),
                      const SizedBox(height: 24),
                    ],
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({this.serviceTitle});
  final String? serviceTitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          serviceTitle != null
              ? 'Le détail des tarifs pour "$serviceTitle" arrive bientôt.'
              : 'Le détail de ce tarif arrive bientôt.',
          textAlign: TextAlign.center,
        ),
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
          1: FlexColumnWidth(1.5),
          2: FlexColumnWidth(1.5),
        },
        border: TableBorder(
          horizontalInside: BorderSide(color: theme.dividerColor),
        ),
        children: [
          TableRow(
            decoration:
                BoxDecoration(color: theme.colorScheme.surfaceContainerHighest),
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

class _PortageBreakdownCard extends StatelessWidget {
  const _PortageBreakdownCard({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fraisGestion = data['frais_gestion_pct'];
    final coefficient = data['coefficient_transformation'];
    final note = data['note'] as String?;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (fraisGestion != null || coefficient != null)
              Wrap(
                spacing: 24,
                runSpacing: 12,
                children: [
                  if (fraisGestion != null)
                    _stat('Frais de gestion', '$fraisGestion %', theme),
                  if (coefficient != null)
                    _stat(
                        'Coefficient de transformation', '$coefficient', theme),
                ],
              ),
            if (note != null) ...[
              const SizedBox(height: 12),
              Text(note, style: theme.textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: theme.textTheme.headlineSmall
                ?.copyWith(color: theme.colorScheme.primary)),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = data['title'] as String?;
    final invoiceHt = data['invoice_ht'];
    final baseCalcul = data['base_calcul'];
    final remuneration = data['remuneration_brute'];
    final note = data['note'] as String?;

    return Card(
      color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              Text(title,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontStyle: FontStyle.italic)),
            const SizedBox(height: 12),
            if (invoiceHt != null || baseCalcul != null || remuneration != null)
              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  if (invoiceHt != null)
                    _step('Facturé HT', '$invoiceHt €', theme),
                  const Icon(Icons.arrow_forward, size: 18),
                  if (baseCalcul != null)
                    _step('Base de calcul', '$baseCalcul €', theme),
                  const Icon(Icons.arrow_forward, size: 18),
                  if (remuneration != null)
                    _step('Rémunération brute', '$remuneration €', theme),
                ],
              ),
            if (note != null) ...[
              const SizedBox(height: 12),
              Text(note, style: theme.textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }

  Widget _step(String label, String value, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
