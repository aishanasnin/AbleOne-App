import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ableone_app/features/ai/domain/entities/ai_context_entity.dart';
import 'package:ableone_app/features/learning/domain/entities/course_entity.dart';
import 'package:ableone_app/features/learning/domain/entities/lesson_entity.dart';
import 'package:ableone_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:ableone_app/features/accessibility/data/repositories/accessibility_repository_impl.dart';

/// StateProvider tracking the course currently being viewed by the user.
final currentCourseStateProvider = StateProvider<CourseEntity?>((ref) => null);

/// StateProvider tracking the lesson currently being viewed by the user.
final currentLessonStateProvider = StateProvider<LessonEntity?>((ref) => null);

/// Provider that constructs and exposes the complete lesson-aware [AIContextEntity].
final aiContextProvider = Provider<AIContextEntity>((ref) {
  final profileAsync = ref.watch(userProfileNotifierProvider);
  final currentCourse = ref.watch(currentCourseStateProvider);
  final currentLesson = ref.watch(currentLessonStateProvider);
  final accessSettings = ref.watch(accessibilitySettingsProvider);

  return profileAsync.maybeWhen(
    data: (profile) {
      if (profile != null) {
        return AIContextEntity(
          userLevel: profile.learningLevel,
          learningPreference: profile.learningPreference,
          accessibilityNeeds: profile.supportNeeds,
          currentCourse: currentCourse,
          currentLesson: currentLesson,
          language: profile.preferredLanguage,
          simpleExplanationsMode: accessSettings.simplifiedMode,
          stepByStepMode: accessSettings.stepByStepMode,
          textScale: accessSettings.textScale,
          readingSpeed: accessSettings.readingSpeed,
        );
      }
      return AIContextEntity(
        userLevel: 'Beginner',
        learningPreference: 'Simple explanations',
        accessibilityNeeds: const [],
        currentCourse: currentCourse,
        currentLesson: currentLesson,
        language: 'English',
        simpleExplanationsMode: accessSettings.simplifiedMode,
        stepByStepMode: accessSettings.stepByStepMode,
        textScale: accessSettings.textScale,
        readingSpeed: accessSettings.readingSpeed,
      );
    },
    orElse: () => AIContextEntity(
      userLevel: 'Beginner',
      learningPreference: 'Simple explanations',
      accessibilityNeeds: const [],
      currentCourse: currentCourse,
      currentLesson: currentLesson,
      language: 'English',
      simpleExplanationsMode: accessSettings.simplifiedMode,
      stepByStepMode: accessSettings.stepByStepMode,
      textScale: accessSettings.textScale,
      readingSpeed: accessSettings.readingSpeed,
    ),
  );
});
