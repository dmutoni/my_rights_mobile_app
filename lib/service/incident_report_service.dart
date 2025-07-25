import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/incident_report_model.dart';

class IncidentReportService {
  static final _firestore = FirebaseFirestore.instance;
  static final _storage = FirebaseStorage.instance;
  static const _collection = 'incident_reports';

  // Create a new incident report
  static Future<IncidentReport> createReport(IncidentReport report) async {
    final docRef =
        await _firestore.collection(_collection).add(report.toFirestore());
    return report.copyWith(id: docRef.id);
  }

  // Get a single report by ID
  static Future<IncidentReport?> getReport(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return IncidentReport.fromFirestore(doc);
  }

  // Get a report by tracking number
  static Future<IncidentReport?> getReportByTrackingNumber(
      String trackingNumber) async {
    final query = await _firestore
        .collection(_collection)
        .where('trackingNumber', isEqualTo: trackingNumber)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return IncidentReport.fromFirestore(query.docs.first);
  }

  // Get all reports for a user
  static Stream<List<IncidentReport>> getUserReports(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => IncidentReport.fromFirestore(doc))
            .toList());
  }

  // Update report status
  static Future<void> updateReportStatus(
      String id, IncidentStatus status) async {
    await _firestore.collection(_collection).doc(id).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Upload evidence files
  static Future<String> uploadFile(
      String reportId, String type, File file) async {
    final ref = _storage.ref().child(
        'reports/$reportId/$type/${DateTime.now().millisecondsSinceEpoch}');
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  // Add evidence URL to report
  static Future<void> addEvidence(
      String reportId, String type, String url) async {
    final field = '${type}Urls';
    await _firestore.collection(_collection).doc(reportId).update({
      field: FieldValue.arrayUnion([url]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete a report and its evidence
  static Future<void> deleteReport(String id) async {
    // Delete evidence files from storage
    final storageRef = _storage.ref().child('reports/$id');
    try {
      final items = await storageRef.listAll();
      for (var item in items.items) {
        await item.delete();
      }
    } catch (e) {
      print('Error deleting files: $e');
    }

    // Delete the document
    await _firestore.collection(_collection).doc(id).delete();
  }

  // Stream report updates
  static Stream<IncidentReport> streamReport(String id) {
    return _firestore
        .collection(_collection)
        .doc(id)
        .snapshots()
        .map((doc) => IncidentReport.fromFirestore(doc));
  }
}
