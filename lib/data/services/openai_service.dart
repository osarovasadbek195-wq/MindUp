import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/task.dart';

class OpenAIService {
  final String apiKey;

  OpenAIService({required this.apiKey});

  Future<List<Task>> generateTasks(String prompt, String subject) async {
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
        Uri.parse(ApiConstants.openAiBaseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": ApiConstants.defaultModel,
          "messages": [
            {"role": "system", "content": systemPrompt},
            {"role": "user", "content": prompt}
          ],
          "temperature": 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['choices'][0]['message']['content'];
        
        // JSON ni tozalash (ba'zan ```json ... ``` ichida keladi)
        String cleanJson = content.replaceAll('```json', '').replaceAll('```', '').trim();
        
        final List<dynamic> jsonList = jsonDecode(cleanJson);
        
        return jsonList.map((item) {
          final task = Task()
            ..title = item['title']
            ..description = item['description']
            ..subject = subject
            ..createdAt = DateTime.now()
            ..nextReviewDate = DateTime.now()
            ..stage = TaskStage.learning;
          return task;
        }).toList();
      } else {
        throw Exception('OpenAI Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error communicating with OpenAI: $e');
    }
  }
}
