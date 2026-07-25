import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ableone_app/core/services/firebase_service.dart';
import 'package:ableone_app/features/learning/domain/entities/course_entity.dart';
import 'package:ableone_app/features/learning/domain/entities/module_entity.dart';
import 'package:ableone_app/features/learning/domain/entities/lesson_entity.dart';
import 'package:ableone_app/features/learning/domain/entities/progress_entity.dart';
import 'package:ableone_app/features/learning/domain/repositories/course_repository.dart';
import 'package:ableone_app/features/learning/data/datasources/course_firestore_datasource.dart';
import 'package:ableone_app/features/learning/data/models/progress_model.dart';

/// Implementation of [CourseRepository] using [CourseFirestoreDatasource].
class CourseRepositoryImpl implements CourseRepository {
  final CourseFirestoreDatasource _datasource;

  /// Creates a [CourseRepositoryImpl] instance.
  CourseRepositoryImpl(this._datasource);

  @override
  Future<List<CourseEntity>> getCourses() async {
    try {
      return await _datasource.getCourses();
    } catch (e) {
      throw Exception('Failed to load courses list: ${e.toString()}');
    }
  }

  @override
  Future<CourseEntity?> getCourseById(String courseId) async {
    try {
      return await _datasource.getCourseById(courseId);
    } catch (e) {
      throw Exception('Failed to load course details: ${e.toString()}');
    }
  }

  @override
  Future<List<ModuleEntity>> getModules(String courseId) async {
    try {
      return await _datasource.getModules(courseId);
    } catch (e) {
      throw Exception('Failed to load modules list: ${e.toString()}');
    }
  }

  @override
  Future<List<LessonEntity>> getLessons(String moduleId) async {
    try {
      return await _datasource.getLessons(moduleId);
    } catch (e) {
      throw Exception('Failed to load lessons list: ${e.toString()}');
    }
  }

  @override
  Future<ProgressEntity?> getProgress(String uid, String courseId) async {
    try {
      return await _datasource.getProgress(uid, courseId);
    } catch (e) {
      throw Exception('Failed to load user course progress: ${e.toString()}');
    }
  }

  @override
  Future<void> saveProgress(ProgressEntity progress) async {
    try {
      final progressModel = ProgressModel.fromEntity(progress);
      await _datasource.saveProgress(progressModel);
    } catch (e) {
      throw Exception('Failed to save user course progress: ${e.toString()}');
    }
  }
}

// Riverpod Providers

/// Provider exposing the [CourseFirestoreDatasource] instance.
final courseFirestoreDatasourceProvider = Provider<CourseFirestoreDatasource>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return CourseFirestoreDatasource(firestore);
});

/// Provider exposing the [CourseRepository] instance.
final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  final datasource = ref.watch(courseFirestoreDatasourceProvider);
  return CourseRepositoryImpl(datasource);
});

/// FutureProvider that fetches all courses available.
final coursesListProvider = FutureProvider<List<CourseEntity>>((ref) async {
  return ref.watch(courseRepositoryProvider).getCourses();
});

/// FutureProvider that fetches a single course by its ID.
final courseDetailsProvider = FutureProvider.family<CourseEntity?, String>((ref, courseId) async {
  return ref.watch(courseRepositoryProvider).getCourseById(courseId);
});

/// FutureProvider that fetches modules for a given course ID.
final modulesListProvider = FutureProvider.family<List<ModuleEntity>, String>((ref, courseId) async {
  return ref.watch(courseRepositoryProvider).getModules(courseId);
});

/// FutureProvider that fetches lessons for a given module ID.
final lessonsListProvider = FutureProvider.family<List<LessonEntity>, String>((ref, moduleId) async {
  return ref.watch(courseRepositoryProvider).getLessons(moduleId);
});

/// Param container for progress fetches.
class ProgressParam {
  /// The user ID.
  final String uid;
  /// The course ID.
  final String courseId;

  /// Creates a [ProgressParam] instance.
  ProgressParam({required this.uid, required this.courseId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgressParam && runtimeType == other.runtimeType && uid == other.uid && courseId == other.courseId;

  @override
  int get hashCode => uid.hashCode ^ courseId.hashCode;
}

/// FutureProvider that fetches the user's progress for a specific course.
final userProgressProvider = FutureProvider.family<ProgressEntity?, ProgressParam>((ref, param) async {
  return ref.watch(courseRepositoryProvider).getProgress(param.uid, param.courseId);
});
