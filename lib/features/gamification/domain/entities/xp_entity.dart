class XPEntity {
  final int currentXP;
  final int level;
  final int nextLevelXP;
  final int dailyGoalXP;
  final int todayXP;

  const XPEntity({
    required this.currentXP,
    required this.level,
    required this.nextLevelXP,
    required this.dailyGoalXP,
    required this.todayXP,
  });
}
