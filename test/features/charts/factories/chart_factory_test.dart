import 'package:flutter_test/flutter_test.dart';
import 'package:portefolio/features/generator/data/extention_models.dart';

void main() {
  group('ChartDataFactory', () {
    test('createChartsFromResults with empty data', () {
      final charts = ChartDataFactory.createChartsFromResults({});
      expect(charts, isEmpty);
    });

    test('createChartsFromDevelopment with ROI data', () {
      final dev = {
        '6_roi_global': {'roi_3_ans': '150%'}
      };
      final charts = ChartDataFactory.createChartsFromResults(dev);
      expect(charts, isNotEmpty);
      expect(charts.first.type, ChartType.scatterChart);
    });
  });
}
