class AdminStatsEntity {
  final int totalUsers;
  final int totalStudents;
  final int totalParents;
  final int totalCounselors;
  final int activeUsers;
  final int lessonsCompleted;
  final int aiInteractions;

  const AdminStatsEntity({
    required this.totalUsers,
    required this.totalStudents,
    required this.totalParents,
    required this.totalCounselors,
    required this.activeUsers,
    required this.lessonsCompleted,
    required this.aiInteractions,
  });
}
