import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:my_rights_mobile_app/service/cloudinary_service.dart';
import '../models/incident_report_model.dart';

class IncidentReportService {
  static final _firestore = FirebaseFirestore.instance;
  static final _storage = FirebaseStorage.instance;
  static const _collection = 'incident_reports';

  // Create a new incident report
  static Future<IncidentReport> createReport(IncidentReport report) async {
    print('Creating incident report in Firestore...');
    print('Report data: ${report.toFirestore()}');

    final docRef =
        await _firestore.collection(_collection).add(report.toFirestore());

    print('Report created with document ID: ${docRef.id}');
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
    print('Getting reports for user: $userId');

    // First, let's check all reports to see what's in the collection
    _firestore.collection(_collection).get().then((allDocs) {
      print('=== ALL REPORTS IN COLLECTION ===');
      print('Total documents in collection: ${allDocs.docs.length}');
      for (var doc in allDocs.docs) {
        final data = doc.data();
        print('Doc ID: ${doc.id}');
        print(
            '  - userId: "${data['userId']}" (length: ${data['userId']?.toString().length})');
        print('  - title: "${data['title']}"');
        print('  - trackingNumber: "${data['trackingNumber']}"');
        print('  - createdAt: ${data['createdAt']}');
        print('---');
      }
      print('================================');

      // Now let's test the specific query
      print('=== TESTING SPECIFIC QUERY ===');
      _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get()
          .then((queryResult) {
        print('Direct query result: ${queryResult.docs.length} documents');

        for (var doc in queryResult.docs) {
          print('Query result doc: ${doc.id} - ${doc.data()}');
        }
      }).catchError((error, stackTrace) {
        print('Query error: $error');
      });
    });

    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      print('Found ${snapshot.docs.length} reports for user: $userId');

      for (var doc in snapshot.docs) {
        print('Document ID: ${doc.id}, Data: ${doc.data()}');
      }
      return snapshot.docs
          .map((doc) => IncidentReport.fromFirestore(doc))
          .toList();
    });
  }

  // Update report status
  static Future<void> updateReportStatus(
      String id, IncidentStatus status) async {
    await _firestore.collection(_collection).doc(id).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<String> uploadFile(
      String reportId, String type, File file) async {
    try {
      // 1. CHECK AUTHENTICATION FIRST
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated to upload files');
      }

      // 2. CHECK FILE EXISTS
      if (!await file.exists()) {
        throw Exception('File does not exist: ${file.path}');
      }

      // 3. CHECK FILE SIZE
      final fileSize = await file.length();
      print('File size: ${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB');

      // Optional: Limit file size (10MB for example)
      if (fileSize > 10 * 1024 * 1024) {
        throw Exception('File too large. Maximum size is 10MB');
      }

      // 4. UPLOAD TO CLOUDINARY
      print('Uploading to Cloudinary...');
      final downloadUrl = await CloudinaryService.uploadFile(file);
      print('File uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e, stackTrace) {
      print('Error uploading file: $e at $stackTrace');
      print('Error details: ${e.toString()}');
      rethrow;
    }
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
