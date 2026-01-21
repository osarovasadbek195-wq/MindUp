import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/task.dart';
import '../models/study_session.dart';
import '../models/user_profile.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [TaskSchema, StudySessionSchema, UserProfileSchema], 
        directory: dir.path,
        inspector: true,
      );
    }
    return Future.value(Isar.getInstance());
  }

  // --- Task CRUD ---

  Future<void> saveTask(Task task) async {
    final isar = await db;
    isar.writeTxnSync(() => isar.tasks.putSync(task));
  }
  
  Future<void> saveTasks(List<Task> tasks) async {
    final isar = await db;
    isar.writeTxnSync(() => isar.tasks.putAllSync(tasks));
  }

  Future<List<Task>> getAllTasks() async {
    final isar = await db;
    return await isar.tasks.where().findAll();
  }
  
  Stream<List<Task>> listenToTasks() async* {
    final isar = await db;
    yield* isar.tasks.where().watch(fireImmediately: true);
  }

  Future<List<Task>> getTasksForDate(DateTime date) async {
    final isar = await db;
    // Kun boshidan kun oxirigacha bo'lgan oraliq
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return await isar.tasks
        .filter()
        .nextReviewDateBetween(startOfDay, endOfDay)
        .findAll();
  }

  // --- Session CRUD ---
  
  Future<void> saveSession(StudySession session) async {
    final isar = await db;
    isar.writeTxnSync(() => isar.studySessions.putSync(session));
  }

  // --- User Profile & Gamification ---

  Future<UserProfile> getUserProfile() async {
    final isar = await db;
    final profile = await isar.userProfiles.where().findFirst();
    if (profile == null) {
      final newProfile = UserProfile();
      isar.writeTxnSync(() => isar.userProfiles.putSync(newProfile));
      return newProfile;
    }
    return profile;
  }

  Future<void> addXP(int amount) async {
    final isar = await db;
    final profile = await getUserProfile();
    profile.totalXP += amount;
    
    // Streak logic check
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (profile.lastStudyDate != null) {
      final lastDate = profile.lastStudyDate!;
      final lastStudyDay = DateTime(lastDate.year, lastDate.month, lastDate.day);
      
      final difference = today.difference(lastStudyDay).inDays;
      
      if (difference == 1) {
        // Streak continues
        profile.currentStreak += 1;
      } else if (difference > 1) {
        // Streak broken
        profile.currentStreak = 1;
      }
      // If difference == 0, already studied today, do nothing to streak
    } else {
      // First time
      profile.currentStreak = 1;
    }
    
    profile.lastStudyDate = now;
    
    isar.writeTxnSync(() => isar.userProfiles.putSync(profile));
  }
  
  Stream<UserProfile?> listenToProfile() async* {
    final isar = await db;
    yield* isar.userProfiles.where().watch(fireImmediately: true).map((event) => event.firstOrNull);
  }
}
