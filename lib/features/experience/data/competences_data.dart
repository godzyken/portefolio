// competences_data.dart

import 'package:flutter/material.dart';

enum NiveauCompetence {
  expert, // Or - 100 pts
  confirme, // Argent - 50 pts
  intermediaire, // Bronze - 25 pts
  fonctionnel, // Cuivre - 10 pts
}

class Competence {
  final String nom;
  final NiveauCompetence niveau;
  final Color couleur;
  final int valeur;
  final List<String> entreprises; // Expériences associées
  final String description;

  const Competence({
    required this.nom,
    required this.niveau,
    required this.couleur,
    required this.valeur,
    required this.entreprises,
    required this.description,
  });
}

// Configuration des couleurs par niveau
const Map<NiveauCompetence, Color> couleursNiveau = {
  NiveauCompetence.expert: Color(0xFFFFD700), // Or
  NiveauCompetence.confirme: Color(0xFFC0C0C0), // Argent
  NiveauCompetence.intermediaire: Color(0xFFCD7F32), // Bronze
  NiveauCompetence.fonctionnel: Color(0xFFB87333), // Cuivre
};

// Configuration des valeurs par niveau
const Map<NiveauCompetence, int> valeursNiveau = {
  NiveauCompetence.expert: 100,
  NiveauCompetence.confirme: 50,
  NiveauCompetence.intermediaire: 25,
  NiveauCompetence.fonctionnel: 10,
};

// Liste complète des compétences
final List<Competence> competences = [
  // NIVEAU EXPERT (Or - 100 pts)
  Competence(
    nom: 'Flutter',
    niveau: NiveauCompetence.expert,
    couleur: couleursNiveau[NiveauCompetence.expert]!,
    valeur: valeursNiveau[NiveauCompetence.expert]!,
    entreprises: ['Keym', 'EGOTE', 'Urbalyon'],
    description: 'Développement mobile cross-platform, architecture avancée',
  ),
  Competence(
    nom: 'Gestion de projet',
    niveau: NiveauCompetence.expert,
    couleur: couleursNiveau[NiveauCompetence.expert]!,
    valeur: valeursNiveau[NiveauCompetence.expert]!,
    entreprises: ['EGOTE', 'Apside', 'Aubry'],
    description: 'Direction de projets, planning, budget, coordination équipes',
  ),
  Competence(
    nom: 'Full-Stack',
    niveau: NiveauCompetence.expert,
    couleur: couleursNiveau[NiveauCompetence.expert]!,
    valeur: valeursNiveau[NiveauCompetence.expert]!,
    entreprises: ['EGOTE', 'Urbalyon', 'Aubry', 'Wayma'],
    description: 'Architecture complète front/back, API, base de données',
  ),
  Competence(
    nom: 'CI/CD',
    niveau: NiveauCompetence.expert,
    couleur: couleursNiveau[NiveauCompetence.expert]!,
    valeur: valeursNiveau[NiveauCompetence.expert]!,
    entreprises: ['EGOTE', 'Apside', 'Urbalyon', 'Aubry', 'Wayma'],
    description: 'Pipeline automatisé, déploiement continu, DevOps',
  ),

  // NIVEAU CONFIRMÉ (Argent - 50 pts)
  Competence(
    nom: 'Angular',
    niveau: NiveauCompetence.confirme,
    couleur: couleursNiveau[NiveauCompetence.confirme]!,
    valeur: valeursNiveau[NiveauCompetence.confirme]!,
    entreprises: ['Apside', 'Aubry', 'Wayma', 'Urbalyon'],
    description: 'Framework web, SPA, Ionic, composants réutilisables',
  ),
  Competence(
    nom: 'Node.js',
    niveau: NiveauCompetence.confirme,
    couleur: couleursNiveau[NiveauCompetence.confirme]!,
    valeur: valeursNiveau[NiveauCompetence.confirme]!,
    entreprises: ['Urbalyon', 'Aubry', 'Wayma'],
    description: 'Backend JavaScript, API REST, Express, microservices',
  ),
  Competence(
    nom: 'Riverpod',
    niveau: NiveauCompetence.confirme,
    couleur: couleursNiveau[NiveauCompetence.confirme]!,
    valeur: valeursNiveau[NiveauCompetence.confirme]!,
    entreprises: ['Keym', 'EGOTE'],
    description: 'Gestion d\'état Flutter, architecture réactive',
  ),
  Competence(
    nom: 'UI/UX',
    niveau: NiveauCompetence.confirme,
    couleur: couleursNiveau[NiveauCompetence.confirme]!,
    valeur: valeursNiveau[NiveauCompetence.confirme]!,
    entreprises: ['Apside', 'Wayma', 'EGOTE', 'Aubry'],
    description: 'Design interface, expérience utilisateur, Figma',
  ),
  Competence(
    nom: 'AMOA',
    niveau: NiveauCompetence.confirme,
    couleur: couleursNiveau[NiveauCompetence.confirme]!,
    valeur: valeursNiveau[NiveauCompetence.confirme]!,
    entreprises: ['Apside'],
    description: 'Conseil, analyse besoins, chiffrage, cahier des charges',
  ),

  // NIVEAU INTERMÉDIAIRE (Bronze - 25 pts)
  Competence(
    nom: 'Base de données',
    niveau: NiveauCompetence.intermediaire,
    couleur: couleursNiveau[NiveauCompetence.intermediaire]!,
    valeur: valeursNiveau[NiveauCompetence.intermediaire]!,
    entreprises: ['EGOTE', 'Urbalyon', 'Aubry', 'CoyCoyCoy', '2RouesVertes'],
    description: 'MySQL, MongoDB, PostgreSQL, Elasticsearch',
  ),
  Competence(
    nom: 'Tests',
    niveau: NiveauCompetence.intermediaire,
    couleur: couleursNiveau[NiveauCompetence.intermediaire]!,
    valeur: valeursNiveau[NiveauCompetence.intermediaire]!,
    entreprises: ['Apside', 'Zodiac', 'Thales', 'EGOTE'],
    description: 'Tests unitaires, intégration, Cypress, qualité logicielle',
  ),
  Competence(
    nom: 'IoT',
    niveau: NiveauCompetence.intermediaire,
    couleur: couleursNiveau[NiveauCompetence.intermediaire]!,
    valeur: valeursNiveau[NiveauCompetence.intermediaire]!,
    entreprises: ['EGOTE', 'Aubry'],
    description: 'Capteurs, télémétrie, objets connectés',
  ),
  Competence(
    nom: 'Qualité',
    niveau: NiveauCompetence.intermediaire,
    couleur: couleursNiveau[NiveauCompetence.intermediaire]!,
    valeur: valeursNiveau[NiveauCompetence.intermediaire]!,
    entreprises: [
      'SunPower',
      'Zodiac',
      'Dédienne',
      'Thales',
      'Continental',
      'Armatis',
    ],
    description: 'Standards AS9100, lean manufacturing, 5S, contrôle qualité',
  ),
  Competence(
    nom: 'E-commerce',
    niveau: NiveauCompetence.intermediaire,
    couleur: couleursNiveau[NiveauCompetence.intermediaire]!,
    valeur: valeursNiveau[NiveauCompetence.intermediaire]!,
    entreprises: ['2RouesVertes', 'CoyCoyCoy'],
    description: 'PrestaShop, boutique en ligne, gestion stock',
  ),

  // NIVEAU FONCTIONNEL (Cuivre - 10 pts)
  Competence(
    nom: 'Relation Client',
    niveau: NiveauCompetence.fonctionnel,
    couleur: couleursNiveau[NiveauCompetence.fonctionnel]!,
    valeur: valeursNiveau[NiveauCompetence.fonctionnel]!,
    entreprises: ['Armatis', 'TME', 'Darty'],
    description: 'Support client, satisfaction, KPI, empathie',
  ),
  Competence(
    nom: 'Logistique',
    niveau: NiveauCompetence.fonctionnel,
    couleur: couleursNiveau[NiveauCompetence.fonctionnel]!,
    valeur: valeursNiveau[NiveauCompetence.fonctionnel]!,
    entreprises: ['UTS31', 'TME', 'Asics', 'Darty'],
    description: 'Livraison, optimisation tournées, gestion stock',
  ),
  Competence(
    nom: 'Production',
    niveau: NiveauCompetence.fonctionnel,
    couleur: couleursNiveau[NiveauCompetence.fonctionnel]!,
    valeur: valeursNiveau[NiveauCompetence.fonctionnel]!,
    entreprises: ['SunPower', 'Zodiac', 'Continental'],
    description: 'Lean manufacturing, assemblage, cadence, ergonomie',
  ),
  Competence(
    nom: 'Aéronautique',
    niveau: NiveauCompetence.fonctionnel,
    couleur: couleursNiveau[NiveauCompetence.fonctionnel]!,
    valeur: valeursNiveau[NiveauCompetence.fonctionnel]!,
    entreprises: ['Dédienne', 'Thales'],
    description: 'Standards AS9100, traçabilité, précision, sécurité',
  ),
  Competence(
    nom: 'VR',
    niveau: NiveauCompetence.fonctionnel,
    couleur: couleursNiveau[NiveauCompetence.fonctionnel]!,
    valeur: valeursNiveau[NiveauCompetence.fonctionnel]!,
    entreprises: ['EGOTE'],
    description: 'Réalité virtuelle, Unity, visualisation 3D',
  ),
];

// Helper function pour obtenir les compétences d'une expérience
List<Competence> getCompetencesForEntreprise(String entreprise) {
  return competences
      .where((comp) => comp.entreprises.contains(entreprise))
      .toList();
}

// Helper function pour obtenir les compétences par niveau
List<Competence> getCompetencesByNiveau(NiveauCompetence niveau) {
  return competences.where((comp) => comp.niveau == niveau).toList();
}

// Map pour la compatibilité avec l'ancien système de tags
final Map<String, Color> tagColors = {
  for (var comp in competences) comp.nom.toLowerCase(): comp.couleur,
};

// Export des tags pour compatibilité
final List<String> allTags =
    competences.map((c) => c.nom.toLowerCase()).toList();
