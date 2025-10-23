import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment:
                isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Text(
                "Godzyken",
                style: GoogleFonts.montserrat(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Développeur Flutter freelance",
                style: GoogleFonts.openSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Je conçois des applications Flutter sur mesure pour aider les entreprises à digitaliser leurs processus métiers.\n\n"
                "Chaque année, je développe un projet complet — de l’idée à la mise en production — pour transformer des besoins réels "
                "en solutions performantes et durables.\n\n"
                "Travaillant seul, je maîtrise chaque aspect du développement (UX, architecture, intégration, déploiement) "
                "afin d’offrir des outils clairs, efficaces et alignés sur les objectifs de mes clients.",
                textAlign: isWide ? TextAlign.start : TextAlign.center,
                style: GoogleFonts.openSans(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  // Action vers contact ou projets
                },
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text("Découvrir mes projets"),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
