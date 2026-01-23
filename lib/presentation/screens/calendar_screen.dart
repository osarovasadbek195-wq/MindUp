import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../data/models/task.dart';
import '../../data/models/user_profile.dart';
import '../blocs/home_bloc.dart';
import '../../core/services/notification_service.dart';
import 'study_screen.dart';
import 'profile_screen.dart';
import '../../data/services/isar_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _selectedLanguage = 'All';

  final List<String> _languages = ['All', 'English', 'Russian', 'Uzbek', 'Math'];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    context.read<HomeBloc>().add(LoadTasks(DateTime.now()));
    _schedule3HourNotification();
  }

  void _schedule3HourNotification() {
    final notificationService = context.read<NotificationService>();
    notificationService.scheduleNotificationIn3Hours(
      1,
      'MindUp Study Reminder',
      '3 soat o\'tdi! O\'rganganlaringizni takrorlash vaqti keldi.',
    );
  }

  void _showInstantNotification() {
    final notificationService = context.read<NotificationService>();
    notificationService.showInstantNotification(
      'MindUp Study Reminder',
      'O\'rganganlaringizni takrorlash vaqti keldi!',
    );
  }

  void _checkPendingNotifications() async {
    final notificationService = context.read<NotificationService>();
    final pendingNotifications = await notificationService.getPendingNotifications();
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pending Notifications'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (pendingNotifications.isEmpty)
                const Text('No pending notifications')
              else
                ...pendingNotifications.map((notif) => ListTile(
                  title: Text(notif.title ?? 'No title'),
                  subtitle: Text('ID: ${notif.id}\nBody: ${notif.body ?? ''}'),
                  leading: const Icon(Icons.schedule),
                )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showTasksWithReviewTimes() async {
    final isarService = context.read<IsarService>();
    final allTasks = await isarService.getAllTasks();
    
    if (!mounted) return;
    
    final now = DateTime.now();
    final upcomingTasks = allTasks
        .where((task) => task.nextReviewDate.isAfter(now))
        .take(10)
        .toList();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upcoming Review Times'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: upcomingTasks.isEmpty
              ? const Text('No upcoming reviews')
              : ListView.builder(
                  itemCount: upcomingTasks.length,
                  itemBuilder: (context, index) {
                    final task = upcomingTasks[index];
                    final hoursUntil = task.nextReviewDate.difference(now).inHours;
                    final daysUntil = task.nextReviewDate.difference(now).inDays;
                    
                    return ListTile(
                      title: Text(task.title),
                      subtitle: Text(
                        'Review in: ${daysUntil > 0 ? '$daysUntil days' : '$hoursUntil hours'}\n'
                        'Step: ${task.repetitionStep}\n'
                        'Date: ${task.nextReviewDate.toString().substring(0, 16)}',
                      ),
                      leading: CircleAvatar(
                        backgroundColor: _getStageColor(task.stage),
                        child: Text('${task.repetitionStep}'),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          if (upcomingTasks.isNotEmpty)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _scheduleFlashcardNotifications(upcomingTasks.take(3).toList());
              },
              child: const Text('Schedule 3 Notifications'),
            ),
        ],
      ),
    );
  }

  void _scheduleFlashcardNotifications(List<Task> tasks) async {
    final notificationService = context.read<NotificationService>();
    final flashcards = tasks.map((task) => {
      'id': task.id.hashCode,
      'title': 'Flashcard Review',
      'body': '${task.title}\n${task.description}',
      'scheduledTime': task.nextReviewDate,
    }).toList();
    
    await notificationService.scheduleFlashcardNotifications(flashcards);
    
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${flashcards.length} flashcard notifications scheduled!'),
        backgroundColor: Colors.green,
      ),
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
                labelText: 'What to learn?',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text('MindUp Learning'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Language Filter
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: (String value) {
              setState(() {
                _selectedLanguage = value;
              });
              // Filter tasks immediately
              context.read<HomeBloc>().add(LoadTasks(_selectedDay ?? DateTime.now()));
            },
            itemBuilder: (BuildContext context) {
              return _languages.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () async {
              final isarService = context.read<IsarService>();
              final allTasks = await isarService.getAllTasks();
              if (!context.mounted) return;
              
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(allTasks: allTasks),
                ),
              );
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
            colors: [Color(0xFFF0F4FF), Color(0xFFE8F1F8)],
          ),
        ),
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            if (state is HomeError) {
              return Center(
                child: Text(
                  'Error: ${state.message}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            
            List<Task> currentTasks = [];
            if (state is HomeLoaded) {
              currentTasks = state.tasks;
              // Filter by language/subject if implemented
              if (_selectedLanguage != 'All') {
                 currentTasks = currentTasks.where((t) => t.subject.contains(_selectedLanguage)).toList();
              }
            }

            return SafeArea(
              child: Column(
                children: [
                  _buildGamificationHeader(),
                  Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                         BoxShadow(
                           color: Colors.black.withValues(alpha: 0.05),
                           blurRadius: 20,
                           offset: const Offset(0, 10),
                         )
                      ],
                    ),
                    child: TableCalendar<Task>(
                      firstDay: const DateTime.utc(2024, 1, 1),
                      lastDay: const DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      eventLoader: (day) {
                        return currentTasks.where((task) {
                          return isSameDay(task.nextReviewDate, day);
                        }).toList();
                      },
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
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        markersMaxCount: 3,
                        markerDecoration: const BoxDecoration(
                          color: Color(0xFF3B82F6),
                          shape: BoxShape.circle,
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'time_btn',
            onPressed: _showTasksWithReviewTimes,
            backgroundColor: Colors.green,
            mini: true,
            child: const Icon(Icons.access_time, size: 20),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'check_btn',
            onPressed: _checkPendingNotifications,
            backgroundColor: Colors.blue,
            mini: true,
            child: const Icon(Icons.list, size: 20),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'notification_btn',
            onPressed: _showInstantNotification,
            backgroundColor: Colors.orange,
            mini: true,
            child: const Icon(Icons.notifications, size: 20),
          ),
          const SizedBox(height: 8),
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No tasks for this day',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          elevation: 0,
          child: ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: _getStageColor(task.stage),
              child: Text(
                '${task.repetitionStep}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(task.subject),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  onPressed: () => _completeTask(task, true),
                  tooltip: 'Completed Successfully',
                ),
                IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  onPressed: () => _completeTask(task, false),
                  tooltip: 'Need More Practice',
                ),
                IconButton(
                  icon: const Icon(Icons.play_arrow_rounded, color: Colors.deepPurple),
                  onPressed: () {
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
                  tooltip: 'Study Now',
                ),
              ],
            ),
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

  void _completeTask(Task task, bool isSuccess) {
    context.read<HomeBloc>().add(CompleteTask(task, isSuccess));
    
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isSuccess ? '✅ Task completed!' : '📚 Need more practice'),
        backgroundColor: isSuccess ? Colors.green : Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Color _getStageColor(TaskStage stage) {
    switch (stage) {
      case TaskStage.learning: return Colors.blue;
      case TaskStage.review: return Colors.orange;
      case TaskStage.mastered: return Colors.purple;
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
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(Icons.local_fire_department, '${profile.currentStreak}', 'Streak', Colors.orange),
              Container(width: 1, height: 40, color: Colors.grey.withValues(alpha: 0.3)),
              _buildStatItem(Icons.star, '${profile.totalXP} XP', 'Lvl ${profile.level}', Colors.amber),
              Container(width: 1, height: 40, color: Colors.grey.withValues(alpha: 0.3)),
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
}
