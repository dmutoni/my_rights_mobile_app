import 'package:my_rights_mobile_app/models/content.dart';

class Chapter {
  final String id;
  final String title;
  final int order;
  final Content? content;

  Chapter({
    required this.id,
    required this.title,
    required this.order,
    required this.content,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'],
      title: json['title'],
      order: json['order'],
      content: json['content'] != null ? Content.fromJson(json['content']) : null,
    );
  }
}
