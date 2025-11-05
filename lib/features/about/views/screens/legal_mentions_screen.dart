import 'package:flutter/material.dart';

class LegalMentionsScreen extends StatelessWidget {
  const LegalMentionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mentions légales & Confidentialité'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: DefaultTextStyle(
          style: textTheme.bodyMedium!.copyWith(height: 1.6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Qui sommes-nous ?'),
              const SelectableText(
                "Ce portfolio est le site personnel de Godzyken, présentant mes projets, expériences et réalisations dans le domaine du développement Flutter et de la transformation digitale.\n"
                "Adresse du site : https://godzyken.github.io/portefolio\n\n"
                "Vous pouvez me contacter directement via le formulaire de contact disponible sur le site ou par e-mail à l’adresse indiquée dans la section “Contact”.",
              ),
              const SizedBox(height: 24),
              _sectionTitle('Commentaires / Messages'),
              const SelectableText(
                "Lorsque vous me contactez via le formulaire, les informations que vous saisissez (nom, adresse e-mail, message) sont enregistrées uniquement pour me permettre de répondre à votre demande.\n"
                "Ces données ne sont ni revendues, ni utilisées à des fins commerciales.\n\n"
                "Aucune fonctionnalité de commentaire public n’est disponible sur ce site.",
              ),
              const SizedBox(height: 24),
              _sectionTitle('Médias'),
              const SelectableText(
                "Aucun envoi d’images ou de fichiers n’est public sur le site.\n"
                "Si vous m’envoyez des fichiers via un formulaire, ils sont conservés uniquement le temps nécessaire pour traiter votre demande, puis supprimés.",
              ),
              const SizedBox(height: 24),
              _sectionTitle('Cookies'),
              const SelectableText(
                "Ce site peut utiliser des cookies techniques pour améliorer l’expérience de navigation (par exemple, retenir vos préférences de thème sombre/clair).\n"
                "Ces cookies ne collectent aucune donnée personnelle.\n\n"
                "Si vous utilisez une section de contact protégée par reCAPTCHA ou un outil d’analyse d’audience, ces services peuvent déposer leurs propres cookies selon leurs politiques de confidentialité.",
              ),
              const SizedBox(height: 24),
              _sectionTitle('Contenu embarqué depuis d’autres sites'),
              const SelectableText(
                "Les pages peuvent inclure des contenus intégrés (ex. vidéos YouTube, publications GitHub, etc.).\n"
                "Ces sites externes peuvent collecter des données vous concernant, utiliser des cookies, ou suivre vos interactions avec leur contenu intégré.",
              ),
              const SizedBox(height: 24),
              _sectionTitle(
                  'Utilisation et transmission de vos données personnelles'),
              const SelectableText(
                "Les informations transmises via le formulaire de contact sont utilisées exclusivement pour vous répondre.\n"
                "Aucune donnée n’est transmise à des tiers, sauf exigence légale (ex. réquisition judiciaire).",
              ),
              const SizedBox(height: 24),
              _sectionTitle('Durée de conservation des données'),
              const SelectableText(
                "Les messages envoyés via le formulaire de contact sont conservés au maximum 12 mois, le temps nécessaire pour répondre et assurer un suivi professionnel.\n"
                "Aucune autre donnée personnelle n’est conservée sur le site.",
              ),
              const SizedBox(height: 24),
              _sectionTitle('Vos droits sur vos données'),
              const SelectableText(
                "Conformément au RGPD, vous pouvez demander à accéder, corriger ou supprimer les données personnelles que vous m’avez communiquées.\n"
                "Pour exercer ce droit, contactez-moi directement via le formulaire de contact ou par e-mail.",
              ),
              const SizedBox(height: 24),
              _sectionTitle('Où vos données sont envoyées'),
              const SelectableText(
                "Les messages envoyés depuis le formulaire de contact peuvent être traités via un service sécurisé d’envoi de mails (ex. Firebase, Formspree, ou un serveur mail professionnel).\n"
                "Aucune donnée n’est transmise à des fins publicitaires.",
              ),
              const SizedBox(height: 24),
              Divider(height: 32, thickness: 1, color: Colors.grey.shade400),
              Center(
                child: Text(
                  "Dernière mise à jour : Octobre 2025",
                  style: textTheme.bodySmall!.copyWith(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
