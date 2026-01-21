class ApiConstants {
  // OpenAI API kaliti - ishlatishdan oldin o'zingizning kalitingizni yozing
  static const String openAIApiKey = "YOUR_OPENAI_API_KEY";
  
  // Google Gemini API kaliti - kerak bo'lganda o'zgartiring
  static const String geminiApiKey = "YOUR_GEMINI_API_KEY";
  
  // API URL'lari
  static const String openAiBaseUrl = 'https://api.openai.com/v1/chat/completions';
  static const String geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  
  // Sozlamalar
  static const String defaultModel = 'gpt-3.5-turbo';
  static const double defaultTemperature = 0.7;
  static const int maxTokens = 1000;
}
