import 'package:ableone_app/features/parent/domain/entities/child_progress_entity.dart';

/// Repository interface defining parents dashboard data retrieval methods.
abstract class ParentRepository {
  /// Fetches learning progress details for a child.
  Future<ChildProgressEntity?> getChildProgress(String childId);

  /// Fetches recent learning activities of a child.
  Future<List<String>> getRecentActivities(String childId);

  /// Fetches counselor review comments/updates for a child.
  Future<List<String>> getCounselorUpdates(String childId);

  /// Fetches AI generated learning insights for a child.
  Future<List<String>> getAILearningInsights(String childId);
}
