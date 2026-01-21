class IntentParser {
  /// Ovozli buyruqni tahlil qilib, uning turini va ma'lumotlarini qaytaradi
  static VoiceIntent parse(String text) {
    final lowerText = text.toLowerCase();
    
    // 1. Qo'shish buyruqlari
    // "Inventory so'zini qo'sh", "Learn Math", "Add English words"
    if (lowerText.contains('qo\'sh') || lowerText.contains('add') || lowerText.contains('learn')) {
      String topic = text;
      // Regexda " belgisi ishlatildi, shunda ' belgisi xato bermaydi
      topic = topic.replaceAll(RegExp(r"(qo'sh|add|learn|about|haqida)", caseSensitive: false), '').trim();
      return VoiceIntent(type: IntentType.add, data: topic);
    }
    
    // 2. Statistika
    if (lowerText.contains('statistika') || lowerText.contains('stats') || lowerText.contains('progress')) {
      return VoiceIntent(type: IntentType.stats);
    }
    
    // 3. O'rganishni boshlash
    if (lowerText.contains('boshlash') || lowerText.contains('start') || lowerText.contains('review')) {
      return VoiceIntent(type: IntentType.study);
    }

    // 4. Qidiruv
    if (lowerText.contains('qidir') || lowerText.contains('search') || lowerText.contains('find')) {
      String query = text;
      query = query.replaceAll(RegExp(r"(qidir|search|find)", caseSensitive: false), '').trim();
      return VoiceIntent(type: IntentType.search, data: query);
    }

    return VoiceIntent(type: IntentType.unknown, data: text);
  }
}

enum IntentType {
  add,
  stats,
  study,
  search,
  unknown
}

class VoiceIntent {
  final IntentType type;
  final String? data;

  VoiceIntent({required this.type, this.data});
}