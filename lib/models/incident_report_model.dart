import 'package:cloud_firestore/cloud_firestore.dart';

enum IncidentStatus {
  submitted,
  underReview,
  resolved,
  rejected
}

class IncidentReport {
  final String id;
  final String userId;
  final String title;
  final DateTime date;
  final String location;
  final String description;
  final String reportTypeId;
  final List<String> photoUrls;
  final List<String> videoUrls;
  final List<String> audioUrls;
  final bool isAnonymous;
  final IncidentStatus status;
  final String trackingNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  const IncidentReport({
    required this.id,
    required this.userId,
    required this.title,
    required this.date,
    required this.location,
    required this.description,
    required this.reportTypeId,
    this.photoUrls = const [],
    this.videoUrls = const [],
    this.audioUrls = const [],
    required this.isAnonymous,
    this.status = IncidentStatus.submitted,
    required this.trackingNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create a new incident report
  factory IncidentReport.create({
    required String userId,
    required String title,
    required DateTime date,
    required String location,
    required String description,
    required String reportTypeId,
    required bool isAnonymous,
  }) {
    final now = DateTime.now();
    final trackingNumber = 'RW${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(7)}';
    
    return IncidentReport(
      id: '', // Will be set by Firestore
      userId: userId,
      title: title,
      date: date,
      location: location,
      description: description,
      reportTypeId: reportTypeId,
      isAnonymous: isAnonymous,
      trackingNumber: trackingNumber,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Create from Firestore document
  factory IncidentReport.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return IncidentReport(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      location: data['location'] ?? '',
      description: data['description'] ?? '',
      reportTypeId: data['reportTypeId'] ?? '',
      photoUrls: List<String>.from(data['photoUrls'] ?? []),
      videoUrls: List<String>.from(data['videoUrls'] ?? []),
      audioUrls: List<String>.from(data['audioUrls'] ?? []),
      isAnonymous: data['isAnonymous'] ?? false,
      status: IncidentStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'submitted'),
        orElse: () => IncidentStatus.submitted,
      ),
      trackingNumber: data['trackingNumber'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Convert to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'date': Timestamp.fromDate(date),
      'location': location,
      'description': description,
      'reportTypeId': reportTypeId,
      'photoUrls': photoUrls,
      'videoUrls': videoUrls,
      'audioUrls': audioUrls,
      'isAnonymous': isAnonymous,
      'status': status.name,
      'trackingNumber': trackingNumber,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create a copy with updated fields
  IncidentReport copyWith({
    String? id,
    String? userId,
    String? title,
    DateTime? date,
    String? location,
    String? description,
    String? reportTypeId,
    List<String>? photoUrls,
    List<String>? videoUrls,
    List<String>? audioUrls,
    bool? isAnonymous,
    IncidentStatus? status,
    String? trackingNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return IncidentReport(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      date: date ?? this.date,
      location: location ?? this.location,
      description: description ?? this.description,
      reportTypeId: reportTypeId ?? this.reportTypeId,
      photoUrls: photoUrls ?? this.photoUrls,
      videoUrls: videoUrls ?? this.videoUrls,
      audioUrls: audioUrls ?? this.audioUrls,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      status: status ?? this.status,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'IncidentReport(id: $id, trackingNumber: $trackingNumber, status: ${status.name})';
  }
} 