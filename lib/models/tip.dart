import 'package:cloud_firestore/cloud_firestore.dart';

class Tip {
  final String title;
  final String description;
  final String imageUrl;

  Tip({
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  factory Tip.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Tip(
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}
