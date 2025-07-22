class Tip {
  final String title;
  final String description;
  final String imageUrl;

  Tip({
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  factory Tip.fromJson(Map<String, dynamic> json) {
    return Tip(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}
