import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifier/iot_view_notifier.dart';

final iotViewModeProvider = NotifierProvider<IoTViewModeNotifier, bool>(
    IoTViewModeNotifier.new,
    name: 'IoTViewMode');

final iotSectionExpandedProvider =
    NotifierProvider<IoTSectionExpandedNotifier, Map<String, bool>>(
        IoTSectionExpandedNotifier.new,
        name: 'IoTSectionExpanded');

final iotSensorFilterProvider =
    NotifierProvider<IoTSensorFilterNotifier, Set<String>>(
        IoTSensorFilterNotifier.new,
        name: 'IoTSensorFilter');

final iotDashboardThemeProvider =
    NotifierProvider<IoTDashboardThemeNotifier, bool>(
        IoTDashboardThemeNotifier.new,
        name: 'IoTDashboardTheme');
