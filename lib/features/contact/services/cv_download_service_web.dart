import 'dart:js_interop';

import 'package:http/http.dart' as http;
import 'package:web/web.dart' as web;

/// Implémentation Web du téléchargement de CV
Future<void> downloadCvWebImpl(String url, {String filename = 'CV.pdf'}) async {
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
