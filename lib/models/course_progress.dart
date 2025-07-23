class CourseProgress {
  final num percentage;
  final List<String> coursesCompleted;

  CourseProgress({
    required this.percentage,
    required this.coursesCompleted,
  });

  factory CourseProgress.fromJson(Map<String, dynamic> json) {
    return CourseProgress(
      percentage: json['percentage'] ?? 0.0,
      coursesCompleted: List<String>.from(json['coursesCompleted'] ?? []),
    );
  }
}
