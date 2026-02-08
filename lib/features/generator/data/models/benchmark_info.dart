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

  factory BenchmarkInfo.fromJson(Map<String, dynamic> json) {
    final scoreStr = json['score']?.toString() ?? '0/100';
    final scoreParts = scoreStr.split('/');
    final score = int.tryParse(scoreParts[0]) ?? 0;

    return BenchmarkInfo(
      projectTitle: json['projectTitle']?.toString() ?? 'Projet',
      scoreGlobal: score,
      performances: _parseInt(json['performances']),
      performancesMax: _parseInt(json['performancesMax'], defaultValue: 30),
      seo: _parseInt(json['seo']),
      seoMax: _parseInt(json['seoMax'], defaultValue: 30),
      mobile: _parseInt(json['mobile']),
      mobileMax: _parseInt(json['mobileMax'], defaultValue: 30),
      securite: _parseInt(json['sécurité'] ?? json['securite']),
      securiteMax: _parseInt(json['securiteMax'], defaultValue: 10),
    );
  }

  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value.split('/').first);
      return parsed ?? defaultValue;
    }
    return defaultValue;
  }
}
