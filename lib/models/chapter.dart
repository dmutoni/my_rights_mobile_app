import 'package:my_rights_mobile_app/models/content.dart';

class Chapter {
  final String id;
  final String title;
  final int order;
  final List<Content> content;

  Chapter({
    required this.id,
    required this.title,
    required this.order,
    required this.content,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as String,
      title: json['title'] as String,
      order: json['order'] as int,
      content: (json['content'] as List<dynamic>?)
          ?.map((item) => Content.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}
