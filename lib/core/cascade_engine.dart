import 'dart:math';
import '../data/models/task.dart';

class CascadeEngine {
  static final Random _random = Random();
  
  /// Vazifa natijasiga qarab keyingi vaqtni hisoblaydi
  /// [isSuccess] - Agar foydalanuvchi to'g'ri topsa true, xato qilsa false
  static Task processReview(Task task, bool isSuccess) {
    if (!isSuccess) {
      // Xato qilsa, boshidan boshlaymiz (3 soat)
      task.repetitionStep = 0;
      task.mistakeCount++;
      task.stage = TaskStage.learning;
      task.nextReviewDate = DateTime.now().add(const Duration(hours: 3));
    } else {
      // To'g'ri topsa, keyingi bosqichga o'tkazamiz
      task.reviewCount++;
      
      // Cascade Intervals: 0:3h, 1:6h, 2:9h, 3:1d, 4:3d, 5:7d, 6:14d, 7:30d, 8:45d, 9:90d
      if (task.repetitionStep < 9) {
        task.repetitionStep++;
      }
      
      // Update Stage for UI/Badge purposes
      if (task.repetitionStep < 3) {
        task.stage = TaskStage.learning; // 3h, 6h, 9h
      } else if (task.repetitionStep < 6) {
        task.stage = TaskStage.review;   // 1d, 3d, 7d
      } else {
        task.stage = TaskStage.mastered; // 14d, 30d, 45d, 90d
      }

      // Calculate next date based on new step with randomization
      switch (task.repetitionStep) {
        case 0: // Should not happen on success unless logic changes, but fallback
          task.nextReviewDate = DateTime.now().add(const Duration(hours: 3));
          break;
        case 1:
          task.nextReviewDate = DateTime.now().add(Duration(hours: 6 + _random.nextInt(2))); // 6-7 hours
          break;
        case 2:
          task.nextReviewDate = DateTime.now().add(Duration(hours: 9 + _random.nextInt(3))); // 9-11 hours
          break;
        case 3:
          task.nextReviewDate = DateTime.now().add(Duration(hours: 24 + _random.nextInt(6))); // 1-1.25 days
          break;
        case 4:
          task.nextReviewDate = DateTime.now().add(Duration(days: 3 + _random.nextInt(2))); // 3-4 days
          break;
        case 5:
          task.nextReviewDate = DateTime.now().add(Duration(days: 7 + _random.nextInt(3))); // 7-9 days
          break;
        case 6:
          task.nextReviewDate = DateTime.now().add(Duration(days: 14 + _random.nextInt(4))); // 14-17 days
          break;
        case 7:
          task.nextReviewDate = DateTime.now().add(Duration(days: 30 + _random.nextInt(7))); // 30-36 days
          break;
        case 8:
          task.nextReviewDate = DateTime.now().add(Duration(days: 45 + _random.nextInt(10))); // 45-54 days
          break;
        case 9:
          task.nextReviewDate = DateTime.now().add(Duration(days: 90 + _random.nextInt(15))); // 90-104 days
          break;
      }
    }
    
    task.lastReviewedAt = DateTime.now();
    return task;
  }
  
  /// Bugungi kun uchun rejalashtirilgan vazifalarni saralaydi
  static List<Task> getTasksForToday(List<Task> allTasks) {
    final now = DateTime.now();
    return allTasks.where((t) => t.nextReviewDate.isBefore(now)).toList();
  }
}
