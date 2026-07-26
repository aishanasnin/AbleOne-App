class StreakEntity {
  final int currentStreak;
  final int longestStreak;
  final DateTime lastActiveDate;
  final int freezeTokens;

  const StreakEntity({
    required this.currentStreak,
    required this.longestStreak,
    required this.lastActiveDate,
    required this.freezeTokens,
  });
}
