import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:portefolio/core/affichage/colors_spec.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/affichage/tech_maturity_framework.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';
import 'package:portefolio/core/ui/widgets/narrative_bubble.dart';
import '../../../../experience/data/experiences_data.dart';

/// Version immersive et narrative pour une expérience professionnelle.
/// Reproduit le layout du "Théâtre du Projet" pour les expériences.
class ExperienceTheatreSection extends StatelessWidget {
  final Experience experience;
  final ResponsiveInfo info;

  const ExperienceTheatreSection({
    super.key,
    required this.experience,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    final maturity = experience.analyzeMaturity();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER IMMERSIF
          _ExperienceHeader(
              experience: experience, maturity: maturity, info: info),

          const SizedBox(height: 32),

          // TITRE DE LA SCÈNE ACTIVE
          _SceneTitle(
            title: experience.tags.contains('Flutter')
                ? 'DÉVELOPPEMENT & PERFORMANCE'
                : 'STRATÉGIE & RÉALISATION',
            info: info,
          ),

          const SizedBox(height: 24),

          // BULLE IA (MOBILE)
          if (info.isMobile)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: NarrativeBubble(
                text: experience.tags.contains('Flutter')
                    ? "Cette expérience a été un pilier pour ma maîtrise de la Production Readiness."
                    : "Une immersion riche en défis techniques et organisationnels.",
              ),
            ),

          // CONTENU NARRATIF + BULLES IA
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BLOC TEXTE PRINCIPAL (GLASSMORPHISM)
              Expanded(
                flex: 7,
                child: Column(
                  children: [
                    _MainDescriptionCard(
                      text: experience.contexte,
                      topPillar: maturity.isNotEmpty
                          ? maturity.entries
                              .reduce((a, b) => a.value > b.value ? a : b)
                              .key
                          : null,
                    ),

                    // NOUVEAU : IMAGE D'EXPÉRIENCE SI DISPONIBLE
                    if (experience.image.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white10),
                            boxShadow: [
                              BoxShadow(color: Colors.black45, blurRadius: 10)
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(19),
                            child: SmartImage(
                              path: experience.image,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 300.ms),

                    const SizedBox(height: 16),
                    if (experience.missions.isNotEmpty)
                      _MissionsCard(missions: experience.missions),
                    const SizedBox(height: 60), // Padding pour le scroll mobile
                  ],
                ),
              ),

              // ZONE DES BULLES IA (COLONNE À DROITE)
              if (!info.isMobile)
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: Column(
                      children: [
                        const NarrativeBubble(
                          text:
                              "Plongez dans les détails. J'ai documenté des tech specs spécifiques à cette expérience.",
                        ),
                        const SizedBox(height: 20),
                        const NarrativeBubble(
                          text:
                              "L'approche 'Production Readiness' a permis de sécuriser le code et d'optimiser les performances de 40%.",
                        )
                            .animate()
                            .fadeIn(delay: const Duration(milliseconds: 500)),
                        const SizedBox(height: 32),
                        // NOUVELLE CARTE VISUELLE POUR LES NON-TECHNIQUES
                        _ImpactMiniCard(experience: experience),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // SUR MOBILE : IMPACT EN BAS
          if (info.isMobile) ...[
            const SizedBox(height: 32),
            _ImpactMiniCard(experience: experience),
            const SizedBox(height: 40),
          ],
        ],
      ),
    );
  }
}

class _ImpactMiniCard extends StatelessWidget {
  final Experience experience;
  const _ImpactMiniCard({required this.experience});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorHelpers.cyan.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorHelpers.cyan.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Text(
            "RÉSUMÉ D'IMPACT",
            style: TextStyle(
              color: ColorHelpers.cyan,
              fontWeight: FontWeight.w900,
              fontSize: 10,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          _ImpactRow(
              icon: Icons.rocket_launch,
              label: "Mise en service",
              value: "Production Ready"),
          const Divider(height: 24, color: Colors.white10),
          _ImpactRow(
              icon: Icons.trending_up,
              label: "Performance",
              value: "Optimisée"),
          const Divider(height: 24, color: Colors.white10),
          _ImpactRow(icon: Icons.security, label: "Sécurité", value: "Validée"),
        ],
      ),
    );
  }
}

class _ImpactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ImpactRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 16),
        const SizedBox(width: 12),
        Text(label,
            style: const TextStyle(color: Colors.white38, fontSize: 11)),
        const Spacer(),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _ExperienceHeader extends StatelessWidget {
  final Experience experience;
  final Map<TechPillar, double> maturity;
  final ResponsiveInfo info;

  const _ExperienceHeader({
    required this.experience,
    required this.maturity,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(info.isMobile ? 20 : 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ColorHelpers.cyan.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ColorHelpers.cyan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.hub_outlined,
                    color: ColorHelpers.cyan, size: info.isMobile ? 20 : 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Immersion '${experience.entreprise}'",
                        style: TextStyle(
                          color: ColorHelpers.cyan,
                          fontWeight: FontWeight.bold,
                          fontSize: info.isMobile ? 18 : 22,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      experience.poste,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: info.isMobile ? 13 : 15,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "🗓 ${experience.periode}",
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: info.isMobile ? 11 : 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (maturity.isNotEmpty) ...[
            const SizedBox(height: 24),
            TechMaturityRadar(scores: maturity, compact: info.isMobile),
          ],
        ],
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 600))
        .slideX(begin: -0.05, end: 0);
  }
}

class _SceneTitle extends StatelessWidget {
  final String title;
  final ResponsiveInfo info;

  const _SceneTitle({required this.title, required this.info});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on,
                color: ColorHelpers.cyan, size: info.isMobile ? 16 : 18),
            const SizedBox(width: 12),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: TextStyle(
                    color: ColorHelpers.cyan,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    fontSize: info.isMobile ? 12 : 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 3,
          width: info.isMobile ? 120 : 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ColorHelpers.cyan,
                ColorHelpers.cyan.withValues(alpha: 0)
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MainDescriptionCard extends StatelessWidget {
  final String text;
  final TechPillar? topPillar;

  const _MainDescriptionCard({required this.text, this.topPillar});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Stack(
        children: [
          // IMAGE DE FOND (PILLIER TECHNIQUE)
          if (topPillar != null)
            Positioned(
              right: -50,
              bottom: -50,
              child: Opacity(
                opacity: 0.15,
                child: Image.asset(
                  topPillar!.skillImage,
                  width: 300,
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (topPillar != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: topPillar!.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: topPillar!.color.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(topPillar!.icon,
                              color: topPillar!.color, size: 14),
                          const SizedBox(width: 8),
                          Text(
                            topPillar!.label.toUpperCase(),
                            style: TextStyle(
                              color: topPillar!.color,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.6,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionsCard extends StatelessWidget {
  final List<String> missions;

  const _MissionsCard({required this.missions});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorHelpers.surface.withValues(alpha: 0.5),
            Colors.black.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorHelpers.cyan.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ColorHelpers.cyan.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome,
                    color: ColorHelpers.cyan, size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "MISSIONS & RÉALISATIONS",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...missions.map((m) {
            final icon = _getMissionIcon(m);
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ColorHelpers.cyan.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: ColorHelpers.cyan.withValues(alpha: 0.1)),
                    ),
                    child: Icon(icon, color: ColorHelpers.cyan, size: 16),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 1,
                          width: 40,
                          color: ColorHelpers.cyan.withValues(alpha: 0.2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  IconData _getMissionIcon(String text) {
    final t = text.toLowerCase();
    if (t.contains('développe') || t.contains('code'))
      return Icons.code_rounded;
    if (t.contains('test') || t.contains('qualité'))
      return Icons.bug_report_outlined;
    if (t.contains('architect') || t.contains('concept'))
      return Icons.account_tree_outlined;
    if (t.contains('performance') || t.contains('optim'))
      return Icons.speed_rounded;
    if (t.contains('sécu')) return Icons.security_rounded;
    if (t.contains('ia') || t.contains('intelligent'))
      return Icons.auto_awesome_mosaic;
    if (t.contains('lead') || t.contains('manage')) return Icons.groups_rounded;
    if (t.contains('client') || t.contains('besoin'))
      return Icons.contact_support_outlined;
    return Icons.task_alt_rounded;
  }
}
