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
  late String subject; // Mavzu (masalan: "English", "Math")

  @enumerated
  TaskStage stage = TaskStage.learning; // Hozirgi bosqich

  // Statistikalar
  int reviewCount = 0;
  int mistakeCount = 0;
}

enum TaskStage {
  learning, // 1-kun (0)
  review1,  // 3-kun (1)
  review2,  // 1-hafta (2)
  review3,  // 2-hafta (3)
  solidify, // 1-oy (4)
  master    // 3-oy (5)
}
