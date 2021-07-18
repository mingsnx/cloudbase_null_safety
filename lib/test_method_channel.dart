import 'package:flutter/services.dart';

class TestMethodChannel {
  static const MethodChannel _channel =
      const MethodChannel('cloudbase_null_safety');

  static Future<String?> get platformTest async {
    final String? version = await _channel.invokeMethod('getTest');
    return version;
  }
}
