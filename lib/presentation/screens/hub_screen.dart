import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/isar_service.dart';
import '../widgets/custom_webview.dart';
import 'mindup_ai_screen.dart';
import 'quiz_screen.dart';
import 'games/memory_match_game.dart';
import 'games/speed_recall_game.dart';
import 'games/context_builder_game.dart';
import 'games/true_false_blitz_game.dart';
import 'games/sequence_master_game.dart';
import 'games/association_chain_game.dart';
import 'games/pattern_recall_game.dart';
import 'games/category_sort_game.dart';
import 'games/reverse_recall_game.dart';
import 'games/spelling_master_game.dart';

class HubScreen extends StatefulWidget {
  const HubScreen({super.key});

  @override
  State<HubScreen> createState() => _HubScreenState();
}

class _HubScreenState extends State<HubScreen> {
  String _selectedLanguage = 'English';
  List<Map<String, dynamic>> _userWords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _loadUserWords();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? 'English';
    });
  }

  Future<void> _changeLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
    setState(() {
      _selectedLanguage = language;
    });
  }

  Future<void> _loadUserWords() async {
    final isarService = context.read<IsarService>();
    final allTasks = await isarService.getAllTasks();
    
    // Group by subject
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final task in allTasks) {
      if (!grouped.containsKey(task.subject)) {
        grouped[task.subject] = [];
      }
      grouped[task.subject]!.add({
        'title': task.title,
        'description': task.description,
        'subject': task.subject,
      });
    }
    
    setState(() {
      _userWords = grouped.entries.map((entry) => {
        'subject': entry.key,
        'count': entry.value.length,
        'words': entry.value,
      }).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: Text(
          _getTranslation('Study Hub', 'Учебный центр', 'O\'quv markazi'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: _changeLanguage,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'English', child: Text('🇺🇸 English')),
              const PopupMenuItem(value: 'Русский', child: Text('🇷🇺 Русский')),
              const PopupMenuItem(value: 'Uzbek', child: Text('🇺🇿 O\'zbek')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IELTS Section
            _buildSection(
              title: '📘 IELTS',
              color: const Color(0xFF4F46E5),
              items: [
                {
                  'icon': 'headphones',
                  'title': _getTranslation('Listening', 'Аудирование', 'Tinglash'),
                  'subtitle': _getTranslation('Practice tests', 'Практические тесты', 'Amaliy testlar'),
                  'url': 'https://ieltsonlinetests.com',
                },
                {
                  'icon': 'menu_book',
                  'title': _getTranslation('Reading', 'Чтение', 'O\'qish'),
                  'subtitle': _getTranslation('Academic reading', 'Академическое чтение', 'Akademik o\'qish'),
                  'url': 'https://ielts-exam.net',
                },
                {
                  'icon': 'edit',
                  'title': _getTranslation('Writing', 'Письмо', 'Yozish'),
                  'subtitle': _getTranslation('Task 1 & 2', 'Задание 1 и 2', '1 va 2-topshiriq'),
                  'url': 'https://www.ielts-mentor.com',
                },
                {
                  'icon': 'record_voice_over',
                  'title': _getTranslation('Speaking', 'Говорение', 'Gapirish'),
                  'subtitle': _getTranslation('Speaking topics', 'Темы для говорения', 'Gapirish mavzulari'),
                  'url': 'https://ieltsliz.com',
                },
                {
                  'icon': 'school',
                  'title': _getTranslation('Strategies', 'Стратегии', 'Strategiyalar'),
                  'subtitle': _getTranslation('Tips & tricks', 'Советы', 'Maslahatlar'),
                  'url': 'https://www.ieltsadvantage.com',
                },
                {
                  'icon': 'hearing',
                  'title': _getTranslation('Audio Lab', 'Аудио лаб', 'Audio lab'),
                  'subtitle': _getTranslation('Listening practice', 'Практика слушания', 'Tinglash amaliyoti'),
                  'url': 'https://www.esl-lab.com',
                },
              ],
            ),
            const SizedBox(height: 20),
            
            // SAT Section
            _buildSection(
              title: '📝 SAT',
              color: const Color(0xFFDC2626),
              items: [
                {
                  'icon': 'calculate',
                  'title': _getTranslation('Math', 'Математика', 'Matematika'),
                  'subtitle': _getTranslation('Khan Academy', 'Хан Академия', 'Khan Academy'),
                  'url': 'https://www.khanacademy.org/sat',
                },
                {
                  'icon': 'description',
                  'title': _getTranslation('Practice', 'Практика', 'Amaliyot'),
                  'subtitle': _getTranslation('Practice tests', 'Пробные тесты', 'Amaliy testlar'),
                  'url': 'https://www.cracksat.net',
                },
                {
                  'icon': 'school',
                  'title': _getTranslation('Official', 'Официальный', 'Rasmiy'),
                  'subtitle': _getTranslation('College Board', 'College Board', 'College Board'),
                  'url': 'https://sat.collegeboard.org',
                },
                {
                  'icon': 'create',
                  'title': _getTranslation('Vocabulary', 'Словарь', 'Lug\'at'),
                  'subtitle': _getTranslation('SAT words', 'SAT слова', 'SAT so\'zlari'),
                  'url': 'https://www.vocabulary.com/lists/52473',
                },
                {
                  'icon': 'quiz',
                  'title': _getTranslation('Kaplan', 'Каплан', 'Kaplan'),
                  'subtitle': _getTranslation('Free prep', 'Бесплатная подготовка', 'Bepul tayyorgarlik'),
                  'url': 'https://www.kaptest.com/sat',
                },
                {
                  'icon': 'stars',
                  'title': _getTranslation('Princeton', 'Принстон', 'Princeton'),
                  'subtitle': _getTranslation('Review', 'Обзор', 'Sharh'),
                  'url': 'https://www.princetonreview.com/college/sat-test-prep',
                },
              ],
            ),
            const SizedBox(height: 20),
            
            // Video & Pronunciation Section
            _buildSection(
              title: '🎥 Video & Pronunciation',
              color: const Color(0xFFF59E0B),
              items: [
                {
                  'icon': 'play_circle',
                  'title': _getTranslation('YouGlish', 'YouGlish', 'YouGlish'),
                  'subtitle': _getTranslation('Pronunciation videos', 'Видео произношения', 'Talaffuz videolari'),
                  'url': 'https://youglish.com',
                },
                {
                  'icon': 'library_books',
                  'title': _getTranslation('Dictionary', 'Словарь', 'Lug\'at'),
                  'subtitle': _getTranslation('Cambridge', 'Кембридж', 'Cambridge'),
                  'url': 'https://dictionary.cambridge.org',
                },
              ],
            ),
            const SizedBox(height: 20),

            // MindUp Games Section
            _buildSection(
              title: '🎮 Brain Games',
              color: const Color(0xFF10B981),
              items: [
                {
                  'icon': 'quiz',
                  'title': _getTranslation('Smart Quiz', 'Умный тест', 'Aqlli test'),
                  'subtitle': _getTranslation('Up to 500 cards', 'До 500 карточек', '500 tagacha karta'),
                  'url': 'game:quiz',
                },
                {
                  'icon': 'extension',
                  'title': _getTranslation('Memory Match', 'Найди пару', 'Juftini top'),
                  'subtitle': _getTranslation('Visual memory', 'Визуальная память', 'Vizual xotira'),
                  'url': 'game:match',
                },
                {
                  'icon': 'timer',
                  'title': _getTranslation('Speed Recall', 'Скорость', 'Tezkor eslash'),
                  'subtitle': _getTranslation('Quick thinking', 'Быстрое мышление', 'Tezkor fikrlash'),
                  'url': 'game:speed',
                },
                {
                  'icon': 'psychology',
                  'title': _getTranslation('Context Build', 'Контекст', 'Kontekst qurish'),
                  'subtitle': _getTranslation('Sentence structure', 'Структура предложений', 'Gap tuzilishi'),
                  'url': 'game:context',
                },
                {
                  'icon': 'bolt',
                  'title': _getTranslation('Blitz Mode', 'Блиц режим', 'Blits rejim'),
                  'subtitle': _getTranslation('True or False', 'Правда или Ложь', 'To\'g\'ri yoki Noto\'g\'ri'),
                  'url': 'game:blitz',
                },
                {
                  'icon': 'format_list_numbered',
                  'title': _getTranslation('Sequence', 'Последовательность', 'Ketma-ketlik'),
                  'subtitle': _getTranslation('Order memory', 'Память на порядок', 'Tartib xotirasi'),
                  'url': 'game:sequence',
                },
                {
                  'icon': 'link',
                  'title': _getTranslation('Chain', 'Цепочка', 'Zanjir'),
                  'subtitle': _getTranslation('Associations', 'Ассоциации', 'Assotsiatsiyalar'),
                  'url': 'game:chain',
                },
                {
                  'icon': 'grid_view',
                  'title': _getTranslation('Pattern', 'Узор', 'Shakl'),
                  'subtitle': _getTranslation('Visual pattern', 'Визуальный узор', 'Vizual shakl'),
                  'url': 'game:pattern',
                },
                {
                  'icon': 'category',
                  'title': _getTranslation('Category', 'Категория', 'Turkum'),
                  'subtitle': _getTranslation('Sort by subject', 'Сортировка', 'Turkumlash'),
                  'url': 'game:category',
                },
                {
                  'icon': 'history',
                  'title': _getTranslation('Reverse', 'Обратный', 'Teskari'),
                  'subtitle': _getTranslation('Recall prompt', 'Вспомнить вопрос', 'Savolni eslash'),
                  'url': 'game:reverse',
                },
                {
                  'icon': 'spellcheck',
                  'title': _getTranslation('Spelling', 'Правописание', 'Imlo'),
                  'subtitle': _getTranslation('Write exactly', 'Пишите точно', 'Aniq yozing'),
                  'url': 'game:spelling',
                },
              ],
            ),
            const SizedBox(height: 20),
            
            // Study Tools Section
            _buildSection(
              title: '🛠️ Study Tools',
              color: const Color(0xFF8B5CF6),
              items: [
                {
                  'icon': 'spellcheck',
                  'title': _getTranslation('Grammarly', 'Grammarly', 'Grammarly'),
                  'subtitle': _getTranslation('Writing assistant', 'Помощник письма', 'Yozish yordamchisi'),
                  'url': 'https://www.grammarly.com',
                },
                {
                  'icon': 'translate',
                  'title': _getTranslation('Translate', 'Переводчик', 'Tarjimon'),
                  'subtitle': _getTranslation('Google Translate', 'Google Переводчик', 'Google Tarjimon'),
                  'url': 'https://translate.google.com',
                },
              ],
            ),
            const SizedBox(height: 20),
            
            // My Words Section
            _buildMyWordsSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MindUpAIScreen()),
          );
        },
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.psychology),
        label: const Text('MindUp AI'),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Color color,
    required List<Map<String, String>> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildResourceCard(
                icon: item['icon']!,
                title: item['title']!,
                subtitle: item['subtitle']!,
                url: item['url']!,
                color: color,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard({
    required String icon,
    required String title,
    required String subtitle,
    required String url,
    required Color color,
  }) {
    IconData iconData;
    switch (icon) {
      case 'headphones':
        iconData = Icons.headphones;
        break;
      case 'menu_book':
        iconData = Icons.menu_book;
        break;
      case 'edit':
        iconData = Icons.edit;
        break;
      case 'record_voice_over':
        iconData = Icons.record_voice_over;
        break;
      case 'calculate':
        iconData = Icons.calculate;
        break;
      case 'description':
        iconData = Icons.description;
        break;
      case 'create':
        iconData = Icons.create;
        break;
      case 'school':
        iconData = Icons.school;
        break;
      case 'hearing':
        iconData = Icons.hearing;
        break;
      case 'quiz':
        iconData = Icons.quiz;
        break;
      case 'stars':
        iconData = Icons.stars;
        break;
      case 'play_circle':
        iconData = Icons.play_circle;
        break;
      case 'library_books':
        iconData = Icons.library_books;
        break;
      case 'spellcheck':
        iconData = Icons.spellcheck;
        break;
      case 'translate':
        iconData = Icons.translate;
        break;
      case 'extension':
        iconData = Icons.extension;
        break;
      case 'timer':
        iconData = Icons.timer;
        break;
      case 'psychology':
        iconData = Icons.psychology;
        break;
      case 'bolt':
        iconData = Icons.bolt;
        break;
      case 'format_list_numbered':
        iconData = Icons.format_list_numbered;
        break;
      case 'link':
        iconData = Icons.link;
        break;
      case 'history':
        iconData = Icons.history;
        break;
      case 'grid_view':
        iconData = Icons.grid_view;
        break;
      case 'category':
        iconData = Icons.category;
        break;
      default:
        iconData = Icons.school;
    }
    
    return GestureDetector(
      onTap: () {
        if (url.startsWith('game:')) {
          _handleGameNavigation(url);
        } else {
          _openInAppWebView(url, title);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconData, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleGameNavigation(String gameUrl) async {
    final isarService = context.read<IsarService>();
    final allTasks = await isarService.getAllTasks();

    if (!mounted) return;

    if (allTasks.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getTranslation(
            'Add at least 4 cards to play games!',
            'Добавьте минимум 4 карточки для игр!',
            'O\'yin o\'ynash uchun kamida 4 ta karta qo\'shing!'
          )),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Widget gameScreen;
    switch (gameUrl) {
      case 'game:quiz':
        gameScreen = QuizScreen(tasks: allTasks);
        break;
      case 'game:match':
        gameScreen = MemoryMatchGame(tasks: allTasks);
        break;
      case 'game:speed':
        gameScreen = SpeedRecallGame(tasks: allTasks);
        break;
      case 'game:context':
        gameScreen = ContextBuilderGame(tasks: allTasks);
        break;
      case 'game:blitz':
        gameScreen = TrueFalseBlitzGame(tasks: allTasks);
        break;
      case 'game:sequence':
        gameScreen = SequenceMasterGame(tasks: allTasks);
        break;
      case 'game:chain':
        gameScreen = AssociationChainGame(tasks: allTasks);
        break;
      case 'game:pattern':
        gameScreen = PatternRecallGame(tasks: allTasks);
        break;
      case 'game:category':
        gameScreen = CategorySortGame(tasks: allTasks);
        break;
      case 'game:reverse':
        gameScreen = ReverseRecallGame(tasks: allTasks);
        break;
      case 'game:spelling':
        gameScreen = SpellingMasterGame(tasks: allTasks);
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => gameScreen),
    ).then((_) => _loadUserWords());
  }

  Widget _buildMyWordsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.book, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Text(
                  _getTranslation('My Words', 'Мои слова', 'Mening so\'zlarim'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_userWords.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.book_outlined, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      _getTranslation('No words added yet', 'Слова еще не добавлены', 'Hali so\'z qo\'shilmagan'),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: _userWords.length,
              itemBuilder: (context, index) {
                final subject = _userWords[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF10B981),
                      child: Text(
                        '${subject['count']}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(subject['subject']),
                    subtitle: Text('${subject['count']} ${_getTranslation('words', 'слов', 'so\'z')}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: Navigate to words list
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _openInAppWebView(String url, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CustomWebView(
          url: url,
          title: title,
          showHelpButton: false,
        ),
      ),
    );
  }

  String _getTranslation(String en, String ru, String uz) {
    switch (_selectedLanguage) {
      case 'Русский':
        return ru;
      case 'Uzbek':
        return uz;
      default:
        return en;
    }
  }
}
