import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/enum_global.dart';
import '../notifier/card_flight_notifier.dart';

final activeTagsProvider = StateProvider<List<String>>((ref) => []);

/// Palette de couleurs associée aux tags
final Map<String, Color> tagColors = {
  "Flutter": Colors.blue,
  "Firebase": Colors.orange,
  "Angular": Colors.orange,
  "devOps": Colors.orange,
  /*"IoT": Colors.green,
  "VR": Colors.purple,
  "BTP": Colors.brown,
  "CRM": Colors.teal,
  "PDF": Colors.red,
  "Sécurité": Colors.indigo,*/
  // ajoute d’autres tags selon tes besoins
};

final cardFlightProvider =
    StateNotifierProvider<CardFlightNotifier, Map<String, CardFlightState>>(
      (ref) => CardFlightNotifier(),
    );
