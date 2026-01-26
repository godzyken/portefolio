import 'package:flutter/material.dart';

import '../../../core/ui/ui_widgets_extentions.dart';
import '../../projets/data/project_data.dart';
import '../../projets/data/project_section.dart';
import '../views/generator_widgets_extentions.dart';

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
      // Hero (toujours présent)
      _buildHeroSection(),
    ];

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

    return sections;
  }

  // ==========================================================================
  // BUILDERS DE SECTIONS
  // ==========================================================================

  ProjectSection _buildHeroSection() {
    return ProjectSection(
      id: 'hero',
      title: 'Présentation',
      icon: Icons.home,
      builder: (context, info) => HeroSection(
        project: project,
        info: info,
        hasProgrammingTag: hasProgrammingTag(),
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

  // ==========================================================================
  // DÉTECTION DE FEATURES
  // ==========================================================================

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

  /// Vérifie si le projet a des résultats
  bool hasResults() {
    return (project.results?.isNotEmpty ?? false) ||
        (project.resultsMap?.isNotEmpty ?? false);
  }

  // ==========================================================================
  // HELPERS D'ACCÈS AUX DONNÉES
  // ==========================================================================

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

  // ==========================================================================
  // FORMATAGE ET UTILITAIRES
  // ==========================================================================

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
