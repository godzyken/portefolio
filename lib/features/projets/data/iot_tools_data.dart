import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

/// Modèle représentant une catégorie d'outil IoT utilisée sur les chantiers
class IoTToolCategory {
  final int index;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const IoTToolCategory({
    required this.index,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

/// Catalogue des outils IoT couramment utilisés sur les chantiers
///
/// Sert de contenu pédagogique/vitrine dans la section IoT du portfolio,
/// en complément du dashboard de démonstration temps réel.
const List<IoTToolCategory> kIoTToolCategories = [
  IoTToolCategory(
    index: 1,
    title: 'Suivi d\'équipements (asset trackers)',
    description:
        'GPS/RTLS, balises Bluetooth ou RFID pour localiser engins, outils et containers.',
    icon: LucideIcons.map_pin,
    color: Colors.cyanAccent,
  ),
  IoTToolCategory(
    index: 2,
    title: 'Télématique machine',
    description:
        'Capteurs branchés sur pelles, bulldozers, nacelles pour remonter heures d\'usage, carburant, codes panne.',
    icon: LucideIcons.truck,
    color: Colors.orangeAccent,
  ),
  IoTToolCategory(
    index: 3,
    title: 'Capteurs de sécurité portables (wearables)',
    description:
        'Bracelet/gilet détectant chute, absence de mouvement, fréquence cardiaque, exposition à la chaleur.',
    icon: LucideIcons.heart_pulse,
    color: Colors.pinkAccent,
  ),
  IoTToolCategory(
    index: 4,
    title: 'Détection de proximité / prévention de collision',
    description:
        'Capteurs ultrasons, radar ou UWB sur engins et personnels pour éviter heurts et collisions.',
    icon: LucideIcons.radar,
    color: Colors.redAccent,
  ),
  IoTToolCategory(
    index: 5,
    title: 'Vidéo intelligente et caméras de chantier',
    description:
        'Caméras IP + analyse vidéo pour sécurité, contrôle d\'accès, comptage d\'ouvriers et suivi d\'avancement.',
    icon: LucideIcons.camera,
    color: Colors.deepPurpleAccent,
  ),
  IoTToolCategory(
    index: 6,
    title: 'Capteurs environnementaux',
    description:
        'Mesure poussières (PM2.5/PM10), gaz (CO, NO2…), bruit, vibration, température/humidité pour conformité et santé.',
    icon: LucideIcons.wind,
    color: Colors.lightGreenAccent,
  ),
  IoTToolCategory(
    index: 7,
    title: 'Surveillance structurelle (structural health)',
    description:
        'Capteurs d\'efforts, jauges de contrainte, inclinomètres et accéléromètres pour ponts, coffrages, excavations.',
    icon: LucideIcons.building_2,
    color: Colors.amberAccent,
  ),
  IoTToolCategory(
    index: 8,
    title: 'Capteurs de béton / cure du béton',
    description:
        'Mesure température et résistance (maturité) pour optimiser décoffrage et qualité.',
    icon: LucideIcons.thermometer,
    color: Colors.blueGrey,
  ),
  IoTToolCategory(
    index: 9,
    title: 'Capteurs de charge et cellules de pesée',
    description:
        'Pour surveillance des charges sur grues, palans et points d\'ancrage.',
    icon: LucideIcons.weight,
    color: Colors.deepOrangeAccent,
  ),
  IoTToolCategory(
    index: 10,
    title: 'Contrôle d\'accès et gestion des présences',
    description:
        'Portails connectés, badges RFID/NFC et bornes pour suivre les entrées/sorties et heures travaillées.',
    icon: LucideIcons.id_card,
    color: Colors.tealAccent,
  ),
  IoTToolCategory(
    index: 11,
    title: 'Drones et photogrammétrie',
    description:
        'Drones équipés de capteurs/photogrammétrie pour levés, suivi d\'avancement, détection d\'anomalies.',
    icon: LucideIcons.plane,
    color: Colors.lightBlueAccent,
  ),
  IoTToolCategory(
    index: 12,
    title: 'Solutions connectivity & gateways',
    description:
        'Gateways LoRaWAN, Sigfox, LTE-M / NB-IoT, Wi-Fi, 4G/5G pour relier capteurs au cloud.',
    icon: LucideIcons.router,
    color: Colors.cyan,
  ),
  IoTToolCategory(
    index: 13,
    title: 'Plateformes IoT / dashboards',
    description:
        'Plateformes cloud pour collecte, visualisation, alerting et intégration avec ERP/BIM.',
    icon: LucideIcons.layout_dashboard,
    color: Colors.purpleAccent,
  ),
  IoTToolCategory(
    index: 14,
    title: 'Intégration BIM + IoT',
    description:
        'Liaison entre maquette numérique et capteurs pour visualiser l\'état réel dans le modèle 3D.',
    icon: LucideIcons.box,
    color: Colors.indigoAccent,
  ),
  IoTToolCategory(
    index: 15,
    title: 'Systèmes d\'alerte et notifications',
    description:
        'Logique d\'alerte (SMS, push, e-mail) pour seuils critiques (gaz, charge, chute).',
    icon: LucideIcons.bell_ring,
    color: Colors.yellowAccent,
  ),
];
