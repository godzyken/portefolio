import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/ui/widgets/responsive_text.dart';

import '../../themes/views/widgets/theme_selector.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
          title: const ResponsiveText.titleLarge("Personnaliser le thème")),
      body: const ResponsiveBox(
        padding: EdgeInsets.all(16),
        paddingSize: ResponsiveSpacing.m,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResponsiveText.headlineMedium(
              "Choisissez un thème :",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ResponsiveBox(
              paddingSize: ResponsiveSpacing.m,
            ),
            ThemeSelector(),
          ],
        ),
      ),
    );
  }
}
