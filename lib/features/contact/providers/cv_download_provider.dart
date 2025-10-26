import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/provider/config_env_provider.dart';
import '../services/cv_download_service.dart';

/// Provider pour le service de téléchargement CV
final cvDownloadServiceProvider = Provider<CvDownloadService>((ref) {
  return CvDownloadService();
});

/// Provider pour l'URL du CV depuis .env
final cvUrlProvider = Provider<String>((ref) {
  try {
    return ref.watch(cvOneDriveUrlProvider);
  } catch (e) {
    developer.log('⚠️ CV_ONEDRIVE_URL non configuré: $e');
    return '';
  }
});

/// Provider pour vérifier si le CV est disponible
final isCvAvailableProvider = Provider<bool>((ref) {
  final url = ref.watch(cvUrlProvider);
  final service = ref.watch(cvDownloadServiceProvider);

  return service.isValidCvUrl(url);
});
