import 'package:flutter/material.dart';

@immutable
class AppImages {
  final List<String> local; // Images locales (assets)
  final List<String> network; // Images réseau (URLs)

  const AppImages({
    required this.local,
    required this.network,
  });

  List<String> get all => [...local, ...network];
}
