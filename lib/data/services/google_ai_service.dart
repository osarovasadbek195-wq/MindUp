import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/task.dart';

class GoogleAIService {
  late final GenerativeModel _model;
  ChatSession? _chat;
  
  GoogleAIService({required String apiKey}) {
    _model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);
    _chat = _model.startChat();
  }
  
  /// Suhbat davomida javob olish
  Future<String> sendMessage(String message) async {
    try {
      _chat ??= _model.startChat();
      final response = await _chat!.sendMessage(Content.text(message));
      return response.text ?? 'No response';
    } catch (e) {
      throw Exception('Google AI Error: $e');
    }
  }
  
  /// Flashcard yaratish
  Future<List<Task>> generateFlashcards(String prompt, String subject) async {
    final systemPrompt = '''
You are a flashcard generation assistant. Based on the user's input about "$subject", generate 5-10 flashcard pairs.

CRITICAL: Return ONLY a raw JSON array. No markdown formatting, no explanations, no ```json``` wrapper.

Format exactly:
[{"front": "question", "back": "answer"}, {"front": "question2", "back": "answer2"}]

Rules:
- "front" must be a clear question
- "back" must be the concise answer
- Ensure valid JSON syntax
- No trailing commas
- No additional text

User input: "$prompt"
''';

    try {
      final response = await _model.generateContent([
        Content.text(systemPrompt),
        Content.text(prompt),
      ]);
      
      final content = response.text?.trim() ?? '';
      
      try {
        final List<dynamic> jsonList = jsonDecode(content);
        
        return jsonList.map((item) {
          final task = Task()
            ..title = item['front'] ?? item['title'] ?? 'No question'
            ..description = item['back'] ?? item['description'] ?? 'No answer'
            ..subject = subject
            ..createdAt = DateTime.now()
            ..lastReviewedAt = DateTime.now();
          task.repetitionStep = 0;
          task.stage = TaskStage.learning;
          task.mistakeCount = 0;
          task.reviewCount = 0;
          return task;
        }).toList();
      } catch (e) {
        throw Exception('Failed to parse JSON response: $e. Content was: $content');
      }
    } catch (e) {
      throw Exception('Error generating flashcards: $e');
    }
  }
  
  /// Yangi suhbat boshlash
  void newChat() {
    _chat = _model.startChat();
  }
  
  /// Suhbat tarixini tozalash
  Future<void> clearHistory() async {
    _chat = _model.startChat();
  }
}
