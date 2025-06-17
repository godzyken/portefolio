import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/state/contact_form_state.dart';
import '../../providers/contact_form_provider.dart';

class ContactScreen extends ConsumerStatefulWidget {
  const ContactScreen({super.key});

  @override
  ConsumerState<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends ConsumerState<ContactScreen> {
  final _formKey = GlobalKey<FormState>();

  void _handleSnack(WidgetRef ref) {
    final s = ref.read(contactFormProvider);
    if (s.status == SubmitStatus.success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Message envoyé !')));
      ref.read(contactFormProvider.notifier).reset();
      _formKey.currentState!.reset();
    } else if (s.status == SubmitStatus.error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur : ${s.error}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(contactFormProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Contact')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'Envoyez-moi un message',
                style: Theme.of(context).textTheme.headlineSmall,
              ),

              const SizedBox(height: 20),
              TextFormField(
                initialValue: formState.name,
                decoration: const InputDecoration(labelText: 'Nom'),
                onChanged:
                    (val) =>
                        ref.read(contactFormProvider.notifier).updateName(val),
                validator:
                    (val) =>
                        val == null || val.isEmpty
                            ? 'Veuillez entrer votre nom'
                            : null,
              ),

              const SizedBox(height: 12),
              TextFormField(
                initialValue: formState.email,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                onChanged:
                    (val) =>
                        ref.read(contactFormProvider.notifier).updateEmail(val),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Veuillez entrer votre email';
                  }
                  final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
                  return emailRegex.hasMatch(val) ? null : 'Email invalide';
                },
              ),

              const SizedBox(height: 12),
              TextFormField(
                initialValue: formState.message,
                decoration: const InputDecoration(labelText: 'Message'),
                maxLines: 4,
                onChanged:
                    (val) => ref
                        .read(contactFormProvider.notifier)
                        .updateMessage(val),
                validator:
                    (val) =>
                        val == null || val.isEmpty
                            ? 'Veuillez écrire un message'
                            : null,
              ),

              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.email),
                label: const Text('Envoyer e‑mail'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await ref
                        .read(contactFormProvider.notifier)
                        .submit(Channel.email);
                    _handleSnack(ref); // fonction utilitaire pour snackbars
                  }
                },
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                icon: Icon(Icons.phone),
                label: const Text('WhatsApp'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await ref
                        .read(contactFormProvider.notifier)
                        .submit(Channel.whatsapp);
                    _handleSnack(ref);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
