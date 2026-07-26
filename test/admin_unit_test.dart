import 'package:flutter_test/flutter_test.dart';
import 'package:ableone_app/features/admin/data/models/admin_stats_model.dart';
import 'package:ableone_app/features/admin/data/models/course_management_model.dart';
import 'package:ableone_app/features/admin/data/datasources/fake_admin_data_source.dart';

void main() {
  group('Admin Clean Architecture Data Layer Unit Tests', () {
    test('AdminStatsModel.fromJson should correctly deserialize values', () {
      final json = {
        'totalUsers': 150,
        'totalStudents': 70,
        'totalParents': 60,
        'totalCounselors': 20,
        'activeUsers': 100,
        'lessonsCompleted': 450,
        'aiInteractions': 900,
      };

      final model = AdminStatsModel.fromJson(json);

      expect(model.totalUsers, 150);
      expect(model.totalStudents, 70);
      expect(model.totalParents, 60);
      expect(model.totalCounselors, 20);
      expect(model.activeUsers, 100);
      expect(model.lessonsCompleted, 450);
      expect(model.aiInteractions, 900);
    });

    test('CourseManagementModel.fromJson should correctly deserialize values', () {
      final json = {
        'courseId': 'c1',
        'title': 'Test Course',
        'category': 'Testing',
        'difficulty': 'Intermediate',
        'enrolledUsers': 15,
        'completionRate': 75.5,
      };

      final model = CourseManagementModel.fromJson(json);

      expect(model.courseId, 'c1');
      expect(model.title, 'Test Course');
      expect(model.category, 'Testing');
      expect(model.difficulty, 'Intermediate');
      expect(model.enrolledUsers, 15);
      expect(model.completionRate, 75.5);
    });

    test('FakeAdminDataSource should fetch valid dummy admin stats', () async {
      final dataSource = FakeAdminDataSource();
      final stats = await dataSource.fetchAdminStats();

      expect(stats.totalUsers, greaterThan(0));
      expect(stats.activeUsers, greaterThan(0));
      expect(stats.lessonsCompleted, greaterThan(0));
    });

    test('FakeAdminDataSource should fetch list of managed courses', () async {
      final dataSource = FakeAdminDataSource();
      final courses = await dataSource.fetchManagedCourses();

      expect(courses, isNotEmpty);
      expect(courses.first.courseId, isNotEmpty);
      expect(courses.first.title, isNotEmpty);
    });
  });
}
