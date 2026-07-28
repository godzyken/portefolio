import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/tracking_service.dart';

final trackingServiceProvider = Provider<TrackingService>((ref) {
  return TrackingService();
});
