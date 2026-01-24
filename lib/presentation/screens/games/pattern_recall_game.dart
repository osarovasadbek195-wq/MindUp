import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../data/models/task.dart';

class PatternRecallGame extends StatefulWidget {
  final List<Task> tasks;

  const PatternRecallGame({super.key, required this.tasks});

  @override
  State<PatternRecallGame> createState() => _PatternRecallGameState();
}

class _PatternRecallGameState extends State<PatternRecallGame> {
  final List<int> _pattern = [];
  final List<int> _userPattern = [];
  bool _showingPattern = false;
  int _score = 0;
  bool _isGameOver = false;
  final math.Random _random = math.Random();
  int _gridSize = 3; // 3x3 grid

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    setState(() {
      _pattern.clear();
      _score = 0;
      _isGameOver = false;
    });
    _nextLevel();
  }

  void _nextLevel() async {
    _userPattern.clear();
    _pattern.add(_random.nextInt(_gridSize * _gridSize));
    
    setState(() {
      _showingPattern = true;
    });

    for (int cell in _pattern) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 600));
      setState(() => _activeCell = cell);
      await Future.delayed(const Duration(milliseconds: 400));
      setState(() => _activeCell = -1);
    }

    if (mounted) {
      setState(() {
        _showingPattern = false;
      });
    }
  }

  int _activeCell = -1;

  void _onCellTap(int index) {
    if (_showingPattern || _isGameOver) return;

    setState(() {
      _userPattern.add(index);
    });

    if (_userPattern.last != _pattern[_userPattern.length - 1]) {
      setState(() {
        _isGameOver = true;
      });
      return;
    }

    if (_userPattern.length == _pattern.length) {
      _score += 10;
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) _nextLevel();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Pattern Recall', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStat('SCORE', '$_score', Colors.blue),
                _buildStat('LEVEL', '${_pattern.length}', Colors.purple),
              ],
            ),
          ),
          const Spacer(),
          _isGameOver ? _buildGameOver() : _buildGrid(),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              _showingPattern ? 'WATCH THE PATTERN...' : 'REPLICATE THE PATTERN!',
              style: TextStyle(
                color: _showingPattern ? Colors.amber : Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
        Text(value, style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _gridSize,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _gridSize * _gridSize,
        itemBuilder: (context, index) {
          final isActive = _activeCell == index;
          return GestureDetector(
            onTap: () => _onCellTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isActive ? Colors.blue : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive ? Colors.blueAccent : Colors.white.withOpacity(0.2),
                  width: 2,
                ),
                boxShadow: isActive ? [BoxShadow(color: Colors.blue.withOpacity(0.5), blurRadius: 15)] : [],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGameOver() {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.videogame_asset_off, size: 80, color: Colors.red),
          const SizedBox(height: 24),
          const Text('GAME OVER', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Final Score: $_score', style: const TextStyle(color: Colors.grey, fontSize: 20)),
          const SizedBox(height: 48),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: _startNewGame,
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
    );
  }
}
