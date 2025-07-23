import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_rights_mobile_app/models/category.dart';
import 'package:my_rights_mobile_app/models/course.dart';
import 'package:my_rights_mobile_app/models/course_progress.dart';
import 'package:my_rights_mobile_app/models/tip.dart';
import 'package:my_rights_mobile_app/provider/auth_provider.dart';
import 'package:my_rights_mobile_app/service/firebase_service.dart';

final courseProgressProvider = StreamProvider<CourseProgress?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);
  return FirebaseService.getDocument(collection: 'user_course_progress', docId: user.id)
    .map((doc) => doc.exists && doc.data() != null ? CourseProgress.fromJson({...doc.data()!, 'id': doc.id}) : null);
  },
);

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
    .asyncMap((doc) async {
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      
      Map<String, dynamic> data = {
        ...doc.data()!,
        'id': doc.id,
      };

      // Fetch lessons
      final lessonsSnapshot = await FirebaseService.getInnerDocument(collection: 'courses', docId: courseId, innerCollection: 'lessons');

      for (var lessonDoc in lessonsSnapshot.docs) {
        // Fetch chapters for this lesson
        final chaptersSnapshot = await FirebaseService.getInnerDocument(collection: 'courses', docId: courseId, innerCollection: 'lessons', innerDocId: lessonDoc.id, anotherCollection: 'chapters');

        // Fetch quizzes for this lesson
        final quizzesSnapshot = await FirebaseService.getInnerDocument(collection: 'courses', docId: courseId, innerCollection: 'lessons', innerDocId: lessonDoc.id, anotherCollection: 'quiz');

        data['lessons'] = {
          ...lessonDoc.data(),
          'id': lessonDoc.id,
          'chapters': chaptersSnapshot.docs
            .map((chapterDoc) => {
              ...chapterDoc.data(),
              'id': chapterDoc.id,
            })
            .toList(),
          'quizzes': quizzesSnapshot.docs
            .map((quizDoc) => {
              ...quizDoc.data(),
              'id': quizDoc.id,
            })
            .toList(),
        };
      }

      return Course.fromJson(data);
    });
});
