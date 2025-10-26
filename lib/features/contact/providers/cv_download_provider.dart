import 'dart:developer' as developer;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/cv_download_service.dart';

/// Provider pour le service de téléchargement CV
final cvDownloadServiceProvider = Provider<CvDownloadService>((ref) {
  return CvDownloadService();
});

/// Provider pour l'URL du CV depuis .env
final cvUrlProvider = Provider<String?>((ref) {
  developer.log("dotenv.env ==> ${dotenv.env['CV_ONEDRIVE_URL']}");

  final url = dotenv.env['CV_ONEDRIVE_URL'] ?? '';

  if (url.isEmpty) {
    throw Exception('Variables CV_ONEDRIVE_URL manquantes dans .env');
  }

  developer.log("OneDrive config:");
  developer.log("url: $url");

  return url;
});

/// Provider pour vérifier si le CV est disponible
final isCvAvailableProvider = Provider<bool>((ref) {
  final url = ref.watch(cvUrlProvider);
  final service = ref.watch(cvDownloadServiceProvider);

  return service.isValidCvUrl(url);
});
