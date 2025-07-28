import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReportType {
  final String id;
  final String name;
  final String displayName;
  final String description;
  final IconData icon;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReportType({
    required this.id,
    required this.name,
    required this.displayName,
    required this.description,
    required this.icon,
    this.isActive = true,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create from Firestore document
  factory ReportType.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReportType(
      id: doc.id,
      name: data['name'] ?? '',
      displayName: data['displayName'] ?? '',
      description: data['description'] ?? '',
      icon: _getIconFromString(data['iconName'] ?? 'help_outline'),
      isActive: data['isActive'] ?? true,
      sortOrder: data['sortOrder'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Convert to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'displayName': displayName,
      'description': description,
      'iconName': _getStringFromIcon(icon),
      'isActive': isActive,
      'sortOrder': sortOrder,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Helper method to convert icon string to IconData
  static IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'attach_money':
        return Icons.attach_money;
      case 'shield_outlined':
        return Icons.shield_outlined;
      case 'people_outline':
        return Icons.people_outline;
      case 'gavel_outlined':
        return Icons.gavel_outlined;
      case 'help_outline':
        return Icons.help_outline;
      case 'security':
        return Icons.security;
      case 'balance':
        return Icons.balance;
      case 'report_problem':
        return Icons.report_problem;
      default:
        return Icons.help_outline;
    }
  }

  // Helper method to convert IconData to string
  static String _getStringFromIcon(IconData icon) {
    if (icon == Icons.attach_money) return 'attach_money';
    if (icon == Icons.shield_outlined) return 'shield_outlined';
    if (icon == Icons.people_outline) return 'people_outline';
    if (icon == Icons.gavel_outlined) return 'gavel_outlined';
    if (icon == Icons.security) return 'security';
    if (icon == Icons.balance) return 'balance';
    if (icon == Icons.report_problem) return 'report_problem';
    return 'help_outline';
  }

  // Create a copy with updated fields
  ReportType copyWith({
    String? id,
    String? name,
    String? displayName,
    String? description,
    IconData? icon,
    bool? isActive,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReportType(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ReportType(id: $id, name: $name, displayName: $displayName)';
  }
}
