import 'package:isar/isar.dart';

part 'user_profile.g.dart';

@collection
class UserProfile {
  Id id = Isar.autoIncrement;

  String name = '';
  
  String email = '';
  
  String bio = '';
  
  DateTime? updatedAt;

  int totalXP = 0;

  int currentStreak = 0;

  DateTime? lastStudyDate;

  // Level ni hisoblash (har 100 XP = 1 level)
  int get level => (totalXP / 100).floor() + 1;
  
  // Keyingi levelga qancha qoldi
  int get xpForNextLevel => 100 - (totalXP % 100);
}
