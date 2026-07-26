import 'package:ableone_app/features/personalization/domain/entities/recommendation_entity.dart';

class RecommendationModel extends RecommendationEntity {
  const RecommendationModel({
    required super.title,
    required super.reason,
    required super.priority,
  });

  factory RecommendationModel.fromMap(Map<String, dynamic> map) {
    return RecommendationModel(
      title: map['title'] as String? ?? '',
      reason: map['reason'] as String? ?? '',
      priority: map['priority'] as String? ?? 'Medium',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'reason': reason,
      'priority': priority,
    };
  }
}
