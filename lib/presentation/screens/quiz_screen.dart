import 'package:flutter/material.dart';
import '../../data/models/task.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/home_bloc.dart';

class QuizScreen extends StatefulWidget {
  final List<Task> tasks;

  const QuizScreen({super.key, required this.tasks});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int _score = 0;
  bool _isAnswered = false;
  int? _selectedOptionIndex;
  late List<Task> _quizTasks;
  late List<String> _options;
  late int _correctOptionIndex;

  @override
  void initState() {
    super.initState();
    // Filter tasks that have valid descriptions (answers)
    _quizTasks = widget.tasks.where((t) => t.description != null && t.description!.isNotEmpty).toList();
    _quizTasks.shuffle(); // Randomize order
    if (_quizTasks.isNotEmpty) {
      _generateOptions();
    }
  }

  void _generateOptions() {
    if (_quizTasks.isEmpty) return;

    final currentTask = _quizTasks[_currentIndex];
    final correctAnswer = currentTask.description!;
    
    // Get distractors from other tasks
    final otherTasks = List<Task>.from(_quizTasks)..removeAt(_currentIndex);
    otherTasks.shuffle();
    
    final distractors = otherTasks
        .take(3)
        .map((t) => t.description!)
        .toList();
    
    // If we don't have enough tasks for distractors, fill with placeholders
    while (distractors.length < 3) {
      distractors.add('Option ${distractors.length + 1}');
    }

    _options = [...distractors, correctAnswer];
    _options.shuffle();
    _correctOptionIndex = _options.indexOf(correctAnswer);
  }

  void _handleAnswer(int selectedIndex) {
    if (_isAnswered) return;

    setState(() {
      _isAnswered = true;
      _selectedOptionIndex = selectedIndex;
      if (selectedIndex == _correctOptionIndex) {
        _score++;
        // Update task progress in background
        context.read<HomeBloc>().add(CompleteTask(_quizTasks[_currentIndex], true));
      } else {
        context.read<HomeBloc>().add(CompleteTask(_quizTasks[_currentIndex], false));
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _quizTasks.length - 1) {
      setState(() {
        _currentIndex++;
        _isAnswered = false;
        _selectedOptionIndex = null;
        _generateOptions();
      });
    } else {
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Completed!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              'Your Score: $_score / ${_quizTasks.length}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _score == _quizTasks.length 
                  ? 'Perfect! You are a master!' 
                  : 'Keep practicing to improve!',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close screen
            },
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentIndex = 0;
                _score = 0;
                _isAnswered = false;
                _selectedOptionIndex = null;
                _quizTasks.shuffle();
                _generateOptions();
              });
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_quizTasks.isEmpty || _quizTasks.length < 4) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz Mode')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.quiz, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Not enough cards for a quiz.\nAdd at least 4 flashcards to play!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentTask = _quizTasks[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: Text('Question ${_currentIndex + 1}/${_quizTasks.length}'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Question Card
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(
                          currentTask.subject,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          currentTask.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Options
            Expanded(
              flex: 3,
              child: Column(
                children: List.generate(4, (index) {
                  final isSelected = _selectedOptionIndex == index;
                  final isCorrect = index == _correctOptionIndex;
                  
                  Color backgroundColor = Colors.white;
                  Color borderColor = Colors.transparent;
                  Color textColor = Colors.black87;

                  if (_isAnswered) {
                    if (isCorrect) {
                      backgroundColor = Colors.green.withValues(alpha: 0.1);
                      borderColor = Colors.green;
                      textColor = Colors.green;
                    } else if (isSelected) {
                      backgroundColor = Colors.red.withValues(alpha: 0.1);
                      borderColor = Colors.red;
                      textColor = Colors.red;
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => _handleAnswer(index),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isAnswered ? borderColor : Colors.white,
                            width: 2,
                          ),
                          boxShadow: [
                            if (!_isAnswered)
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: textColor.withValues(alpha: 0.1),
                              child: Text(
                                String.fromCharCode(65 + index), // A, B, C, D
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                _options[index],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: textColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (_isAnswered && isCorrect)
                              const Icon(Icons.check_circle, color: Colors.green),
                            if (_isAnswered && isSelected && !isCorrect)
                              const Icon(Icons.cancel, color: Colors.red),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            
            // Next Button
            if (_isAnswered)
              ElevatedButton.icon(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.arrow_forward),
                label: Text(_currentIndex < _quizTasks.length - 1 ? 'Next Question' : 'Finish Quiz'),
              ),
          ],
        ),
      ),
    );
  }
}
