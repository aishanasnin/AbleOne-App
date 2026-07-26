import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ableone_app/features/personalization/data/models/learning_profile_model.dart';
import 'package:ableone_app/features/personalization/data/models/study_plan_model.dart';
import 'package:ableone_app/features/personalization/data/models/recommendation_model.dart';

void main() {
  group('Personalization Module Unit Tests', () {
    test('LearningProfileModel should correctly map fields from database map', () {
      final map = {
        'learningStyle': 'Auditory',
        'strengths': ['Auditory engagement', 'Speech attempt'],
        'weaknesses': ['Long sightwords spelling'],
        'preferredDifficulty': 'Intermediate',
      };

      final model = LearningProfileModel.fromMap(map, 'user_xyz');

      expect(model.userId, 'user_xyz');
      expect(model.learningStyle, 'Auditory');
      expect(model.strengths, contains('Auditory engagement'));
      expect(model.weaknesses, contains('Long sightwords spelling'));
      expect(model.preferredDifficulty, 'Intermediate');
    });

    test('StudyPlanModel should correctly map fields from database map', () {
      final now = DateTime.now();
      final map = {
        'date': Timestamp.fromDate(now),
        'tasks': ['Task A', 'Task B'],
        'completionStatus': {
          'Task A': true,
          'Task B': false,
        },
      };

      final model = StudyPlanModel.fromMap(map);

      expect(model.tasks, contains('Task A'));
      expect(model.completionStatus['Task A'], true);
      expect(model.completionStatus['Task B'], false);
    });

    test('RecommendationModel should correctly map fields from database map', () {
      final map = {
        'title': 'Vowel Recap',
        'reason': 'Needs phonetic practice',
        'priority': 'High',
      };

      final model = RecommendationModel.fromMap(map);

      expect(model.title, 'Vowel Recap');
      expect(model.reason, 'Needs phonetic practice');
      expect(model.priority, 'High');
    });
  });
}
