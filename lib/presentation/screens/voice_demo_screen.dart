import 'package:flutter/material.dart';
import '../widgets/voice_assistant_widget.dart';

class VoiceDemoScreen extends StatefulWidget {
  const VoiceDemoScreen({super.key});

  @override
  State<VoiceDemoScreen> createState() => _VoiceDemoScreenState();
}

class _VoiceDemoScreenState extends State<VoiceDemoScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<String> _voiceInputs = [];

  void _handleVoiceInput(String text) {
    // This is where we send the 'text' variable to the AI (Gemini/OpenAI) or add it to the Task List.
    setState(() {
      _voiceInputs.add(text);
      _textController.text = text;
    });
    
    // You can also trigger AI processing here
    _processWithAI(text);
    
    // Show success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Voice input received: "$text"'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _processWithAI(String text) {
    // Example: Send to your AI service
    // final homeBloc = context.read<HomeBloc>();
    // homeBloc.add(ProcessVoiceInput(text));
    
    // For demo, we'll just show a debug message
    debugPrint('Processing voice input with AI: $text');
  }

  void _showVoiceModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VoiceAssistantWidget(
        onInputComplete: _handleVoiceInput,
        isModal: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Input Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Instructions
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Voice Input Instructions:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                    Text(
                      '• Tap the microphone to start speaking\n'
                      '• Speak clearly and naturally\n'
                      '• The app will auto-stop after 2 seconds of silence\n'
                      '• Tap again to stop manually\n'
                      '• Your speech will be converted to text and processed',
                      style: TextStyle(fontSize: 14),
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Current input display
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Voice Input Text',
                hintText: 'Your speech will appear here...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 24),
            
            // Voice history
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Voice Input History:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _voiceInputs.isEmpty
                        ? const Center(
                            child: Text(
                              'No voice inputs yet.\nTry speaking!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _voiceInputs.length,
                            itemBuilder: (context, index) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Text('${index + 1}'),
                                  ),
                                  title: Text(_voiceInputs[index]),
                                  subtitle: Text('Input #${index + 1}'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      setState(() {
                                        _voiceInputs.removeAt(index);
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      
      // Bottom voice widget
      bottomNavigationBar: VoiceAssistantWidget(
        onInputComplete: _handleVoiceInput,
      ),
      
      // Floating action button for modal
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showVoiceModal,
        icon: const Icon(Icons.mic),
        label: const Text('Voice Modal'),
        backgroundColor: Colors.cyan,
        foregroundColor: Colors.white,
      ),
    );
  }
}
