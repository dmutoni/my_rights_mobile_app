import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  final String id;
  final num rating;
  final List<String> categories;
  final String description;
  final List<String> learningObjectives;
  final bool featured;
  final String imageUrl;
  final String title;
  final bool certificateEligible;
  final String difficulty;
  final int totalQuestions;
  final num estimatedDurationMinutes;
  final int totalLessons;

  Course({
    required this.id,
    required this.rating,
    required this.categories,
    required this.description,
    required this.learningObjectives,
    required this.featured,
    required this.imageUrl,
    required this.title,
    required this.certificateEligible,
    required this.difficulty,
    required this.totalQuestions,
    required this.estimatedDurationMinutes,
    required this.totalLessons,
  });

  factory Course.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Course(
      id: doc.id,
      rating: data['rating'] ?? 0,
      categories: List<String>.from(data['categories'] ?? []),
      description: data['description'] ?? '',
      learningObjectives: List<String>.from(data['learningObjectives'] ?? []),
      featured: data['featured'] ?? false,
      imageUrl: data['imageUrl'] ?? '',
      title: data['title'] ?? '',
      certificateEligible: data['certificateEligible'] ?? false,
      difficulty: data['difficulty'] ?? '',
      totalQuestions: data['totalQuestions'] ?? 0,
      estimatedDurationMinutes: data['estimatedDurationMinutes'] ?? 0,
      totalLessons: data['totalLessons'] ?? 0,
    );
  }
}
