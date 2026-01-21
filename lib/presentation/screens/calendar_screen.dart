import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../data/models/task.dart';
import '../../data/models/user_profile.dart';
import '../blocs/home_bloc.dart';
import 'study_screen.dart';
import 'ai_search_screen.dart';
import 'analytics_screen.dart';

import '../../data/services/isar_service.dart';
import '../../core/services/voice_service.dart';
import '../../core/utils/intent_parser.dart';
import '../../core/utils/logger.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    // Ilk yuklanishda bugungi vazifalarni so'rash
    context.read<HomeBloc>().add(LoadTasks(DateTime.now()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MindUp Learning'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AISearchScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () async {
              final isarService = context.read<IsarService>();
              final allTasks = await isarService.getAllTasks();
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AnalyticsScreen(allTasks: allTasks),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
              context.read<HomeBloc>().add(LoadTasks(DateTime.now()));
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF0F4FF), Color(0xFFE8F1F8)], // Soft HyperOS Gradient
          ),
        ),
        child: BlocConsumer<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state is HomeError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            List<Task> currentTasks = [];
            if (state is HomeLoaded) {
              currentTasks = state.tasks;
            }

            return SafeArea(
              child: Column(
                children: [
                  _buildGamificationHeader(),
                  Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                         BoxShadow(
                           color: Colors.black.withOpacity(0.05),
                           blurRadius: 20,
                           offset: const Offset(0, 10),
                         )
                      ],
                    ),
                    child: TableCalendar<Task>(
                      firstDay: DateTime.utc(2024, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        if (!isSameDay(_selectedDay, selectedDay)) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                          context.read<HomeBloc>().add(LoadTasks(selectedDay));
                        }
                      },
                      onFormatChanged: (format) {
                        if (_calendarFormat != format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        }
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                      eventLoader: (day) => [], 
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Expanded(
                    child: state is HomeLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _buildTaskList(currentTasks),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'voice_btn',
            backgroundColor: _isListening ? Colors.red : Colors.deepPurple,
            foregroundColor: Colors.white,
            onPressed: _handleVoiceCommand,
            child: Icon(_isListening ? Icons.mic : Icons.mic_none),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'add_btn',
            onPressed: _showSmartInputDialog,
            child: const Icon(Icons.auto_awesome),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_available, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No tasks for this day',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStageColor(task.stage),
              child: Text(
                '${task.reviewCount}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(task.subject),
            trailing: const Icon(Icons.play_arrow_rounded, color: Colors.deepPurple),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StudyScreen(
                    task: task,
                    onResult: (isSuccess) {
                      context.read<HomeBloc>().add(CompleteTask(task, isSuccess));
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
  
  Color _getStageColor(TaskStage stage) {
    switch (stage) {
      case TaskStage.learning: return Colors.blue;
      case TaskStage.review1: return Colors.orange;
      case TaskStage.review2: return Colors.amber;
      case TaskStage.review3: return Colors.green;
      case TaskStage.solidify: return Colors.teal;
      case TaskStage.master: return Colors.purple;
    }
  }

  Widget _buildGamificationHeader() {
    return StreamBuilder<UserProfile?>(
      stream: context.read<IsarService>().listenToProfile(),
      builder: (context, snapshot) {
        final profile = snapshot.data ?? UserProfile();
        
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(Icons.local_fire_department, '${profile.currentStreak}', 'Streak', Colors.orange),
              Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.3)),
              _buildStatItem(Icons.star, '${profile.totalXP} XP', 'Lvl ${profile.level}', Colors.amber),
              Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.3)),
              _buildStatItem(Icons.next_plan, '${profile.xpForNextLevel}', 'Next Lvl', Colors.blue),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  void _showSmartInputDialog({String? initialSubject}) {
    final TextEditingController promptController = TextEditingController();
    final TextEditingController subjectController = TextEditingController(text: initialSubject);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Smart Input'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject (e.g., Math, English)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: promptController,
              decoration: const InputDecoration(
                labelText: 'What to learn? (e.g., 5 difficult SAT words)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (promptController.text.isNotEmpty && subjectController.text.isNotEmpty) {
                context.read<HomeBloc>().add(
                  AddSmartTask(promptController.text, subjectController.text),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  void _handleVoiceCommand() async {
    final voiceService = context.read<VoiceService>();
    
    if (_isListening) {
      await voiceService.stopListening();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      await voiceService.startListening(
        onResult: (text) {
          AppLogger.info("Voice result: $text");
          
          // Stop listening after command received
          voiceService.stopListening();
          setState(() => _isListening = false);

          // Parse and process
          final intent = IntentParser.parse(text);
          _processIntent(intent);
        },
      );
    }
  }

  void _processIntent(VoiceIntent intent) {
    switch (intent.type) {
      case IntentType.add:
        // "Learn Math" -> open dialog with Math pre-filled
        _showSmartInputDialog(initialSubject: intent.data);
        break;
      case IntentType.stats:
        // Navigate to analytics
        _navigateToAnalytics();
        break;
      case IntentType.study:
        // Load today's tasks
        setState(() {
          _focusedDay = DateTime.now();
          _selectedDay = DateTime.now();
        });
        context.read<HomeBloc>().add(LoadTasks(DateTime.now()));
        break;
      case IntentType.search:
        if (intent.data != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AISearchScreen(initialQuery: intent.data),
            ),
          );
        }
        break;
      case IntentType.unknown:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Tushunarsiz buyruq: ${intent.data}")),
        );
        break;
    }
  }

  Future<void> _navigateToAnalytics() async {
    final isarService = context.read<IsarService>();
    final allTasks = await isarService.getAllTasks();
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AnalyticsScreen(allTasks: allTasks),
        ),
      );
    }
  }
}
