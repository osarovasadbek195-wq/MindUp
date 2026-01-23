import 'package:shared_preferences/shared_preferences.dart';

class TranslationService {
  static const String _languageKey = 'language';
  static const String _defaultLanguage = 'English';
  
  static const List<String> supportedLanguages = ['English', 'Русский', 'Uzbek'];
  
  static Future<String> getCurrentLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? _defaultLanguage;
  }
  
  static Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }
  
  static String translate(String key, {
    required String english,
    required String russian,
    required String uzbek,
  }) {
    // For now, return English. In a real app, you'd load the current language
    // and return the appropriate translation
    return english;
  }
  
  // Common translations
  static Map<String, Map<String, String>> get translations => {
    'home': {
      'English': 'Home',
      'Русский': 'Главная',
      'Uzbek': 'Bosh sahifa',
    },
    'calendar': {
      'English': 'Calendar',
      'Русский': 'Календарь',
      'Uzbek': 'Kalendar',
    },
    'hub': {
      'English': 'Hub',
      'Русский': 'Центр',
      'Uzbek': 'Markaz',
    },
    'ai': {
      'English': 'AI',
      'Русский': 'ИИ',
      'Uzbek': 'AI',
    },
    'profile': {
      'English': 'Profile',
      'Русский': 'Профиль',
      'Uzbek': 'Profil',
    },
    'add_task': {
      'English': 'Add Task',
      'Русский': 'Добавить задачу',
      'Uzbek': 'Vazifa qo\'shish',
    },
    'quiz': {
      'English': 'Quiz',
      'Русский': 'Викторина',
      'Uzbek': 'Viktorina',
    },
    'settings': {
      'English': 'Settings',
      'Русский': 'Настройки',
      'Uzbek': 'Sozlamalar',
    },
    'today_tasks': {
      'English': "Today's Tasks",
      'Русский': 'Задачи на сегодня',
      'Uzbek': 'Bugungi vazifalar',
    },
    'no_tasks': {
      'English': 'No tasks for today!',
      'Русский': 'Нет задач на сегодня!',
      'Uzbek': 'Bugun vazifalar yo\'q!',
    },
    'tap_add': {
      'English': "Tap + to add a new task.",
      'Русский': "Нажмите + чтобы добавить задачу.",
      'Uzbek': "Yangi vazifa qo'shish uchun + tugmasini bosing.",
    },
  };
}
