import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:avatar_glow/avatar_glow.dart';

class VoiceAssistantWidget extends StatefulWidget {
  final Function(String text) onInputComplete;
  final bool isModal;
  
  const VoiceAssistantWidget({
    super.key,
    required this.onInputComplete,
    this.isModal = false,
  });

  @override
  State<VoiceAssistantWidget> createState() => _VoiceAssistantWidgetState();
}

class _VoiceAssistantWidgetState extends State<VoiceAssistantWidget>
    with TickerProviderStateMixin {
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  bool _isInitialized = false;
  String _recognizedText = '';
  Timer? _silenceTimer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _silenceTimer?.cancel();
    _pulseController.dispose();
    _speechToText.stop();
    super.dispose();
  }

  Future<void> _initializeSpeech() async {
    try {
      bool available = await _speechToText.initialize(
        onError: (error) => _handleError(error.errorMsg),
        onStatus: (status) => _handleStatus(status),
      );
      
      if (available) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Speech initialization error: $e');
    }
  }

  void _handleError(String error) {
    debugPrint('Speech error: $error');
    setState(() {
      _isListening = false;
    });
    _pulseController.stop();
    _pulseController.reset();
    HapticFeedback.lightImpact();
  }

  void _handleStatus(String status) {
    debugPrint('Speech status: $status');
    
    if (status == 'done') {
      _stopListening();
    }
  }

  void _startListening() async {
    if (!_isInitialized) {
      await _initializeSpeech();
      if (!_isInitialized) return;
    }

    setState(() {
      _isListening = true;
      _recognizedText = '';
    });

    _pulseController.repeat(reverse: true);
    HapticFeedback.mediumImpact(); // Haptic feedback on start

    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _recognizedText = result.recognizedWords;
        });

        // Reset silence timer on new speech
        _silenceTimer?.cancel();
        _silenceTimer = Timer(const Duration(seconds: 2), () {
          _stopListening();
        });
      },
      listenFor: const Duration(seconds: 30), // Max listening duration
      pauseFor: const Duration(seconds: 2),   // Pause duration
      listenOptions: SpeechListenOptions(
        cancelOnError: true,
        partialResults: true,
        listenMode: ListenMode.confirmation,
        autoPunctuation: true,
      ),
    );
  }

  void _stopListening() async {
    _silenceTimer?.cancel();
    _pulseController.stop();
    _pulseController.reset();

    await _speechToText.stop();

    setState(() {
      _isListening = false;
    });

    HapticFeedback.lightImpact(); // Haptic feedback on stop

    // Only process if we have actual text
    if (_recognizedText.isNotEmpty && _recognizedText.trim().isNotEmpty) {
      // This is where we send the 'text' variable to the AI (Gemini/OpenAI) or add it to the Task List.
      widget.onInputComplete(_recognizedText.trim());
      
      // Clear text after processing
      setState(() {
        _recognizedText = '';
      });
    }
  }

  void _toggleListening() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isModal) {
      return _buildModalContent();
    } else {
      return _buildBottomWidget();
    }
  }

  Widget _buildBottomWidget() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Real-time text display
          if (_recognizedText.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _recognizedText,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 16,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          
          // Microphone button with glow
          GestureDetector(
            onTap: _toggleListening,
            child: AvatarGlow(
              glowColor: _isListening 
                  ? Colors.cyan.withValues(alpha: 0.8)
                  : Colors.blue.withValues(alpha: 0.3),
              duration: const Duration(milliseconds: 2000),
              repeat: _isListening,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isListening
                        ? [Colors.cyan, Colors.blue]
                        : [Colors.grey.withValues(alpha: 0.3), Colors.grey.withValues(alpha: 0.5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: _isListening
                      ? [
                          BoxShadow(
                            color: Colors.cyan.withValues(alpha: 0.5),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Status text
          Text(
            _isListening ? 'Listening...' : 'Tap to speak',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalContent() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          Text(
            'Voice Input',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.headlineLarge?.color,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Real-time text display
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.withValues(alpha: 0.2),
                ),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _recognizedText.isNotEmpty 
                      ? _recognizedText 
                      : 'Start speaking to see your text here...',
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.5,
                    color: _recognizedText.isNotEmpty
                        ? Theme.of(context).textTheme.bodyLarge?.color
                        : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Microphone button
          GestureDetector(
            onTap: _toggleListening,
            child: AvatarGlow(
              glowColor: _isListening 
                  ? Colors.cyan.withValues(alpha: 0.8)
                  : Colors.blue.withValues(alpha: 0.3),
              duration: const Duration(milliseconds: 2000),
              repeat: _isListening,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isListening
                        ? [Colors.cyan, Colors.blue]
                        : [Colors.grey.withValues(alpha: 0.3), Colors.grey.withValues(alpha: 0.5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: _isListening
                      ? [
                          BoxShadow(
                            color: Colors.cyan.withValues(alpha: 0.5),
                            blurRadius: 30,
                            spreadRadius: 3,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Status text
          Text(
            _isListening ? 'Listening... Tap to stop' : 'Tap to start speaking',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// Usage Example:
/*
// In your screen widget:
void _handleVoiceInput(String text) {
  // This is where we send the 'text' variable to the AI (Gemini/OpenAI) or add it to the Task List.
  print('Voice input: $text');
  // You can now send this to your AI service or add to task list
}

// For bottom widget:
VoiceAssistantWidget(
  onInputComplete: _handleVoiceInput,
)

// For modal:
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) => VoiceAssistantWidget(
    onInputComplete: _handleVoiceInput,
    isModal: true,
  ),
);
*/
