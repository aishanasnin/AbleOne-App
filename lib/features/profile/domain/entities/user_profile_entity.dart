/// Domain entity representing a user accessibility personalization profile.
class UserProfileEntity {
  /// Unique identifier of the user profile.
  final String id;

  /// Display name of the user.
  final String name;

  /// Role of the user in the system (e.g. Student, Parent, Counselor, Admin).
  final String role;

  /// List of custom support needs (e.g. Visual Support, Hearing Support).
  final List<String> supportNeeds;

  /// Preferred level of explanations (e.g. Beginner, Intermediate, Advanced).
  final String learningLevel;

  /// Selected learning preference type (e.g. Simple explanations, Visual examples).
  final String learningPreference;

  /// Chosen language for user interface controls.
  final String preferredLanguage;

  /// Flag indicating if the user requests active counselor feedback.
  final bool needsCounselor;

  /// Timestamp indicating when this profile configuration was initialized.
  final DateTime createdAt;

  /// Creates a [UserProfileEntity] instance.
  const UserProfileEntity({
    required this.id,
    required this.name,
    required this.role,
    required this.supportNeeds,
    required this.learningLevel,
    required this.learningPreference,
    required this.preferredLanguage,
    required this.needsCounselor,
    required this.createdAt,
  });
}
