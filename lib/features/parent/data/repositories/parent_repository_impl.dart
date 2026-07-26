import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ableone_app/features/parent/domain/entities/child_progress_entity.dart';
import 'package:ableone_app/features/parent/domain/repositories/parent_repository.dart';

/// Mock implementation of [ParentRepository] for parent insight panels.
class ParentRepositoryImpl implements ParentRepository {
  @override
  Future<ChildProgressEntity?> getChildProgress(String childId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (childId == 'c2') {
      return const ChildProgressEntity(
        childId: 'c2',
        childName: 'Emily Davis',
        completedLessons: [
          'Vowel Sounds Pronunciation',
          'Audio Comprehension Basics',
        ],
        progressPercentage: 45.0,
        streak: 2,
        strengths: [
          'Great auditory engagement',
          'Persistent effort in speech',
        ],
        improvementAreas: [
          'Visual reading alignment',
          'Simplifying long sightwords',
        ],
      );
    }
    if (childId == 'c3') {
      return const ChildProgressEntity(
        childId: 'c3',
        childName: 'Chloe Clark',
        completedLessons: [
          'Complex Sentence Sequencing',
          'Advanced Dialogue Comprehension',
          'Diagnostic Writing Exercise',
        ],
        progressPercentage: 95.0,
        streak: 12,
        strengths: [
          'Exceptional textual retention',
          'Advanced grammar sequencing',
        ],
        improvementAreas: [
          'Keyboard hotkey guidance',
          'Focus markers calibration',
        ],
      );
    }
    return const ChildProgressEntity(
      childId: 'c1',
      childName: 'Alex Smith',
      completedLessons: [
        'Photosynthesis Overview',
        'Plant Cells Structure',
        'Light Reactions',
        'Dark Reactions',
      ],
      progressPercentage: 80.0,
      streak: 5,
      strengths: [
        'Visual concept retention',
        'Active recall in Science',
        'High quiz accuracy',
      ],
      improvementAreas: [
        'Audio descriptions vocabulary',
        'Extended attention layout intervals',
      ],
    );
  }

  @override
  Future<List<String>> getRecentActivities(String childId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      'Completed "Light Reactions" quiz with 90% score (10 mins ago)',
      'Studied "Plant Cells Structure" text description (2 hrs ago)',
      'Discussed Photosynthesis with the AI Tutor (1 day ago)',
      'Completed "Photosynthesis Overview" video (2 days ago)',
    ];
  }

  @override
  Future<List<String>> getCounselorUpdates(String childId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      'Alex is showing exceptional engagement with visual diagram modules in Science.',
      'Recommended incorporating short cognitive pauses after every quiz attempt to allow vocabulary reflection.',
      'Next review scheduled for Tuesday morning at 10:00 AM.',
    ];
  }

  @override
  Future<List<String>> getAILearningInsights(String childId) async {
    await Future.delayed(const Duration(milliseconds: 550));
    return [
      'Alex retains concepts 2.5x faster when content uses emojis, list items, and high-contrast styling.',
      'Active learning streak of 5 days suggests strong morning study habits. Keep encouraging daily sessions.',
      'Consider adding extra diagrams or visual flashcards to reinforce vocabulary terms.',
    ];
  }
}

// Riverpod Providers

/// Provider exposing the parent repository implementation.
final parentRepositoryProvider = Provider<ParentRepository>((ref) {
  return ParentRepositoryImpl();
});

/// FutureProvider that retrieves the child progress statistics.
final childProgressProvider = FutureProvider.family<ChildProgressEntity?, String>((ref, childId) {
  return ref.watch(parentRepositoryProvider).getChildProgress(childId);
});

/// FutureProvider that retrieves the child's recent activities list.
final parentRecentActivitiesProvider = FutureProvider.family<List<String>, String>((ref, childId) {
  return ref.watch(parentRepositoryProvider).getRecentActivities(childId);
});

/// FutureProvider that retrieves the child's counselor updates list.
final parentCounselorUpdatesProvider = FutureProvider.family<List<String>, String>((ref, childId) {
  return ref.watch(parentRepositoryProvider).getCounselorUpdates(childId);
});

/// FutureProvider that retrieves AI-driven learning insights.
final parentAIInsightsProvider = FutureProvider.family<List<String>, String>((ref, childId) {
  return ref.watch(parentRepositoryProvider).getAILearningInsights(childId);
});
