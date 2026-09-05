import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/home/data/services_data.dart';
import '../service/supabase_service.dart';
import 'json_data_provider.dart';

/// Services affichés sur le site, AVEC tarifs.
///
/// Source de vérité : table Supabase `portfolio_services`.
/// Si Supabase n'est pas configuré (pas de clés d'env), on retombe sur le
/// catalogue statique `assets/data/services.json` (sans prix) pour que le
/// site reste fonctionnel hors-ligne / en dev local.
final portfolioServicesProvider = FutureProvider<List<Service>>((ref) async {
  if (!SupabaseService.isReady) {
    developer.log(
      'Supabase indisponible, fallback sur assets/data/services.json',
      name: 'portfolioServicesProvider',
    );
    return ref.watch(servicesJsonProvider.future);
  }

  try {
    final rows = await SupabaseService.client
        .from('portfolio_services')
        .select()
        .eq('active', true)
        .order('priority', ascending: true);

    return (rows as List)
        .map((row) => Service.fromJson(row as Map<String, dynamic>))
        .toList();
  } catch (e, st) {
    developer.log('❌ Erreur chargement portfolio_services: $e',
        name: 'portfolioServicesProvider', error: e, stackTrace: st);
    // Fallback silencieux sur le JSON local pour ne jamais casser le site
    return ref.watch(servicesJsonProvider.future);
  }
}, name: 'PortfolioServices');

/// Tous les packs tarifaires actifs, tous services confondus, triés.
final pricingPacksProvider = FutureProvider<List<PricingPack>>((ref) async {
  if (!SupabaseService.isReady) return [];

  try {
    final rows = await SupabaseService.client
        .from('portfolio_pricing_packs')
        .select()
        .eq('active', true)
        .order('priority', ascending: true);

    return (rows as List)
        .map((row) => PricingPack.fromJson(row as Map<String, dynamic>))
        .toList();
  } catch (e, st) {
    developer.log('❌ Erreur chargement portfolio_pricing_packs: $e',
        name: 'pricingPacksProvider', error: e, stackTrace: st);
    return [];
  }
}, name: 'PricingPacks');

/// Packs tarifaires filtrés pour un service donné.
final pricingPacksForServiceProvider =
    FutureProvider.family<List<PricingPack>, String>((ref, serviceId) async {
  final all = await ref.watch(pricingPacksProvider.future);
  return all.where((p) => p.serviceId == serviceId).toList();
}, name: 'PricingPacksForService');

/// Est-ce que l'utilisateur connecté a le droit de modifier les tarifs ?
final isPortfolioAdminProvider = FutureProvider<bool>((ref) async {
  if (!SupabaseService.isReady) return false;
  final user = SupabaseService.client.auth.currentUser;
  if (user == null) return false;

  try {
    final result =
        await SupabaseService.client.rpc('is_portfolio_admin') as bool?;
    return result ?? false;
  } catch (e) {
    developer.log('❌ Erreur vérification admin: $e',
        name: 'isPortfolioAdminProvider');
    return false;
  }
}, name: 'IsPortfolioAdmin');

/// État de session auth Supabase, pour réagir au login/logout dans l'UI.
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return SupabaseService.client.auth.onAuthStateChange;
}, name: 'AuthStateChanges');

/// Contenu de la page publique "pourquoi ce tarif" pour un service donné.
/// Retourne null si aucun contenu n'a été renseigné pour ce service.
final pricingRationaleProvider =
    FutureProvider.family<PricingRationale?, String>((ref, serviceId) async {
  if (!SupabaseService.isReady) return null;

  try {
    final rows = await SupabaseService.client
        .from('portfolio_pricing_rationale')
        .select()
        .eq('service_id', serviceId)
        .limit(1);

    final list = rows as List;
    if (list.isEmpty) return null;
    return PricingRationale.fromJson(list.first as Map<String, dynamic>);
  } catch (e, st) {
    developer.log('❌ Erreur chargement pricing_rationale: $e',
        name: 'pricingRationaleProvider', error: e, stackTrace: st);
    return null;
  }
}, name: 'PricingRationale');
