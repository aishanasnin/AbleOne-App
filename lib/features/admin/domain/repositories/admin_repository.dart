import 'package:ableone_app/features/admin/domain/entities/admin_stats_entity.dart';
import 'package:ableone_app/features/admin/domain/entities/course_management_entity.dart';

abstract class AdminRepository {
  Future<AdminStatsEntity> getAdminStats();
  Future<List<CourseManagementEntity>> getManagedCourses();
  Future<List<Map<String, dynamic>>> getUsersList();
}
