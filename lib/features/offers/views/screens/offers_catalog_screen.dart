import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/provider/pricing_provider.dart';
import '../../../home/data/services_data.dart';

/// Catalogue d'offres type magazine — orienté conversion.
class OffersCatalogScreen extends ConsumerWidget {
  const OffersCatalogScreen({
    super.key,
    this.highlightCategory,
    this.highlightServiceId,
  });

  /// Filtre optionnel: mobile | web | desktop | amoa | cloud | support
  final String? highlightCategory;

  /// Met en avant un service précis (ex: mobile-dev)
  final String? highlightServiceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(portfolioServicesProvider);
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width > 1100 ? 3 : width > 700 ? 2 : 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes offres'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => context.go('/contact'),
            icon: const Icon(Icons.mail_outline, size: 18),
            label: const Text('Me contacter'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: servicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (services) {
          var list = List<Service>.from(services)
            ..sort((a, b) => a.priority.compareTo(b.priority));

          if (highlightCategory != null && highlightCategory!.isNotEmpty) {
            final cat = highlightCategory!.toLowerCase();
            final filtered = list
                .where((s) =>
                    s.category.name.toLowerCase() == cat ||
                    s.id.toLowerCase().contains(cat))
                .toList();
            if (filtered.isNotEmpty) list = filtered;
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mes offres',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Des solutions concrètes pour avancer vite — choisissez une offre, comparez, démarrez.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: list.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: crossAxisCount == 1 ? 1.35 : 0.92,
                        ),
                        itemBuilder: (context, index) {
                          final s = list[index];
                          final featured = s.id == highlightServiceId ||
                              s.id == 'mobile-dev' &&
                                  highlightServiceId == null &&
                                  highlightCategory == null;
                          return _OfferCard(
                            service: s,
                            featured: featured || s.id == 'amoa-conseil',
                          );
                        },
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

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.service, this.featured = false});

  final Service service;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = service.category.color;

    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.go('/offres/${service.id}'),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: featured
                  ? color.withValues(alpha: 0.7)
                  : theme.dividerColor.withValues(alpha: 0.4),
              width: featured ? 1.5 : 1,
            ),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(service.icon, color: color, size: 22),
                  ),
                  const Spacer(),
                  if (featured)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '★ Populaire',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                service.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                service.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Text(
                service.priceLabel,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              ...service.features.take(3).map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle,
                              size: 14, color: color.withValues(alpha: 0.9)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              f,
                              style: theme.textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              const Spacer(),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.go('/offres/${service.id}'),
                  child: const Text('Voir l\'offre'),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/contact'),
                  child: const Text('Demander un devis'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
