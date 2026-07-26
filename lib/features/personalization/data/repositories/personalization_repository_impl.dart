import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ableone_app/features/personalization/domain/entities/learning_profile_entity.dart';
import 'package:ableone_app/features/personalization/domain/entities/study_plan_entity.dart';
import 'package:ableone_app/features/personalization/domain/entities/recommendation_entity.dart';
import 'package:ableone_app/features/personalization/domain/repositories/personalization_repository.dart';
import 'package:ableone_app/features/personalization/data/models/learning_profile_model.dart';
import 'package:ableone_app/features/personalization/data/models/study_plan_model.dart';
import 'package:ableone_app/features/personalization/data/models/recommendation_model.dart';
import 'package:ableone_app/core/services/firebase_service.dart';

class PersonalizationRepositoryImpl implements PersonalizationRepository {
  final FirebaseFirestore _firestore;

  PersonalizationRepositoryImpl(this._firestore);

  DocumentReference<Map<String, dynamic>> _profileDoc(String userId) =>
      _firestore.collection('users').doc(userId).collection('personalization').doc('profile');

  DocumentReference<Map<String, dynamic>> _planDoc(String userId, String dateStr) =>
      _firestore.collection('users').doc(userId).collection('personalization').doc('study_plans').collection('dates').doc(dateStr);

  CollectionReference<Map<String, dynamic>> _recsCol(String userId) =>
      _firestore.collection('users').doc(userId).collection('personalization').doc('recommendations').collection('items');

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Future<LearningProfileEntity> getLearningProfile(String userId) async {
    try {
      final doc = await _profileDoc(userId).get();
      if (doc.exists && doc.data() != null) {
        return LearningProfileModel.fromMap(doc.data()!, userId);
      }
      final defaultProfile = LearningProfileModel(
        userId: userId,
        learningStyle: 'Visual',
        strengths: const ['Diagram retention', 'Visual pattern matches'],
        weaknesses: const ['Complex syllable splits', 'Audio-only descriptions'],
        preferredDifficulty: 'Beginner',
      );
      await _profileDoc(userId).set(defaultProfile.toMap());
      return defaultProfile;
    } catch (e) {
      throw Exception('Failed to get learning profile: $e');
    }
  }

  @override
  Future<StudyPlanEntity> getStudyPlan(String userId, DateTime date) async {
    try {
      final dateStr = _formatDate(date);
      final doc = await _planDoc(userId, dateStr).get();
      if (doc.exists && doc.data() != null) {
        return StudyPlanModel.fromMap(doc.data()!);
      }
      final defaultPlan = StudyPlanModel(
        date: date,
        tasks: const [
          'Read "What are Sight Words?" text guide',
          'Complete the Vowel Pronunciation audio exercise',
          'Ask the AI chatbot tutor to explain vowel sounds',
        ],
        completionStatus: const {
          'Read "What are Sight Words?" text guide': false,
          'Complete the Vowel Pronunciation audio exercise': false,
          'Ask the AI chatbot tutor to explain vowel sounds': false,
        },
      );
      await _planDoc(userId, dateStr).set(defaultPlan.toMap());
      return defaultPlan;
    } catch (e) {
      throw Exception('Failed to get study plan: $e');
    }
  }

  @override
  Future<List<RecommendationEntity>> getRecommendations(String userId) async {
    try {
      final col = await _recsCol(userId).get();
      if (col.docs.isNotEmpty) {
        return col.docs.map((doc) => RecommendationModel.fromMap(doc.data())).toList();
      }
      final defaultRecs = [
        const RecommendationModel(
          title: 'Review Sight Word Vowels',
          reason: 'Alex is struggling with vowel pronunciations during quick quizzes. AI recommends spending 5 minutes on vowel placement guides.',
          priority: 'High',
        ),
        const RecommendationModel(
          title: 'Introduce Short Rest Breaks',
          reason: 'Streak data indicates learning efficiency drops after 15 minutes. Consider implementing cognitive pauses.',
          priority: 'Medium',
        ),
      ];
      for (final rec in defaultRecs) {
        await _recsCol(userId).add(rec.toMap());
      }
      return defaultRecs;
    } catch (e) {
      throw Exception('Failed to get recommendations: $e');
    }
  }

  @override
  Future<void> updateLearningProfile(LearningProfileEntity profile) async {
    try {
      final model = LearningProfileModel(
        userId: profile.userId,
        learningStyle: profile.learningStyle,
        strengths: profile.strengths,
        weaknesses: profile.weaknesses,
        preferredDifficulty: profile.preferredDifficulty,
      );
      await _profileDoc(profile.userId).set(model.toMap());
    } catch (e) {
      throw Exception('Failed to update learning profile: $e');
    }
  }

  @override
  Future<void> toggleTaskCompletion(String userId, DateTime date, String task) async {
    try {
      final dateStr = _formatDate(date);
      final current = await getStudyPlan(userId, date);
      final newStatus = Map<String, bool>.from(current.completionStatus);
      newStatus[task] = !(newStatus[task] ?? false);

      await _planDoc(userId, dateStr).update({
        'completionStatus': newStatus,
      });
    } catch (e) {
      throw Exception('Failed to toggle task: $e');
    }
  }
}

// Riverpod Providers
final personalizationRepositoryProvider = Provider<PersonalizationRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return PersonalizationRepositoryImpl(firestore);
});

final learningProfileProvider = FutureProvider.family<LearningProfileEntity, String>((ref, userId) {
  return ref.watch(personalizationRepositoryProvider).getLearningProfile(userId);
});

class StudyPlanParam {
  final String userId;
  final DateTime date;
  StudyPlanParam({required this.userId, required this.date});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudyPlanParam &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          date.year == other.date.year &&
          date.month == other.date.month &&
          date.day == other.date.day;

  @override
  int get hashCode => userId.hashCode ^ date.year.hashCode ^ date.month.hashCode ^ date.day.hashCode;
}

final studyPlanProvider = FutureProvider.family<StudyPlanEntity, StudyPlanParam>((ref, param) {
  return ref.watch(personalizationRepositoryProvider).getStudyPlan(param.userId, param.date);
});

final aiRecommendationsProvider = FutureProvider.family<List<RecommendationEntity>, String>((ref, userId) {
  return ref.watch(personalizationRepositoryProvider).getRecommendations(userId);
});
