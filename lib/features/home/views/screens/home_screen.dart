import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/provider/providers.dart';
import '../widgets/services_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesFutureProvider);
    final orientation = MediaQuery.of(context).orientation;
    final screenSize = MediaQuery.of(context).size;
    final isPortrait = orientation == Orientation.portrait;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Choisissez vos projets',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
      body: SafeArea(
        child: servicesAsync.when(
          data: (services) {
            if (isPortrait) {
              // 📱 Portrait : Column verticale classique
              return Column(
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Image.asset(
                      'assets/images/logo_godzyken.png',
                      width: screenSize.width * 0.3,
                      height: screenSize.width * 0.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Godzyken",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Text(
                    "Développement d'applications mobiles & web",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: PageView.builder(
                      scrollDirection: Axis.horizontal,
                      controller: PageController(viewportFraction: 0.85),
                      itemCount: services.length,
                      itemBuilder:
                          (context, index) =>
                              ServicesCard(service: services[index]),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              );
            } else {
              // 💻 Paysage : Row -> gauche (logo+textes) | droite (PageView)
              return Row(
                children: [
                  // Partie gauche : Logo + textes
                  Flexible(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/logo_godzyken.png',
                            width: screenSize.height * 0.25,
                            height: screenSize.height * 0.25,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Godzyken",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const Text(
                            "Développement d'applications mobiles & web",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Partie droite : PageView vertical
                  Flexible(
                    flex: 7,
                    child: PageView.builder(
                      scrollDirection: Axis.vertical,
                      controller: PageController(viewportFraction: 0.85),
                      itemCount: services.length,
                      itemBuilder:
                          (context, index) =>
                              ServicesCard(service: services[index]),
                    ),
                  ),
                ],
              );
            }
          },
          error: (e, _) => Center(child: Text('Erreur : $e')),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
