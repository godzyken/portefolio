import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/generator/data/extention_models.dart';
import 'package:portefolio/features/generator/views/widgets/hover_card.dart';

class ServicesCard extends ConsumerWidget {
  final Service service;

  const ServicesCard({super.key, required this.service});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return HoverCard(
      id: service.title,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // --- Image de fond ---
            if (service.imageUrl != null)
              Positioned.fill(
                child: Image.asset(
                  service.imageUrl!,
                  fit: BoxFit.cover,
                ),
              ),

            // --- Effet glassmorphism ---
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withAlpha((255 * 0.55).toInt()),
                        theme.colorScheme.primary
                            .withAlpha((255 * 0.35).toInt()),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
            ),

            // --- Contenu ---
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: theme.colorScheme.primary
                        .withAlpha((255 * 0.8).toInt()),
                    child: Icon(service.icon, size: 36, color: Colors.white),
                  ),
                  const SizedBox(height: 16),

                  // Titre
                  Text(
                    service.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  // Description scrollable
                  SizedBox(
                    height: 80,
                    child: SingleChildScrollView(
                      child: Text(
                        service.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Features sous forme de Chips
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: service.features.map((f) {
                      return Chip(
                        label: Text(f),
                        backgroundColor: theme.colorScheme.secondary
                            .withAlpha((255 * 0.25).toInt()),
                        labelStyle: const TextStyle(color: Colors.white),
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
        .slideY(begin: 0.2, duration: 500.ms, curve: Curves.easeOutBack)
        .scale(begin: const Offset(0.95, 0.95));
  }
}
