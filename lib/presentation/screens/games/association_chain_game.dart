import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../data/models/task.dart';

class AssociationChainGame extends StatefulWidget {
  final List<Task> tasks;

  const AssociationChainGame({super.key, required this.tasks});

  @override
  State<AssociationChainGame> createState() => _AssociationChainGameState();
}

class _AssociationChainGameState extends State<AssociationChainGame> {
  late Task _currentTask;
  late List<String> _chain;
  int _score = 0;
  int _currentIndex = 0;
  bool _isGameOver = false;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _startNewRound();
  }

  void _startNewRound() {
    if (widget.tasks.isEmpty) return;
    
    setState(() {
      _currentTask = widget.tasks[_random.nextInt(widget.tasks.length)];
      _currentIndex = 0;
      _isGameOver = false;
      
      // Create a chain: Title -> first word of description -> second word...
      List<String> words = (_currentTask.description ?? '').split(' ').where((w) => w.isNotEmpty).toList();
      _chain = [_currentTask.title, ...words];
    });
  }

  void _onWordTap(String word) {
    if (_isGameOver) return;

    if (word == _chain[_currentIndex + 1]) {
      setState(() {
        _currentIndex++;
        _score += 15;
        if (_currentIndex == _chain.length - 1) {
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
        title: const Text('Chain Completed! 🔗'),
        content: Text('You successfully linked all associations for "${_currentTask.title}".'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startNewRound();
            },
            child: const Text('Next Chain'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF5FF),
      appBar: AppBar(
        title: const Text('Association Chain'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildScoreBoard(),
            const SizedBox(height: 40),
            _buildChainDisplay(),
            const Spacer(),
            if (!_isGameOver) _buildWordOptions(),
            if (_isGameOver) _buildGameOver(),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBoard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('SCORE', style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
          Text('$_score', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.purple)),
        ],
      ),
    );
  }

  Widget _buildChainDisplay() {
    return Wrap(
      spacing: 8,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: List.generate(_currentIndex + 1, (index) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: index == 0 ? Colors.purple[700] : Colors.purple[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _chain[index],
                style: TextStyle(
                  color: index == 0 ? Colors.white : Colors.purple[900],
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (index < _currentIndex) ...[
                const SizedBox(width: 8),
                Icon(Icons.link, size: 16, color: index == 0 ? Colors.white70 : Colors.purple[400]),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildWordOptions() {
    // Get next correct word and some distractors
    String correctWord = _chain[_currentIndex + 1];
    List<String> options = [correctWord];
    
    // Add distractors from other tasks
    final otherWords = widget.tasks
        .map((t) => (t.description ?? '').split(' '))
        .expand((words) => words)
        .where((w) => w.isNotEmpty && w != correctWord)
        .toList();
    
    otherWords.shuffle();
    options.addAll(otherWords.take(5));
    options.shuffle();

    return Column(
      children: [
        const Text('Pick the next link in the chain:', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: options.map((word) => ActionChip(
            label: Text(word),
            onPressed: () => _onWordTap(word),
            backgroundColor: Colors.white,
            side: BorderSide(color: Colors.purple[100]!),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildGameOver() {
    return Column(
      children: [
        const Icon(Icons.link_off, size: 64, color: Colors.red),
        const SizedBox(height: 16),
        const Text('CHAIN BROKEN!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red)),
        const SizedBox(height: 8),
        Text('The correct word was: ${_chain[_currentIndex + 1]}', style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _startNewRound,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Try Another Chain'),
          ),
        ),
      ],
    );
  }
}
