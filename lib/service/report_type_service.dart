import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/report_type.dart';

class ReportTypeService {
  static final _firestore = FirebaseFirestore.instance;
  static const _collection = 'report_types';

  // Get all active report types
  static Stream<List<ReportType>> getActiveReportTypes() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .orderBy('displayName')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReportType.fromFirestore(doc))
            .toList());
  }

  // Get all report types (including inactive)
  static Stream<List<ReportType>> getAllReportTypes() {
    return _firestore
        .collection(_collection)
        .orderBy('sortOrder')
        .orderBy('displayName')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReportType.fromFirestore(doc))
            .toList());
  }

  // Get a specific report type by ID
  static Future<ReportType?> getReportType(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (!doc.exists) return null;
      return ReportType.fromFirestore(doc);
    } catch (e) {
      print('Error getting report type: $e');
      return null;
    }
  }

  // Get a specific report type by name
  static Future<ReportType?> getReportTypeByName(String name) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('name', isEqualTo: name)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;
      return ReportType.fromFirestore(query.docs.first);
    } catch (e) {
      print('Error getting report type by name: $e');
      return null;
    }
  }

  // Create a new report type (admin only)
  static Future<ReportType> createReportType(ReportType reportType) async {
    try {
      final docRef = await _firestore.collection(_collection).add(reportType.toFirestore());
      return reportType.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to create report type: $e');
    }
  }

  // Update a report type (admin only)
  static Future<void> updateReportType(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update report type: $e');
    }
  }

  // Delete a report type (admin only)
  static Future<void> deleteReportType(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete report type: $e');
    }
  }

  // Initialize default report types (one-time setup)
  static Future<void> initializeDefaultReportTypes() async {
    try {
      final existing = await _firestore.collection(_collection).limit(1).get();
      if (existing.docs.isNotEmpty) {
        print('Report types already initialized');
        return;
      }

      final now = DateTime.now();
      final defaultTypes = [
        ReportType(
          id: '',
          name: 'corruption',
          displayName: 'Corruption',
          description: 'Report cases of corruption, bribery, or misuse of public resources',
          icon: Icons.attach_money,
          sortOrder: 1,
          createdAt: now,
          updatedAt: now,
        ),
        ReportType(
          id: '',
          name: 'human_rights_violation',
          displayName: 'Human Rights Violation',
          description: 'Report violations of human rights and civil liberties',
          icon: Icons.shield_outlined,
          sortOrder: 2,
          createdAt: now,
          updatedAt: now,
        ),
        ReportType(
          id: '',
          name: 'discrimination',
          displayName: 'Discrimination',
          description: 'Report cases of discrimination based on race, gender, religion, etc.',
          icon: Icons.people_outline,
          sortOrder: 3,
          createdAt: now,
          updatedAt: now,
        ),
        ReportType(
          id: '',
          name: 'abuse_of_power',
          displayName: 'Abuse of Power',
          description: 'Report misuse of authority or position for personal gain',
          icon: Icons.gavel_outlined,
          sortOrder: 4,
          createdAt: now,
          updatedAt: now,
        ),
        ReportType(
          id: '',
          name: 'other',
          displayName: 'Other',
          description: 'Report other types of violations or misconduct',
          icon: Icons.help_outline,
          sortOrder: 5,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      for (final type in defaultTypes) {
        await _firestore.collection(_collection).add(type.toFirestore());
      }

      print('Default report types initialized successfully');
    } catch (e) {
      print('Error initializing default report types: $e');
      throw Exception('Failed to initialize default report types: $e');
    }
  }
}
