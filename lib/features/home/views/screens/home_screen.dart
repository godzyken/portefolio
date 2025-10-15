import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/home/data/services_data.dart';

import '../../../../core/affichage/screen_size_detector.dart';
import '../../../../core/provider/providers.dart';
import '../../../home/views/widgets/services_card.dart';
import '../../../parametres/themes/views/widgets/space_background.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesProvider);
    final info = ref.watch(responsiveInfoProvider);
    final theme = Theme.of(context);

    return SafeArea(
      child: servicesAsync.when(
        data: (services) => SpaceBackground(
          primaryColor: theme.colorScheme.primary,
          secondaryColor: theme.colorScheme.secondary,
          starCount: 150,
          child: LayoutBuilder(
            builder: (context, constraints) {
              bool isPortrait = info.isPortrait;
              return isPortrait
                  ? _buildPortraitLayout(context, info, services, theme)
                  : _buildLandscapeLayout(context, info, services, theme);
            },
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erreur: $e'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(
    BuildContext context,
    ResponsiveInfo info,
    List<Service> services,
    ThemeData theme,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 32),
          _buildHeader(context, info, theme, isPortrait: true),
          const SizedBox(height: 24),
          SizedBox(
            height: info.size.height * 0.55,
            child: PageView.builder(
              controller: PageController(viewportFraction: 0.85),
              itemCount: services.length,
              itemBuilder: (_, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ServicesCard(service: services[index]),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildPaginationDots(services.length, theme),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout(
    BuildContext context,
    ResponsiveInfo info,
    List<Service> services,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Row(
        children: [
          Flexible(
            flex: 3,
            child: _buildHeader(context, info, theme, isPortrait: false),
          ),
          Flexible(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Mes Services",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: PageView.builder(
                    scrollDirection: Axis.vertical,
                    controller: PageController(viewportFraction: 0.85),
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

  Widget _buildHeader(
    BuildContext context,
    ResponsiveInfo info,
    ThemeData theme, {
    required bool isPortrait,
  }) {
    double imageSize =
        isPortrait ? info.size.width * 0.35 : info.size.height * 0.3;

    return Column(
      mainAxisAlignment:
          isPortrait ? MainAxisAlignment.start : MainAxisAlignment.center,
      crossAxisAlignment:
          isPortrait ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/logo_godzyken.png',
              width: imageSize,
              height: imageSize,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Godzyken',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
          textAlign: isPortrait ? TextAlign.center : TextAlign.left,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "Développement Mobile & Web",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
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
                      .withValues(alpha: 0.7),
                  height: 1.6,
                ),
            textAlign: TextAlign.left,
          ),
        ],
      ],
    );
  }

  Widget _buildPaginationDots(int count, ThemeData theme) {
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
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}
