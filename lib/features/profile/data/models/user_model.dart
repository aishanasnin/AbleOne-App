import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ableone_app/features/profile/domain/entities/user_entity.dart';

/// Data model representing a user profile that extends [UserEntity] and
/// supports JSON/Firestore mapping and instance copying.
class UserModel extends UserEntity {
  /// Creates a [UserModel] instance.
  const UserModel({
    required super.uid,
    required super.name,
    required super.email,
    required super.role,
    super.profileImage,
    super.phone,
    required super.language,
    super.disabilityType,
    required super.createdAt,
    required super.updatedAt,
    required super.isActive,
  });

  /// Factory method to reconstruct a [UserModel] from a key-value map.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDateTime(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        return DateTime.parse(value);
      } else {
        return DateTime.now();
      }
    }

    return UserModel(
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: map['role'] as String? ?? 'student',
      profileImage: map['profileImage'] as String?,
      phone: map['phone'] as String?,
      language: map['language'] as String? ?? 'English',
      disabilityType: map['disabilityType'] as String?,
      createdAt: parseDateTime(map['createdAt']),
      updatedAt: parseDateTime(map['updatedAt']),
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  /// Converts the [UserModel] instance into a serializable key-value map.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'profileImage': profileImage ?? '',
      'phone': phone ?? '',
      'language': language,
      'disabilityType': disabilityType ?? '',
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
    };
  }

  /// Creates a copy of this [UserModel] with replacement field values.
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    String? profileImage,
    String? phone,
    String? language,
    String? disabilityType,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      phone: phone ?? this.phone,
      language: language ?? this.language,
      disabilityType: disabilityType ?? this.disabilityType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Creates a [UserModel] from a standard [UserEntity].
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      name: entity.name,
      email: entity.email,
      role: entity.role,
      profileImage: entity.profileImage,
      phone: entity.phone,
      language: entity.language,
      disabilityType: entity.disabilityType,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isActive: entity.isActive,
    );
  }
}
