import 'package:flutter/material.dart';

class LegalMentionsScreen extends StatelessWidget {
  const LegalMentionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mentions légales'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Mentions légales',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            Text(
              "Éditeur du site :\n"
              "Nom commercial: Godzyken\n"
              "Nom : Doré E.\n"
              "Email : isgodzy@gmail.com\n"
              "Hébergeur : GitHub Pages\n"
              "Adresse : Pézenas. Hérault, 34120, France\n",
            ),
            SizedBox(height: 16),
            Text(
              "Propriété intellectuelle :\n"
              "Les contenus de ce site (textes, images, code source, etc.) sont la propriété exclusive de leur auteur, sauf mention contraire.",
            ),
            SizedBox(height: 16),
            Text(
              "Données personnelles :\n"
              "Ce site ne collecte pas de données personnelles. Aucune information n’est stockée ou partagée.",
            ),
            SizedBox(height: 16),
            Text(
              "Crédits :\n"
              "Développement : Godzyken\n"
              "Technologies : Flutter, Dart, GitHub Pages",
            ),
            SizedBox(height: 32),
            Text(
              "Dernière mise à jour : novembre 2025",
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
