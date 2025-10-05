// lib/features/home/views/widgets/services_card.dart

import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/generator/data/extention_models.dart';
import 'package:portefolio/features/generator/views/widgets/hover_card.dart';

import '../../../parametres/views/widgets/smart_image.dart';

class ServicesCard extends ConsumerWidget {
  final Service service;

  const ServicesCard({super.key, required this.service});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // 🔍 DEBUG: Afficher les infos du service
    developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    developer.log('🎴 RENDERING SERVICE CARD');
    developer.log('📌 Title: ${service.title}');
    developer.log('🖼️ Image URL: ${service.imageUrl}');
    developer.log('✨ Cleaned URL: ${service.cleanedImageUrl}');
    developer.log('✅ Has Valid Image: ${service.hasValidImage}');
    developer.log('🌐 Is Network: ${service.isNetworkImage}');
    developer.log('📦 Is Asset: ${service.isAssetImage}');
    developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    return HoverCard(
      id: service.title,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // --- Image de fond ---
            Positioned.fill(
              child: _buildBackgroundImage(context, theme),
            ),

            // --- Overlay sombre pour meilleure lisibilité ---
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withAlpha((255 * 0.75).toInt()),
                      Colors.black.withAlpha((255 * 0.45).toInt()),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // --- Contenu ---
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icône avec glow effect
                  _buildIconBadge(theme),
                  const SizedBox(height: 20),

                  // Titre
                  Text(
                    service.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Description
                  SizedBox(
                    height: 70,
                    child: SingleChildScrollView(
                      child: Text(
                        service.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withAlpha((255 * 0.9).toInt()),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Features
                  _buildFeatures(service.features),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 150.ms)
        .slideY(begin: 0.2, duration: 500.ms, curve: Curves.easeOutBack);
  }

  /// Construit l'image de fond avec gestion d'erreur robuste
  Widget _buildBackgroundImage(BuildContext context, ThemeData theme) {
    // Si pas d'image valide, afficher un gradient
    if (!service.hasValidImage) {
      developer
          .log('⚠️ Pas d\'image valide, affichage du gradient de fallback');
      return _buildFallbackGradient(theme);
    }

    final imageUrl = service.cleanedImageUrl!;
    developer.log('🎨 Tentative d\'affichage de l\'image: $imageUrl');

    // Utiliser SmartImage pour gérer automatiquement les assets et le réseau
    return SmartImage(
      path: imageUrl,
      fit: BoxFit.cover,
      fallbackIcon: service.icon,
      fallbackColor: theme.colorScheme.primary,
      loadingWidget: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              'Chargement...',
              style: TextStyle(
                color: Colors.white.withAlpha((255 * 0.7).toInt()),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Gradient de fallback quand pas d'image
  Widget _buildFallbackGradient(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withAlpha((255 * 0.4).toInt()),
            theme.colorScheme.secondary.withAlpha((255 * 0.3).toInt()),
            theme.colorScheme.tertiary.withAlpha((255 * 0.2).toInt()),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          service.icon,
          size: 120,
          color: Colors.white.withAlpha((255 * 0.15).toInt()),
        ),
      ),
    );
  }

  /// Badge d'icône avec effet lumineux
  Widget _buildIconBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withAlpha((255 * 0.5).toInt()),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        service.icon,
        size: 32,
        color: Colors.white,
      ),
    );
  }

  /// Construit la liste des features
  Widget _buildFeatures(List<String> features) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: features.map((feature) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha((255 * 0.15).toInt()),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withAlpha((255 * 0.3).toInt()),
            ),
          ),
          child: Text(
            feature,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Widget de debug pour tester l'affichage d'une image
class ServiceImageDebug extends StatelessWidget {
  final Service service;

  const ServiceImageDebug({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Debug: ${service.title}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Infos
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Title: ${service.title}'),
                    const SizedBox(height: 8),
                    Text('Original URL: ${service.imageUrl ?? "null"}'),
                    const SizedBox(height: 8),
                    Text('Cleaned URL: ${service.cleanedImageUrl ?? "null"}'),
                    const SizedBox(height: 8),
                    Text('Has Valid Image: ${service.hasValidImage}'),
                    const SizedBox(height: 8),
                    Text('Is Network: ${service.isNetworkImage}'),
                    const SizedBox(height: 8),
                    Text('Is Asset: ${service.isAssetImage}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Test d'affichage
            const Text(
              'Test d\'affichage:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            if (service.hasValidImage)
              SizedBox(
                height: 300,
                child: SmartImage(
                  path: service.cleanedImageUrl!,
                  fit: BoxFit.contain,
                  fallbackIcon: service.icon,
                ),
              )
            else
              Container(
                height: 300,
                color: Colors.grey.shade300,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(service.icon, size: 64),
                      const SizedBox(height: 8),
                      const Text('Pas d\'image disponible'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
