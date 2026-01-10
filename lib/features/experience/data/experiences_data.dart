import 'package:latlong2/latlong.dart';

import '../../generator/data/models/location_data.dart';

class Experience {
  final String id;
  final String entreprise;
  final String logo;
  final String image;
  final String contexte;
  final List<String> objectifs;
  final List<String> missions;
  final String code;
  final List<String> tags;
  final Map<String, List<String>> stack;
  final String periode;
  final String lienProjet;
  final String? youtubeVideoId;
  final LocationData? location;
  final List<String> resultats;
  final String poste;

  Experience({
    required this.id,
    required this.entreprise,
    required this.logo,
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
    required this.poste,
    this.youtubeVideoId,
    this.location,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      // ✅ Protection contre null avec valeurs par défaut
      id: json['exp_id']?.toString() ?? '',
      entreprise: json['entreprise']?.toString() ?? '',
      logo: json['logo']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      contexte: json['contexte']?.toString() ?? '',
      objectifs: (json['objectifs'] as List?)?.cast<String>() ?? [],
      missions: (json['missions'] as List?)?.cast<String>() ?? [],
      code: json['code']?.toString() ?? '',
      tags: (json['tags'] as List?)?.cast<String>() ?? [],
      stack: _parseStack(json['stack']),
      periode: json['periode']?.toString() ?? '',
      lienProjet: json['lienProjet']?.toString() ?? '',
      youtubeVideoId: json['youtubeVideoId']?.toString() ?? '',
      location: json['location'] != null
          ? LocationData.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      resultats: (json['resultats'] as List?)?.cast<String>() ?? [],
      poste: json['poste']?.toString() ?? '',
    );
  }

  // ✅ Méthode helper pour parser le stack de manière sûre
  static Map<String, List<String>> _parseStack(dynamic stackData) {
    if (stackData == null) return {};

    try {
      final Map<String, dynamic> stackMap = stackData as Map<String, dynamic>;
      return stackMap.map((key, value) {
        final List<String> valueList = (value as List?)?.cast<String>() ?? [];
        return MapEntry(key, valueList);
      });
    } catch (e) {
      return {};
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'entreprise': entreprise,
        'logo': logo,
        'image': image,
        'contexte': contexte,
        'objectifs': objectifs,
        'missions': missions,
        'code': code,
        'tags': tags,
        'stack': stack,
        'periode': periode,
        'lienProjet': lienProjet,
        'youtubeVideoId': youtubeVideoId,
        'location': location,
        'resultats': resultats,
        'poste': poste,
      };
}

class WorkExperience {
  final String id;
  final String entreprise;
  final String poste;
  final String periode;
  final LatLng location;

  WorkExperience({
    required this.id,
    required this.entreprise,
    required this.poste,
    required this.periode,
    required this.location,
  });

  factory WorkExperience.fromJson(Map<String, dynamic> json) {
    return WorkExperience(
      id: json['id'],
      entreprise: json['entreprise'],
      poste: json['poste'],
      periode: json['periode'],
      location: LatLng(
        json['location']['latitude'],
        json['location']['longitude'],
      ),
    );
  }
}
