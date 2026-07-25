import 'package:ableone_app/features/learning/domain/entities/module_entity.dart';

/// Data model representing a Module record, supporting database mapping and copying.
class ModuleModel extends ModuleEntity {
  /// Creates a [ModuleModel] instance.
  const ModuleModel({
    required super.id,
    required super.courseId,
    required super.title,
    required super.description,
    required super.order,
  });

  /// Factory method to reconstruct a [ModuleModel] from a key-value map.
  factory ModuleModel.fromMap(Map<String, dynamic> map, String docId) {
    return ModuleModel(
      id: docId,
      courseId: map['courseId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      order: map['order'] as int? ?? 0,
    );
  }

  /// Converts the [ModuleModel] instance into a serializable key-value map.
  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'title': title,
      'description': description,
      'order': order,
    };
  }

  /// Creates a copy of this [ModuleModel] with replacement field values.
  ModuleModel copyWith({
    String? id,
    String? courseId,
    String? title,
    String? description,
    int? order,
  }) {
    return ModuleModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      order: order ?? this.order,
    );
  }

  /// Creates a [ModuleModel] from a standard [ModuleEntity].
  factory ModuleModel.fromEntity(ModuleEntity entity) {
    return ModuleModel(
      id: entity.id,
      courseId: entity.courseId,
      title: entity.title,
      description: entity.description,
      order: entity.order,
    );
  }
}
