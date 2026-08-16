import 'package:flutter/material.dart';

import '../../../core/ui/ui_widgets_extentions.dart';
import '../../projets/data/project_data.dart';
import '../../projets/data/project_section.dart';
import '../views/generator_widgets_extentions.dart';
import '../views/widgets/sections/artifacts_section.dart';
import '../views/widgets/sections/project_theatre_section.dart';
import '../../../core/affichage/tech_maturity_framework.dart';

/// Gestionnaire centralisé pour la configuration des sections d'un projet
///
/// Responsabilités:
/// - Déterminer quelles sections afficher selon les données du projet
/// - Construire la liste des sections avec leurs builders
/// - Fournir des helpers pour la détection de features (IoT, Programming, etc.)
class SectionManager {
  final ProjectInfo project;

  SectionManager(this.project);

  /// Construit la liste complète des sections à afficher
  List<ProjectSection> buildSections(BuildContext context) {
    final sections = <ProjectSection>[
      // Théâtre Narratif (Remplaçant du Hero pour plus d'immersion)
      _buildTheatreSection(),
    ];

    // SectionAperçu
    if (hasLivePreview()) {
      sections.add(_buildLivePreviewSection());
    }

    // Section développement (WakaTime)
    if (hasProgrammingTag()) {
      sections.add(_buildWakaTimeSection());
    }

    // Section Infrastructure
    if (hasInfrastructureData()) {
      sections.add(_buildInfrastructureSection());
    }

    // Section Analyse économique
    if (hasEconomicData()) {
      sections.add(_buildEconomicSection());
    }

    // Section IoT
    if (hasIoTFeatures()) {
      sections.add(_buildIoTSection());
    }

    // Section Détails techniques
    if (hasTechDetails()) {
      sections.add(_buildTechDetailsSection());
    }

    // Section Résultats
    if (hasResults()) {
      sections.add(_buildResultsSection());
    }

    // Section Artefacts (.md issus du repo GitHub : présentation, vision...)
    // S'auto-masque si aucun artefact n'est trouvé côté GitHub.
    if (hasGithubRepo()) {
      sections.add(_buildArtifactsSection());
    }

    return sections;
  }

  ProjectSection _buildTheatreSection() {
    return ProjectSection(
      id: 'hero',
      title: 'Storytelling',
      icon: Icons.auto_stories_outlined,
      builder: (context, info) => ProjectTheatreSection(
        project: project,
        info: info,
      ),
    );
  }

  ProjectSection _buildLivePreviewSection() {
    return ProjectSection(
      id: 'live_preview',
      title: 'Aperçu',
      icon: Icons.preview,
      builder: (context, info) => LivePreviewSection(
        url: project.lienProjet!,
        projectTitle: project.title,
        info: info,
      ),
    );
  }

  ProjectSection _buildWakaTimeSection() {
    return ProjectSection(
      id: 'wakatime',
      title: 'Développement',
      icon: Icons.code,
      builder: (context, info) => EnhancedWakaTimeSection(
        projectName: project.title,
        info: info,
      ),
    );
  }

  ProjectSection _buildInfrastructureSection() {
    return ProjectSection(
      id: 'infrastructure',
      title: 'Infrastructure',
      icon: Icons.architecture,
      builder: (context, info) => InfrastructureSection(
        development: project.development!,
        info: info,
      ),
    );
  }

  ProjectSection _buildEconomicSection() {
    return ProjectSection(
      id: 'economic',
      title: 'Analyse économique',
      icon: Icons.bar_chart_rounded,
      builder: (context, info) => EconomicSection(
        development: project.development!,
        info: info,
      ),
    );
  }

  ProjectSection _buildIoTSection() {
    return ProjectSection(
      id: 'iot',
      title: 'IoT',
      icon: Icons.sensors,
      builder: (context, info) => IoTSection(info: info),
    );
  }

  ProjectSection _buildTechDetailsSection() {
    return ProjectSection(
      id: 'tech',
      title: 'Techniques',
      icon: Icons.settings,
      builder: (context, info) => TechDetailsSection(
        techDetails: project.techDetails!,
        info: info,
      ),
    );
  }

  ProjectSection _buildResultsSection() {
    return ProjectSection(
      id: 'results',
      title: 'Résultats',
      icon: Icons.assessment,
      builder: (context, info) => ResultsSection(
        project: project,
        info: info,
      ),
    );
  }

  ProjectSection _buildArtifactsSection() {
    return ProjectSection(
      id: 'artifacts',
      title: 'En savoir plus',
      icon: Icons.menu_book_outlined,
      builder: (context, info) => ArtifactsSection(
        project: project,
        info: info,
      ),
    );
  }

  /// Détecte si le projet a des tags de programmation
  ///
  /// Vérifie:
  /// - Les mots-clés de programmation dans le titre
  /// - Les technologies de programmation dans les points
  bool hasProgrammingTag() {
    final titleLower = project.title.toLowerCase();

    // Vérifier les tags de programmation dans le titre
    final titleMatches = TechIconHelper.getProgrammingTags()
        .any((tag) => titleLower.contains(tag));

    // Vérifier les technologies dans les points
    final pointsMatch = project.points.any((p) {
      return TechIconHelper.isProgrammingTech(p);
    });

    return titleMatches || pointsMatch;
  }

  /// Détecte si le projet a des liens vers un site déployé (preview live)
  bool hasLivePreview() {
    return project.lienProjet != null && project.lienProjet!.trim().isNotEmpty;
  }

  /// Détecte si le projet a des features IoT
  ///
  /// Recherche des mots-clés IoT dans:
  /// - Le titre du projet
  /// - Les points de description
  bool hasIoTFeatures() {
    final titleLower = project.title.toLowerCase();
    final pointsText = project.points.join(' ').toLowerCase();

    // Mots-clés IoT à détecter
    const iotKeywords = [
      'iot',
      'capteur',
      'sensor',
      'température',
      'consommation',
      'vibration',
      'humidité',
      'esp8266',
      'esp32',
      'raspberry',
      'arduino',
      'temps réel',
      'real-time',
      'monitoring',
      'surveillance',
      'chantier',
      'mqtt',
      'telemetry',
      'télémétrie',
    ];

    return iotKeywords.any((keyword) =>
        titleLower.contains(keyword) || pointsText.contains(keyword));
  }

  /// Vérifie si le projet a des données d'infrastructure
  bool hasInfrastructureData() {
    return project.development != null && project.development!.isNotEmpty;
  }

  /// Vérifie si le projet a des données économiques
  bool hasEconomicData() {
    return project.development != null &&
        project.development!.isNotEmpty &&
        (project.development!.containsKey('6_roi_global') ||
            project.development!.containsKey('5_synthese_annuelle'));
  }

  /// Vérifie si le projet a des détails techniques
  bool hasTechDetails() {
    return project.techDetails?.isNotEmpty ?? false;
  }

  /// Vérifie si le projet a un repo GitHub renseigné (nécessaire pour
  /// tenter de récupérer les artefacts .md)
  bool hasGithubRepo() {
    return project.githubRepoUrl != null &&
        project.githubRepoUrl!.trim().isNotEmpty;
  }

  /// Vérifie si le projet a des résultats
  bool hasResults() {
    return (project.results?.isNotEmpty ?? false) ||
        (project.resultsMap?.isNotEmpty ?? false);
  }

  /// Retourne la liste des images du projet
  List<String> getImages() {
    final images = project.cleanedImages ?? project.image;
    return images ?? [];
  }

  /// Retourne le nombre total de sections disponibles
  int getSectionsCount(BuildContext context) {
    return buildSections(context).length;
  }

  /// Vérifie si une section spécifique existe
  bool hasSectionWithId(String sectionId, BuildContext context) {
    return buildSections(context).any((s) => s.id == sectionId);
  }

  /// Retourne une section par son ID (ou null si introuvable)
  ProjectSection? getSectionById(String sectionId, BuildContext context) {
    try {
      return buildSections(context).firstWhere((s) => s.id == sectionId);
    } catch (e) {
      return null;
    }
  }

  /// Analyse la maturité technique du projet selon les 8 piliers
  Map<TechPillar, double> analyzeMaturity() {
    final scores = <TechPillar, double>{};
    final pointsText = project.points.join(' ').toLowerCase();
    final techDetailsText = project.techDetails?.toString().toLowerCase() ?? '';
    final allText = '$pointsText $techDetailsText ${project.title.toLowerCase()}';

    for (final pillar in TechPillar.values) {
      double score = 0.1; // SCORE MINIMAL FORCÉ POUR VISIBILITÉ
      switch (pillar) {
        case TechPillar.architecture:
          if (allText.contains('arch') || allText.contains('clean')) score += 0.4;
          if (allText.contains('modul')) score += 0.3;
          if (allText.contains('ddd') || allText.contains('mvvm')) score += 0.3;
          break;
        case TechPillar.stateManagement:
          if (allText.contains('riverpod') || allText.contains('bloc')) score += 0.5;
          if (allText.contains('prov') || allText.contains('getit') || allText.contains('state')) score += 0.3;
          break;
        case TechPillar.testing:
          if (allText.contains('test')) score += 0.4;
          if (allText.contains('qualité') || allText.contains('ready')) score += 0.3;
          break;
        case TechPillar.security:
          if (allText.contains('auth') || allText.contains('secu')) score += 0.3;
          if (allText.contains('chiffr') || allText.contains('crypt') || allText.contains('ssl')) score += 0.4;
          break;
        case TechPillar.performance:
          if (allText.contains('fps') || allText.contains('fluide') || allText.contains('perf')) score += 0.3;
          if (allText.contains('optim')) score += 0.3;
          if (allText.contains('async') || allText.contains('future')) score += 0.4;
          break;
        case TechPillar.cicd:
          if (allText.contains('github') || allText.contains('git') || allText.contains('deploy')) score += 0.5;
          break;
        case TechPillar.monitoring:
          if (allText.contains('sentry') || allText.contains('fireb') || allText.contains('log')) score += 0.4;
          if (allText.contains('analytic') || allText.contains('suivi')) score += 0.3;
          break;
        case TechPillar.aiSmart:
          if (allText.contains('ia ') || allText.contains('ai ') || allText.contains('gpt') || allText.contains('intel')) score += 0.5;
          if (allText.contains('smart')) score += 0.5;
          break;
      }
      scores[pillar] = score.clamp(0.0, 1.0);
    }
    return scores;
  }

  /// Formate une clé technique en texte lisible
  ///
  /// Exemple: "temps_economise_total" -> "Temps Économisé Total"
  static String formatKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) =>
            word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Extrait les badges économiques depuis les données de développement
  static List<Map<String, String>> getEconomicBadges(Map<String, dynamic> dev) {
    final badges = <Map<String, String>>[];

    // ROI Global
    if (dev.containsKey('6_roi_global')) {
      final roi = dev['6_roi_global'] as Map<String, dynamic>;

      if (roi.containsKey('roi_3_ans')) {
        badges.add(
            {'label': '💰 ROI 3 ans', 'value': roi['roi_3_ans'].toString()});
      }

      if (roi.containsKey('gains_totaux')) {
        badges.add({'label': '💶 Gains', 'value': '${roi['gains_totaux']}€'});
      }

      if (roi.containsKey('couts_totaux')) {
        badges.add({'label': '💸 Coûts', 'value': '${roi['couts_totaux']}€'});
      }
    }

    // Interprétation Business
    if (dev.containsKey('7_interpretation_business')) {
      final business = dev['7_interpretation_business'] as Map<String, dynamic>;

      if (business.containsKey('temps_economise_total')) {
        badges.add({
          'label': '⏰ Temps gagné',
          'value': business['temps_economise_total'].toString()
        });
      }

      if (business.containsKey('reactivite')) {
        badges.add({
          'label': '⚡ Réactivité',
          'value': business['reactivite'].toString()
        });
      }
    }

    return badges;
  }
}
