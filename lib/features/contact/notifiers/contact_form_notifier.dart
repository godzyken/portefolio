import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/state/contact_form_state.dart';
import '../providers/emailjs_provider.dart';
import '../services/contact_form_service.dart';

class ContactFormNotifier extends Notifier<ContactFormState> {
  @override
  ContactFormState build() {
    return const ContactFormState();
  }

  void updateName(String value) => state = state.copyWith(name: value);
  void updateEmail(String value) => state = state.copyWith(email: value);
  void updateMessage(String value) => state = state.copyWith(message: value);

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
            email:
                state.email.isNotEmpty ? state.email : "no-reply@example.com",
            message: state.message.isNotEmpty ? state.message : "-",
          );
          state = state.copyWith(status: SubmitStatus.success);
          break;

        case Channel.whatsapp:
          final whatsappService = ref.read(whatsappServiceProvider);
          await whatsappService.send(state.name, state.email, state.message);
          state = state.copyWith(status: SubmitStatus.success);
          break;
      }
    } catch (e, st) {
      developer.log('Error submitting contact form', error: e, stackTrace: st);
      state = state.copyWith(status: SubmitStatus.error, error: e.toString());
    }
  }

  void reset() => state = const ContactFormState();
}
