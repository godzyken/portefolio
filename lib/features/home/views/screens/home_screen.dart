import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/affichage/screen_size_detector.dart';
import '../../../../core/debug/assets_debugger.dart';
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
      if (!mounted) return;
      ref.read(appBarTitleProvider.notifier).setTitle("Godzyken Portfolio");
      ref.read(appBarActionsProvider.notifier).setActions([
        // Bouton de debug (à retirer en production)
        IconButton(
          icon: const Icon(Icons.bug_report),
          tooltip: 'Debug Assets',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AssetsDebugger()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.palette_outlined),
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

    return SafeArea(
      child: servicesAsync.when(
        data: (services) {
          // MODE PORTRAIT (Mobile/Tablet)
          if (info.isPortrait) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.surfaceContainer,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  // Header section
                  _buildHeader(context, info, isPortrait: true),
                  const SizedBox(height: 24),
                  // Services carousel
                  Expanded(
                    child: PageView.builder(
                      scrollDirection: Axis.horizontal,
                      controller: PageController(viewportFraction: 0.88),
                      itemCount: services.length,
                      itemBuilder: (_, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: ServicesCard(service: services[index]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Pagination dots
                  _buildPaginationDots(services.length),
                  const SizedBox(height: 16),
                ],
              ),
            );
          }
          // MODE LANDSCAPE (Desktop/Large tablet)
          else {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.surfaceContainer,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Row(
                children: [
                  // Left panel - Header
                  Flexible(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context)
                                .colorScheme
                                .primary
                                .withAlpha((255 * 0.1).toInt()),
                            Colors.transparent,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: _buildHeader(context, info, isPortrait: false),
                    ),
                  ),
                  // Right panel - Services
                  Flexible(
                    flex: 7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            "Mes Services",
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        Expanded(
                          child: PageView.builder(
                            scrollDirection: Axis.vertical,
                            controller: PageController(viewportFraction: 0.88),
                            itemCount: services.length,
                            itemBuilder: (_, index) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 8,
                              ),
                              child: ServicesCard(service: services[index]),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Erreur de chargement',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  e.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                "Chargement des services...",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ResponsiveInfo info,
      {required bool isPortrait}) {
    return Column(
      mainAxisAlignment:
          isPortrait ? MainAxisAlignment.start : MainAxisAlignment.center,
      crossAxisAlignment:
          isPortrait ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        // Logo avec effet de glow
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withAlpha((255 * 0.3).toInt()),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/logo_godzyken.png',
              width:
                  isPortrait ? info.size.width * 0.35 : info.size.height * 0.3,
              height:
                  isPortrait ? info.size.width * 0.35 : info.size.height * 0.3,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Nom
        Text(
          'Godzyken',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
          textAlign: isPortrait ? TextAlign.center : TextAlign.left,
        ),
        const SizedBox(height: 8),
        // Sous-titre
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "Développement Mobile & Web",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                ),
            textAlign: isPortrait ? TextAlign.center : TextAlign.left,
          ),
        ),
        if (!isPortrait) ...[
          const SizedBox(height: 24),
          Text(
            "Expert en Flutter, Angular et solutions cloud.\nCréation d'applications performantes et élégantes.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withAlpha((255 * 0.7).toInt()),
                  height: 1.6,
                ),
            textAlign: TextAlign.left,
          ),
        ],
      ],
    );
  }

  Widget _buildPaginationDots(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context)
                .colorScheme
                .primary
                .withAlpha((255 * 0.3).toInt()),
          ),
        ),
      ),
    );
  }
}
