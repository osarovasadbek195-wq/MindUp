import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // OpenAI API kaliti - .env fayldan olinadi
  static String get openAIApiKey => dotenv.env['OPENAI_API_KEY'] ?? 'YOUR_OPENAI_API_KEY_HERE';
  
  // API URL'lari
  static const String openAiBaseUrl = 'https://api.openai.com/v1/chat/completions';
  
  // Sozlamalar
  static const String defaultModel = 'gpt-4o-mini';
  static const double defaultTemperature = 0.7;
  static const int maxTokens = 1000;
}
