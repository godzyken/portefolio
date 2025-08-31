import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/contact/providers/emailjs_provider.dart';

import '../model/state/contact_form_state.dart';
import '../services/contact_form_service.dart';

enum Channel { email, whatsapp }

final contactFormProvider =
    StateNotifierProvider<ContactFormNotifier, ContactFormState>((ref) {
      return ContactFormNotifier(ref);
    });

class ContactFormNotifier extends StateNotifier<ContactFormState> {
  ContactFormNotifier(this.ref) : super(const ContactFormState());
  final Ref ref;

  // updates
  void updateName(String v) => state = state.copyWith(name: v);
  void updateEmail(String v) => state = state.copyWith(email: v);
  void updateMessage(String v) => state = state.copyWith(message: v);

  Future<void> submit(Channel channel) async {
    state = state.copyWith(status: SubmitStatus.loading, error: null);

    try {
      switch (channel) {
        case Channel.email:
          final emailJs = ref.read(emailJsProvider);

          developer.log(">>> SUBMIT EMAILJS");
          developer.log("name: ${state.name}");
          developer.log("email: ${state.email}");
          developer.log("message: ${state.message}");

          await emailJs.sendEmail(
            name: state.name.isNotEmpty ? state.name : "Anonyme",
            email: state.email.isNotEmpty
                ? state.email
                : "no-reply@example.com",
            message: state.message.isNotEmpty ? state.message : "-",
          );
          state = state.copyWith(status: SubmitStatus.success);
          break;
        case Channel.whatsapp:
          await ref
              .read(whatsappServiceProvider)
              .send(state.name, state.email, state.message);
          break;
      }
      state = state.copyWith(status: SubmitStatus.success);
    } catch (e) {
      state = state.copyWith(status: SubmitStatus.error, error: e.toString());
    }
  }

  void reset() => state = const ContactFormState();
}
