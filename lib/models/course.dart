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
    required this.totalLessons
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? '',
      rating: json['rating'] ?? 0,
      categories: List<String>.from(json['categories'] ?? []),
      description: json['description'] ?? '',
      learningObjectives: List<String>.from(json['learningObjectives'] ?? []),
      featured: json['featured'] ?? false,
      imageUrl: json['imageUrl'] ?? '',
      title: json['title'] ?? '',
      certificateEligible: json['certificateEligible'] ?? false,
      difficulty: json['difficulty'] ?? '',
      totalQuestions: json['totalQuestions'] ?? 0,
      estimatedDurationMinutes: json['estimatedDurationMinutes'] ?? 0,
      totalLessons: json['totalLessons'] ?? 0
    );
  }
}
