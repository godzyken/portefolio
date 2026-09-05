import 'package:flutter_test/flutter_test.dart';
import 'package:portefolio/features/generator/data/extention_models.dart';

void main() {
  group('ChartDataFactory', () {
    test('createChartsFromResults with empty data', () {
      final charts = ChartDataFactory.createChartsFromResults({});
      expect(charts, isEmpty);
    });

    test('createChartsFromResults with scalar ROI data', () {
      final results = {'roi': '150%'};
      final charts = ChartDataFactory.createChartsFromResults(results);
      expect(charts, isNotEmpty);
      expect(charts.first.type, ChartType.kpiCards);
      expect(charts.first.kpiValues!['ROI'], '150%');
    });
  });
}
