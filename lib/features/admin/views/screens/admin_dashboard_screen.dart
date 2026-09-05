import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/provider/pricing_provider.dart';
import '../../../home/data/services_data.dart';
import '../../controller/admin_auth_controller.dart';
import '../../controller/pricing_admin_controller.dart';
import '../widgets/analytics_dashboard_view.dart';
import '../widgets/pack_form_dialog.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authChanges = ref.watch(authStateChangesProvider);
    final isAdminAsync = ref.watch(isPortfolioAdminProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(
                  icon: Icon(Icons.analytics_outlined),
                  text: 'Analytics & Conversions'),
              Tab(
                  icon: Icon(Icons.settings_outlined),
                  text: 'Tarifs & Services'),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Retour au site',
              icon: const Icon(Icons.public),
              onPressed: () => context.go('/'),
            ),
            IconButton(
              tooltip: 'Déconnexion',
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await ref.read(adminAuthControllerProvider.notifier).signOut();
                if (context.mounted) context.go('/admin/login');
              },
            ),
          ],
        ),
        body: authChanges.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erreur session: $e')),
          data: (_) {
            return isAdminAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erreur: $e')),
              data: (isAdmin) {
                if (!isAdmin) {
                  return _NotAuthorized(
                    onLoginRedirect: () => context.go('/admin/login'),
                  );
                }
                return const TabBarView(
                  children: [
                    AnalyticsDashboardView(),
                    _ServicesAdminList(),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _NotAuthorized extends StatelessWidget {
  const _NotAuthorized({required this.onLoginRedirect});
  final VoidCallback onLoginRedirect;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.block,
                size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            const Text(
              'Ce compte n\'est pas autorisé à modifier les tarifs.\n'
              'Connecte-toi avec le compte admin, ou ajoute ton email\n'
              'à la table portfolio_admins dans Supabase.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onLoginRedirect,
              child: const Text('Revenir à la connexion'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServicesAdminList extends ConsumerWidget {
  const _ServicesAdminList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(portfolioServicesProvider);

    return servicesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur chargement services: $e')),
      data: (services) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: services.length,
          itemBuilder: (context, i) => _ServiceAdminCard(service: services[i]),
        );
      },
    );
  }
}

class _ServiceAdminCard extends ConsumerStatefulWidget {
  const _ServiceAdminCard({required this.service});
  final Service service;

  @override
  ConsumerState<_ServiceAdminCard> createState() => _ServiceAdminCardState();
}

class _ServiceAdminCardState extends ConsumerState<_ServiceAdminCard> {
  late final TextEditingController _priceCtrl;
  late final TextEditingController _unitCtrl;
  late final TextEditingController _noteCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _priceCtrl = TextEditingController(
        text: widget.service.basePrice?.toStringAsFixed(0) ?? '');
    _unitCtrl = TextEditingController(text: widget.service.priceUnit);
    _noteCtrl = TextEditingController(text: widget.service.priceNote ?? '');
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    _unitCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(pricingAdminControllerProvider).upsertServicePrice(
            serviceId: widget.service.id,
            basePrice: _priceCtrl.text.trim().isEmpty
                ? null
                : double.tryParse(_priceCtrl.text.trim()),
            priceUnit: _unitCtrl.text.trim().isEmpty
                ? 'sur devis'
                : _unitCtrl.text.trim(),
            priceNote:
                _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Tarif de "${widget.service.title}" enregistré ✅')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final packsAsync =
        ref.watch(pricingPacksForServiceProvider(widget.service.id));

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(widget.service.icon, color: widget.service.category.color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(widget.service.title,
                      style: Theme.of(context).textTheme.titleLarge),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 140,
                  child: TextField(
                    controller: _priceCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Prix de base',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _unitCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Unité (ex: à partir de €, €/mois)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                SizedBox(
                  width: 280,
                  child: TextField(
                    controller: _noteCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Note (optionnel)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save_outlined, size: 18),
                  label: const Text('Enregistrer'),
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Packs / offres',
                    style: Theme.of(context).textTheme.titleMedium),
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter un pack'),
                  onPressed: () => showPackFormDialog(
                    context,
                    ref,
                    serviceId: widget.service.id,
                  ),
                ),
              ],
            ),
            packsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(8),
                child: LinearProgressIndicator(),
              ),
              error: (e, _) => Text('Erreur packs: $e'),
              data: (packs) {
                if (packs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Aucun pack pour ce service.'),
                  );
                }
                return Column(
                  children: packs
                      .map((pack) =>
                          _PackTile(pack: pack, serviceId: widget.service.id))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PackTile extends ConsumerWidget {
  const _PackTile({required this.pack, required this.serviceId});
  final PricingPack pack;
  final String serviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: pack.isFeatured
          ? const Icon(Icons.star, color: Colors.amber)
          : const Icon(Icons.card_giftcard_outlined),
      title: Text('${pack.name} — ${pack.priceLabel}'),
      subtitle: Text(pack.description ?? pack.features.join(' · ')),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => showPackFormDialog(context, ref,
                serviceId: serviceId, existing: pack),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Supprimer ce pack ?'),
                  content: Text('"${pack.name}" sera définitivement supprimé.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Annuler')),
                    FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Supprimer')),
                  ],
                ),
              );
              if (confirm == true && pack.id != null) {
                await ref
                    .read(pricingAdminControllerProvider)
                    .deletePack(pack.id!);
              }
            },
          ),
        ],
      ),
    );
  }
}
