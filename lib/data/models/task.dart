import 'package:isar/isar.dart';

part 'task.g.dart';

@collection
class Task {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String title; // So'z yoki savol

  String? description; // Ma'nosi yoki javobi

  @Index()
  late DateTime createdAt;

  @Index()
  late DateTime nextReviewDate; // Keyingi takrorlash vaqti

  @Index()
  late String subject; // Fan nomi

  int repetitionStep = 0; // 0 to 7 corresponding to intervals
  int reviewCount = 0; // Takrorlashlar soni
  int mistakeCount = 0; // Xatolar soni
  
  // Cascade Intervals: 3h, 6h, 9h, 1d, 3d, 7d, 14d, 30d
  DateTime getNextReviewDate() {
    final now = DateTime.now();
    switch (repetitionStep) {
      case 0: return now.add(const Duration(hours: 3));
      case 1: return now.add(const Duration(hours: 6));
      case 2: return now.add(const Duration(hours: 9));
      case 3: return now.add(const Duration(days: 1));
      case 4: return now.add(const Duration(days: 3));
      case 5: return now.add(const Duration(days: 7));
      case 6: return now.add(const Duration(days: 14));
      case 7: return now.add(const Duration(days: 30));
      default: return now.add(const Duration(days: 30)); // Max interval
    }
  }

  @enumerated
  TaskStage stage = TaskStage.learning; // Bosqichi
  
  DateTime? lastReviewedAt; // Oxirgi ko'rib chiqilgan vaqti
  
  // Web uchun kichik ID
  int get webId => hashCode.abs();
}

enum TaskStage {
  learning, // 3h, 6h, 9h
  review,   // 1d, 3d, 7d
  mastered  // 14d, 30d
}
