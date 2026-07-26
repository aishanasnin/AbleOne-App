/// Domain entity representing the accessibility and preference context provided to the AI tutor.
class AIUserContext {
  /// The student's learning and explanation level.
  final String learningLevel;

  /// The active accessibility support needs.
  final List<String> supportNeeds;

  /// The preferred interface/explanation language.
  final String preferredLanguage;

  /// The preferred style of explanation presentation.
  final String learningPreference;

  /// Creates an [AIUserContext] instance.
  const AIUserContext({
    required this.learningLevel,
    required this.supportNeeds,
    required this.preferredLanguage,
    required this.learningPreference,
  });
}
