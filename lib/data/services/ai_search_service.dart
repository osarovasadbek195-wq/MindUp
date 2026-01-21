import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class AISearchResult {
  final String title;
  final String content;
  final String source;
  final String url;

  AISearchResult({
    required this.title,
    required this.content,
    required this.source,
    required this.url,
  });

  factory AISearchResult.fromJson(Map<String, dynamic> json) {
    return AISearchResult(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      source: json['source'] ?? 'AI',
      url: json['url'] ?? '',
    );
  }
}

class AISearchService {
  final String apiKey;

  AISearchService({required this.apiKey});

  Future<List<AISearchResult>> search(String query) async {
    final systemPrompt = '''
      Siz aqlli qidiruv tizimisiz. Foydalanuvchining so'roviga asoslanib, 
      tegishli va foydali ma'lumotlarni taqdim eting.
      
      Quyidagi formatda javob bering:
      [
        {
          "title": "Maqola sarlavhasi",
          "content": "Qisqa mazmuni (200 ta belgidan kam)",
          "source": "Manba nomi",
          "url": "Havola (agar bo'lsa)"
        }
      ]
      
      Har doim 3-5 ta natija qaytaring. Javobni faqat JSON formatida bering.
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
            {"role": "user", "content": "Qidiruv so'rovi: $query"}
          ],
          "temperature": 0.5,
          "max_tokens": ApiConstants.maxTokens,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['choices'][0]['message']['content'];
        
        String cleanJson = content
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
        
        final List<dynamic> jsonList = jsonDecode(cleanJson);
        
        return jsonList.map((item) => AISearchResult.fromJson(item)).toList();
      } else {
        throw Exception('API xatosi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Qidiruvda xatolik: $e');
    }
  }

  Future<String> getDetailedAnswer(String query) async {
    final systemPrompt = '''
      Siz o'qituvchi yordamchisiz. Berilgan savolga batafsil va tushunarli javob bering.
      Javobingiz strukturasi:
      1. Asosiy javob (qisqacha)
      2. Tafsilotlar
      3. Misollar (agar kerak bo'lsa)
      4. Xulosa
      
      Javobni o'zbek tilida bering.
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
            {"role": "user", "content": query}
          ],
          "temperature": 0.7,
          "max_tokens": 1500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('API xatosi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Javob olishda xatolik: $e');
    }
  }
}
