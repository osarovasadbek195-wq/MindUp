import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // Google AI API kaliti - .env fayldan olinadi
  static String get googleAIApiKey => dotenv.env['GOOGLE_AI_API_KEY'] ?? 'YOUR_GOOGLE_AI_API_KEY_HERE';
  
  // Sozlamalar
  static const String defaultModel = 'gemini-2.0-flash';
  static const double defaultTemperature = 0.7;
  static const int maxTokens = 1000;
}
