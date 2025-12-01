import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/state/contact_form_state.dart';
import '../notifiers/contact_form_notifier.dart';

final contactFormProvider =
    NotifierProvider<ContactFormNotifier, ContactFormState>(
  ContactFormNotifier.new,
);
