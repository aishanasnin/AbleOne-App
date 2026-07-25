/// Domain entity representing a user profile in the AbleOne system.
class UserEntity {
  /// Unique identifier of the user (matching Firebase Auth uid).
  final String uid;

  /// Full display name of the user.
  final String name;

  /// Email address of the user.
  final String email;

  /// User access role (student, parent, counselor, admin).
  final String role;

  /// URL string referencing the user's uploaded profile picture.
  final String? profileImage;

  /// Phone number associated with the user's account.
  final String? phone;

  /// Preferred display language for application screens.
  final String language;

  /// Type of disability if user profile role is student.
  final String? disabilityType;

  /// Point in time when the user profile document was generated.
  final DateTime createdAt;

  /// Last modification timestamp of the user profile document.
  final DateTime updatedAt;

  /// Flag indicating if the user's profile is active.
  final bool isActive;

  /// Creates a [UserEntity] instance.
  const UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.profileImage,
    this.phone,
    required this.language,
    this.disabilityType,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });
}
