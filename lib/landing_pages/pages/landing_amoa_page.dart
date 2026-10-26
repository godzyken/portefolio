import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import '../widgets/cta_section.dart';
import '../widgets/process_step.dart';
import '../widgets/section_title.dart';
import '../widgets/service_card.dart';

class LandingAmoaPage extends StatelessWidget {
  const LandingAmoaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: LandingAmoaContent(),
    );
  }
}

class LandingAmoaContent extends StatelessWidget {
  const LandingAmoaContent({super.key});

  static const Color _accent = AppTheme.amoaAccent;

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
                color: AppTheme.amoaPrimary,
              ),
              children: [
                TextSpan(text: 'Portfolio '),
                TextSpan(
                  text: 'AMOA',
                  style: TextStyle(color: _accent),
                ),
              ],
            ),
          ),
          actions: [
            if (isWide) ...[
              _NavLink(
                  label: 'Offres',
                  onTap: () => context.go('/offres?category=amoa')),
              _NavLink(
                  label: 'AMOA',
                  onTap: () => context.go('/offres/amoa-conseil')),
              _NavLink(
                  label: 'Catalogue', onTap: () => context.go('/offres')),
              const SizedBox(width: 12),
            ],
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: ElevatedButton(
                onPressed: () => context.go('/contact'),
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
                colors: [Color(0xFF0F172A), Color(0xFF1E3A5F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Conseil AMOA\nPilotage de projets digitaux',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: isWide ? 42 : 28,
                      ),
                ),
                const SizedBox(height: 20),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Text(
                    'J’accompagne les directions métiers et les DSI : cadrage, gouvernance, Agile, recette et mise en production.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 18,
                        ),
                  ),
                ),
                const SizedBox(height: 36),
                Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => context.go('/contact'),
                      child: const Text('Discutons de votre projet'),
                    ),
                    OutlinedButton(
                      onPressed: () => context.go('/offres/amoa-conseil'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 2),
                      ),
                      child: const Text('Voir l’offre AMOA'),
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
                  title: 'Mes services AMOA',
                  subtitle:
                      'Un accompagnement de bout en bout pour sécuriser vos projets digitaux',
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
                          icon: Icons.assignment_outlined,
                          title: 'Cadrage & Expression de besoins',
                          description:
                              'Analyse des besoins, ateliers, priorisation.',
                          accentColor: _accent,
                        ),
                        ServiceCard(
                          icon: Icons.track_changes,
                          title: 'Pilotage & Gouvernance',
                          description:
                              'Jalons, reporting, risques et comités.',
                          accentColor: _accent,
                        ),
                        ServiceCard(
                          icon: Icons.sync,
                          title: 'Méthodes Agile & Scrum',
                          description:
                              'Pratiques Agile, coaching, cérémonies.',
                          accentColor: _accent,
                        ),
                        ServiceCard(
                          icon: Icons.verified_outlined,
                          title: 'Recette & Qualité',
                          description:
                              'Plans de recette, UAT, critères d’acceptation.',
                          accentColor: _accent,
                        ),
                        ServiceCard(
                          icon: Icons.link,
                          title: 'Interface Métiers / Technique',
                          description:
                              'Traduction besoins → specs claires.',
                          accentColor: _accent,
                        ),
                        ServiceCard(
                          icon: Icons.rocket_launch_outlined,
                          title: 'MEP & Conduite du changement',
                          description:
                              'Go-live, formation, adoption.',
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
                  title: 'Pourquoi un AMOA expérimenté ?',
                  subtitle:
                      'Des projets mieux cadrés, mieux livrés et mieux adoptés',
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 700 ? 2 : 1;
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 20,
                      childAspectRatio: 4.5,
                      children: const [
                        _BenefitItem(
                          title: 'Réduction des risques',
                          description:
                              'Identification précoce des écarts et blocages.',
                        ),
                        _BenefitItem(
                          title: 'Alignement métiers / IT',
                          description:
                              'Un langage commun entre parties prenantes.',
                        ),
                        _BenefitItem(
                          title: 'Respect délais & budgets',
                          description:
                              'Pilotage rigoureux et reporting transparent.',
                        ),
                        _BenefitItem(
                          title: 'Qualité de livraison',
                          description:
                              'Recette structurée et critères clairs.',
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
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 72, horizontal: 24),
            child: Column(
              children: [
                const SectionTitle(
                  title: 'Mon approche',
                  subtitle: 'Une méthode pragmatique et collaborative',
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
                          title: 'Diagnostic',
                          description:
                              'Contexte, enjeux et contraintes.',
                          accentColor: _accent,
                        ),
                        ProcessStep(
                          number: 2,
                          title: 'Cadrage',
                          description:
                              'Périmètre, objectifs, plan de charge.',
                          accentColor: _accent,
                        ),
                        ProcessStep(
                          number: 3,
                          title: 'Pilotage',
                          description: 'Animer, suivre, anticiper, arbitrer.',
                          accentColor: _accent,
                        ),
                        ProcessStep(
                          number: 4,
                          title: 'Livraison',
                          description:
                              'Valider, déployer, accompagner l’adoption.',
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
            title: 'Un projet digital à sécuriser ?',
            subtitle:
                'Échange gratuit de 30 minutes, ou consultez l’offre AMOA.',
            buttonLabel: 'Voir l’offre AMOA',
            onPressed: () => context.go('/offres/amoa-conseil'),
            accentColor: _accent,
          ),
        ),

        SliverToBoxAdapter(
          child: Container(
            color: AppTheme.amoaPrimary,
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

class _BenefitItem extends StatelessWidget {
  final String title;
  final String description;

  const _BenefitItem({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Color(0xFFDCFCE7),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, size: 16, color: Color(0xFF16A34A)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 16,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
