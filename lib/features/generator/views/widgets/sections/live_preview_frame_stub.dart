import 'package:flutter/material.dart';

Widget buildLivePreviewIframe(String url) {
  return const Center(
    child: Text(
      'La preview embarquée n\'est disponible que sur le Web. '
      'Utilisez le bouton "Ouvrir le site" sur mobile/desktop.',
      textAlign: TextAlign.center,
    ),
  );
}
