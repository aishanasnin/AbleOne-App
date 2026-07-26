import 'package:ableone_app/features/admin/data/models/admin_stats_model.dart';
import 'package:ableone_app/features/admin/data/models/course_management_model.dart';

class FakeAdminDataSource {
  Future<AdminStatsModel> fetchAdminStats() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return const AdminStatsModel(
      totalUsers: 142,
      totalStudents: 68,
      totalParents: 54,
      totalCounselors: 20,
      activeUsers: 92,
      lessonsCompleted: 412,
      aiInteractions: 835,
    );
  }

  Future<List<CourseManagementModel>> fetchManagedCourses() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return [
      const CourseManagementModel(
        courseId: 'c1',
        title: 'Introduction to Sight Words',
        category: 'English Literacy',
        difficulty: 'Beginner',
        enrolledUsers: 45,
        completionRate: 78.5,
      ),
      const CourseManagementModel(
        courseId: 'c2',
        title: 'Introduction to Numbers',
        category: 'Mathematics',
        difficulty: 'Beginner',
        enrolledUsers: 38,
        completionRate: 64.0,
      ),
      const CourseManagementModel(
        courseId: 'c3',
        title: 'Emotions and Expression',
        category: 'Social Learning',
        difficulty: 'Intermediate',
        enrolledUsers: 25,
        completionRate: 40.0,
      ),
      const CourseManagementModel(
        courseId: 'c4',
        title: 'Attentiveness Training',
        category: 'Cognitive Therapy',
        difficulty: 'Advanced',
        enrolledUsers: 34,
        completionRate: 85.0,
      ),
    ];
  }

  Future<List<Map<String, dynamic>>> fetchUsersList() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return [
      {
        'id': 'u1',
        'name': 'Bobby Smith',
        'email': 'bobby@ableone.org',
        'role': 'student',
        'learningLevel': 'Beginner',
        'supportNeeds': ['Visual Support', 'Autism Support'],
        'progress': 75.0,
        'streak': 12,
        'lastSession': '2026-07-25',
      },
      {
        'id': 'u2',
        'name': 'Emma Watson',
        'email': 'emma@ableone.org',
        'role': 'student',
        'learningLevel': 'Intermediate',
        'supportNeeds': ['Hearing Support'],
        'progress': 60.0,
        'streak': 8,
        'lastSession': '2026-07-24',
      },
      {
        'id': 'u3',
        'name': 'John Smith',
        'email': 'john.smith@gmail.com',
        'role': 'parent',
        'associatedChild': 'Bobby Smith',
        'notifications': true,
        'linkedCounselor': 'Dr. Sarah Adams',
      },
      {
        'id': 'u4',
        'name': 'Dr. Sarah Adams',
        'email': 'sarah.adams@counseling.org',
        'role': 'counselor',
        'assignedStudents': 8,
        'rating': 4.9,
        'bio': 'Expert pediatric cognitive specialist with 12+ years of clinical service.',
        'specialties': ['Speech Therapy', 'Autism Support'],
      },
      {
        'id': 'u5',
        'name': 'Dr. Michael Chen',
        'email': 'm.chen@clinical.org',
        'role': 'counselor',
        'assignedStudents': 6,
        'rating': 4.8,
        'bio': 'Specializes in language pathology & audio assistive technologies.',
        'specialties': ['Hearing Support', 'Attentiveness Training'],
      },
    ];
  }
}
