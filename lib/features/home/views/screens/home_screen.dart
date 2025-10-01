import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/affichage/screen_size_detector.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/provider/providers.dart';
import '../../../home/views/widgets/services_card.dart';
import '../../../parametres/themes/views/widgets/theme_selector.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return; // <-- sécurité importante
      ref.read(appBarTitleProvider.notifier).setTitle("Godzyken Portefolio");
      ref.read(appBarActionsProvider.notifier).setActions([
        IconButton(
          icon: const Icon(Icons.color_lens),
          tooltip: 'Personnaliser le thème',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ThemeSelector()),
            );
          },
        ),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(servicesFutureProvider);
    final info = ref.watch(responsiveInfoProvider);

    appBarTitleAction(ref, context);

    return SafeArea(
      child: servicesAsync.when(
        data: (services) {
          // ------------------------ PORTRAIT ------------------------------
          if (info.isPortrait) {
            return Column(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Image.asset(
                    'assets/images/logo_godzyken.png',
                    width: info.size.width * 0.3,
                    height: info.size.width * 0.3,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Godzyken',
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
                    itemBuilder: (_, index) =>
                        ServicesCard(service: services[index]),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            );
          }
          // ------------------------ LANDSCAPE / DESKTOP -------------------
          else {
            return Row(
              children: [
                Flexible(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/logo_godzyken.png',
                          width: info.size.height * 0.25,
                          height: info.size.height * 0.25,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Godzyken',
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
                Flexible(
                  flex: 7,
                  child: PageView.builder(
                    scrollDirection: Axis.vertical,
                    controller: PageController(viewportFraction: 0.85),
                    itemCount: services.length,
                    itemBuilder: (_, index) =>
                        ServicesCard(service: services[index]),
                  ),
                ),
              ],
            );
          }
        },
        error: (e, st) {
          ref.read(loggerProvider("HomeScreen")).log(
                "Erreur lors du chargement des services",
                level: LogLevel.error,
                error: e,
                stackTrace: st,
              );
          return Center(child: Text('Erreur : $e'));
        },
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  void appBarTitleAction(WidgetRef ref, BuildContext context) {
    Future.microtask(() {
      ref.read(appBarTitleProvider.notifier).setTitle("Godzyken Portefolio");
      ref.read(appBarActionsProvider.notifier).setActions([
        IconButton(
          icon: const Icon(Icons.color_lens),
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ThemeSelector()));
          },
          tooltip: 'Personnaliser le thème',
        ),
      ]);
    });
  }
}
