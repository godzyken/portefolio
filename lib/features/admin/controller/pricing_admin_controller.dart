import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/provider/pricing_provider.dart';
import '../../../core/service/supabase_service.dart';
import '../../home/data/services_data.dart';

/// Opérations d'écriture sur `portfolio_services` / `portfolio_pricing_packs`.
/// Protégées côté serveur par les policies RLS (seul `portfolio_admins` peut
/// écrire) — ce contrôleur ne fait qu'appeler l'API, la sécurité réelle est
/// dans la base.
class PricingAdminController {
  PricingAdminController(this.ref);
  final Ref ref;

  Future<void> upsertServicePrice({
    required String serviceId,
    required double? basePrice,
    required String priceUnit,
    String? priceNote,
  }) async {
    await SupabaseService.client.from('portfolio_services').update({
      'base_price': basePrice,
      'price_unit': priceUnit,
      'price_note': priceNote,
    }).eq('id', serviceId);

    ref.invalidate(portfolioServicesProvider);
  }

  Future<void> createPack(PricingPack pack) async {
    await SupabaseService.client
        .from('portfolio_pricing_packs')
        .insert(pack.toInsertPayload());

    ref.invalidate(pricingPacksProvider);
  }

  Future<void> updatePack(PricingPack pack) async {
    if (pack.id == null) {
      throw ArgumentError('updatePack nécessite un id existant');
    }
    await SupabaseService.client
        .from('portfolio_pricing_packs')
        .update(pack.toInsertPayload())
        .eq('id', pack.id!);

    ref.invalidate(pricingPacksProvider);
  }

  Future<void> deletePack(int packId) async {
    await SupabaseService.client
        .from('portfolio_pricing_packs')
        .delete()
        .eq('id', packId);

    ref.invalidate(pricingPacksProvider);
  }
}

final pricingAdminControllerProvider = Provider<PricingAdminController>((ref) {
  return PricingAdminController(ref);
}, name: 'PricingAdminController');
