class RecommendationEntity {
  final String title;
  final String reason;
  final String priority; // High, Medium, Low

  const RecommendationEntity({
    required this.title,
    required this.reason,
    required this.priority,
  });
}
