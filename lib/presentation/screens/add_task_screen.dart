import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/task.dart';
import '../../data/services/google_ai_service.dart';
import '../../data/services/isar_service.dart';
import '../../core/services/notification_service.dart';
import '../blocs/home_bloc.dart';

class AddTaskScreen extends StatefulWidget {
  final VoidCallback? onTaskAdded;

  const AddTaskScreen({super.key, this.onTaskAdded});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  
  // Manual Input Controllers
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  final _subjectController = TextEditingController();

  // AI Input Controllers
  final _topicController = TextEditingController();
  final _aiSubjectController = TextEditingController();

  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _questionController.dispose();
    _answerController.dispose();
    _subjectController.dispose();
    _topicController.dispose();
    _aiSubjectController.dispose();
    super.dispose();
  }

  Future<void> _saveManualTask() async {
    if (_formKey.currentState!.validate()) {
      final task = Task()
        ..title = _questionController.text
        ..description = _answerController.text
        ..subject = _subjectController.text.isNotEmpty ? _subjectController.text : 'General'
        ..createdAt = DateTime.now()
        ..lastReviewedAt = DateTime.now();
      task.repetitionStep = 0;
      task.stage = TaskStage.learning;
      task.mistakeCount = 0;
      task.reviewCount = 0;
      
      // Services before async gap
      final isarService = context.read<IsarService>();
      final notificationService = context.read<NotificationService>();
      final homeBloc = context.read<HomeBloc>();
      
      await isarService.saveTask(task);
      
      // Avtomatik notification rejalashtirish
      await notificationService.scheduleNotification(
        task.id.hashCode,
        'Flashcard Review',
        '${task.title}\n${task.description}',
        task.nextReviewDate,
      );
      
      if (!mounted) return;
      
      homeBloc.add(LoadTasks(DateTime.now()));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task added successfully!'), backgroundColor: Colors.green),
        );
      }
      _questionController.clear();
      _answerController.clear();
      widget.onTaskAdded?.call();
    }
  }

  Future<void> _generateAiTasks() async {
    if (_topicController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a topic'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isGenerating = true);
    
    // Capture services before async gap
    final googleAIService = context.read<GoogleAIService>();
    final isarService = context.read<IsarService>();
    final homeBloc = context.read<HomeBloc>();
    
    try {
      final subject = _aiSubjectController.text.isNotEmpty ? _aiSubjectController.text : 'General';
      
      final tasks = await googleAIService.generateFlashcards(_topicController.text, subject);
      
      if (tasks.isNotEmpty) {
        await isarService.saveTasks(tasks);
        
        // Avtomatik notificationlarni rejalashtirish
        final notificationService = context.read<NotificationService>();
        for (final task in tasks) {
          await notificationService.scheduleNotification(
            task.id.hashCode,
            'Flashcard Review',
            '${task.title}\n${task.description}',
            task.nextReviewDate,
          );
        }
        
        if (!mounted) return;

        homeBloc.add(LoadTasks(DateTime.now()));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${tasks.length} flashcards generated!'), backgroundColor: Colors.green),
        );
        _topicController.clear();
        widget.onTaskAdded?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text('Add New Task', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF3B82F6),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF3B82F6),
          tabs: const [
            Tab(icon: Icon(Icons.edit), text: 'Manual'),
            Tab(icon: Icon(Icons.auto_awesome), text: 'AI Generate'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildManualTab(),
          _buildAiTab(),
        ],
      ),
    );
  }

  Widget _buildManualTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(
              controller: _subjectController,
              label: 'Subject (Optional)',
              icon: Icons.category,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _questionController,
              label: 'Question / Front',
              icon: Icons.help_outline,
              maxLines: 3,
              validator: (v) => v?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _answerController,
              label: 'Answer / Back',
              icon: Icons.lightbulb_outline,
              maxLines: 3,
              validator: (v) => v?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveManualTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Save Card', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Color(0xFF3B82F6)),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Generate flashcards instantly from any topic using AI.',
                    style: TextStyle(color: Color(0xFF1F2937), fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildTextField(
            controller: _aiSubjectController,
            label: 'Subject (Optional)',
            icon: Icons.category,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _topicController,
            label: 'Topic to Learn',
            hint: 'e.g., Photosynthesis process, French basics, World War II',
            icon: Icons.search,
            maxLines: 2,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _isGenerating ? null : _generateAiTasks,
            icon: _isGenerating 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.auto_awesome),
            label: Text(_isGenerating ? 'Generating...' : 'Generate Flashcards'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6), // Purple for AI
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
