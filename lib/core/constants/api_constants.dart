class ApiConstants {
  // OpenAI API kaliti - ishlatishdan oldin o'zingizning kalitingizni yozing
  static const String openAIApiKey = "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";
  
  // Google Gemini API kaliti - kerak bo'lganda o'zgartiring
  static const String geminiApiKey = "YOUR_GEMINI_API_KEY";
  
  // API URL'lari
  static const String openAiBaseUrl = 'https://api.openai.com/v1/chat/completions';
  static const String geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  
  // Sozlamalar
  static const String defaultModel = 'gpt-4-mini';
  static const double defaultTemperature = 0.7;
  static const int maxTokens = 1000;
}
