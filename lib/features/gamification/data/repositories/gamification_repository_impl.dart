import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ableone_app/features/gamification/domain/entities/xp_entity.dart';
import 'package:ableone_app/features/gamification/domain/entities/badge_entity.dart';
import 'package:ableone_app/features/gamification/domain/entities/streak_entity.dart';
import 'package:ableone_app/features/gamification/domain/repositories/gamification_repository.dart';
import 'package:ableone_app/features/gamification/data/models/xp_model.dart';
import 'package:ableone_app/features/gamification/data/models/badge_model.dart';
import 'package:ableone_app/features/gamification/data/models/streak_model.dart';
import 'package:ableone_app/core/services/firebase_service.dart';

class GamificationRepositoryImpl implements GamificationRepository {
  final FirebaseFirestore _firestore;

  GamificationRepositoryImpl(this._firestore);

  DocumentReference<Map<String, dynamic>> _xpDoc(String userId) =>
      _firestore.collection('users').doc(userId).collection('gamification').doc('xp');

  DocumentReference<Map<String, dynamic>> _streakDoc(String userId) =>
      _firestore.collection('users').doc(userId).collection('gamification').doc('streak');

  CollectionReference<Map<String, dynamic>> _badgesCol(String userId) =>
      _firestore.collection('users').doc(userId).collection('gamification').doc('badges_list').collection('items');

  @override
  Future<XPEntity> getXPStats(String userId) async {
    try {
      final doc = await _xpDoc(userId).get();
      if (doc.exists && doc.data() != null) {
        return XPModel.fromMap(doc.data()!);
      }
      // Seed default
      final defaultStats = const XPModel(
        currentXP: 240,
        level: 3,
        nextLevelXP: 400,
        dailyGoalXP: 50,
        todayXP: 30,
      );
      await _xpDoc(userId).set(defaultStats.toMap());
      return defaultStats;
    } catch (e) {
      throw Exception('Failed to get XP: $e');
    }
  }

  @override
  Future<StreakEntity> getStreak(String userId) async {
    try {
      final doc = await _streakDoc(userId).get();
      if (doc.exists && doc.data() != null) {
        return StreakModel.fromMap(doc.data()!);
      }
      // Seed default
      final defaultStreak = StreakModel(
        currentStreak: 5,
        longestStreak: 12,
        lastActiveDate: DateTime.now(),
        freezeTokens: 1,
      );
      await _streakDoc(userId).set(defaultStreak.toMap());
      return defaultStreak;
    } catch (e) {
      throw Exception('Failed to get Streak: $e');
    }
  }

  @override
  Future<List<BadgeEntity>> getBadges(String userId) async {
    try {
      final col = await _badgesCol(userId).get();
      if (col.docs.isNotEmpty) {
        return col.docs.map((doc) => BadgeModel.fromMap(doc.data(), doc.id)).toList();
      }

      // Seed default set of badges
      final defaultBadges = [
        const BadgeModel(
          id: 'b1',
          title: 'First Step',
          description: 'Completed your first lesson sound guide',
          icon: 'school_rounded',
          isUnlocked: true,
        ),
        const BadgeModel(
          id: 'b2',
          title: 'Conversationalist',
          description: 'Asked your first question to the AI tutor',
          icon: 'chat_rounded',
          isUnlocked: true,
        ),
        const BadgeModel(
          id: 'b3',
          title: 'Streak Star',
          description: 'Achieve a learning streak of 7 days',
          icon: 'star_rounded',
          isUnlocked: false,
        ),
        const BadgeModel(
          id: 'b4',
          title: 'XP Scholar',
          description: 'Reach 500 total XP points',
          icon: 'psychology_rounded',
          isUnlocked: false,
        ),
      ];

      for (final badge in defaultBadges) {
        await _badgesCol(userId).doc(badge.id).set(badge.toMap());
      }
      return defaultBadges;
    } catch (e) {
      throw Exception('Failed to get Badges: $e');
    }
  }

  @override
  Future<void> addXP(String userId, int amount) async {
    try {
      final current = await getXPStats(userId);
      var newXP = current.currentXP + amount;
      var newToday = current.todayXP + amount;
      var newLevel = current.level;
      var nextThreshold = current.nextLevelXP;

      if (newXP >= nextThreshold) {
        newLevel++;
        newXP = newXP - nextThreshold;
        nextThreshold = (nextThreshold * 1.5).toInt();
      }

      await _xpDoc(userId).update({
        'currentXP': newXP,
        'todayXP': newToday,
        'level': newLevel,
        'nextLevelXP': nextThreshold,
      });
    } catch (e) {
      throw Exception('Failed to add XP: $e');
    }
  }

  @override
  Future<void> updateStreak(String userId) async {
    try {
      final current = await getStreak(userId);
      final newStreak = current.currentStreak + 1;
      final newLongest = newStreak > current.longestStreak ? newStreak : current.longestStreak;

      await _streakDoc(userId).update({
        'currentStreak': newStreak,
        'longestStreak': newLongest,
        'lastActiveDate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update streak: $e');
    }
  }

  @override
  Future<void> unlockBadge(String userId, String badgeId) async {
    try {
      await _badgesCol(userId).doc(badgeId).update({
        'isUnlocked': true,
        'unlockedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to unlock badge: $e');
    }
  }
}

// Riverpod Providers
final gamificationRepositoryProvider = Provider<GamificationRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return GamificationRepositoryImpl(firestore);
});

final xpStatsProvider = FutureProvider.family<XPEntity, String>((ref, userId) {
  return ref.watch(gamificationRepositoryProvider).getXPStats(userId);
});

final badgesProvider = FutureProvider.family<List<BadgeEntity>, String>((ref, userId) {
  return ref.watch(gamificationRepositoryProvider).getBadges(userId);
});

final streakProvider = FutureProvider.family<StreakEntity, String>((ref, userId) {
  return ref.watch(gamificationRepositoryProvider).getStreak(userId);
});
