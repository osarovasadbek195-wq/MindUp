import 'package:flutter/material.dart';
import '../../../data/models/task.dart';
import 'dart:math' as math;

class SpellingMasterGame extends StatefulWidget {
  final List<Task> tasks;

  const SpellingMasterGame({super.key, required this.tasks});

  @override
  State<SpellingMasterGame> createState() => _SpellingMasterGameState();
}

class _SpellingMasterGameState extends State<SpellingMasterGame> {
  late List<Task> _gameTasks;
  int _currentIndex = 0;
  int _score = 0;
  bool _isGameOver = false;
  final TextEditingController _controller = TextEditingController();
  final math.Random _random = math.Random();
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    _setupGame();
  }

  void _setupGame() {
    _gameTasks = List.from(widget.tasks)..shuffle(_random);
    _gameTasks = _gameTasks.take(math.min(widget.tasks.length, 15)).toList();
    _currentIndex = 0;
    _score = 0;
    _isGameOver = false;
    _controller.clear();
    _showHint = false;
  }

  void _checkAnswer() {
    final correct = _gameTasks[_currentIndex].title.trim().toLowerCase();
    final user = _controller.text.trim().toLowerCase();

    if (user == correct) {
      setState(() {
        _score += 20;
        if (_currentIndex < _gameTasks.length - 1) {
          _currentIndex++;
          _controller.clear();
          _showHint = false;
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
        title: const Text('Spelling Master! ✍️'),
        content: Text('Perfect spelling! Final Score: $_score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _setupGame();
              setState(() {});
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Spelling Master'),
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
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _gameTasks.length,
            backgroundColor: Colors.blue.withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Item ${_currentIndex + 1}/${_gameTasks.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('Score: $_score', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 40),
          const Text('SPELL THE WORD FOR:', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 20),
          _buildDefinitionCard(currentTask),
          const SizedBox(height: 40),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Type exactly...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: IconButton(
                icon: Icon(_showHint ? Icons.visibility : Icons.lightbulb_outline),
                onPressed: () => setState(() => _showHint = !_showHint),
              ),
            ),
            onSubmitted: (_) => _checkAnswer(),
          ),
          if (_showHint) ...[
            const SizedBox(height: 12),
            Text(
              'Hint: ${currentTask.title[0]}...${currentTask.title[currentTask.title.length - 1]} (${currentTask.title.length} letters)',
              style: const TextStyle(color: Colors.orange, fontStyle: FontStyle.italic),
            ),
          ],
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _checkAnswer,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('SUBMIT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefinitionCard(Task task) {
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
      child: Text(
        task.description ?? 'No description',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildGameOver() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.spellcheck, size: 80, color: Colors.red),
            const SizedBox(height: 24),
            const Text('MISSPELLING!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Correct spelling: ${_gameTasks[_currentIndex].title}', 
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
