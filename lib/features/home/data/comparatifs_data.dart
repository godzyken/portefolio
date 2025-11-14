import 'package:equatable/equatable.dart';

class Comparatif extends Equatable {
  final String id;
  final String title;
  final String description;
  final List<ComparatifEntry> entries;

  const Comparatif({
    required this.id,
    required this.title,
    required this.description,
    required this.entries,
  });

  factory Comparatif.fromJson(Map<String, dynamic> json) {
    return Comparatif(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      entries: (json['entries'] as List<dynamic>)
          .map((e) => ComparatifEntry.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'entries': entries.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [id, title, description, entries];
}

/// Une entrée représentant une catégorie avec une valeur.
///
/// Exemple : durée, coût, satisfaction, etc.
class ComparatifEntry extends Equatable {
  final String label;
  final double value;

  const ComparatifEntry({
    required this.label,
    required this.value,
  });

  factory ComparatifEntry.fromJson(Map<String, dynamic> json) {
    return ComparatifEntry(
      label: json['label'] as String,
      value: (json['value'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'value': value,
      };

  @override
  List<Object?> get props => [label, value];
}
