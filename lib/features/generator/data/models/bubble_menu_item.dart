import 'package:flutter/material.dart';

class BubbleMenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  BubbleMenuItem(
      {required this.icon, required this.label, required this.onPressed});
}
