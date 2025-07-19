import 'package:cloud_firestore/cloud_firestore.dart';

class CourseProgress {
  final double percentage;
  final List<String> coursesCompleted;

  CourseProgress({
    required this.percentage,
    required this.coursesCompleted,
  });

  factory CourseProgress.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CourseProgress(
      percentage: (data['percentage'] ?? 0.0).toDouble(),
      coursesCompleted: List<String>.from(data['coursesCompleted'] ?? []),
    );
  }
}
