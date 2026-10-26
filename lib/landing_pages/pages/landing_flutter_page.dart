import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import '../widgets/cta_section.dart';
import '../widgets/process_step.dart';
import '../widgets/section_title.dart';
import '../widgets/service_card.dart';

class LandingFlutterPage extends StatelessWidget {
  const LandingFlutterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: LandingFlutterContent(),
    );
  }
}

class LandingFlutterContent extends StatelessWidget {
  const LandingFlutterContent({super.key});

  static const Color _accent = AppTheme.flutterAccent;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 800;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: AppTheme.white,
          elevation: 1,
          title: RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.flutterPrimary,
              ),
              children: [
                TextSpan(text: 'Portfolio '),
                TextSpan(
                  text: 'Flutter',
                  style: TextStyle(color: _accent),
                ),
              ],
            ),
          ),
          actions: [
            if (isWide) ...[
              _NavLink(
                  label: 'Offres', onTap: () => context.go('/offres')),
              _NavLink(
                  label: 'Mobile',
                  onTap: () => context.go('/offres/mobile-dev')),
              _NavLink(
                  label: 'Web', onTap: () => context.go('/offres/web-dev')),
              const SizedBox(width: 12),
            ],
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: ElevatedButton(
                onPressed: () => context.go('/contact'),
                style: ElevatedButton.styleFrom(backgroundColor: _accent),
                child: const Text('Me contacter'),
              ),
            ),
          ],
        ),

        SliverToBoxAdapter(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: isWide ? 80 : 56,
              horizontal: 24,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0A1628),
                  Color(0xFF0C2D5E),
                  Color(0xFF027DFD),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Architecture Flutter\nApplications performantes',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: isWide ? 42 : 28,
                      ),
                ),
                const SizedBox(height: 20),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Text(
                    'Je conçois et industrialise des architectures Flutter robustes pour iOS, Android, Web et Desktop.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 18,
                        ),
                  ),
                ),
                const SizedBox(height: 36),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => context.go('/offres/mobile-dev'),
                      icon: const Icon(Icons.phone_android, size: 18),
                      style: ElevatedButton.styleFrom(backgroundColor: _accent),
                      label: const Text('Mobile (iOS / Android)'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => context.go('/offres/web-dev'),
                      icon: const Icon(Icons.language, size: 18),
                      style: ElevatedButton.styleFrom(backgroundColor: _accent),
                      label: const Text('Web'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => context.go('/offres/desktop-dev'),
                      icon: const Icon(Icons.desktop_windows, size: 18),
                      style: ElevatedButton.styleFrom(backgroundColor: _accent),
                      label: const Text('Desktop'),
                    ),
                    OutlinedButton(
                      onPressed: () => context.go('/contact'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 2),
                      ),
                      child: const Text('Parler de mon projet'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 72, horizontal: 24),
            child: Column(
              children: [
                const SectionTitle(
                  title: 'Mes expertises Flutter',
                  subtitle: 'De l’architecture à la mise en production',
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 900
                        ? 3
                        : constraints.maxWidth > 600
                            ? 2
                            : 1;
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: 1.15,
                      children: [
                        ServiceCard(
                          icon: Icons.architecture,
                          title: 'Architecture applicative',
                          description:
                              'Clean Architecture, Feature-first, Modularisation, séparation claire des couches.',
                          accentColor: _accent,
                        ),
                        ServiceCard(
                          icon: Icons.bolt,
                          title: 'State Management',
                          description:
                              'Riverpod, Bloc, Provider… Choix adapté à votre contexte.',
                          accentColor: _accent,
                        ),
                        ServiceCard(
                          icon: Icons.api,
                          title: 'Intégration Backend & APIs',
                          description:
                              'REST, GraphQL, Firebase, auth sécurisée, offline-first.',
                          accentColor: _accent,
                        ),
                        ServiceCard(
                          icon: Icons.phone_android,
                          title: 'UI / UX & Design System',
                          description:
                              'Composants réutilisables, theming, responsive, accessibilité.',
                          accentColor: _accent,
                        ),
                        ServiceCard(
                          icon: Icons.speed,
                          title: 'Performance & Qualité',
                          description:
                              'Profiling, tests, CI/CD et monitoring.',
                          accentColor: _accent,
                        ),
                        ServiceCard(
                          icon: Icons.inventory_2_outlined,
                          title: 'Industrialisation & Scale',
                          description:
                              'Multi-packages, monorepo, code generation, conventions.',
                          accentColor: _accent,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Container(
            color: AppTheme.white,
            padding: const EdgeInsets.symmetric(vertical: 72, horizontal: 24),
            child: Column(
              children: [
                const SectionTitle(
                  title: 'Stack technique',
                  subtitle: 'Les technologies que j’utilise au quotidien',
                ),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: const [
                    _TechBadge(label: 'Flutter'),
                    _TechBadge(label: 'Dart'),
                    _TechBadge(label: 'Riverpod'),
                    _TechBadge(label: 'Bloc'),
                    _TechBadge(label: 'GoRouter'),
                    _TechBadge(label: 'Freezed'),
                    _TechBadge(label: 'Firebase'),
                    _TechBadge(label: 'REST / GraphQL'),
                    _TechBadge(label: 'CI/CD'),
                    _TechBadge(label: 'Clean Architecture'),
                    _TechBadge(label: 'Testing'),
                    _TechBadge(label: 'Performance Profiling'),
                  ],
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 72, horizontal: 24),
            child: Column(
              children: [
                const SectionTitle(
                  title: 'Mon approche d’architecture',
                  subtitle: 'Une base solide dès le premier commit',
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 800
                        ? 4
                        : constraints.maxWidth > 500
                            ? 2
                            : 1;
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 32,
                      childAspectRatio: 1.3,
                      children: [
                        ProcessStep(
                          number: 1,
                          title: 'Analyse',
                          description:
                              'Comprendre les besoins fonctionnels, techniques et de scale.',
                          accentColor: _accent,
                        ),
                        ProcessStep(
                          number: 2,
                          title: 'Conception',
                          description:
                              'Architecture, packages, patterns et conventions.',
                          accentColor: _accent,
                        ),
                        ProcessStep(
                          number: 3,
                          title: 'Implémentation',
                          description:
                              'Fondations et bonnes pratiques d’équipe.',
                          accentColor: _accent,
                        ),
                        ProcessStep(
                          number: 4,
                          title: 'Industrialisation',
                          description:
                              'CI/CD, tests, monitoring et documentation.',
                          accentColor: _accent,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: CtaSection(
            title: 'Vous avez un projet Flutter ?',
            subtitle:
                'Audit d’architecture, démarrage de projet ou renfort senior — voyez les offres ou parlons-en.',
            buttonLabel: 'Voir les offres',
            onPressed: () => context.go('/offres'),
            accentColor: _accent,
          ),
        ),

        SliverToBoxAdapter(
          child: Container(
            color: AppTheme.flutterPrimary,
            padding: const EdgeInsets.symmetric(vertical: 36),
            child: const Center(
              child: Text(
                '© 2026 – Consultant AMOA & Architecte Flutter',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NavLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.muted,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _TechBadge extends StatelessWidget {
  final String label;

  const _TechBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: AppTheme.text,
        ),
      ),
    );
  }
}
