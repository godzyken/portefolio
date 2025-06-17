enum SubmitStatus { idle, loading, success, error }

class ContactFormState {
  final String name;
  final String email;
  final String message;
  final SubmitStatus status;
  final String? error;

  const ContactFormState({
    this.name = '',
    this.email = '',
    this.message = '',
    this.status = SubmitStatus.idle,
    this.error,
  });

  ContactFormState copyWith({
    String? name,
    String? email,
    String? message,
    SubmitStatus? status,
    String? error,
  }) => ContactFormState(
    name: name ?? this.name,
    email: email ?? this.email,
    message: message ?? this.message,
    status: status ?? this.status,
    error: error,
  );
}
