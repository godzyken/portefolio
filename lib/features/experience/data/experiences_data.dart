class Experience {
  final String entreprise;
  final String image;
  final String contexte;
  final List<String> objectifs;
  final List<String> missions;
  final String code;
  final List<String> tags;
  final Map<String, List<String>> stack;
  final String periode;
  final String lienProjet;
  final List<String> resultats;

  Experience({
    required this.entreprise,
    required this.image,
    required this.contexte,
    required this.objectifs,
    required this.missions,
    required this.code,
    required this.tags,
    required this.stack,
    required this.periode,
    required this.lienProjet,
    required this.resultats,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      entreprise: json['entreprise'],
      image: json['image'],
      contexte: json['contexte'],
      objectifs: List<String>.from(json['objectifs']),
      missions: List<String>.from(json['missions']),
      code: json['code'],
      tags: List<String>.from(json['tags']),
      stack: Map<String, List<String>>.from(
        json['stack'].map(
          (key, value) => MapEntry(key, List<String>.from(value)),
        ),
      ),
      periode: json['periode'],
      lienProjet: json['lienProjet'],
      resultats: List<String>.from(json['resultats']),
    );
  }

  Map<String, dynamic> toJson() => {
        'entreprise': entreprise,
        'image': image,
        'contexte': contexte,
        'objectifs': objectifs,
        'missions': missions,
        'code': code,
        'tags': tags,
        'stack': stack,
        'periode': periode,
        'lienProjet': lienProjet,
        'resultats': resultats,
      };
}
