import '../data/models/task.dart';

class CascadeEngine {
  /// Vazifa natijasiga qarab keyingi vaqtni hisoblaydi
  /// [isSuccess] - Agar foydalanuvchi to'g'ri topsa true, xato qilsa false
  static Task processReview(Task task, bool isSuccess) {
    if (!isSuccess) {
      // Xato qilsa, orqaga qaytaramiz (Jazo tizimi)
      // Agar "Master" bo'lsa ham, xato qilsa "Review 2" ga tushadi (misol uchun)
      task.stage = TaskStage.learning;
      task.mistakeCount++;
      // Ertaga qayta so'raymiz
      task.nextReviewDate = DateTime.now().add(const Duration(days: 1));
    } else {
      // To'g'ri topsa, keyingi bosqichga o'tkazamiz
      task.reviewCount++;
      
      switch (task.stage) {
        case TaskStage.learning:
          task.stage = TaskStage.review1;
          task.nextReviewDate = DateTime.now().add(const Duration(days: 3));
          break;
        case TaskStage.review1:
          task.stage = TaskStage.review2;
          task.nextReviewDate = DateTime.now().add(const Duration(days: 7));
          break;
        case TaskStage.review2:
          task.stage = TaskStage.review3;
          task.nextReviewDate = DateTime.now().add(const Duration(days: 14));
          break;
        case TaskStage.review3:
          task.stage = TaskStage.solidify;
          task.nextReviewDate = DateTime.now().add(const Duration(days: 30));
          break;
        case TaskStage.solidify:
          task.stage = TaskStage.master;
          task.nextReviewDate = DateTime.now().add(const Duration(days: 90));
          break;
        case TaskStage.master:
          // Master bo'lgandan keyin har 6 oyda bir eslatib turamiz
          task.nextReviewDate = DateTime.now().add(const Duration(days: 180));
          break;
      }
    }
    return task;
  }
  
  /// Bugungi kun uchun rejalashtirilgan vazifalarni saralaydi
  static List<Task> getTasksForToday(List<Task> allTasks) {
    final now = DateTime.now();
    // Bugun yoki o'tib ketgan barcha vazifalar
    return allTasks.where((t) => t.nextReviewDate.isBefore(now) || 
        (t.nextReviewDate.year == now.year && 
         t.nextReviewDate.month == now.month && 
         t.nextReviewDate.day == now.day)).toList();
  }
}
