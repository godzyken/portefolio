import 'package:flutter/services.dart';

class NativeConfig {
  static const _channel = MethodChannel('com.your.app/config');

  static Future<String> getSendGridKey() async {
    return await _channel.invokeMethod('SENDGRID_KEY');
  }

  static Future<String> getSrcMail() async {
    return await _channel.invokeMethod('SRC_MAIL');
  }

  static Future<String> getDestMail() async {
    return await _channel.invokeMethod('DEST_MAIL');
  }
}
