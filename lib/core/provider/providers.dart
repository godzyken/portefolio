import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/tech_logos.dart';
import '../../features/generator/pdf_export_service.dart';
import '../../features/home/data/extentions_models.dart';

// Exemple : état de chargement du PDF
final isGeneratingProvider = StateProvider<bool>((ref) => false);

// Etat de la page courante
final isPageViewProvider = StateProvider<bool>((ref) => true);

// Liste des projets sélectionnés
final selectedProjectsProvider = StateProvider<List<ProjectInfo>>((ref) => []);

// Listes des expériences
final experiencesProvider = StateProvider<List<Experience>>((ref) => []);
final experiencesFutureProvider = FutureProvider<List<Experience>>((ref) async {
  final jsonStr = await rootBundle.loadString('assets/data/experiences.json');
  final List<dynamic> jsonList = jsonDecode(jsonStr);
  return jsonList.map((json) => Experience.fromJson(json)).toList();
});

// Filtre des expériences
final experienceFilterProvider = StateProvider<String?>((ref) => null);
final filterExperiencesProvider = Provider<List<Experience>>((ref) {
  final List<Experience> all = ref
      .watch(experiencesFutureProvider)
      .maybeWhen(data: (d) => d, orElse: () => <Experience>[]);
  final filter = ref.watch(experienceFilterProvider);

  if (filter == null || filter.isEmpty) return all;

  return all.where((exp) => exp.tags.contains(filter)).toList();
});

// List des Services proposer
final servicesFutureProvider = FutureProvider<List<Service>>((ref) async {
  final jsonStr = await rootBundle.loadString('assets/data/services.json');
  final List jsonList = jsonDecode(jsonStr);
  return jsonList.map((json) => Service.fromJson(json)).toList();
});

// Liste des projets
final projectsFutureProvider = FutureProvider<List<ProjectInfo>>((ref) async {
  final jsonStr = await rootBundle.loadString('assets/data/projects.json');
  final List<dynamic> jsonList = jsonDecode(jsonStr);
  return jsonList.map((json) => ProjectInfo.fromJson(json)).toList();
});

// Génerateur de PDF
final pdfExportProvider = Provider<PdfExportService>((ref) {
  return PdfExportService();
});

// Etat du badge WakaTime
final wakatimeBadgeProvider = Provider.family<String?, String>((
  ref,
  projectName,
) {
  return wakatimeBadges[projectName];
});
