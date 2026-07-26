class LearningProfileEntity {
  final String userId;
  final String learningStyle;
  final List<String> strengths;
  final List<String> weaknesses;
  final String preferredDifficulty;

  const LearningProfileEntity({
    required this.userId,
    required this.learningStyle,
    required this.strengths,
    required this.weaknesses,
    required this.preferredDifficulty,
  });
}
