import 'package:ableone_app/features/personalization/domain/entities/learning_profile_entity.dart';
import 'package:ableone_app/features/personalization/domain/entities/study_plan_entity.dart';
import 'package:ableone_app/features/personalization/domain/entities/recommendation_entity.dart';

abstract class PersonalizationRepository {
  Future<LearningProfileEntity> getLearningProfile(String userId);
  Future<StudyPlanEntity> getStudyPlan(String userId, DateTime date);
  Future<List<RecommendationEntity>> getRecommendations(String userId);
  Future<void> updateLearningProfile(LearningProfileEntity profile);
  Future<void> toggleTaskCompletion(String userId, DateTime date, String task);
}
