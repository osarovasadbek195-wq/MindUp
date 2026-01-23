import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/isar_service.dart';

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
                  'url': 'https://ieltsonlinetests.com',
                },
                {
                  'icon': 'edit',
                  'title': _getTranslation('Writing', 'Письмо', 'Yozish'),
                  'subtitle': _getTranslation('Task 1 & 2', 'Задание 1 и 2', '1 va 2-topshiriq'),
                  'url': 'https://www.ieltsadvantage.com',
                },
                {
                  'icon': 'record_voice_over',
                  'title': _getTranslation('Speaking', 'Говорение', 'Gapirish'),
                  'subtitle': _getTranslation('Speaking topics', 'Темы для говорения', 'Gapirish mavzulari'),
                  'url': 'https://ieltsliz.com',
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
                  'subtitle': _getTranslation('Full course', 'Полный курс', 'To\'liq kurs'),
                  'url': 'https://www.khanacademy.org',
                },
                {
                  'icon': 'description',
                  'title': _getTranslation('Reading', 'Чтение', 'O\'qish'),
                  'subtitle': _getTranslation('Reading strategies', 'Стратегии чтения', 'O\'qish strategiyalari'),
                  'url': 'https://www.khanacademy.org',
                },
                {
                  'icon': 'create',
                  'title': _getTranslation('Writing', 'Письмо', 'Yozish'),
                  'subtitle': _getTranslation('Writing section', 'Секция письма', 'Yozish bo\'limi'),
                  'url': 'https://www.cracksat.net',
                },
              ],
            ),
            const SizedBox(height: 20),
            
            // My Words Section
            _buildMyWordsSection(),
          ],
        ),
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
            color: Colors.black.withOpacity(0.05),
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
      default:
        iconData = Icons.school;
    }
    
    return GestureDetector(
      onTap: () => _launchURL(url),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
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
                color: color.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyWordsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              color: const Color(0xFF10B981),
              borderRadius: const BorderRadius.only(
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
                    Icon(Icons.book_outlined, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      _getTranslation('No words added yet', 'Слова еще не добавлены', 'Hali so\'z qo\'shilmagan'),
                      style: TextStyle(color: Colors.grey),
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

  Future<void> _launchURL(String url) async {
    try {
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
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
