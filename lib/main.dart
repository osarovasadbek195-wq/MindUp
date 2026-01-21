import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/services/isar_service.dart';
import 'data/services/openai_service.dart';
import 'data/services/gemini_service.dart';
import 'core/services/voice_service.dart';
import 'core/services/notification_service.dart';
import 'core/constants/api_constants.dart';
import 'presentation/blocs/home_bloc.dart';
import 'presentation/screens/voice_demo_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Servislarni ishga tushurish
  final isarService = IsarService();
  final voiceService = VoiceService();
  final notificationService = NotificationService();
  
  // Asinxron initlar
  await voiceService.init();
  await notificationService.init();

  runApp(MindUpApp(
    isarService: isarService,
    voiceService: voiceService,
  ));
}

class MindUpApp extends StatelessWidget {
  final IsarService isarService;
  final VoiceService voiceService;

  const MindUpApp({
    super.key, 
    required this.isarService, 
    required this.voiceService
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: isarService),
        RepositoryProvider.value(value: voiceService),
        RepositoryProvider(create: (context) => OpenAIService(apiKey: ApiConstants.openAIApiKey)),
        RepositoryProvider(create: (context) => GeminiService(apiKey: ApiConstants.geminiApiKey)),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => HomeBloc(
              isarService: isarService,
              openAIService: context.read<OpenAIService>(),
              geminiService: context.read<GeminiService>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'MindUp',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF3B82F6), // HyperOS Blue
              brightness: Brightness.light,
              surface: const Color(0xFFF8F9FA),
            ),
            useMaterial3: true,
            // HyperOS Style Card
            cardTheme: CardThemeData(
              elevation: 0,
              color: Colors.white.withValues(alpha: 0.8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24), // More rounded
                side: BorderSide(color: Colors.white.withValues(alpha: 0.5), width: 1),
              ),
            ),
            // HyperOS Style Dialog
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              backgroundColor: Colors.white.withValues(alpha: 0.95),
              elevation: 10,
            ),
            // HyperOS Style Buttons
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
               elevation: 4,
            ),
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              titleTextStyle: TextStyle(
                color: Colors.black87, 
                fontSize: 22, 
                fontWeight: FontWeight.w600
              ),
            ),
          ),
          home: const VoiceDemoScreen(),
        ),
      ),
    );
  }
}
