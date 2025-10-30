import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/ui/widgets/responsive_text.dart';
import 'package:portefolio/features/home/views/widgets/services_card.dart';

import '../../../../core/affichage/screen_size_detector.dart';
import '../../../../core/provider/json_data_provider.dart';

class ServicesSection extends ConsumerWidget {
  const ServicesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(responsiveInfoProvider);
    final theme = Theme.of(context);

    final servicesAsync = ref.watch(servicesJsonProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre de section
        Center(
          child: Column(
            children: [
              ResponsiveText.titleLarge(
                'Mes Services',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: info.isMobile ? 28 : 40,
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
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: info.isMobile ? 14 : 16,
                ),
              ),
            ],
          ),
        ),

        const ResponsiveBox(height: 40),

        // Grille de services
        servicesAsync.when(
            data: (services) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  // Adapter le nombre de colonnes selon la largeur
                  int crossAxisCount;
                  if (info.isMobile) {
                    crossAxisCount = 1;
                  } else if (info.isTablet) {
                    crossAxisCount = 2;
                  } else {
                    crossAxisCount = constraints.maxWidth > 1400 ? 4 : 3;
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: info.isMobile ? 1.2 : 0.85,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final service = services[index];
                      return ServicesCard(
                        service: service,
                        onTap: () {
                          // Tu peux ajouter une navigation ou un dialog ici
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: ResponsiveText.headlineMedium(
                                  'Service : ${service.title}'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
            error: (err, stack) => Center(
                  child: ResponsiveText.headlineMedium('Erreur : $err'),
                ),
            loading: () => const Center(
                  child: CircularProgressIndicator(),
                ))
      ],
    );
  }
}
