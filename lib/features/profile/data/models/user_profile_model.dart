import 'package:ableone_app/features/profile/domain/entities/user_profile_entity.dart';

/// Data model representing a User Personalization Profile record, supporting database mapping and copying.
class UserProfileModel extends UserProfileEntity {
  /// Creates a [UserProfileModel] instance.
  const UserProfileModel({
    required super.id,
    required super.name,
    required super.role,
    required super.supportNeeds,
    required super.learningLevel,
    required super.learningPreference,
    required super.preferredLanguage,
    required super.needsCounselor,
    required super.createdAt,
  });

  /// Factory method to reconstruct a [UserProfileModel] from a key-value map.
  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      role: map['role'] as String? ?? 'Student',
      supportNeeds: List<String>.from(map['supportNeeds'] as List? ?? []),
      learningLevel: map['learningLevel'] as String? ?? 'Beginner',
      learningPreference: map['learningPreference'] as String? ?? 'Simple explanations',
      preferredLanguage: map['preferredLanguage'] as String? ?? 'English',
      needsCounselor: map['needsCounselor'] as bool? ?? false,
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch),
    );
  }

  /// Converts the [UserProfileModel] instance into a serializable key-value map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'supportNeeds': supportNeeds,
      'learningLevel': learningLevel,
      'learningPreference': learningPreference,
      'preferredLanguage': preferredLanguage,
      'needsCounselor': needsCounselor,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Creates a copy of this [UserProfileModel] with replacement field values.
  UserProfileModel copyWith({
    String? id,
    String? name,
    String? role,
    List<String>? supportNeeds,
    String? learningLevel,
    String? learningPreference,
    String? preferredLanguage,
    bool? needsCounselor,
    DateTime? createdAt,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      supportNeeds: supportNeeds ?? this.supportNeeds,
      learningLevel: learningLevel ?? this.learningLevel,
      learningPreference: learningPreference ?? this.learningPreference,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      needsCounselor: needsCounselor ?? this.needsCounselor,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Creates a [UserProfileModel] from a standard [UserProfileEntity].
  factory UserProfileModel.fromEntity(UserProfileEntity entity) {
    return UserProfileModel(
      id: entity.id,
      name: entity.name,
      role: entity.role,
      supportNeeds: entity.supportNeeds,
      learningLevel: entity.learningLevel,
      learningPreference: entity.learningPreference,
      preferredLanguage: entity.preferredLanguage,
      needsCounselor: entity.needsCounselor,
      createdAt: entity.createdAt,
    );
  }
}
