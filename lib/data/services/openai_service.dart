import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/task.dart';

class OpenAIService {
  final String apiKey;

  OpenAIService({required this.apiKey});

  Future<List<Task>> generateTasks(String prompt, String subject) async {
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
        final content = data['choices'][0]['message']['content'].trim();
        
        try {
          final List<dynamic> jsonList = jsonDecode(content);
          
          return jsonList.map((item) {
            final task = Task()
              ..title = item['front'] ?? item['title'] ?? 'No question'
              ..description = item['back'] ?? item['description'] ?? 'No answer'
              ..subject = subject
              ..createdAt = DateTime.now()
              ..nextReviewDate = DateTime.now()
              ..stage = TaskStage.learning;
            return task;
          }).toList();
        } catch (e) {
          throw Exception('Failed to parse JSON response from OpenAI: $e. Content was: $content');
        }
      } else {
        throw Exception('OpenAI Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error communicating with OpenAI: $e');
    }
  }
}
