import 'dart:io';

class AppConfig {
  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) {
      return fromEnv;
    }

    // Android emulator cannot access host machine via localhost.
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8090';
    }

    return 'http://localhost:8090';
  }
}
