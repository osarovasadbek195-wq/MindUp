import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../data/models/task.dart';
import 'dart:math';

class TrueFalseBlitzGame extends StatefulWidget {
  final List<Task> tasks;

  const TrueFalseBlitzGame({super.key, required this.tasks});

  @override
  State<TrueFalseBlitzGame> createState() => _TrueFalseBlitzGameState();
}

class _TrueFalseBlitzGameState extends State<TrueFalseBlitzGame> {
  late Task _currentTask;
  late String _displayedAnswer;
  late bool _isActuallyCorrect;
  int _score = 0;
  int _streak = 0;
  int _timeLeft = 20;
  Timer? _timer;
  bool _isGameOver = false;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _nextRound();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _timer?.cancel();
        setState(() => _isGameOver = true);
      }
    });
  }

  void _nextRound() {
    if (widget.tasks.isEmpty) return;
    
    _currentTask = widget.tasks[_random.nextInt(widget.tasks.length)];
    _isActuallyCorrect = _random.nextBool();

    if (_isActuallyCorrect) {
      _displayedAnswer = _currentTask.description ?? 'No answer';
    } else {
      // Pick a random description from another task as a distractor
      final otherTasks = widget.tasks.where((t) => t.id != _currentTask.id).toList();
      if (otherTasks.isNotEmpty) {
        _displayedAnswer = otherTasks[_random.nextInt(otherTasks.length)].description ?? 'Wrong answer';
      } else {
        _displayedAnswer = 'Incorrect data';
      }
    }
    setState(() {});
  }

  void _handleChoice(bool userChoice) {
    if (_isGameOver) return;

    if (userChoice == _isActuallyCorrect) {
      setState(() {
        _score += 10 + (_streak * 2);
        _streak++;
        _timeLeft = min(20, _timeLeft + 2);
      });
    } else {
      setState(() {
        _streak = 0;
        _timeLeft = max(0, _timeLeft - 3);
      });
    }
    _nextRound();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        title: const Text('True/False Blitz', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isGameOver ? _buildGameOver() : _buildGameContent(),
    );
  }

  Widget _buildGameContent() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          _buildTopBar(),
          const Spacer(),
          _buildQuestionArea(),
          const Spacer(),
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('SCORE', style: TextStyle(color: Colors.grey, fontSize: 12)),
            Text('$_score', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
        _buildTimer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('STREAK', style: TextStyle(color: Colors.grey, fontSize: 12)),
            Text('x$_streak', style: const TextStyle(color: Colors.amber, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildTimer() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _timeLeft < 5 ? Colors.red : Colors.blue, width: 4),
      ),
      child: Center(
        child: Text(
          '$_timeLeft',
          style: TextStyle(
            color: _timeLeft < 5 ? Colors.red : Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionArea() {
    return Column(
      children: [
        const Text(
          'DOES THIS MATCH?',
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        const SizedBox(height: 32),
        Text(
          _currentTask.title,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Icon(Icons.compare_arrows, color: Colors.grey, size: 40),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            _displayedAnswer,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.amber, fontSize: 22, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildChoiceButton(false, 'FALSE', Colors.red),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildChoiceButton(true, 'TRUE', Colors.green),
        ),
      ],
    );
  }

  Widget _buildChoiceButton(bool choice, String label, Color color) {
    return SizedBox(
      height: 80,
      child: ElevatedButton(
        onPressed: () => _handleChoice(choice),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildGameOver() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Blitz Over!', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text('Final Score: $_score', style: const TextStyle(color: Colors.grey, fontSize: 24)),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _score = 0;
                _streak = 0;
                _timeLeft = 20;
                _isGameOver = false;
                _nextRound();
                _startTimer();
              });
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Try Again', style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
        ],
      ),
    );
  }
}
