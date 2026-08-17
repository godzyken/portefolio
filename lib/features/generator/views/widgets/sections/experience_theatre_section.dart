import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:portefolio/core/affichage/colors_spec.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/affichage/tech_maturity_framework.dart';
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
          _ExperienceHeader(experience: experience, maturity: maturity),

          const SizedBox(height: 32),

          // TITRE DE LA SCÈNE ACTIVE (Ex: DÉVELOPPEMENT & PERFORMANCE)
          _SceneTitle(
            title: experience.tags.contains('Flutter') 
              ? 'DÉVELOPPEMENT & PERFORMANCE' 
              : 'STRATÉGIE & RÉALISATION',
          ),

          const SizedBox(height: 24),

          // BULLE IA (MOBILE : AU DESSUS DU CONTENU)
          if (info.isMobile)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
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
                    _MainDescriptionCard(text: experience.contexte),
                    const SizedBox(height: 16),
                    if (experience.missions.isNotEmpty)
                      _MissionsCard(missions: experience.missions),
                    const SizedBox(height: 40), // Padding pour le scroll mobile
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
                          text: "Plongez dans les détails. J'ai documenté des tech specs spécifiques à cette expérience.",
                        ),
                        const SizedBox(height: 20),
                        const NarrativeBubble(
                          text: "L'approche 'Production Readiness' a permis de sécuriser le code et d'optimiser les performances de 40%.",
                        ).animate().fadeIn(delay: const Duration(milliseconds: 500)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExperienceHeader extends StatelessWidget {
  final Experience experience;
  final Map<TechPillar, double> maturity;

  const _ExperienceHeader({required this.experience, required this.maturity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
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
              const Icon(Icons.hub_outlined, color: ColorHelpers.cyan, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Immersion '${experience.entreprise}' (${experience.poste})",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: ColorHelpers.cyan,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Détails : ${experience.periode}",
                      style: const TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (maturity.isNotEmpty) ...[
            const SizedBox(height: 20),
            TechMaturityRadar(scores: maturity, compact: false),
          ],
        ],
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 600)).slideX(begin: -0.05, end: 0);
  }
}

class _SceneTitle extends StatelessWidget {
  final String title;

  const _SceneTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.location_on, color: ColorHelpers.cyan, size: 18),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                color: ColorHelpers.cyan,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 3,
          width: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [ColorHelpers.cyan, ColorHelpers.cyan.withValues(alpha: 0)],
            ),
          ),
        ),
      ],
    );
  }
}

class _MainDescriptionCard extends StatelessWidget {
  final String text;

  const _MainDescriptionCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 15,
          height: 1.6,
        ),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorHelpers.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: missions.map((m) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle_outline, color: ColorHelpers.cyan, size: 16),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  m,
                  style: const TextStyle(color: Colors.white60, fontSize: 14),
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }
}
