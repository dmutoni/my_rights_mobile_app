import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final bool isCompleted;
  final bool featured;
  final DateTime createdAt;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.isCompleted = false,
    this.featured = false,
    required this.createdAt,
  });

  factory Course.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Course(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      featured: data['featured'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
