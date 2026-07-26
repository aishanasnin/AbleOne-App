class StudyPlanEntity {
  final DateTime date;
  final List<String> tasks;
  final Map<String, bool> completionStatus;

  const StudyPlanEntity({
    required this.date,
    required this.tasks,
    required this.completionStatus,
  });
}
