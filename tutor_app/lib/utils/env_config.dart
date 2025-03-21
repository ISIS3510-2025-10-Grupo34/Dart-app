import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;

class EnvConfig {
  static Future<void> load() async {
    await dotenv.dotenv.load(fileName: ".env");
  }

  static String get apiUrl {
    return dotenv.dotenv.env['API_URL'] ?? 'http://localhost:8000';
  }
}
