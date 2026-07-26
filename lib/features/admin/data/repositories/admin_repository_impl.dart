import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ableone_app/features/admin/domain/entities/admin_stats_entity.dart';
import 'package:ableone_app/features/admin/domain/entities/course_management_entity.dart';
import 'package:ableone_app/features/admin/domain/repositories/admin_repository.dart';
import 'package:ableone_app/features/admin/data/datasources/fake_admin_data_source.dart';

class AdminRepositoryImpl implements AdminRepository {
  final FakeAdminDataSource _dataSource;

  AdminRepositoryImpl({FakeAdminDataSource? dataSource})
      : _dataSource = dataSource ?? FakeAdminDataSource();

  @override
  Future<AdminStatsEntity> getAdminStats() {
    return _dataSource.fetchAdminStats();
  }

  @override
  Future<List<CourseManagementEntity>> getManagedCourses() {
    return _dataSource.fetchManagedCourses();
  }

  @override
  Future<List<Map<String, dynamic>>> getUsersList() {
    return _dataSource.fetchUsersList();
  }
}

// Riverpod Providers
final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepositoryImpl();
});

final adminStatsProvider = FutureProvider<AdminStatsEntity>((ref) {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getAdminStats();
});

final adminCoursesProvider = FutureProvider<List<CourseManagementEntity>>((ref) {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getManagedCourses();
});

final adminUsersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getUsersList();
});
