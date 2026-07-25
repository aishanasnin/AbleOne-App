import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ableone_app/features/learning/data/models/course_model.dart';
import 'package:ableone_app/features/learning/data/models/module_model.dart';
import 'package:ableone_app/features/learning/data/models/lesson_model.dart';
import 'package:ableone_app/features/learning/data/models/progress_model.dart';

/// Firestore data source executing database reads/writes for courses, modules, lessons, and progress.
class CourseFirestoreDatasource {
  final FirebaseFirestore _firestore;

  /// Creates a [CourseFirestoreDatasource] instance.
  CourseFirestoreDatasource(this._firestore);

  CollectionReference<Map<String, dynamic>> get _coursesCollection =>
      _firestore.collection('courses');

  CollectionReference<Map<String, dynamic>> get _modulesCollection =>
      _firestore.collection('modules');

  CollectionReference<Map<String, dynamic>> get _lessonsCollection =>
      _firestore.collection('lessons');

  CollectionReference<Map<String, dynamic>> get _progressCollection =>
      _firestore.collection('progress');

  /// Fetches all course records from Firestore.
  Future<List<CourseModel>> getCourses() async {
    try {
      await seedIfEmpty();
      final querySnapshot = await _coursesCollection.get();
      return querySnapshot.docs
          .map((doc) => CourseModel.fromMap(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Firestore Error: ${e.message ?? 'Unknown database error.'}');
    }
  }

  /// Fetches a single course record from Firestore by [courseId].
  Future<CourseModel?> getCourseById(String courseId) async {
    try {
      final doc = await _coursesCollection.doc(courseId).get();
      if (doc.exists && doc.data() != null) {
        return CourseModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } on FirebaseException catch (e) {
      throw Exception('Firestore Error: ${e.message}');
    }
  }

  /// Fetches modules belonging to a course, ordered sequentially.
  Future<List<ModuleModel>> getModules(String courseId) async {
    try {
      final querySnapshot = await _modulesCollection
          .where('courseId', isEqualTo: courseId)
          .orderBy('order')
          .get();
      return querySnapshot.docs
          .map((doc) => ModuleModel.fromMap(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Firestore Error: ${e.message}');
    }
  }

  /// Fetches lessons belonging to a module, ordered sequentially.
  Future<List<LessonModel>> getLessons(String moduleId) async {
    try {
      final querySnapshot = await _lessonsCollection
          .where('moduleId', isEqualTo: moduleId)
          .orderBy('order')
          .get();
      return querySnapshot.docs
          .map((doc) => LessonModel.fromMap(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Firestore Error: ${e.message}');
    }
  }

  /// Fetches the progress record for a specific user and course.
  Future<ProgressModel?> getProgress(String uid, String courseId) async {
    try {
      final docId = '${uid}_$courseId';
      final doc = await _progressCollection.doc(docId).get();
      if (doc.exists && doc.data() != null) {
        return ProgressModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } on FirebaseException catch (e) {
      throw Exception('Firestore Error: ${e.message}');
    }
  }

  /// Saves or updates the progress record for a user.
  Future<void> saveProgress(ProgressModel progress) async {
    try {
      final docId = '${progress.uid}_${progress.courseId}';
      await _progressCollection.doc(docId).set(progress.toMap());
    } on FirebaseException catch (e) {
      throw Exception('Firestore Error: ${e.message}');
    }
  }

  /// Seeds dummy data into the database if the courses collection is empty.
  Future<void> seedIfEmpty() async {
    try {
      final snapshot = await _coursesCollection.limit(1).get();
      if (snapshot.docs.isNotEmpty) return;

      // Seed Course 1: Sight Words Introduction
      await _coursesCollection.doc('c1').set({
        'title': 'Introduction to Sight Words',
        'description': 'Learn fundamental sight words to build basic literacy, pronunciation, and reading speed.',
        'difficulty': 'Beginner',
        'thumbnail': 'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=400',
        'modulesCount': 2,
        'lessonsCount': 4,
        'duration': '1 hour',
      });

      await _modulesCollection.doc('c1_m1').set({
        'courseId': 'c1',
        'title': 'Basic Sounds & Symbols',
        'description': 'Introduction to sight word concepts and vowel groupings.',
        'order': 1,
      });

      await _lessonsCollection.doc('c1_m1_l1').set({
        'moduleId': 'c1_m1',
        'courseId': 'c1',
        'title': 'What are Sight Words?',
        'type': 'text',
        'content': 'Sight words are commonly used words that children are encouraged to recognize instantly by sight, without sounding them out. Examples include: the, of, to, and, a, is, in, that, it, you, he, was, for, on, are, as, with, his, they, I.\n\nDeveloping sight word recognition helps children read more fluently, as they do not have to struggle to sound out every word, allowing them to focus on text comprehension.',
        'order': 1,
        'duration': '5 mins',
      });

      await _lessonsCollection.doc('c1_m1_l2').set({
        'moduleId': 'c1_m1',
        'courseId': 'c1',
        'title': 'Common Sight Words Video Guide',
        'type': 'video',
        'content': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        'order': 2,
        'duration': '10 mins',
      });

      await _lessonsCollection.doc('c1_m1_l3').set({
        'moduleId': 'c1_m1',
        'courseId': 'c1',
        'title': 'Sight Word Phonetics Audio Practice',
        'type': 'audio',
        'content': 'Interactive audio reader spelling helper.',
        'order': 3,
        'duration': '5 mins',
      });

      await _modulesCollection.doc('c1_m2').set({
        'courseId': 'c1',
        'title': 'Reading & Sentence Placement',
        'description': 'Apply sight words contextually in simple sentence models.',
        'order': 2,
      });

      await _lessonsCollection.doc('c1_m2_l4').set({
        'moduleId': 'c1_m2',
        'courseId': 'c1',
        'title': 'Sentence Structure Worksheet',
        'type': 'pdf',
        'content': 'Printable PDF activity guide for basic sentence tracing.',
        'order': 1,
        'duration': '15 mins',
      });

      await _lessonsCollection.doc('c1_m2_l5').set({
        'moduleId': 'c1_m2',
        'courseId': 'c1',
        'title': 'Module Recap Quiz',
        'type': 'quiz',
        'content': 'A simple spelling check-up.',
        'order': 2,
        'duration': '5 mins',
      });

      // Seed Course 2: Visual Cognitive Counting
      await _coursesCollection.doc('c2').set({
        'title': 'Visual Cognitive Counting',
        'description': 'Develop fundamental number visual recognition matching sets and shapes.',
        'difficulty': 'Beginner',
        'thumbnail': 'https://images.unsplash.com/photo-1518133680790-3985ea56d495?w=400',
        'modulesCount': 1,
        'lessonsCount': 2,
        'duration': '30 mins',
      });

      await _modulesCollection.doc('c2_m1').set({
        'courseId': 'c2',
        'title': 'Numbers 1 to 10',
        'description': 'Basic visualization of values.',
        'order': 1,
      });

      await _lessonsCollection.doc('c2_m1_l1').set({
        'moduleId': 'c2_m1',
        'courseId': 'c2',
        'title': 'Interactive Number Video',
        'type': 'video',
        'content': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        'order': 1,
        'duration': '10 mins',
      });

      await _lessonsCollection.doc('c2_m1_l2').set({
        'moduleId': 'c2_m1',
        'courseId': 'c2',
        'title': 'Matching Shapes Practice',
        'type': 'quiz',
        'content': 'Match elements count worksheet.',
        'order': 2,
        'duration': '5 mins',
      });

      // Seed Course 3: Mindfulness & Daily Focus
      await _coursesCollection.doc('c3').set({
        'title': 'Mindfulness & Daily Focus',
        'description': 'Simple attentiveness exercises and calming routines designed for visual pacing.',
        'difficulty': 'Intermediate',
        'thumbnail': 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400',
        'modulesCount': 1,
        'lessonsCount': 1,
        'duration': '45 mins',
      });

      await _modulesCollection.doc('c3_m1').set({
        'courseId': 'c3',
        'title': 'Finding Calm',
        'description': 'Attentiveness strategies.',
        'order': 1,
      });

      await _lessonsCollection.doc('c3_m1_l1').set({
        'moduleId': 'c3_m1',
        'courseId': 'c3',
        'title': 'Visual Paced Breathing Guide',
        'type': 'video',
        'content': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        'order': 1,
        'duration': '8 mins',
      });
    } catch (_) {
      // Suppress or catch connection log outputs during initial cold loads.
    }
  }
}
