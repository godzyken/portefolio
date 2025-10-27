import 'dart:developer' as developer;
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:web/web.dart' as web;

class CvDownloadService {
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
                SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    )),
                Icon(Icons.download, color: Colors.white),
                SizedBox(width: 16),
                Expanded(
                  child: Text('Téléchargement du CV en cours...'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
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

  /// ✅ Téléchargement direct pour le Web (sans ouvrir de navigateur)
  Future<void> downloadCvWeb(String url, {String filename = 'CV.pdf'}) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Erreur HTTP: ${response.statusCode}');
    }

    final blob = web.Blob([response.bodyBytes] as JSArray<web.BlobPart>);
    final blobUrl = web.URL.createObjectURL(blob);

    final anchor = web.HTMLAnchorElement()
      ..href = blobUrl
      ..setAttribute('download', filename)
      ..style.display = 'none';

    web.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    web.URL.revokeObjectURL(blobUrl);
  }

  /// Convertit une URL OneDrive en URL de téléchargement direct
  String _convertToDirectDownloadUrl(String url) {
    try {
      developer.log('🔄 Conversion URL: $url');

      // OneDrive: ajouter le paramètre download=1
      if (url.contains('1drv.ms') || url.contains('onedrive.live.com')) {
        if (url.contains('?')) {
          return '$url&download=1';
        } else {
          return '$url?download=1';
        }
      }

      // Google Drive: format d'export direct
      if (url.contains('drive.google.com')) {
        final fileId = _extractGoogleDriveFileId(url);
        if (fileId != null) {
          return 'https://drive.google.com/uc?export=download&id=$fileId';
        }
      }

      // Dropbox: remplacer dl=0 par dl=1
      if (url.contains('dropbox.com')) {
        return url.replaceAll('dl=0', 'dl=1');
      }

      // Par défaut, retourner l'URL originale
      return url;
    } catch (e) {
      developer.log('⚠️ Erreur conversion URL: $e');
      return url;
    }
  }

  /// Extrait l'ID du fichier Google Drive depuis une URL
  String? _extractGoogleDriveFileId(String url) {
    final patterns = [
      RegExp(r'/d/([a-zA-Z0-9_-]+)'),
      RegExp(r'id=([a-zA-Z0-9_-]+)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null) {
        return match.group(1);
      }
    }

    return null;
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

  /// Télécharge le CV et retourne les bytes (pour preview)
  Future<Uint8List?> downloadCvBytes(String cvUrl) async {
    try {
      final downloadUrl = _convertToDirectDownloadUrl(cvUrl);
      final response = await http.get(Uri.parse(downloadUrl));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      }

      return null;
    } catch (e) {
      developer.log('❌ Erreur downloadCvBytes: $e');
      return null;
    }
  }
}
