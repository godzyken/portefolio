import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/home/notifier/splash_notifier.dart';

import '../controller/splash_state.dart';

final splashProvider =
    NotifierProvider<SplashNotifier, SplashState>(SplashNotifier.new);
