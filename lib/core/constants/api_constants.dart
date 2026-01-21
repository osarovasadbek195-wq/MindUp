class ApiConstants {
  // OpenAI API kaliti - environment variable dan oling
  static const String openAIApiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: 'YOUR_OPENAI_API_KEY_HERE',
  );
  
  // API URL'lari
  static const String openAiBaseUrl = 'https://api.openai.com/v1/chat/completions';
  
  // Sozlamalar
  static const String defaultModel = 'gpt-3.5-turbo';
  static const double defaultTemperature = 0.7;
  static const int maxTokens = 1000;
}
