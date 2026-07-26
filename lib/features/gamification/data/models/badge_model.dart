import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ableone_app/features/gamification/domain/entities/badge_entity.dart';

class BadgeModel extends BadgeEntity {
  const BadgeModel({
    required super.id,
    required super.title,
    required super.description,
    required super.icon,
    required super.isUnlocked,
    super.unlockedAt,
  });

  factory BadgeModel.fromMap(Map<String, dynamic> map, String id) {
    final timestamp = map['unlockedAt'] as Timestamp?;
    return BadgeModel(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      icon: map['icon'] as String? ?? 'award',
      isUnlocked: map['isUnlocked'] as bool? ?? false,
      unlockedAt: timestamp?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'icon': icon,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt != null ? Timestamp.fromDate(unlockedAt!) : null,
    };
  }
}
