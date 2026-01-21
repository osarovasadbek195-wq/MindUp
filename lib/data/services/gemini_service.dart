import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';
import '../../core/constants/api_constants.dart';

class GeminiService {
  final String apiKey;

  GeminiService({required this.apiKey});

  Future<List<Task>> generateTasks(String prompt, String subject) async {
    final url = Uri.parse('${ApiConstants.geminiBaseUrl}?key=$apiKey');
    
    // Biz AI ga aniq struktura (JSON) so'raymiz
    final systemPrompt = '''
      You are a helpful study assistant. The user wants to learn about "$subject".
      Based on the user's request: "$prompt", generate a list of 5-10 active recall questions.
      
      Focus on "Active Recall". The title should be a challenging question, and the description should be the answer.
      
      Return ONLY a JSON array. No markdown, no extra text.
      Format:
      [
        {
          "title": "Question (e.g., What is the formula for...?)",
          "description": "Answer (e.g., F=ma)"
        }
      ]
    ''';

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": systemPrompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        
        // JSON ni tozalash (ba'zan ```json ... ``` ichida keladi)
        String cleanJson = text.replaceAll('```json', '').replaceAll('```', '').trim();
        
        final List<dynamic> jsonList = jsonDecode(cleanJson);
        
        return jsonList.map((item) {
          final task = Task()
            ..title = item['title']
            ..description = item['description']
            ..subject = subject
            ..createdAt = DateTime.now()
            ..nextReviewDate = DateTime.now() // Darhol o'rganish uchun
            ..stage = TaskStage.learning;
          return task;
        }).toList();
      } else {
        throw Exception('Failed to generate content: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error communicating with AI: $e');
    }
  }
}
