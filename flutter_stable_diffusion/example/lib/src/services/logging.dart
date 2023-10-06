import 'package:flutter/foundation.dart';

class Logging {
  void log(String message) {
    if (kDebugMode) {
      print(message);
    }
  }
}
