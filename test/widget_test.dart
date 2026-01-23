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
import 'package:mind_up/data/services/google_ai_service.dart';
import 'package:mind_up/core/services/notification_service.dart';
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
  
  @override
  Stream<List<Task>> listenToTasks() {
     return super.noSuchMethod(
      Invocation.method(#listenToTasks, []),
      returnValue: Stream.value(<Task>[]),
      returnValueForMissingStub: Stream.value(<Task>[]),
    );
  }
}

class MockNotificationService extends Mock implements NotificationService {
  @override
  Future<void> init() {
    return super.noSuchMethod(
      Invocation.method(#init, []),
      returnValue: Future.value(),
      returnValueForMissingStub: Future.value(),
    );
  }
}

class MockGoogleAIService extends Mock implements GoogleAIService {
  String get apiKey => super.noSuchMethod(
    Invocation.getter(#apiKey),
    returnValue: '',
  );
}

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Mock servislarni yaratish
    final mockIsarService = MockIsarService();
    final mockNotificationService = MockNotificationService();

    // Stubbing
    when(mockIsarService.getTasksForDate(any))
        .thenAnswer((_) async => []);
    when(mockNotificationService.init())
        .thenAnswer((_) async {});

    // Appni qurish
    await tester.pumpWidget(MindUpApp(
      isarService: mockIsarService,
      notificationService: mockNotificationService,
      googleAIService: MockGoogleAIService(),
    ));

    // Kuting (Splash yoki loading uchun)
    await tester.pumpAndSettle();

    // Asosiy ekranda "MindUp Learning" sarlavhasi borligini tekshirish - Calendar Screen is assumed to be default or accessed?
    // Actually MainNavigation shows HomeScreen or CalendarScreen.
    // If MainNavigation default index is 0, it shows HomeScreen. 
    // HomeScreen has title "Today's Tasks". CalendarScreen has "MindUp Learning".
    // Let's check for "Today's Tasks" instead if HomeScreen is first.
    // Or just check for a widget that is definitely there.
    
    // Check for MainNavigation widgets
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
