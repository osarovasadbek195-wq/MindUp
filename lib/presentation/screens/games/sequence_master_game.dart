import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../data/models/task.dart';

class SequenceMasterGame extends StatefulWidget {
  final List<Task> tasks;

  const SequenceMasterGame({super.key, required this.tasks});

  @override
  State<SequenceMasterGame> createState() => _SequenceMasterGameState();
}

class _SequenceMasterGameState extends State<SequenceMasterGame> {
  List<Task> _sequence = [];
  List<Task> _userSequence = [];
  bool _showingSequence = false;
  int _currentLevel = 1;
  bool _isGameOver = false;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    setState(() {
      _currentLevel = 1;
      _sequence = [];
      _isGameOver = false;
    });
    _nextLevel();
  }

  void _nextLevel() async {
    _userSequence = [];
    final nextTask = widget.tasks[_random.nextInt(widget.tasks.length)];
    _sequence.add(nextTask);
    
    setState(() {
      _showingSequence = true;
    });

    await Future.delayed(const Duration(milliseconds: 1000));
    
    setState(() {
      _showingSequence = false;
    });
  }

  void _onTaskTap(Task task) {
    if (_showingSequence || _isGameOver) return;

    setState(() {
      _userSequence.add(task);
    });

    // Check if the tap was correct
    if (_userSequence.last.id != _sequence[_userSequence.length - 1].id) {
      setState(() {
        _isGameOver = true;
      });
      return;
    }

    // Check if level completed
    if (_userSequence.length == _sequence.length) {
      _currentLevel++;
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) _nextLevel();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      appBar: AppBar(
        title: const Text('Sequence Master'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isGameOver ? _buildGameOver() : _buildGameBoard(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('LEVEL', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              Text('$_currentLevel', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _showingSequence ? Colors.orange[100] : Colors.green[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _showingSequence ? 'WATCH!' : 'YOUR TURN!',
              style: TextStyle(
                color: _showingSequence ? Colors.orange[800] : Colors.green[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameBoard() {
    // Show only 9 tasks in a grid for selection
    final availableTasks = widget.tasks.take(math.min(widget.tasks.length, 9)).toList();

    if (_showingSequence) {
      final currentShowingTask = _sequence.last;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Remember this one:', style: TextStyle(color: Colors.grey, fontSize: 18)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.green.withOpacity(0.2), blurRadius: 20, spreadRadius: 5),
                ],
              ),
              child: Text(
                currentShowingTask.title,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: availableTasks.length,
      itemBuilder: (context, index) {
        final task = availableTasks[index];
        return GestureDetector(
          onTap: () => _onTaskTap(task),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green[100]!, width: 2),
            ),
            child: Center(
              child: Text(
                task.title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
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
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 24),
            const Text('SEQUENCE BROKEN!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('You reached Level $_currentLevel', style: const TextStyle(fontSize: 20, color: Colors.grey)),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startNewGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
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
