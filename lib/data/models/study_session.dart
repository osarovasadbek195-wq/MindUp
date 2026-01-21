import 'package:isar/isar.dart';

part 'study_session.g.dart';

@collection
class StudySession {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime date;

  int durationSeconds = 0; // Qancha vaqt shug'ullangani
  
  int tasksCompleted = 0;
  
  List<String> subjectsCovered = []; // Qaysi mavzular o'qilgani
}
