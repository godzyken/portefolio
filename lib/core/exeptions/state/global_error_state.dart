class GlobalErrorState {
  final String message;
  final String? updateUrl;
  final bool? isForceUpdate;

  GlobalErrorState({
    required this.message,
    this.updateUrl,
    this.isForceUpdate = false,
  });
}
