import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/provider/providers.dart';
import '../../model/state/contact_form_state.dart';
import '../../providers/contact_form_provider.dart';

/// ➜ Ajoute `url_launcher` si tu souhaites déclencher WhatsApp ou ouvrir un mail
class ContactScreen extends ConsumerStatefulWidget {
  const ContactScreen({super.key});

  @override
  ConsumerState<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends ConsumerState<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appBarTitleProvider.notifier).setTitle("Contactez moi");
      ref.read(appBarActionsProvider.notifier).clearActions();
      ref.read(appBarDrawerProvider.notifier).setDrawer;
    });
  }

  // Affiche un SnackBar selon le nouveau status.
  void _listenAndSnack(ContactFormState next) {
    if (next.status == SubmitStatus.success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Message envoyé !')));
      ref.read(contactFormProvider.notifier).reset();
      _formKey.currentState?.reset();
    } else if (next.status == SubmitStatus.error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur : ${next.error}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Écoute les changements pour gérer les SnackBars
    ref.listen<ContactFormState>(contactFormProvider, (_, next) {
      _listenAndSnack(next);
    });

    final formState = ref.watch(contactFormProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final horizontalPadding = isWide ? constraints.maxWidth * .2 : 24.0;

        return Scrollbar(
          controller: _scrollCtrl,
          child: SingleChildScrollView(
            controller: _scrollCtrl,
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 24,
            ),
            child: Form(
              key: _formKey,
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Envoyez‑moi un message',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    _NameField(initial: formState.name),
                    const SizedBox(height: 12),
                    _EmailField(initial: formState.email),
                    const SizedBox(height: 12),
                    _MessageField(initial: formState.message),
                    const SizedBox(height: 20),
                    _SubmitRow(
                      isSubmitting: formState.status == SubmitStatus.loading,
                      onEmail: () async {
                        if (_formKey.currentState!.validate()) {
                          await ref
                              .read(contactFormProvider.notifier)
                              .submit(Channel.email);
                        }
                      },
                      onWhatsApp: () async {
                        if (_formKey.currentState!.validate()) {
                          await ref
                              .read(contactFormProvider.notifier)
                              .submit(Channel.whatsapp);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ——————————————————————————————————————— Widgets champs ——————————————————————————————————————
class _NameField extends ConsumerWidget {
  final String initial;
  const _NameField({required this.initial});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextFormField(
      initialValue: initial,
      decoration: const InputDecoration(labelText: 'Nom'),
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.name],
      onChanged: (val) =>
          ref.read(contactFormProvider.notifier).updateName(val),
      validator: (val) =>
          val == null || val.isEmpty ? 'Veuillez entrer votre nom' : null,
    );
  }
}

class _EmailField extends ConsumerWidget {
  final String initial;
  const _EmailField({required this.initial});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextFormField(
      initialValue: initial,
      decoration: const InputDecoration(labelText: 'Email'),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      onChanged: (val) =>
          ref.read(contactFormProvider.notifier).updateEmail(val),
      validator: (val) {
        if (val == null || val.isEmpty) {
          return 'Veuillez entrer votre email';
        }
        final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+\$');
        return emailRegex.hasMatch(val) ? null : 'Email invalide';
      },
    );
  }
}

class _MessageField extends ConsumerWidget {
  final String initial;
  const _MessageField({required this.initial});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextFormField(
      initialValue: initial,
      decoration: const InputDecoration(labelText: 'Message'),
      maxLines: 6,
      onChanged: (val) =>
          ref.read(contactFormProvider.notifier).updateMessage(val),
      validator: (val) =>
          val == null || val.isEmpty ? 'Veuillez écrire un message' : null,
    );
  }
}

// ———————————————————————————————— Row Boutons / Loading ————————————————————————————————
class _SubmitRow extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback onEmail;
  final VoidCallback onWhatsApp;

  const _SubmitRow({
    required this.isSubmitting,
    required this.onEmail,
    required this.onWhatsApp,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.email),
                  label: const Text('Envoyer e‑mail'),
                  onPressed: onEmail,
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  icon: const Icon(Icons.phone),
                  label: const Text('WhatsApp'),
                  onPressed: onWhatsApp,
                ),
              ],
            ),
    );
  }
}
