import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/incident_report_model.dart';

class IncidentReportService {
  static final _firestore = FirebaseFirestore.instance;
  static final _storage = FirebaseStorage.instance;
  static const _collection = 'reports';

  // Create a new incident report in users/{userId}/reports collection
  static Future<IncidentReport> createReport(IncidentReport report) async {
    final docRef = await _firestore
        .collection('users')
        .doc(report.userId)
        .collection(_collection)
        .add(report.toFirestore());
    return report.copyWith(id: docRef.id);
  }

  // Get a single report by ID for a specific user
  static Future<IncidentReport?> getReport(
      String userId, String reportId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection(_collection)
        .doc(reportId)
        .get();
    if (!doc.exists) return null;
    return IncidentReport.fromFirestore(doc);
  }

  // Get a report by tracking number (search across all users)
  static Future<IncidentReport?> getReportByTrackingNumber(
      String trackingNumber) async {
    // For global search, we'll use a collection group query
    final query = await _firestore
        .collectionGroup(_collection)
        .where('trackingNumber', isEqualTo: trackingNumber)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return IncidentReport.fromFirestore(query.docs.first);
  }

  // Get all reports for a user
  static Stream<List<IncidentReport>> getUserReports(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection(_collection)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => IncidentReport.fromFirestore(doc))
            .toList());
  }

  // Update report status
  static Future<void> updateReportStatus(
      String userId, String reportId, IncidentStatus status) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection(_collection)
        .doc(reportId)
        .update({
      'status': status.name,
      'submittedAt': FieldValue
          .serverTimestamp(), // Update submission timestamp when status changes
    });
  }

  // Add evidence to report
  static Future<void> addEvidence(
      String userId, String reportId, EvidenceItem evidence) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection(_collection)
        .doc(reportId)
        .update({
      'evidence': FieldValue.arrayUnion([evidence.toJson()]),
    });
  }

  // Update report priority
  static Future<void> updateReportPriority(
      String userId, String reportId, ReportPriority priority) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection(_collection)
        .doc(reportId)
        .update({
      'priority': priority.name,
    });
  }

  // Assign report to an officer
  static Future<void> assignReport(
      String userId, String reportId, String officerId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection(_collection)
        .doc(reportId)
        .update({
      'assignedTo': officerId,
    });
  }

  // Add update to report
  static Future<void> addReportUpdate(
      String userId, String reportId, ReportUpdate update) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection(_collection)
        .doc(reportId)
        .update({
      'updates': FieldValue.arrayUnion([update.toJson()]),
    });
  }

  // Upload evidence files
  static Future<String> uploadFile(
      String userId, String reportId, String type, File file) async {
    final ref = _storage.ref().child(
        'reports/$userId/$reportId/$type/${DateTime.now().millisecondsSinceEpoch}');
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  // Delete a report and its evidence
  static Future<void> deleteReport(String userId, String reportId) async {
    // Delete evidence files from storage
    final storageRef = _storage.ref().child('reports/$userId/$reportId');
    try {
      final items = await storageRef.listAll();
      for (var item in items.items) {
        await item.delete();
      }
    } catch (e) {
      print('Error deleting files: $e');
    }

    // Delete the document
    await _firestore
        .collection('users')
        .doc(userId)
        .collection(_collection)
        .doc(reportId)
        .delete();
  }

  // Stream report updates
  static Stream<IncidentReport> streamReport(String userId, String reportId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection(_collection)
        .doc(reportId)
        .snapshots()
        .map((doc) => IncidentReport.fromFirestore(doc));
  }

  // Get all reports across all users (admin functionality)
  static Stream<List<IncidentReport>> getAllReports() {
    return _firestore
        .collectionGroup(_collection)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => IncidentReport.fromFirestore(doc))
            .toList());
  }

  // Get reports by status (admin functionality)
  static Stream<List<IncidentReport>> getReportsByStatus(
      IncidentStatus status) {
    return _firestore
        .collectionGroup(_collection)
        .where('status', isEqualTo: status.name)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => IncidentReport.fromFirestore(doc))
            .toList());
  }

  // Get reports by type (admin functionality)
  static Stream<List<IncidentReport>> getReportsByType(String reportType) {
    return _firestore
        .collectionGroup(_collection)
        .where('reportType', isEqualTo: reportType)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => IncidentReport.fromFirestore(doc))
            .toList());
  }
}
