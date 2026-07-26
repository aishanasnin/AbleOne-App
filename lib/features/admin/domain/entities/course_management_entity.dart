class CourseManagementEntity {
  final String courseId;
  final String title;
  final String category;
  final String difficulty;
  final int enrolledUsers;
  final double completionRate;

  const CourseManagementEntity({
    required this.courseId,
    required this.title,
    required this.category,
    required this.difficulty,
    required this.enrolledUsers,
    required this.completionRate,
  });
}
