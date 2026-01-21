import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/task.dart';
import '../../data/services/isar_service.dart';

class StudyScreen extends StatefulWidget {
  final Task task;
  final Function(bool isSuccess) onResult;

  const StudyScreen({super.key, required this.task, required this.onResult});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> with SingleTickerProviderStateMixin {
  bool _isAnswerRevealed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.task.subject),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE0EAFC), Color(0xFFCFDEF3)], // HyperOS Light Blue Gradient
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Flashcard Container
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'QUESTION',
                            style: TextStyle(
                              color: Colors.blueGrey[300],
                              fontSize: 14,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            widget.task.title,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),
                          
                          // Divider with subtle gradient
                          Container(
                            height: 1,
                            width: 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent, 
                                  Colors.grey.withOpacity(0.5), 
                                  Colors.transparent
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return FadeTransition(opacity: animation, child: SlideTransition(
                                position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(animation),
                                child: child,
                              ));
                            },
                            child: _isAnswerRevealed
                                ? Column(
                                    key: const ValueKey('answer'),
                                    children: [
                                      Text(
                                        'ANSWER',
                                        style: TextStyle(
                                          color: Colors.green[300],
                                          fontSize: 14,
                                          letterSpacing: 1.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        widget.task.description ?? "No description",
                                        style: const TextStyle(
                                          fontSize: 22,
                                          color: Colors.black54,
                                          height: 1.4,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  )
                                : const SizedBox(
                                    key: ValueKey('hidden'),
                                    height: 100,
                                    child: Center(
                                      child: Icon(Icons.lock_outline, size: 40, color: Colors.black12),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),

                // Controls
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: !_isAnswerRevealed
                      ? FilledButton.icon(
                          onPressed: () => setState(() => _isAnswerRevealed = true),
                          icon: const Icon(Icons.remove_red_eye_outlined),
                          label: const Text('Reveal Answer'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blueAccent,
                            elevation: 0,
                            side: const BorderSide(color: Colors.blueAccent),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                          ),
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: _buildActionButton(
                                context,
                                'Forgot',
                                Icons.close_rounded,
                                Colors.red[100]!,
                                Colors.red[700]!,
                                () {
                                  widget.onResult(false);
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildActionButton(
                                context,
                                'Got it',
                                Icons.check_rounded,
                                Colors.green[100]!,
                                Colors.green[800]!,
                                () {
                                  // XP berish (masalan 10 XP)
                                  context.read<IsarService>().addXP(10);
                                  
                                  widget.onResult(true);
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, Color bgColor, Color textColor, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: bgColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
