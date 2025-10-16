import 'package:flutter/material.dart';

@immutable
class AppImages {
  final List<String> projects;
  final List<String> experiences;
  final List<String> services;
  final List<String> network;

  const AppImages({
    required this.projects,
    required this.experiences,
    required this.services,
    required this.network,
  });

  List<String> get all =>
      [...projects, ...experiences, ...services, ...network];
}
