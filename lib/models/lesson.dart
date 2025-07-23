import 'package:my_rights_mobile_app/models/chapter.dart';
import 'package:my_rights_mobile_app/models/quiz.dart';

class Lesson {
  final String id;
  final String title;
  final String description;
  final int order;
  final num estimatedDurationMinutes;
  final List<Chapter> chapters;
  final List<Quiz> quizzes;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
    required this.estimatedDurationMinutes,
    this.chapters = const [],
    this.quizzes = const [],
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      order: json['order'] ?? 0,
      estimatedDurationMinutes: json['estimatedDurationMinutes'] ?? 0,
      chapters: (json['chapters'] as List<dynamic>?)?.map((chapter) => Chapter.fromJson(chapter)).toList() ?? [],
      quizzes: (json['quizzes'] as List<dynamic>?)?.map((quiz) => Quiz.fromJson(quiz)).toList() ?? [],
    );
  }
}
