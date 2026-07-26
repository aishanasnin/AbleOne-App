import 'package:ableone_app/features/gamification/domain/entities/xp_entity.dart';

class XPModel extends XPEntity {
  const XPModel({
    required super.currentXP,
    required super.level,
    required super.nextLevelXP,
    required super.dailyGoalXP,
    required super.todayXP,
  });

  factory XPModel.fromMap(Map<String, dynamic> map) {
    return XPModel(
      currentXP: (map['currentXP'] as num?)?.toInt() ?? 0,
      level: (map['level'] as num?)?.toInt() ?? 1,
      nextLevelXP: (map['nextLevelXP'] as num?)?.toInt() ?? 100,
      dailyGoalXP: (map['dailyGoalXP'] as num?)?.toInt() ?? 50,
      todayXP: (map['todayXP'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currentXP': currentXP,
      'level': level,
      'nextLevelXP': nextLevelXP,
      'dailyGoalXP': dailyGoalXP,
      'todayXP': todayXP,
    };
  }
}
