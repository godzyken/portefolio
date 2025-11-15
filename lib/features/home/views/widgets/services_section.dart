import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/ui/widgets/responsive_text.dart';
import 'package:portefolio/features/generator/views/generator_widgets_extentions.dart';

import '../../../../core/provider/json_data_provider.dart';

class ServicesSection extends ConsumerStatefulWidget {
  const ServicesSection({super.key});

  @override
  ConsumerState<ServicesSection> createState() => _ServicesSectionState();
}

class _ServicesSectionState extends ConsumerState<ServicesSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // Lance l'animation une fois que Flutter a tout construit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final servicesAsync = ref.watch(servicesJsonProvider);

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: servicesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: ResponsiveText.headlineMedium('Erreur : $err'),
          ),

          // Le contenu du layout responsive
          data: (services) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------- TITRE ----------
                Center(
                  child: Column(
                    children: [
                      ResponsiveText.titleLarge(
                        'Mes Services',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..shader = LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.secondary,
                              ],
                            ).createShader(const Rect.fromLTWH(0, 0, 300, 70)),
                        ),
                      ),
                      const ResponsiveBox(paddingSize: ResponsiveSpacing.l),
                      ResponsiveText.bodyMedium(
                        'Solutions digitales pour votre entreprise',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                const ResponsiveBox(paddingSize: ResponsiveSpacing.l),

                // ---------- LISTE RESPONSIVE ----------
                const ServicesSlider()
              ],
            );
          },
        ),
      ),
    );
  }
}
