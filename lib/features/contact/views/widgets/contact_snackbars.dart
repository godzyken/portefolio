import 'package:flutter/material.dart';
import 'package:portefolio/core/ui/widgets/responsive_text.dart';

class ContactSnackbars {
  static SnackBar success() {
    return SnackBar(
      content: Row(
        children: [
          ResponsiveBox(
            paddingSize: ResponsiveSpacing.s,
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle),
            child: const Icon(Icons.check_circle, color: Colors.white),
          ),
          const ResponsiveBox(paddingSize: ResponsiveSpacing.m),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ResponsiveText.bodyMedium('Message envoyé !',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ResponsiveText.bodyMedium('Je vous répondrai sous 24h',
                    style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 4),
    );
  }

  static SnackBar error(String? error) {
    return SnackBar(
      content: Row(children: [
        const Icon(Icons.error_outline, color: Colors.white),
        const ResponsiveBox(paddingSize: ResponsiveSpacing.m),
        Expanded(child: ResponsiveText.headlineSmall('Erreur : \$error'))
      ]),
      backgroundColor: Colors.red.shade700,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(16),
    );
  }
}
