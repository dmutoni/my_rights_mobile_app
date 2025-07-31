import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_rights_mobile_app/models/category.dart';
import 'package:my_rights_mobile_app/models/chapter.dart';
import 'package:my_rights_mobile_app/models/course.dart';
import 'package:my_rights_mobile_app/models/lesson.dart';
import 'package:my_rights_mobile_app/models/quiz.dart';
import 'package:my_rights_mobile_app/models/tip.dart';
import 'package:my_rights_mobile_app/service/firebase_service.dart';

final featuredCoursesProvider = StreamProvider<List<Course>>((ref) {
  return FirebaseService.getDocumentQuery(collection: 'courses', field: 'featured', value: true)
      .map((snapshot) =>
          snapshot.docs.map((doc) => Course.fromJson({...doc.data(), 'id': doc.id})).toList());
});

final helpfulTipsProvider = StreamProvider<List<Tip>>((ref) {
  return FirebaseService.getCollectionStream('tips')
      .map((snapshot) =>
          snapshot.docs.map((doc) => Tip.fromJson({...doc.data(), 'id': doc.id})).toList());
});

final categoriesProvider = StreamProvider<List<Category>>((ref) {
  return FirebaseService.getDocumentOrdered(collection: 'categories', orderByField: 'name')
      .map((snapshot) =>
          snapshot.docs.map((doc) => Category.fromJson({...doc.data(), 'id': doc.id})).toList());
});

final coursesProvider = StreamProvider<List<Course>>((ref) {
  return FirebaseService.getCollectionStream('courses')
    .map((snapshot) =>
        snapshot.docs.map((doc) => Course.fromJson({...doc.data(), 'id': doc.id})).toList());
});

final coursesByCategoryProvider = StreamProvider.family<List<Course>, String>((ref, categoryId) {
  return FirebaseService.getDocumentArrayQuery(
    collection: 'courses',
    field: 'categories',
    value: categoryId,
  ).map((snapshot) =>
      snapshot.docs.map((doc) => Course.fromJson({...doc.data(), 'id': doc.id})).toList());
});

final courseDetailProvider = StreamProvider.family<Course?, String>((ref, courseId) {
  return FirebaseService.getDocument(collection: 'courses', docId: courseId)
      .map((doc) => doc.exists ? Course.fromJson({...doc.data()!, 'id': doc.id}) : null);
});

final courseLessonsProvider = StreamProvider.family<List<Lesson>, String>((ref, courseId) {
  return FirebaseService.getInnerDocument(collection: 'courses', docId: courseId, innerCollection: 'lessons')
      .map((snapshot) => 
          snapshot.docs.map((doc) => Lesson.fromJson({...doc.data(), 'id': doc.id})).toList());
});

final lessonChaptersProvider = StreamProvider.family<List<Chapter>, ({String courseId, String lessonId})>((ref, params) {
  return FirebaseService.getInnerDocument(collection: 'courses', docId: params.courseId, innerCollection: 'lessons', innerDocId: params.lessonId, anotherCollection: 'chapters', orderByField: 'order')
      .map((snapshot) => 
          snapshot.docs.map((doc) => Chapter.fromJson({...doc.data(), 'id': doc.id})).toList());
});

final lessonQuizProvider = StreamProvider.family<List<Quiz>, ({String courseId, String lessonId})>((ref, params) {
  return FirebaseService.getInnerDocument(collection: 'courses', docId: params.courseId, innerCollection: 'lessons', innerDocId: params.lessonId, anotherCollection: 'quiz')
      .map((snapshot) => 
          snapshot.docs.map((doc) => Quiz.fromJson({...doc.data(), 'id': doc.id})).toList());
});

final currentChapterProvider = StateProvider.family<int, String>((ref, lessonId) => 0);
final currentQuestionProvider = StateProvider<int>((ref) => 0);
final selectedAnswersProvider = StateProvider<Map<int, int>>((ref) => {});
final startedLessonsProvider = StateProvider<Set<String>>((ref) => {});
