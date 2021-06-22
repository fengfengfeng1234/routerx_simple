
import 'dart:async';

import 'package:flutter/services.dart';

class IntegratedRouting {
  static const MethodChannel _channel =
      const MethodChannel('integrated_routing');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
