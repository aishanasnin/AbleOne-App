import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const String appName = 'AbleOne';
  static const String environment = 'development';
  static const String apiBaseUrl = 'https://api.ableone.example.com';

  /// Reads the Gemini API Key dynamically from the loaded environment variables.
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
}
