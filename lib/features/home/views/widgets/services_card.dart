import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/generator/data/extention_models.dart';
import 'package:portefolio/features/generator/views/widgets/hover_card.dart';

class ServicesCard extends ConsumerStatefulWidget {
  final Service service;

  const ServicesCard({super.key, required this.service});

  @override
  ConsumerState<ServicesCard> createState() => _ServicesCardState();
}

class _ServicesCardState extends ConsumerState<ServicesCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return HoverCard(
          id: widget.service.title,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // --- Image de fond ---
                Image.asset(
                  widget.service.imageUrl!,
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                  alignment: Alignment.center,
                ),

                // --- Film glass / blur + dégradé ---
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.lightGreenAccent.withAlpha(
                            (255 * 0.35).toInt(),
                          ),
                          Colors.indigoAccent.withAlpha((255 * 0.35).toInt()),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),

                // ✅ Contenu
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Spacer(),
                      Icon(
                        widget.service.icon,
                        size: 56,
                        color: Colors.black87,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.service.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            widget.service.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 450.ms, delay: 100.ms)
        .slideY(begin: 0.15, duration: 450.ms, curve: Curves.easeOutBack);
  }
}
