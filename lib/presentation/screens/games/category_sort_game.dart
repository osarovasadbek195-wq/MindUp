import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../data/models/task.dart';

class CategorySortGame extends StatefulWidget {
  final List<Task> tasks;

  const CategorySortGame({super.key, required this.tasks});

  @override
  State<CategorySortGame> createState() => _CategorySortGameState();
}

class _CategorySortGameState extends State<CategorySortGame> {
  late List<Task> _gameTasks;
  late List<String> _subjects;
  int _score = 0;
  int _currentIndex = 0;
  bool _isGameOver = false;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _setupGame();
  }

  void _setupGame() {
    setState(() {
      _gameTasks = List.from(widget.tasks)..shuffle(_random);
      _gameTasks = _gameTasks.take(math.min(widget.tasks.length, 20)).toList();
      _subjects = widget.tasks.map((t) => t.subject).toSet().toList();
      if (_subjects.length > 4) {
        _subjects.shuffle();
        _subjects = _subjects.take(4).toList();
      }
      // Ensure the subjects of game tasks are in the subject list
      for (var task in _gameTasks) {
        if (!_subjects.contains(task.subject)) {
          if (_subjects.length < 4) {
            _subjects.add(task.subject);
          }
        }
      }
      _currentIndex = 0;
      _score = 0;
      _isGameOver = false;
    });
  }

  void _handleSort(String subject) {
    if (_isGameOver) return;

    if (_gameTasks[_currentIndex].subject == subject) {
      setState(() {
        _score += 10;
        _nextQuestion();
      });
    } else {
      setState(() {
        _isGameOver = true;
      });
    }
  }

  void _nextQuestion() {
    if (_currentIndex < _gameTasks.length - 1) {
      _currentIndex++;
    } else {
      _showWinDialog();
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Great Job! 🎯'),
        content: Text('You sorted all words correctly! Final Score: $_score'),
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
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Category Sort'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isGameOver ? _buildGameOver() : _buildGameContent(),
    );
  }

  Widget _buildGameContent() {
    final currentTask = _gameTasks[_currentIndex];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          _buildProgressBar(),
          const SizedBox(height: 40),
          const Text(
            'SORT THIS ITEM:',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          const SizedBox(height: 20),
          _buildItemCard(currentTask),
          const Spacer(),
          const Text(
            'SELECT THE CORRECT CATEGORY:',
            style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildCategoryButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Item ${_currentIndex + 1}/${_gameTasks.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Score: $_score', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (_currentIndex + 1) / _gameTasks.length,
          backgroundColor: Colors.blue.withOpacity(0.1),
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          borderRadius: BorderRadius.circular(10),
        ),
      ],
    );
  }

  Widget _buildItemCard(Task task) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Text(
            task.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          if (task.description != null) ...[
            const SizedBox(height: 12),
            Text(
              task.description!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryButtons() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: _subjects.length,
      itemBuilder: (context, index) {
        final subject = _subjects[index];
        return ElevatedButton(
          onPressed: () => _handleSort(subject),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue,
            elevation: 0,
            side: const BorderSide(color: Colors.blue, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(
            subject,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        );
      },
    );
  }

  Widget _buildGameOver() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sentiment_very_dissatisfied, size: 80, color: Colors.red),
            const SizedBox(height: 24),
            const Text('WRONG CATEGORY!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('The correct category was: ${_gameTasks[_currentIndex].subject}', 
                textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _setupGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Try Again'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
