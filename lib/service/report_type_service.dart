import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report_type.dart';

class ReportTypeService {
  static final _firestore = FirebaseFirestore.instance;
  static const _collection = 'report_types';

  // Get all active report types
  static Stream<List<ReportType>> getActiveReportTypes() {
    return _firestore
        .collection(_collection)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReportType.fromFirestore(doc))
            .toList());
  }

  // Get a single report type by ID
  static Future<ReportType?> getReportType(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return ReportType.fromFirestore(doc);
  }

  // Create a new report type
  static Future<ReportType> createReportType(ReportType reportType) async {
    final docRef = await _firestore.collection(_collection).add(reportType.toFirestore());
    return reportType.copyWith(id: docRef.id);
  }

  // Update a report type
  static Future<void> updateReportType(String id, Map<String, dynamic> data) async {
    await _firestore.collection(_collection).doc(id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete a report type
  static Future<void> deleteReportType(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  // Seed default report types
  static Future<void> seedDefaultReportTypes() async {
    // Check if report types already exist
    final existingTypes = await _firestore.collection(_collection).limit(1).get();
    if (existingTypes.docs.isNotEmpty) {
      print('Report types already exist, skipping seeding');
      return;
    }

    final defaultTypes = [
      {
        'name': 'Corruption',
        'description': 'Report cases of corruption, bribery, or misuse of public funds',
        'icon': 'attach_money',
      },
      {
        'name': 'Human Rights Violation',
        'description': 'Report violations of human rights and freedoms',
        'icon': 'shield_outlined',
      },
      {
        'name': 'Discrimination',
        'description': 'Report cases of discrimination based on race, gender, religion, or other factors',
        'icon': 'people_outline',
      },
      {
        'name': 'Abuse of Power',
        'description': 'Report abuse of authority or power by officials',
        'icon': 'gavel_outlined',
      },
      {
        'name': 'Police Brutality',
        'description': 'Report cases of excessive force or misconduct by law enforcement',
        'icon': 'security',
      },
      {
        'name': 'Environmental Violation',
        'description': 'Report environmental damage or violations',
        'icon': 'eco',
      },
      {
        'name': 'Labor Rights Violation',
        'description': 'Report violations of workers\' rights and labor laws',
        'icon': 'work',
      },
      {
        'name': 'Other',
        'description': 'Report other types of incidents not covered above',
        'icon': 'help_outline',
      },
    ];

    final batch = _firestore.batch();
    final now = DateTime.now();

    for (final typeData in defaultTypes) {
      final docRef = _firestore.collection(_collection).doc();
      final reportType = ReportType(
        id: docRef.id,
        name: typeData['name']!,
        description: typeData['description']!,
        icon: typeData['icon']!,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );
      batch.set(docRef, reportType.toFirestore());
    }

    await batch.commit();
    print('Report types seeded successfully');
  }
} 