import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? photoURL;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? preferences;
  final List<String>? roles;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.photoURL,
    this.isEmailVerified = false,
    required this.createdAt,
    required this.updatedAt,
    this.preferences,
    this.roles,
  });

  factory UserModel.fromFirebaseUser({
    required String uid,
    required String name,
    required String email,
    bool isEmailVerified = false,
    String? phone,
    String? photoURL,
  }) {
    final now = DateTime.now();
    return UserModel(
      id: uid,
      name: name,
      email: email,
      phone: phone,
      photoURL: photoURL,
      isEmailVerified: isEmailVerified,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      photoURL: json['photoURL'],
      isEmailVerified: json['isEmailVerified'] ?? false,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      preferences: json['preferences'] != null
          ? Map<String, dynamic>.from(json['preferences'])
          : null,
      roles: json['roles'] != null ? List<String>.from(json['roles']) : null,
    );
  }

  // Convert UserModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'photoURL': photoURL,
      'isEmailVerified': isEmailVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'preferences': preferences,
      'roles': roles,
    };
  }

  // Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? photoURL,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? preferences,
    List<String>? roles,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoURL: photoURL ?? this.photoURL,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      preferences: preferences ?? this.preferences,
      roles: roles ?? this.roles,
    );
  }

  // Get user's display name
  String get displayName {
    if (name.isNotEmpty) return name;
    return email.split('@').first;
  }

  // Get user's initials for avatar
  String get initials {
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty) {
      return words[0][0].toUpperCase();
    }
    return email[0].toUpperCase();
  }

  // Check if user has specific role
  bool hasRole(String role) {
    return roles?.contains(role) ?? false;
  }

  // Check if user is admin
  bool get isAdmin => hasRole('admin');

  // Check if profile is complete
  bool get isProfileComplete {
    return name.isNotEmpty && email.isNotEmpty && isEmailVerified;
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, isEmailVerified: $isEmailVerified)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.phone == phone &&
        other.photoURL == photoURL &&
        other.isEmailVerified == isEmailVerified;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        phone.hashCode ^
        photoURL.hashCode ^
        isEmailVerified.hashCode;
  }
}
