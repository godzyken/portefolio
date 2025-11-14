import 'package:equatable/equatable.dart';

class Comparatif extends Equatable {
  final String id;
  final String title;
  final String description;

  final List<ComparatifCategory> categories;

  final ComparatifGraphs graphs;

  final ComparatifRecommendation recommendation;

  const Comparatif({
    required this.id,
    required this.title,
    required this.description,
    required this.categories,
    required this.graphs,
    required this.recommendation,
  });

  factory Comparatif.fromJson(Map<String, dynamic> json) {
    return Comparatif(
      id: json["id"],
      title: json["title"],
      description: json["description"],
      categories: (json["categories"] as List)
          .map((e) => ComparatifCategory.fromJson(e))
          .toList(),
      graphs: ComparatifGraphs.fromJson(json["graphs"]),
      recommendation: ComparatifRecommendation.fromJson(json["recommendation"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "categories": categories.map((e) => e.toJson()).toList(),
        "graphs": graphs.toJson(),
        "recommendation": recommendation.toJson(),
      };

  @override
  List<Object?> get props =>
      [id, title, description, categories, graphs, recommendation];
}

class ComparatifCategory extends Equatable {
  final String name;
  final String flutter;
  final String reactNative;
  final int scoreFlutter;
  final int scoreReactNative;

  const ComparatifCategory({
    required this.name,
    required this.flutter,
    required this.reactNative,
    required this.scoreFlutter,
    required this.scoreReactNative,
  });

  factory ComparatifCategory.fromJson(Map<String, dynamic> json) {
    return ComparatifCategory(
      name: json["name"],
      flutter: json["flutter"],
      reactNative: json["react_native"],
      scoreFlutter: json["score_flutter"],
      scoreReactNative: json["score_react_native"],
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "flutter": flutter,
        "react_native": reactNative,
        "score_flutter": scoreFlutter,
        "score_react_native": scoreReactNative,
      };

  @override
  List<Object?> get props => [
        name,
        flutter,
        reactNative,
        scoreFlutter,
        scoreReactNative,
      ];
}

class ComparatifGraphs extends Equatable {
  final BarChartDataModel barChart;
  final RadarChartDataModel radarChart;

  const ComparatifGraphs({
    required this.barChart,
    required this.radarChart,
  });

  factory ComparatifGraphs.fromJson(Map<String, dynamic> json) {
    return ComparatifGraphs(
      barChart: BarChartDataModel.fromJson(json["bar_chart"]),
      radarChart: RadarChartDataModel.fromJson(json["radar_chart"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "bar_chart": barChart.toJson(),
        "radar_chart": radarChart.toJson(),
      };

  @override
  List<Object?> get props => [barChart, radarChart];
}

class BarChartDataModel extends Equatable {
  final String title;
  final List<String> axes;
  final List<BarChartEntry> data;

  const BarChartDataModel({
    required this.title,
    required this.axes,
    required this.data,
  });

  factory BarChartDataModel.fromJson(Map<String, dynamic> json) {
    return BarChartDataModel(
      title: json["title"],
      axes: List<String>.from(json["axes"]),
      data:
          (json["data"] as List).map((e) => BarChartEntry.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        "title": title,
        "axes": axes,
        "data": data.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [title, axes, data];
}

class BarChartEntry extends Equatable {
  final String category;
  final int flutter;
  final int reactNative;

  const BarChartEntry({
    required this.category,
    required this.flutter,
    required this.reactNative,
  });

  factory BarChartEntry.fromJson(Map<String, dynamic> json) {
    return BarChartEntry(
      category: json["category"],
      flutter: json["flutter"],
      reactNative: json["react_native"],
    );
  }

  Map<String, dynamic> toJson() => {
        "category": category,
        "flutter": flutter,
        "react_native": reactNative,
      };

  @override
  List<Object?> get props => [category, flutter, reactNative];
}

class RadarChartDataModel extends Equatable {
  final String title;
  final List<String> labels;
  final List<int> flutter;
  final List<int> reactNative;

  const RadarChartDataModel({
    required this.title,
    required this.labels,
    required this.flutter,
    required this.reactNative,
  });

  factory RadarChartDataModel.fromJson(Map<String, dynamic> json) {
    return RadarChartDataModel(
      title: json["title"],
      labels: List<String>.from(json["labels"]),
      flutter: List<int>.from(json["flutter"]),
      reactNative: List<int>.from(json["react_native"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "title": title,
        "labels": labels,
        "flutter": flutter,
        "react_native": reactNative,
      };

  @override
  List<Object?> get props => [title, labels, flutter, reactNative];
}

class ComparatifRecommendation extends Equatable {
  final String summary;
  final List<String> details;

  const ComparatifRecommendation({
    required this.summary,
    required this.details,
  });

  factory ComparatifRecommendation.fromJson(Map<String, dynamic> json) {
    return ComparatifRecommendation(
      summary: json["summary"],
      details: List<String>.from(json["details"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "summary": summary,
        "details": details,
      };

  @override
  List<Object?> get props => [summary, details];
}
