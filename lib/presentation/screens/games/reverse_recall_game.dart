import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../data/models/task.dart';

class ReverseRecallGame extends StatefulWidget {
  final List<Task> tasks;

  const ReverseRecallGame({super.key, required this.tasks});

  @override
  State<ReverseRecallGame> createState() => _ReverseRecallGameState();
}

class _ReverseRecallGameState extends State<ReverseRecallGame> {
  late Task _currentTask;
  late List<String> _options;
  int _score = 0;
  int _currentIndex = 0;
  bool _isGameOver = false;
  final math.Random _random = math.Random();
  late List<Task> _gameTasks;

  @override
  void initState() {
    super.initState();
    _setupGame();
  }

  void _setupGame() {
    _gameTasks = List.from(widget.tasks)..shuffle(_random);
    _gameTasks = _gameTasks.take(math.min(widget.tasks.length, 20)).toList();
    _currentIndex = 0;
    _score = 0;
    _isGameOver = false;
    _nextQuestion();
  }

  void _nextQuestion() {
    _currentTask = _gameTasks[_currentIndex];
    final correctQuestion = _currentTask.title;
    
    final distractors = widget.tasks
        .where((t) => t.id != _currentTask.id)
        .map((t) => t.title)
        .toSet()
        .toList();
    distractors.shuffle();
    
    _options = distractors.take(3).toList();
    _options.add(correctQuestion);
    _options.shuffle();
    setState(() {});
  }

  void _handleChoice(String choice) {
    if (_isGameOver) return;

    if (choice == _currentTask.title) {
      setState(() {
        _score += 15;
        if (_currentIndex < _gameTasks.length - 1) {
          _currentIndex++;
          _nextQuestion();
        } else {
          _showWinDialog();
        }
      });
    } else {
      setState(() {
        _isGameOver = true;
      });
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Expert Mode! 🏆'),
        content: Text('You reversed all definitions perfectly! Final Score: $_score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _setupGame();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F8),
      appBar: AppBar(
        title: const Text('Reverse Recall'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isGameOver ? _buildGameOver() : _buildGameContent(),
    );
  }

  Widget _buildGameContent() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 40),
          const Text('WHAT IS THE QUESTION FOR:', style: TextStyle(color: Colors.pink, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 20),
          _buildAnswerCard(),
          const Spacer(),
          ..._options.map((opt) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleChoice(opt),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.pink[700],
                  elevation: 0,
                  side: BorderSide(color: Colors.pink[100]!, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(opt, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Progress: ${_currentIndex + 1}/${_gameTasks.length}', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        Text('Score: $_score', style: const TextStyle(color: Colors.pink, fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }

  Widget _buildAnswerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.pink.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Text(
        _currentTask.description ?? 'No definition',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: Color(0xFF1F2937)),
      ),
    );
  }

  Widget _buildGameOver() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history_toggle_off, size: 80, color: Colors.red),
          const SizedBox(height: 24),
          const Text('RECALL FAILED', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Correct: ${_currentTask.title}', style: const TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: _setupGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
