import 'package:ableone_app/features/personalization/domain/entities/learning_profile_entity.dart';

class LearningProfileModel extends LearningProfileEntity {
  const LearningProfileModel({
    required super.userId,
    required super.learningStyle,
    required super.strengths,
    required super.weaknesses,
    required super.preferredDifficulty,
  });

  factory LearningProfileModel.fromMap(Map<String, dynamic> map, String userId) {
    final strengthsRaw = map['strengths'] as List<dynamic>? ?? [];
    final weaknessesRaw = map['weaknesses'] as List<dynamic>? ?? [];
    
    return LearningProfileModel(
      userId: userId,
      learningStyle: map['learningStyle'] as String? ?? 'Visual',
      strengths: strengthsRaw.map((e) => e.toString()).toList(),
      weaknesses: weaknessesRaw.map((e) => e.toString()).toList(),
      preferredDifficulty: map['preferredDifficulty'] as String? ?? 'Beginner',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'learningStyle': learningStyle,
      'strengths': strengths,
      'weaknesses': weaknesses,
      'preferredDifficulty': preferredDifficulty,
    };
  }
}
