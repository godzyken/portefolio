class WakaTimeStats {
  final double totalSeconds;
  final List<WakaTimeProjectStat> projects;
  final List<WakaTimeLanguage> languages;
  final List<WakaTimeEditor> editors;
  final String range;

  WakaTimeStats({
    required this.totalSeconds,
    required this.projects,
    required this.languages,
    required this.editors,
    required this.range,
  });

  factory WakaTimeStats.fromJson(Map<String, dynamic> json) {
    return WakaTimeStats(
      totalSeconds: (json['total_seconds'] ?? 0.0).toDouble(),
      projects: (json['projects'] as List?)
              ?.map((p) => WakaTimeProjectStat.fromJson(p))
              .toList() ??
          [],
      languages: (json['languages'] as List?)
              ?.map((l) => WakaTimeLanguage.fromJson(l))
              .toList() ??
          [],
      editors: (json['editors'] as List?)
              ?.map((e) => WakaTimeEditor.fromJson(e))
              .toList() ??
          [],
      range: json['range'] ?? '',
    );
  }
}

class WakaTimeProjectStat {
  final String name;
  final double totalSeconds;
  final double percent;
  final String digital;
  final String text;

  WakaTimeProjectStat({
    required this.name,
    required this.totalSeconds,
    required this.percent,
    required this.digital,
    required this.text,
  });

  factory WakaTimeProjectStat.fromJson(Map<String, dynamic> json) {
    return WakaTimeProjectStat(
      name: json['name'] ?? '',
      totalSeconds: (json['total_seconds'] ?? 0.0).toDouble(),
      percent: (json['percent'] ?? 0).toDouble(),
      digital: json['digital'] ?? '0:00',
      text: json['text'] ?? '0 secs',
    );
  }
}

class WakaTimeBadge {
  final String id;
  final String url;
  final String title;
  final String leftText;
  final String link;

  WakaTimeBadge({
    required this.id,
    required this.url,
    required this.title,
    required this.leftText,
    required this.link,
  });

  factory WakaTimeBadge.fromJson(Map<String, dynamic> json) {
    return WakaTimeBadge(
      id: json['id'] ?? '',
      url: json['url'] ?? '',
      title: json['title'] ?? 'wakatime',
      leftText: json['left_text'] ?? 'wakatime',
      link: json['link'] ?? '',
    );
  }
}

class WakaTimeProject {
  final String id;
  final String name;
  final String? repository;
  final DateTime createdAt;
  final DateTime? lastHeartbeatAt;
  final WakaTimeBadge? badge;
  final bool hasPublicUrl;

  WakaTimeProject({
    required this.id,
    required this.name,
    this.repository,
    required this.createdAt,
    required this.lastHeartbeatAt,
    this.badge,
    required this.hasPublicUrl,
  });

  factory WakaTimeProject.fromJson(Map<String, dynamic> json) {
    return WakaTimeProject(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Project',
      repository: json['repository'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      lastHeartbeatAt: json['last_heartbeat_at'] != null
          ? DateTime.tryParse(json['last_heartbeat_at'])
          : null,
      badge:
          json['badge'] != null ? WakaTimeBadge.fromJson(json['badge']) : null,
      hasPublicUrl: json['has_public_url'] ?? false,
    );
  }
}

class WakaTimeLanguage {
  final String name;
  final double totalSeconds;
  final double percent;

  WakaTimeLanguage({
    required this.name,
    required this.totalSeconds,
    required this.percent,
  });

  factory WakaTimeLanguage.fromJson(Map<String, dynamic> json) {
    return WakaTimeLanguage(
      name: json['name'] ?? '',
      totalSeconds: (json['total_seconds'] ?? 0.0).toDouble(),
      percent: (json['percent'] ?? 0).toDouble(),
    );
  }
}

class WakaTimeEditor {
  final String name;
  final double totalSeconds;
  final double percent;

  WakaTimeEditor({
    required this.name,
    required this.totalSeconds,
    required this.percent,
  });

  factory WakaTimeEditor.fromJson(Map<String, dynamic> json) {
    return WakaTimeEditor(
      name: json['name'] ?? '',
      totalSeconds: (json['total_seconds'] ?? 0.0).toDouble(),
      percent: (json['percent'] ?? 0).toDouble(),
    );
  }
}

class WakaTimeProjectDuration {
  final String name;
  final double totalSeconds;

  WakaTimeProjectDuration({required this.name, required this.totalSeconds});

  double get totalHours => totalSeconds / 3600;
}
