import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_rights_mobile_app/models/course.dart';
import 'package:my_rights_mobile_app/models/course_progress.dart';
import 'package:my_rights_mobile_app/provider/auth_provider.dart';

final courseProgressProvider = StreamProvider<CourseProgress?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);
  return FirebaseFirestore.instance
    .collection('user_course_progress')
    .doc(user.id)
    .snapshots()
    .map((doc) => doc.exists ? CourseProgress.fromFirestore(doc) : null);
  },
);

final featuredCoursesProvider = StreamProvider<List<Course>>((ref) {
  return FirebaseFirestore.instance
      .collection('courses')
      .where('featured', isEqualTo: true)
      .snapshots()
      .map((snapshot) => 
          snapshot.docs.map((doc) => Course.fromFirestore(doc)).toList());
});

final helpfulTipsProvider = StreamProvider<List<Course>>((ref) {
  return FirebaseFirestore.instance
      .collection('helpful_tips')
      .snapshots()
      .map((snapshot) => 
          snapshot.docs.map((doc) => Course.fromFirestore(doc)).toList());
});
