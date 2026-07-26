import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ableone_app/features/gamification/domain/entities/streak_entity.dart';

class StreakModel extends StreakEntity {
  const StreakModel({
    required super.currentStreak,
    required super.longestStreak,
    required super.lastActiveDate,
    required super.freezeTokens,
  });

  factory StreakModel.fromMap(Map<String, dynamic> map) {
    final timestamp = map['lastActiveDate'] as Timestamp?;
    return StreakModel(
      currentStreak: (map['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (map['longestStreak'] as num?)?.toInt() ?? 0,
      lastActiveDate: timestamp?.toDate() ?? DateTime.now(),
      freezeTokens: (map['freezeTokens'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActiveDate': Timestamp.fromDate(lastActiveDate),
      'freezeTokens': freezeTokens,
    };
  }
}
