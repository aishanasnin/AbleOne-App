import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ableone_app/features/personalization/domain/entities/study_plan_entity.dart';

class StudyPlanModel extends StudyPlanEntity {
  const StudyPlanModel({
    required super.date,
    required super.tasks,
    required super.completionStatus,
  });

  factory StudyPlanModel.fromMap(Map<String, dynamic> map) {
    final timestamp = map['date'] as Timestamp?;
    final tasksRaw = map['tasks'] as List<dynamic>? ?? [];
    final statusRaw = map['completionStatus'] as Map<dynamic, dynamic>? ?? {};

    final completionStatus = <String, bool>{};
    statusRaw.forEach((k, v) {
      completionStatus[k.toString()] = v as bool? ?? false;
    });

    return StudyPlanModel(
      date: timestamp?.toDate() ?? DateTime.now(),
      tasks: tasksRaw.map((e) => e.toString()).toList(),
      completionStatus: completionStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'tasks': tasks,
      'completionStatus': completionStatus,
    };
  }
}
