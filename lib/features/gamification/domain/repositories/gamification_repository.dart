import 'package:ableone_app/features/gamification/domain/entities/xp_entity.dart';
import 'package:ableone_app/features/gamification/domain/entities/badge_entity.dart';
import 'package:ableone_app/features/gamification/domain/entities/streak_entity.dart';

abstract class GamificationRepository {
  Future<XPEntity> getXPStats(String userId);
  Future<List<BadgeEntity>> getBadges(String userId);
  Future<StreakEntity> getStreak(String userId);
  Future<void> addXP(String userId, int amount);
  Future<void> updateStreak(String userId);
  Future<void> unlockBadge(String userId, String badgeId);
}
