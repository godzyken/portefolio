import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifier/iot_view_notifier.dart';

final iotViewModeProvider =
    NotifierProvider<IoTViewModeNotifier, bool>(IoTViewModeNotifier.new);

final iotSectionExpandedProvider =
    NotifierProvider<IoTSectionExpandedNotifier, Map<String, bool>>(
        IoTSectionExpandedNotifier.new);

final iotSensorFilterProvider =
    NotifierProvider<IoTSensorFilterNotifier, Set<String>>(
        IoTSensorFilterNotifier.new);

final iotDashboardThemeProvider =
    NotifierProvider<IoTDashboardThemeNotifier, bool>(
        IoTDashboardThemeNotifier.new);
