// Données de benchmark
class BenchmarkInfo {
  final String projectTitle;
  final int scoreGlobal;
  final int performances;
  final int performancesMax;
  final int seo;
  final int seoMax;
  final int mobile;
  final int mobileMax;
  final int securite;
  final int securiteMax;

  const BenchmarkInfo({
    required this.projectTitle,
    required this.scoreGlobal,
    required this.performances,
    this.performancesMax = 30,
    required this.seo,
    this.seoMax = 30,
    required this.mobile,
    this.mobileMax = 30,
    required this.securite,
    this.securiteMax = 10,
  });

  int get total => performances + seo + mobile + securite;
  int get maxTotal => performancesMax + seoMax + mobileMax + securiteMax;

  factory BenchmarkInfo.fromJson(Map<String, dynamic> json) {
    // Parse "79/100" ou juste "79"
    int parseScore(dynamic value) {
      if (value is int) return value;
      if (value is String) {
        return int.tryParse(value.split('/').first) ?? 0;
      }
      return 0;
    }

    return BenchmarkInfo(
      projectTitle: json['projectTitle'] ?? '',
      scoreGlobal: parseScore(json['score']),
      performances: parseScore(json['performances']),
      performancesMax: json['performancesMax'] ?? 30,
      seo: parseScore(json['seo']),
      seoMax: json['seoMax'] ?? 30,
      mobile: parseScore(json['mobile']),
      mobileMax: json['mobileMax'] ?? 30,
      securite: parseScore(json['sécurité'] ?? json['securite']),
      securiteMax: json['securiteMax'] ?? 10,
    );
  }
}
