import 'package:flutter/material.dart';
import '../../../../data/models/task.dart';
import 'dart:math';

class ContextBuilderGame extends StatefulWidget {
  final List<Task> tasks;

  const ContextBuilderGame({super.key, required this.tasks});

  @override
  State<ContextBuilderGame> createState() => _ContextBuilderGameState();
}

class _ContextBuilderGameState extends State<ContextBuilderGame> {
  late Task _currentTask;
  late List<String> _scrambledWords;
  List<String> _selectedWords = [];
  int _score = 0;
  bool _isCorrect = false;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    _nextRound();
  }

  void _nextRound() {
    if (widget.tasks.isEmpty) return;
    final random = Random();
    _currentTask = widget.tasks[random.nextInt(widget.tasks.length)];
    final answer = _currentTask.description ?? '';
    
    // Split answer into words and scramble
    _scrambledWords = answer.split(' ')..shuffle(random);
    _selectedWords = [];
    _showResult = false;
    _isCorrect = false;
    setState(() {});
  }

  void _onWordTap(int index, bool isSelected) {
    if (_showResult) return;
    setState(() {
      if (isSelected) {
        final word = _selectedWords.removeAt(index);
        _scrambledWords.add(word);
      } else {
        final word = _scrambledWords.removeAt(index);
        _selectedWords.add(word);
      }
    });
  }

  void _checkAnswer() {
    final userAnswer = _selectedWords.join(' ');
    final correctAnswer = _currentTask.description ?? '';
    
    setState(() {
      _showResult = true;
      _isCorrect = userAnswer.trim() == correctAnswer.trim();
      if (_isCorrect) _score += 20;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Context Builder'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildQuestionCard(),
            const SizedBox(height: 32),
            _buildConstructionArea(),
            const SizedBox(height: 24),
            _buildWordBank(),
            const Spacer(),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('QUESTION', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
            Text(_currentTask.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(20)),
          child: Text('Score: $_score', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildQuestionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: const Text(
        'Reconstruct the answer by picking words in the correct order:',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.blueGrey, fontStyle: FontStyle.italic),
      ),
    );
  }

  Widget _buildConstructionArea() {
    return Container(
      minHeight: 100,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50]!.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[50]!, width: 2, style: BorderStyle.solid),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(_selectedWords.length, (index) {
          return ActionChip(
            label: Text(_selectedWords[index]),
            onPressed: () => _onWordTap(index, true),
            backgroundColor: Colors.blue[100],
          );
        }),
      ),
    );
  }

  Widget _buildWordBank() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(_scrambledWords.length, (index) {
        return ActionChip(
          label: Text(_scrambledWords[index]),
          onPressed: () => _onWordTap(index, false),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }),
    );
  }

  Widget _buildActionButtons() {
    if (_showResult) {
      return Column(
        children: [
          Text(
            _isCorrect ? 'PERFECT! 🌟' : 'NOT QUITE...',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _isCorrect ? Colors.green : Colors.red,
            ),
          ),
          if (!_isCorrect) ...[
            const SizedBox(height: 8),
            Text('Correct: ${_currentTask.description}', style: const TextStyle(color: Colors.grey)),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextRound,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Next Round', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _selectedWords.isEmpty ? null : _checkAnswer,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Check Order', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
