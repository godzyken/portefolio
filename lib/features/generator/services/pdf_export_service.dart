import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../projets/data/project_data.dart';

class PdfExportService {
  Future<pw.Font> loadCustomFont() async {
    final fontData = await rootBundle.load(
      'assets/fonts/Noto_Sans/NotoSans-VariableFont_wdth-wght.ttf',
      //'assets/fonts/Noto_Sans/static/NotoSans-Regular.ttf',
    );
    return pw.Font.ttf(fontData);
  }

  Future<Uint8List> generatePdfWithUnicode(List<ProjectInfo> selected) async {
    final font = await loadCustomFont();

    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        build: (context) => pw.Column(
          children: selected.map((p) {
            return pw.Text(
              "${p.title} 🚀", // ou n'importe quel champ contenant des emojis
              style: pw.TextStyle(font: font),
            );
          }).toList(),
        ),
      ),
    );

    return doc.save();
  }

  String sanitizeText(String input) {
    // Supprime les emojis non supportés (Unicode supérieur à U+FFFF)
    return input.replaceAll(
      RegExp(r'[\u{1F300}-\u{1FAFF}]', unicode: true),
      '',
    );
  }

  Future<void> export(List<ProjectInfo> projects) async {
    final pdf = pw.Document();
    final customFont = await loadCustomFont();

    for (final project in projects) {
      pw.MemoryImage? bgImage;

      if (project.cleanedImages != null && project.cleanedImages!.isNotEmpty) {
        try {
          final data = await rootBundle.load(project.cleanedImages!.first);
          final bytes = data.buffer.asUint8List();
          bgImage = pw.MemoryImage(bytes);
        } catch (e) {
          if (kDebugMode) {
            print("Erreur de chargement image PDF : $e");
          }
        }
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Stack(
              children: [
                if (bgImage != null)
                  pw.Positioned.fill(
                    child: pw.Opacity(
                      opacity: 0.15,
                      child: pw.Image(bgImage, fit: pw.BoxFit.cover),
                    ),
                  ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(32),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        project.title,
                        style: pw.TextStyle(
                          font: customFont,
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.indigo800,
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      ...project.points.map(
                        (point) => pw.Bullet(
                          text: sanitizeText(point),
                          style: pw.TextStyle(font: customFont),
                        ),
                      ),
                      pw.SizedBox(height: 20),
                      if (project.lienProjet != null)
                        pw.UrlLink(
                          destination: project.lienProjet!,
                          child: pw.Text(
                            '🔗 Voir le projet en ligne',
                            style: pw.TextStyle(
                              font: customFont,
                              fontSize: 12,
                              decoration: pw.TextDecoration.underline,
                              color: PdfColors.blue,
                            ),
                          ),
                        ),
                      pw.Spacer(),
                      pw.Divider(),
                      pw.Text(
                        '— Page générée automatiquement —',
                        style: pw.TextStyle(
                          font: customFont,
                          fontSize: 10,
                          color: PdfColors.grey600,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}
