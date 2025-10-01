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

    // 🔍 DEBUG: Afficher l'URL de l'image
    developer.log('🖼️ SERVICE: ${service.title}');
    developer.log('📍 IMAGE URL: ${service.imageUrl}');

    return HoverCard(
      id: service.title,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // --- Image de fond ---
            if (service.imageUrl != null && service.imageUrl!.isNotEmpty)
              Positioned.fill(
                child: _buildImage(service.imageUrl!, context),
              )
            else
              // Fallback si pas d'image
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary
                            .withAlpha((255 * 0.3).toInt()),
                        theme.colorScheme.secondary
                            .withAlpha((255 * 0.2).toInt()),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
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
                  Container(
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
                          color: theme.colorScheme.primary
                              .withAlpha((255 * 0.5).toInt()),
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
                  ),
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
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: service.features.map((f) {
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
                          f,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
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

  // Widget pour gérer à la fois les assets locaux et les URLs réseau
  Widget _buildImage(String path, BuildContext context) {
    return SmartImage(
      path: path,
      fit: BoxFit.cover,
      fallbackIcon: service.icon,
      fallbackColor: Theme.of(context).colorScheme.primary,
    );
  }
}
