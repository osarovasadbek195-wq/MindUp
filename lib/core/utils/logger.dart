import 'dart:developer' as developer;

class AppLogger {
  static const String _tag = 'MindUp';
  
  static void debug(String message, {String? tag}) {
    developer.log('🔍 $message', name: tag ?? _tag, level: 500);
  }
  
  static void info(String message, {String? tag}) {
    developer.log('ℹ️ $message', name: tag ?? _tag, level: 800);
  }
  
  static void warning(String message, {String? tag}) {
    developer.log('⚠️ $message', name: tag ?? _tag, level: 900);
  }
  
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    developer.log(
      '❌ $message',
      name: tag ?? _tag,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
