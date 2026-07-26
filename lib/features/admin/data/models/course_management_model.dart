import 'package:ableone_app/features/admin/domain/entities/course_management_entity.dart';

class CourseManagementModel extends CourseManagementEntity {
  const CourseManagementModel({
    required super.courseId,
    required super.title,
    required super.category,
    required super.difficulty,
    required super.enrolledUsers,
    required super.completionRate,
  });

  factory CourseManagementModel.fromJson(Map<String, dynamic> json) {
    return CourseManagementModel(
      courseId: json['courseId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? '',
      enrolledUsers: json['enrolledUsers'] as int? ?? 0,
      completionRate: (json['completionRate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'title': title,
      'category': category,
      'difficulty': difficulty,
      'enrolledUsers': enrolledUsers,
      'completionRate': completionRate,
    };
  }
}
