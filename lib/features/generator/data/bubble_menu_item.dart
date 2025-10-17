import 'package:flutter/material.dart';

// Modèle pour chaque bouton du menu
class BubbleMenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onPressed; // Action à exécuter au clic

  BubbleMenuItem(
      {required this.icon, required this.label, required this.onPressed});
}
