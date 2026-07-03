import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

final Set<String> _registeredViewTypes = {};

/// Construit un `HtmlElementView` affichant [url] dans une iframe.
///
/// Web uniquement. Si le site cible envoie un header `X-Frame-Options` ou
/// une CSP `frame-ancestors` restrictive, le navigateur affichera une page
/// blanche à l'intérieur de l'iframe (comportement du navigateur, pas
/// détectable côté Flutter) : c'est pourquoi l'appelant doit toujours
/// proposer un bouton "Ouvrir dans un nouvel onglet" en complément.
Widget buildLivePreviewIframe(String url) {
  final viewType = 'live-preview-iframe-${Uri.encodeComponent(url)}';

  if (!_registeredViewTypes.contains(viewType)) {
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final iframe = web.HTMLIFrameElement()
        ..src = url
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allow = 'clipboard-write; fullscreen'
        ..referrerPolicy = 'no-referrer-when-downgrade';

      return iframe;
    });

    _registeredViewTypes.add(viewType);
  }

  return HtmlElementView(viewType: viewType);
}
