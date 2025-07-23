class Resource {
  final String id;
  final String title;
  final String description;
  final String type;
  final String url;

  Resource({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.url,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      url: json['url'] ?? '',
    );
  }
}