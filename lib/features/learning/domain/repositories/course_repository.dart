import 'package:ableone_app/features/learning/domain/entities/course_entity.dart';
import 'package:ableone_app/features/learning/domain/entities/module_entity.dart';
import 'package:ableone_app/features/learning/domain/entities/lesson_entity.dart';
import 'package:ableone_app/features/learning/domain/entities/progress_entity.dart';

/// Repository interface defining core data access operations for courses, modules, lessons, and progress.
abstract class CourseRepository {
  /// Fetches all courses available in the system.
  Future<List<CourseEntity>> getCourses();

  /// Fetches details for a specific course by [courseId].
  Future<CourseEntity?> getCourseById(String courseId);

  /// Fetches modules belonging to a course by [courseId].
  Future<List<ModuleEntity>> getModules(String courseId);

  /// Fetches lessons belonging to a module by [moduleId].
  Future<List<LessonEntity>> getLessons(String moduleId);

  /// Fetches the user progress tracked under a specific course.
  Future<ProgressEntity?> getProgress(String uid, String courseId);

  /// Saves or updates the user progress metrics under a course.
  Future<void> saveProgress(ProgressEntity progress);
}
