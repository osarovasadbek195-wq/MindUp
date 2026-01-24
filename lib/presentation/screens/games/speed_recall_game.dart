import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../data/models/task.dart';

class SpeedRecallGame extends StatefulWidget {
  final List<Task> tasks;

  const SpeedRecallGame({super.key, required this.tasks});

  @override
  State<SpeedRecallGame> createState() => _SpeedRecallGameState();
}

class _SpeedRecallGameState extends State<SpeedRecallGame> {
  late Task _currentTask;
  late List<String> _options;
  int _score = 0;
  int _timeLeft = 30;
  Timer? _timer;
  bool _isGameOver = false;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _nextQuestion();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _timer?.cancel();
        setState(() => _isGameOver = true);
      }
    });
  }

  void _nextQuestion() {
    if (widget.tasks.isEmpty) return;
    
    setState(() {
      _currentTask = widget.tasks[_random.nextInt(widget.tasks.length)];
      final correctAnswer = _currentTask.description ?? 'No answer';
      
      final distractors = widget.tasks
          .where((t) => t.id != _currentTask.id)
          .map((t) => t.description ?? 'N/A')
          .toSet()
          .toList();
      distractors.shuffle();
      
      _options = distractors.take(3).toList();
      _options.add(correctAnswer);
      _options.shuffle();
    });
  }

  void _checkAnswer(String selected) {
    if (_isGameOver) return;
    
    if (selected == (_currentTask.description ?? 'No answer')) {
      setState(() {
        _score += 10;
        _timeLeft += 2; // Bonus time
      });
      _nextQuestion();
    } else {
      setState(() {
        _score = math.max(0, _score - 5);
        _timeLeft = math.max(0, _timeLeft - 3); // Penalty
      });
      _nextQuestion();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E293B),
      appBar: AppBar(
        title: const Text('Speed Recall', style: TextStyle(color: Colors.white)),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard('Score', _score.toString(), Colors.blue),
              _buildStatCard('Time', '${_timeLeft}s', _timeLeft < 10 ? Colors.red : Colors.green),
            ],
          ),
          const SizedBox(height: 48),
          const Text('WHAT IS THE MEANING OF:', style: TextStyle(color: Colors.blueGrey, letterSpacing: 2)),
          const SizedBox(height: 16),
          Text(
            _currentTask.title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          ..._options.map((opt) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _checkAnswer(opt),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: Colors.blueGrey[800],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(opt, style: const TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
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
            const Icon(Icons.timer_off, size: 80, color: Colors.red),
            const SizedBox(height: 24),
            const Text('TIME UP!', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Final Score: $_score', style: const TextStyle(color: Colors.blueGrey, fontSize: 24)),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _score = 0;
                    _timeLeft = 30;
                    _isGameOver = false;
                    _nextQuestion();
                    _startTimer();
                  });
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Play Again', style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
