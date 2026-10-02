import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

class AppLogger {
  static const String _tag = 'ATHEER';

  static void d(String message) {
    if (!kDebugMode) return;
    developer.log(message, name: _tag, level: 500);
  }

  static void i(String message) {
    developer.log(message, name: _tag, level: 800);
  }

  static void w(String message) {
    developer.log(message, name: _tag, level: 900);
  }

  static void e(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: _tag,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
