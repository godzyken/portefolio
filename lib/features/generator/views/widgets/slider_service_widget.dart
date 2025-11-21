import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/home/views/widgets/extentions_widgets.dart';

import '../../../../core/affichage/screen_size_detector.dart';
import '../../../../core/provider/json_data_provider.dart';
import '../../../../core/ui/widgets/ui_widgets_extentions.dart';

class ServicesSlider extends ConsumerStatefulWidget {
  const ServicesSlider({super.key});

  @override
  ConsumerState<ServicesSlider> createState() => _ServicesSliderState();
}

class _ServicesSliderState extends ConsumerState<ServicesSlider> {
  late final PageController controller;

  @override
  void initState() {
    super.initState();
    controller = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncServices = ref.watch(servicesJsonProvider);
    final info = ref.watch(responsiveInfoProvider);

    return asyncServices.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          Center(child: Text('Erreur lors du chargement des services: $e')),
      data: (services) {
        if (services.isEmpty) {
          return const SizedBox.shrink();
        }

        return AspectRatio(
          aspectRatio: info.isMobile ? 1.0 : 1.5,
          child: PageView.builder(
            controller: controller,
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return AnimatedBuilder(
                animation: controller,
                builder: (context, child) {
                  double value = 1.0;

                  if (controller.position.haveDimensions) {
                    value = (controller.page! - index).abs();
                    // Plus de zoom si la valeur est plus proche de 1.0
                    value = (1 - (value * 0.3)).clamp(0.8, 1.0);
                  }

                  return Transform.scale(
                    scale: Curves.easeOut.transform(value),
                    child: child,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 16.0),
                  child: ServicesCard(
                    service: service,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: ResponsiveText.bodyMedium(
                              'Service : ${service.title}'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
