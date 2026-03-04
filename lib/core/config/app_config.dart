import 'package:flutter/foundation.dart';

class AppConfig {
  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) {
      return fromEnv;
    }

    // Web build served by nginx should use same-origin proxied backend.
    if (kIsWeb) {
      return Uri.base.origin;
    }

    final platform = defaultTargetPlatform;
    // Android emulator cannot access host machine via localhost.
    if (platform == TargetPlatform.android) {
      return 'http://10.0.2.2:8090';
    }

    return 'http://localhost:8090';
  }
}
