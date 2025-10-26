import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CvDownloadService {
  // URL de ton CV sur OneDrive (à ajouter dans .env)
  static const String _cvUrlKey = 'CV_ONEDRIVE_URL';

  /// Télécharge le CV depuis OneDrive
  Future<void> downloadCv(BuildContext context, String cvUrl) async {
    try {
      final uri = Uri.parse(cvUrl);

      if (!await canLaunchUrl(uri)) {
        throw Exception('Impossible d\'ouvrir le lien du CV');
      }

      // Ouvrir le lien dans le navigateur
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.download, color: Colors.white),
                SizedBox(width: 16),
                Expanded(
                  child: Text('Téléchargement du CV en cours...'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      developer.log('❌ Erreur téléchargement CV: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 16),
                Expanded(
                  child: Text('Erreur: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Vérifie si le lien CV est valide
  bool isValidCvUrl(String? url) {
    if (url == null || url.isEmpty) return false;

    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
}
