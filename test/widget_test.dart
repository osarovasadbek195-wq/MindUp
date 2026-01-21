// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_up/main.dart';
import 'package:mind_up/data/services/isar_service.dart';
import 'package:mind_up/core/services/voice_service.dart';
import 'package:mind_up/data/models/task.dart';
import 'package:mockito/mockito.dart';

class MockIsarService extends Mock implements IsarService {
  @override
  Future<List<Task>> getTasksForDate(DateTime? date) {
    return super.noSuchMethod(
      Invocation.method(#getTasksForDate, [date]),
      returnValue: Future.value(<Task>[]),
      returnValueForMissingStub: Future.value(<Task>[]),
    );
  }
}

class MockVoiceService extends Mock implements VoiceService {
  @override
  Future<bool> init() {
    return super.noSuchMethod(
      Invocation.method(#init, []),
      returnValue: Future.value(true),
      returnValueForMissingStub: Future.value(true),
    );
  }
}

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Mock servislarni yaratish
    final mockIsarService = MockIsarService();
    final mockVoiceService = MockVoiceService();

    // Stubbing
    when(mockIsarService.getTasksForDate(any))
        .thenAnswer((_) async => []);
    when(mockVoiceService.init())
        .thenAnswer((_) async => true);

    // Appni qurish
    await tester.pumpWidget(MindUpApp(
      isarService: mockIsarService,
      voiceService: mockVoiceService,
    ));

    // Kuting (Splash yoki loading uchun)
    await tester.pumpAndSettle();

    // Asosiy ekranda "MindUp Learning" sarlavhasi borligini tekshirish
    expect(find.text('MindUp Learning'), findsOneWidget);
    
    // Calendar widget borligini tekshirish
    expect(find.byIcon(Icons.today), findsOneWidget);
  });
}
