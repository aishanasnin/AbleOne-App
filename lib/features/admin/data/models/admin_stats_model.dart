import 'package:ableone_app/features/admin/domain/entities/admin_stats_entity.dart';

class AdminStatsModel extends AdminStatsEntity {
  const AdminStatsModel({
    required super.totalUsers,
    required super.totalStudents,
    required super.totalParents,
    required super.totalCounselors,
    required super.activeUsers,
    required super.lessonsCompleted,
    required super.aiInteractions,
  });

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) {
    return AdminStatsModel(
      totalUsers: json['totalUsers'] as int? ?? 0,
      totalStudents: json['totalStudents'] as int? ?? 0,
      totalParents: json['totalParents'] as int? ?? 0,
      totalCounselors: json['totalCounselors'] as int? ?? 0,
      activeUsers: json['activeUsers'] as int? ?? 0,
      lessonsCompleted: json['lessonsCompleted'] as int? ?? 0,
      aiInteractions: json['aiInteractions'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalUsers': totalUsers,
      'totalStudents': totalStudents,
      'totalParents': totalParents,
      'totalCounselors': totalCounselors,
      'activeUsers': activeUsers,
      'lessonsCompleted': lessonsCompleted,
      'aiInteractions': aiInteractions,
    };
  }
}
