import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../utils/logger.dart';

class VoiceService {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  
  bool _isEnabled = false;

  /// Ovozli xizmatlarni ishga tushurish
  Future<bool> init() async {
    _isEnabled = await _speechToText.initialize(
      onError: (val) => AppLogger.error('Voice Error: $val', error: val),
      onStatus: (val) => AppLogger.debug('Voice Status: $val'),
    );
    
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    AppLogger.info('Voice service initialized. Enabled: $_isEnabled');
    return _isEnabled;
  }

  /// Gapirishni boshlash (Tinglash)
  Future<void> startListening({required Function(String) onResult}) async {
    if (!_isEnabled) return;

    await _speechToText.listen(
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
        }
      },
      localeId: 'en_US', // Hozircha ingliz tili, keyin o'zbek tiliga moslash mumkin
      listenOptions: SpeechListenOptions(
        cancelOnError: true,
        partialResults: false,
      ),
    );
  }

  /// Tinglashni to'xtatish
  Future<void> stopListening() async {
    await _speechToText.stop();
  }

  /// Matnni ovoz chiqarib o'qish (Text-to-Speech)
  Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }
}
