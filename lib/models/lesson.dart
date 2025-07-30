class Lesson {
  final String id;
  final String title;
  final String description;
  final int order;
  final num estimatedDurationMinutes;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
    required this.estimatedDurationMinutes,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      order: json['order'] ?? 0,
      estimatedDurationMinutes: json['estimatedDurationMinutes'] ?? 0
    );
  }
}
