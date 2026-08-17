import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/provider/json_data_provider.dart';
import 'package:portefolio/features/experience/data/experiences_data.dart';
import 'package:portefolio/features/projets/data/project_data.dart';

class AvatarContextBuilder {
  final Ref ref;

  AvatarContextBuilder(this.ref);

  Future<String> buildGlobalContext() async {
    final projects = await ref.read(projectsProvider.future);
    final experiences = await ref.read(experiencesProvider.future);

    final buffer = StringBuffer();
    buffer.writeln("Voici les informations sur le développeur Flutter freelance :");
    
    buffer.writeln("\n### EXPÉRIENCES PROFESSIONNELLES :");
    for (final exp in experiences) {
      buffer.writeln("- ${exp.poste} chez ${exp.entreprise} (${exp.periode})");
      buffer.writeln("  Contexte : ${exp.contexte}");
      if (exp.missions.isNotEmpty) {
        buffer.writeln("  Missions : ${exp.missions.join(', ')}");
      }
      if (exp.stack.isNotEmpty) {
        buffer.writeln("  Stack : ${exp.stack.values.expand((e) => e).join(', ')}");
      }
    }

    buffer.writeln("\n### PROJETS RÉALISÉS :");
    for (final proj in projects) {
      buffer.writeln("- ${proj.title}");
      if (proj.storyline != null) {
        buffer.writeln("  Storyline : ${proj.storyline}");
      }
      buffer.writeln("  Points clés : ${proj.points.join(', ')}");
      if (proj.tags != null) {
        buffer.writeln("  Tags : ${proj.tags!.join(', ')}");
      }
    }

    buffer.writeln("\n### INSTRUCTIONS POUR L'AVATAR :");
    buffer.writeln("Tu es l'avatar virtuel de ce développeur. Réponds aux questions des visiteurs en utilisant EXCLUSIVEMENT les informations ci-dessus.");
    buffer.writeln("Si une information n'est pas présente, réponds poliment que tu n'as pas de données spécifiques à ce sujet mais que tu peux parler de ses expériences chez Apside, EMAP, etc.");
    buffer.writeln("Ton ton est professionnel, technique mais accessible, et légèrement futuriste (style cyberpunk).");
    buffer.writeln("Ne mentionne jamais que tu es une IA ou un modèle de langage. Tu es l'Avatar.");

    String context = buffer.toString();
    // Tronquage rudimentaire si trop long (estimation 1 mot ≈ 1.3 tokens)
    if (context.length > 12000) {
      context = context.substring(0, 12000) + "... [Contexte tronqué]";
    }
    
    return context;
  }
}

final avatarContextBuilderProvider = Provider((ref) => AvatarContextBuilder(ref));
