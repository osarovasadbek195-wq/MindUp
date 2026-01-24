import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../data/models/task.dart';
import 'dart:math';

class MemoryMatchGame extends StatefulWidget {
  final List<Task> tasks;

  const MemoryMatchGame({super.key, required this.tasks});

  @override
  State<MemoryMatchGame> createState() => _MemoryMatchGameState();
}

class _MemoryMatchGameState extends State<MemoryMatchGame> {
  late List<MatchItem> _items;
  int? _firstSelectedIndex;
  bool _isProcessing = false;
  int _matchesFound = 0;
  int _tries = 0;
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _setupGame();
  }

  void _setupGame() {
    final random = Random();
    // Use up to 8 pairs (16 cards)
    final gameTasks = List<Task>.from(widget.tasks)..shuffle(random);
    final selectedTasks = gameTasks.take(min(widget.tasks.length, 8)).toList();

    _items = [];
    for (var task in selectedTasks) {
      _items.add(MatchItem(content: task.title, pairId: task.id, type: MatchType.question));
      _items.add(MatchItem(content: task.description ?? 'No answer', pairId: task.id, type: MatchType.answer));
    }
    _items.shuffle(random);

    _firstSelectedIndex = null;
    _isProcessing = false;
    _matchesFound = 0;
    _tries = 0;
    _secondsElapsed = 0;
    _isGameOver = false;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onItemTap(int index) {
    if (_isProcessing || _items[index].isMatched || _firstSelectedIndex == index) return;

    setState(() {
      _items[index].isRevealed = true;
    });

    if (_firstSelectedIndex == null) {
      _firstSelectedIndex = index;
    } else {
      _tries++;
      _isProcessing = true;
      final firstItem = _items[_firstSelectedIndex!];
      final secondItem = _items[index];

      if (firstItem.pairId == secondItem.pairId && firstItem.type != secondItem.type) {
        // Match found
        setState(() {
          firstItem.isMatched = true;
          secondItem.isMatched = true;
          _matchesFound++;
          _firstSelectedIndex = null;
          _isProcessing = false;
          
          if (_matchesFound == _items.length ~/ 2) {
            _isGameOver = true;
            _timer?.cancel();
          }
        });
      } else {
        // No match
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            setState(() {
              firstItem.isRevealed = false;
              secondItem.isRevealed = false;
              _firstSelectedIndex = null;
              _isProcessing = false;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Memory Match'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: _setupGame, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Time', '${_secondsElapsed}s'),
                _buildStat('Matches', '$_matchesFound/${_items.length ~/ 2}'),
                _buildStat('Tries', '$_tries'),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemCount: _items.length,
              itemBuilder: (context, index) => _buildCard(index),
            ),
          ),
          if (_isGameOver) _buildGameOver(),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }

  Widget _buildCard(int index) {
    final item = _items[index];
    final isVisible = item.isRevealed || item.isMatched;

    return GestureDetector(
      onTap: () => _onItemTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isVisible ? (item.isMatched ? Colors.green[100] : Colors.white) : Colors.blue[400],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Center(
          child: isVisible
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    item.content,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: item.isMatched ? Colors.green[700] : Colors.black87,
                    ),
                  ),
                )
              : const Icon(Icons.help_outline, color: Colors.white, size: 32),
        ),
      ),
    );
  }

  Widget _buildGameOver() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Excellent! 🎉', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('You matched everything in $_tries tries and $_secondsElapsed seconds.'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _setupGame,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Play Again'),
            ),
          ),
        ],
      ),
    );
  }
}

enum MatchType { question, answer }

class MatchItem {
  final String content;
  final dynamic pairId;
  final MatchType type;
  bool isRevealed;
  bool isMatched;

  MatchItem({
    required this.content,
    required this.pairId,
    required this.type,
    this.isRevealed = false,
    this.isMatched = false,
  });
}
